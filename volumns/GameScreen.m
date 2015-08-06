//
//  GameScreen.m
//  volumns
//
//  Created by 原田 正隆 on 13/04/29.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameScreen.h"
#import "SpriteManager.h"
#import "AppDelegate.h"

@implementation GameScreen

@synthesize mino;
@synthesize sprMgr;
@synthesize phase;
//出玉が偏らないようにするための処理に使います
NSMutableArray *jewelTypeOrder0;
NSMutableArray *jewelTypeOrder1;
NSMutableArray *jewelTypeOrder2;

int Screen_H, Screen_W;
int matrix[13][6] = {//0:空 下位16bit=シリアル番号
    {0,0,0,0,0,0},// 0
    {0,0,0,0,0,0},// 1
    {0,0,0,0,0,0},// 2
    {0,0,0,0,0,0},// 3
    {0,0,0,0,0,0},// 4
    {0,0,0,0,0,0},// 5
    {0,0,0,0,0,0},// 6
    {2,0,0,4,0,0},// 7
    {1,0,1,3,0,0},// 8
    {5,5,3,3,5,3},// 9
    {1,5,1,4,4,2},// 10
    {3,2,2,4,5,2},// 11
    {2,2,3,5,3,5} // 12
};
CCSprite *sprContainer;
CCSprite *sprTeam;
ScreenInfo screenInfo, publicSc;
float screenScale = 1.5;
// [0]
// [1]
// [2] <- line:col
NSMutableArray *piledGems;
int serial = 1;

CCLabelTTF *label;
//Game Vars
int theLevel = 1;
long theScore = 0;
float sessionInterval = 1.0;//ssec
int sessionLines = 0;
int sessionChain = 0;
int clearCount = 0;
int dropNum = 0;
int generateCount = 0;
int numSpecialGem = 0;
int specialNorma = 100;
BOOL mahousekiMode = false;//魔法石出現中
CCSprite *nextGemIcon[3][5] = {
    {NULL, NULL, NULL, NULL, NULL},
    {NULL, NULL, NULL, NULL, NULL},
    {NULL, NULL, NULL, NULL, NULL}
};
CCSpriteBatchNode *batchNode[6];
NSString *CharaPng[6] = {
@"j1.png", @"j2.png", @"j3.png", @"j4.png", @"j5.png", @"j6.png"
};

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScreen *layer = [GameScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    srand(time(NULL));
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        
        phase = PHASE_DISABLE;
        CGSize winSize = [[CCDirector sharedDirector]winSize];
        Screen_H = winSize.height;
        Screen_W = winSize.width;
        
        sprContainer = [CCSprite spriteWithFile:@"container_bg.png"];
        //sprContainer = [CCSprite alloc];
        //[sprContainer setTextureRect:CGRectMake(0,0,144,312)];
        sprContainer.anchorPoint = CGPointMake(0.0,0.0);
        [self addChild:sprContainer];
        sprContainer.scaleX = screenScale;
        sprContainer.scaleY = screenScale;
        sprContainer.position = CGPointMake((Screen_W-(144*screenScale))/2, Screen_H-(MARGIN_TOP+(312*screenScale)));

        //キャラ画像をSpriteManagerに登録
        sprMgr = [SpriteManager sharedManager];
        for(int i = 0; i < 6; i++){
            NSString *strKey = [NSString stringWithFormat:@"%d", i+1];
            [sprMgr addTexture:CharaPng[i] key:strKey];
        }
        
        screenInfo.screen_h = Screen_H;
        screenInfo.screen_w = Screen_W;
        screenInfo.stageOffset_x = sprContainer.position.x + (BLOCKSIZE/2);
        screenInfo.stageOffset_y = (-MARGIN_TOP)-(BLOCKSIZE/2);
        
        //表示中の宝石リスト
        piledGems = [[NSMutableArray alloc]init];
        
        CGRect arect = sprContainer.textureRect;
        //ScreenInfo sci2;
        publicSc.screen_h = arect.size.height;
        publicSc.screen_w = arect.size.width;
        publicSc.stageOffset_x = (BLOCKSIZE/2);
        publicSc.stageOffset_y = (BLOCKSIZE/2);
        for(int l = 0; l < GRIDSZ_H; l++){
            for(int c = 0; c < GRIDSZ_W; c++){
                int nid = matrix[l][c];
                if(nid > 0){
                    [self createOneJewel:nid line:l col:c];
                }
            }
        }
        
        //落ちる３個
        //mino = [ColumnsMino alloc];
        mino.order = [[NSMutableArray alloc]init];
        [mino.order addObject:[NSNull null]];
        [mino.order addObject:[NSNull null]];
        [mino.order addObject:[NSNull null]];
        //[0]
        //[1]
        //[2] <- line/col
        sprTeam = [CCSprite spriteWithFile:@"container_bg.png"];
        [sprTeam setTextureRect:CGRectMake(0,0,BLOCKSIZE,BLOCKSIZE*3)];
        sprTeam.anchorPoint = CGPointMake(0.0,0.0);
        [sprContainer addChild:sprTeam];
        mino.sprMino = sprTeam;
        
        jewelTypeOrder0 = [[NSMutableArray alloc]init];
        jewelTypeOrder1 = [[NSMutableArray alloc]init];
        jewelTypeOrder2 = [[NSMutableArray alloc]init];
		//最初の出玉設定
		[self makeNextMinoOrder];

        //SCORE
        label = [CCLabelTTF labelWithString:@"SCORE : " fontName:@"Arial" fontSize:18];
        label.position = ccp(Screen_W/2-32, Screen_H-12);
        [self addChild:label];
        [self addScore:0];
        //[label setString:[NSString stringWithFormat:@"SCORE : %d", 0]];
        //[self performSelector:@selector(checkSmash) withObject:nil afterDelay:3];
        
        int nl, nt = 1;
        for(nl = 0; nl < 3; nl++){
            for(nt = 1; nt <= 5; nt++){
                Jewel *jwl = [[Jewel alloc]initWithScreenInfo:(id)&publicSc];
                CCSprite *aSpr = [jwl createGemSprite:nt];
                [jwl setPosByLC:nl+3 col:6];
                [sprContainer addChild:aSpr];
                aSpr.position = CGPointMake(aSpr.position.x+4, aSpr.position.y);
                aSpr.opacity = 0;
                nextGemIcon[nl][nt-1] = aSpr;
                [jwl release];
                
//                batchNode[i-1] = [CCSpriteBatchNode batchNodeWithFile:CharaPng[i-1]];
            }
        }
        [self generateNextMino];
        //[self putNextJewels:jemOrder0[0] type1:jemOrder1[0] type2:jemOrder2[0]];
    }
    return self;
}

- (void)putNextJewels:(int)t0 type1:(int)t1 type2:(int)t2
{
    int i;
    for(i = 0; i < 5; i++){
        CCSprite *aSpr0 = nextGemIcon[0][i];
        if(t0-1 == i){
            aSpr0.opacity = 255;
        }else{
            aSpr0.opacity = 0;
        }
        CCSprite *aSpr1 = nextGemIcon[1][i];
        if(t1-1 == i){
            aSpr1.opacity = 255;
        }else{
            aSpr1.opacity = 0;
        }
        CCSprite *aSpr2 = nextGemIcon[2][i];
        if(t2-1 == i){
            aSpr2.opacity = 255;
        }else{
            aSpr2.opacity = 0;
        }
    }
}

- (void)onEnter
{
    [super onEnter];
    phase = PHASE_FREETIME;
    [self performSelector:@selector(waitTimeEnd) withObject:nil afterDelay:1.0];
}

static int jemOrder0[5], jemOrder1[5], jemOrder2[5];
- (void)makeNextMinoOrder
{
    //出玉が偏らないようにするための処理
    //1-5番をランダムに並びかえ出玉順とする。これを３段分について作る
    //5ターン毎に順番を更新する
    int i;
    for(i = 0; i < 5; i++){// 配列をランダムに並び替える処理
        int rv = ((rand()%0xffff)<<16) | (i+1);
        [jewelTypeOrder0 addObject:[NSNumber numberWithInt:rv]];
        rv = ((rand()%0xffff)<<16) | (i+1);
        [jewelTypeOrder1 addObject:[NSNumber numberWithInt:rv]];
        rv = ((rand()%0xffff)<<16) | (i+1);
        [jewelTypeOrder2 addObject:[NSNumber numberWithInt:rv]];
    }
    NSArray *jewelPattern0, *jewelPattern1, *jewelPattern2;
    jewelPattern0 = [jewelTypeOrder0 sortedArrayUsingSelector:@selector(compare:)];
    jewelPattern1 = [jewelTypeOrder1 sortedArrayUsingSelector:@selector(compare:)];
    jewelPattern2 = [jewelTypeOrder2 sortedArrayUsingSelector:@selector(compare:)];
    for(i = 0; i< 5; i++){
        jemOrder0[i] = [[jewelPattern0 objectAtIndex:i] intValue] & 0xffff;
        jemOrder1[i] = [[jewelPattern1 objectAtIndex:i] intValue] & 0xffff;
        jemOrder2[i] = [[jewelPattern2 objectAtIndex:i] intValue] & 0xffff;
    }
    [jewelTypeOrder0 removeAllObjects];
    [jewelTypeOrder1 removeAllObjects];
    [jewelTypeOrder2 removeAllObjects];
}
//次のmino生成
- (BOOL)generateNextMino
{
    int type0, type1, type2;
	int type0next, type1next, type2next;
    ScreenInfo cellInfo;//mino用
    int newCol = 2;
    int tick = generateCount % 5;
    int wType = 0;
    
    if(clearCount >= specialNorma){
        mahousekiMode = YES;
        numSpecialGem++;
        specialNorma += ( (numSpecialGem+2) * 50 );
        type0 = 6;
        type1 = 6;
        type2 = 6;
        wType = 1;
    }else{
        mahousekiMode = NO;
//        if(generateCount == 0 && dropNum == 0){
//            type0 = 2;
//            type1 = 5;
//            type2 = 1;
//            generateCount = -1;
//        }else{
            //if(tick == 0){
            	/*
                for(i = 0; i < 5; i++){// 配列をランダムに並び替える処理
                    int rv = ((rand()%0xffff)<<16) | (i+1);
                    [jewelTypeOrder0 addObject:[NSNumber numberWithInt:rv]];
                    rv = ((rand()%0xffff)<<16) | (i+1);
                    [jewelTypeOrder1 addObject:[NSNumber numberWithInt:rv]];
                    rv = ((rand()%0xffff)<<16) | (i+1);
                    [jewelTypeOrder2 addObject:[NSNumber numberWithInt:rv]];
                }
                NSArray *jewelPattern0, *jewelPattern1, *jewelPattern2;
                jewelPattern0 = [jewelTypeOrder0 sortedArrayUsingSelector:@selector(compare:)];
                jewelPattern1 = [jewelTypeOrder1 sortedArrayUsingSelector:@selector(compare:)];
                jewelPattern2 = [jewelTypeOrder2 sortedArrayUsingSelector:@selector(compare:)];
                for(i = 0; i< 5; i++){
                    jemOrder0[i] = [[jewelPattern0 objectAtIndex:i] intValue] & 0xffff;
                    jemOrder1[i] = [[jewelPattern1 objectAtIndex:i] intValue] & 0xffff;
                    jemOrder2[i] = [[jewelPattern2 objectAtIndex:i] intValue] & 0xffff;
                }
                [jewelTypeOrder0 removeAllObjects];
                [jewelTypeOrder1 removeAllObjects];
                [jewelTypeOrder2 removeAllObjects];
            	*/
            	//[self makeNextMinoOrder];
            //}
            type0 = jemOrder0[tick];
            type1 = jemOrder1[tick];
            type2 = jemOrder2[tick];
//        }
        generateCount++;
    }
	tick = generateCount % 5;
	if(tick == 0){
		[self makeNextMinoOrder];
	}
	//つぎの出玉
    type0next = jemOrder0[tick];
    type1next = jemOrder1[tick];
    type2next = jemOrder2[tick];
    [self putNextJewels:type0next type1:type1next type2:type2next];

    CCLOG(@"%d %d %d", type0, type1, type2);
    
    if(matrix[2][2] != 0){
        newCol = -1;
        int cols[6] = {3,2,4,1,5,0};
        for(int i = 0; i < 6; i++){
            if(matrix[2][cols[i]] == 0){
                newCol = cols[i];
                break;
            }
        }
    }
    if(newCol < 0){
        return NO;//ゲームオーバー
    }
    
    cellInfo.screen_h = BLOCKSIZE*3;
    cellInfo.screen_w = BLOCKSIZE;
    cellInfo.stageOffset_x = (BLOCKSIZE/2);
    cellInfo.stageOffset_y = (BLOCKSIZE/2);
    
    sprTeam.visible = YES;
    Jewel *wGem0, *wGem1, *wGem2;
    wGem0 = [[Jewel alloc]initWithScreenInfo:(id)&cellInfo];
    [sprTeam addChild:[wGem0 createGemSprite:type0]];
    [wGem0 setPosByLC:0 col:0];
    wGem1 = [[Jewel alloc]initWithScreenInfo:(id)&cellInfo];
    [sprTeam addChild:[wGem1 createGemSprite:type1]];
    [wGem1 setPosByLC:1 col:0];
    wGem2 = [[Jewel alloc]initWithScreenInfo:(id)&cellInfo];
    [sprTeam addChild:[wGem2 createGemSprite:type2]];
    [wGem2 setPosByLC:2 col:0];
    mino.order[0] = wGem0;
    mino.order[1] = wGem1;
    mino.order[2] = wGem2;
    mino.type = wType;
    [self mino_setpos:2 col:newCol];
    //limitMinoLine = 2 + 1;
    
    return YES;
}

//Mino release
-(void)destroyMino
{
    Jewel *pj0 = (Jewel *)mino.order[0];
    Jewel *pj1 = (Jewel *)mino.order[1];
    Jewel *pj2 = (Jewel *)mino.order[2];
    CCLOG(@"destroyMino()");
    if(![pj0 isEqual:[NSNull null]]){
        [sprTeam removeChild:pj0.mySprite cleanup:YES];
        [sprTeam removeChild:pj1.mySprite cleanup:YES];
        [sprTeam removeChild:pj2.mySprite cleanup:YES];
        [self deleteGemBySerialNo:pj0.serialNo];
        [self deleteGemBySerialNo:pj1.serialNo];
        [self deleteGemBySerialNo:pj2.serialNo];
        [mino.order[0] release];
        [mino.order[1] release];
        [mino.order[2] release];
        mino.order[0] = [NSNull null]; //if(![mino.order[0] isEqual:[NSNull null]]){}
        mino.order[1] = [NSNull null];
        mino.order[2] = [NSNull null];
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [self destroyMino];
    [mino.order release];
    [piledGems release];
    [jewelTypeOrder0 release];
    [jewelTypeOrder1 release];
    [jewelTypeOrder2 release];
	// in case you have something to dealloc, do it in thi９s method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

//宝石を一個生成
- (void)createOneJewel:(int)nid line:(int)l col:(int)c
{
    Jewel *jwl = [[Jewel alloc]initWithScreenInfo:(id)&publicSc];
    CCSprite *aSpr = [jwl createGemSprite:nid];
    [jwl setPosByLC:l col:c];
    [sprContainer addChild:aSpr];
    jwl.serialNo = ++serial;
    matrix[l][c] = serial;   //matrix更新
    [piledGems addObject:jwl];
}

//自由に動かせる時間スタート
- (void)freeTimeStart
{
    phase = PHASE_FREETIME;
    [self performSelector:@selector(waitTimeEnd) withObject:nil afterDelay:sessionInterval];
}

//空白時間終わり 1段落下
- (void)waitTimeEnd
{
    CCLOG(@"Falltime phase=%d", phase);
    BOOL tc, mahou = NO;
    tc = [self mino_moveDown];
    if(tc == YES){
        [self performSelector:@selector(waitTimeEnd) withObject:nil afterDelay:sessionInterval];
    }else{
        //minoが接地して単独の宝石として配置
        if(!mahousekiMode){
            Jewel *pj0 = (Jewel *)mino.order[0];
            Jewel *pj1 = (Jewel *)mino.order[1];
            Jewel *pj2 = (Jewel *)mino.order[2];
            if([pj0 isEqual:[NSNull null]]){
                return;
            }
            [self createOneJewel:pj0.typeIndex line:mino.line-2 col:mino.col];
            [self createOneJewel:pj1.typeIndex line:mino.line-1 col:mino.col];
            [self createOneJewel:pj2.typeIndex line:mino.line col:mino.col];
        }else{
            mahou = YES;
        }
        mahousekiMode = NO;
        //mino消す
        [self destroyMino];
        sprTeam.visible = NO;

        if(mahou){//魔法石
            [self applySpecial];
            [self checkSmash];
        }else{
            [self scanMatrix];
        }
        
        dropNum++;
    }
}

//魔法石着地
- (void)applySpecial
{
    int targetType;
    int l, c;
    if(mino.line+1 == GRIDSZ_H){
        //ボーナス！
    }else{
        Jewel *ptr = [self searchGemBySerialNo:matrix[mino.line+1][mino.col] & 0xffff];
        if(![ptr isEqual:[NSNull null]]){
            targetType = ptr.typeIndex;
            CCLOG(@"mohou=%d", targetType);
            for(l = 0; l < GRIDSZ_H; l++){
                for(c = 0; c < GRIDSZ_W; c++){
                    Jewel *lcj = [self searchGemBySerialNo:matrix[l][c] & 0xffff];
                    if(![lcj isEqual:[NSNull null]]){
                        if(lcj.typeIndex == targetType){
                            matrix[l][c] |= SMASHED_FLAG;
                        }
                    }
                }
            }
        }
    }
}

//serialで宝石検索
- (id)searchGemBySerialNo:(int)no
{
    for(Jewel *ptr in piledGems){
        if(ptr.serialNo == no){
            return ptr;
        }
    }
    return [NSNull null];
}

//位置で宝石検索
- (id)searchGemByLC:(int)l col:(int)c
{
    for(Jewel *ptr in piledGems){
        if(ptr.line == l && ptr.col == c){
            return ptr;
        }
    }
    return [NSNull null];
}

//宝石削除
-(id)deleteGemBySerialNo:(int)no{
    int n = [piledGems count];
    for(int i = n-1; i >= 0; i--){
        Jewel *ptr = piledGems[i];
        if(![ptr isEqual:[NSNull null]]){
            if(ptr.serialNo == no){
                [piledGems removeObjectAtIndex:i];
                [ptr clearTexture];
                return ptr;
            }
        }
    }
    return [NSNull null];
}

//ローテート
- (void)mino_rotate:(int)order
{
    if(order == 1){//↓
        [mino.order exchangeObjectAtIndex:0 withObjectAtIndex:2];
        [mino.order exchangeObjectAtIndex:1 withObjectAtIndex:2];
    }else if(order == -1){//↑
        [mino.order exchangeObjectAtIndex:0 withObjectAtIndex:2];
        [mino.order exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    //local位置は固定
    [mino.order[0] setPosByLC:0 col:0];
    [mino.order[1] setPosByLC:1 col:0];
    [mino.order[2] setPosByLC:2 col:0];
}

//位置設定(一番下の宝石の位置)
- (void)mino_setpos:(int)l col:(int)c
{
    mino.line = l;
    mino.col  = c;
    mino.sprMino.position = CGPointMake(BLOCKSIZE*c, BLOCKSIZE*(GRIDSZ_H-(l+1)));
}

//右へ
- (void)mino_moveRight
{
    if(mino.col+1 >= GRIDSZ_W){
        return;
    }
    int l = mino.line, c = mino.col + 1;
    if(matrix[l][c] != 0 || matrix[l-1][c] != 0 || matrix[l-2][c] != 0){
        return;
    }
    [self mino_setpos:l col:c];
}

//左へ
- (void)mino_moveLeft
{
    if(mino.col <= 0){
        return;
    }
    int l = mino.line, c = mino.col - 1;
    if(matrix[l][c] != 0 || matrix[l-1][c] != 0 || matrix[l-2][c] != 0){
        return;
    }
    [self mino_setpos:mino.line col:c];
}

//下へ まだ落下可能な場合はYESを返す
- (BOOL)mino_moveDown
{
    //if([mino.order[0] isEqual:[NSNull null]]){
    //    return NO;
   // }
    int l = mino.line + 1;
    if(l >= GRIDSZ_H){
        return NO;
    }
    if(matrix[l][mino.col] != 0){
        return NO;
    }
    [self mino_setpos:l col:mino.col];
//    limitMinoLine = mino.line + 1;
    return YES;
}

//--------------------------------------------------------
//３つ以上並んだものを走査しビンゴマーク付与
- (void)scanMatrix
{
    phase = PHASE_CHECKING;
    //[self _print_matrix];//++++
    
    //横
    [self scanHorizontal];
    //縦
    [self scanVirtical];
    //斜め方向
	[self scanXDown];
	[self scanXUp];
    
    //パキーン-------------------------------
    /*
     deleted = 0;
     pakin = 0;
     ppush = 0;
     ppop = 0;
     for(var gyo = 0; gyo < MAX_GYO; gyo++ ){
     for(var retsu = 0; retsu < MAX_RETSU; retsu++){
     var point = matrix[gyo][retsu];
     if( point == -1 ) continue;
     if( (point & ERASE_MASK) ) {
     if( deleted == 0 ) {
     sfx_02.start();
     }
     EraseOne(gyo, retsu, theTotalDelete);
     deleted++;
     pakin++;
     theTotalDelete++;
     }
     }
     }
     */
    //破裂処理
    [self checkSmash];
    /*
     NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:3.0f
     target:self
     selector:@selector(readySmash:)
     userInfo:nil repeats:NO];
     [tm fire];
     */
    //落下チェックへ
}

- (void)scanHorizontal
{
	int prev, chain, start;
    //横方向
	for(int l = 0; l < GRIDSZ_H; l++){
		chain = 0;
		Jewel *ptr;
		if( matrix[l][0] == VOIDSPACE ) {
			prev = VOIDSPACE;
		}else{
			ptr = [self searchGemBySerialNo:matrix[l][0] & 0xffff];
            if(![ptr isEqual:[NSNull null]]){
                prev = ptr.typeIndex;
            }
		}
		for(int c = 1; c < GRIDSZ_W; c++){
			int aNo = matrix[l][c];
			if( aNo == VOIDSPACE ) {
				if( chain >= 2 ){
					for(int j = start; j <= start+chain; j++){
						matrix[l][j]  |=  SMASHED_FLAG;
					}
					sessionLines += (chain - 1);
				}
				chain = 0;
				prev = VOIDSPACE;
				continue;
			}
			Jewel *aptr = [self searchGemBySerialNo:matrix[l][c] & 0xffff];
            if(![aptr isEqual:[NSNull null]]){
                if( aptr.typeIndex  == prev ){
                    if( chain == 0 ) start = c-1;
                    chain++;
                }else{
                    if( chain >= 2 ){
                        for(int j = start; j <= start+chain; j++){
                            matrix[l][j]  |=  SMASHED_FLAG;
                        }
                        sessionLines += (chain - 1);
                    }
                    chain = 0;
                }
                prev = aptr.typeIndex;
            }
		}
		if( chain >= 2 ){
			for(int j = start; j <= start+chain; j++){
				matrix[l][j]  |=  SMASHED_FLAG;
			}
			sessionLines += (chain - 1);
		}
	}
}

- (void)scanVirtical
{
    int prev, chain, start;
    //縦方向
	for(int c = 0; c < GRIDSZ_W; c++){
		chain = 0;
		Jewel *ptr;
		if( matrix[0][c] == VOIDSPACE ){
			prev = VOIDSPACE;
		}else{
			ptr = [self searchGemBySerialNo: matrix[0][c] & 0xffff];
            if(![ptr isEqual:[NSNull null]]){
                prev = ptr.typeIndex;
            }
		}
		for(int l = 1; l < GRIDSZ_H; l++){
			int aNo = matrix[l][c];
			if( aNo == VOIDSPACE ) {
				prev = VOIDSPACE;
				continue;
			}
			Jewel *aptr = [self searchGemBySerialNo: matrix[l][c] & 0xffff];
            if(![aptr isEqual:[NSNull null]]){
                if( aptr.typeIndex  == prev ){
                    if( chain == 0 ) start = l-1;
                    chain++;
                }else{
                    if( chain >= 2 ){
                        for(int i = start; i <= start+chain; i++){
                            matrix[i][c]  |=  SMASHED_FLAG;
                        }
                        sessionLines += (chain - 1);
                    }
                    chain = 0;
                }
                prev = aptr.typeIndex;
            }
        }
		if( chain >= 2 ){
            for(int i = start; i <= start+chain; i++){
                matrix[i][c]  |=  SMASHED_FLAG;
            }
            sessionLines += (chain - 1);
		}
	}
}

int ScDataDw_sg[] =  {0,1,2,3,4,5,6,7,8,9,10,11,12,0,0,0};
int ScDataDw_sr[] =  {0,0,0,0,0,0,0,0,0,0,0, 0, 0, 1,2,3};
int ScDataDw_num[] = {6,6,6,6,6,6,6,6,5,4,3, 2, 1, 5,4,3};
//斜め下方向
- (void)scanXDown
{
	int sg, sr;
	int chain = 0;
	int prev, bg, br;
	for(int i = 0; i < 16; i++){
		chain = 0;
		sg = ScDataDw_sg[i];
		sr = ScDataDw_sr[i];
		Jewel *ptr;
		if( matrix[sg][sr] == VOIDSPACE ){
            prev = VOIDSPACE;
		}else{
			ptr = [self searchGemBySerialNo:(matrix[sg][sr] & 0xffff)];
            if(![ptr isEqual:[NSNull null]]){
                prev = ptr.typeIndex;
            }
		}
		sg++;
		sr++;
		for(int j = 1; j < ScDataDw_num[i]; j++ ){
			int aNum = matrix[sg][sr];
			if( aNum == VOIDSPACE ) {
				if( chain >= 2 ){
					for(int k=0; k<=chain; k++){
						matrix[bg][br] |= SMASHED_FLAG;
						bg++;
						br++;
					}
					sessionLines += (chain - 1);
					chain = 0;
				}
				sg++;
				sr++;
				prev = VOIDSPACE;
				chain = 0;
				continue;
			}
			ptr = [self searchGemBySerialNo:(matrix[sg][sr] & 0xffff)];
            if(![ptr isEqual:[NSNull null]]){
                if( prev == ptr.typeIndex ){
                    if( chain == 0 ) {
                        bg = sg - 1;
                        br = sr - 1;
                    }
                    chain++;
                }else{
                    if( chain >= 2 ){
                        for(int k=0; k<=chain; k++){
                            matrix[bg][br] |= SMASHED_FLAG;
                            bg++;
                            br++;
                        }
                        sessionLines += (chain - 1);
                    }
                    chain = 0;
                }
                sg++;
                sr++;
                prev = ptr.typeIndex;
            }
		}
		if( chain >= 2 ){
			for(int k=0; k<=chain; k++){
				matrix[bg][br] |= SMASHED_FLAG;
				bg++;
				br++;
			}
			sessionLines += (chain - 1);
			chain = 0;
		}
	}
}

int ScDataUp_sg[] =  {2,3,4,5,6,7,8,9,10,11,12,12,12,12,12,12};
int ScDataUp_sr[] =  {0,0,0,0,0,0,0,0,0 ,0 ,0 ,1 ,2 ,3 ,4 ,5};
int ScDataUp_num[] = {3,4,5,6,6,6,6,6,6 ,6 ,6 ,5 ,4 ,3 ,2 ,1};
//斜め上方向
- (void)scanXUp
{
	int sg, sr;
	int prev, chain = 0, bg, br;
	for(int i = 0; i < 16; i++){
		chain = 0;
		sg = ScDataUp_sg[i];
		sr = ScDataUp_sr[i];
		Jewel *ptr;
		if( matrix[sg][sr] == VOIDSPACE ){
            prev = VOIDSPACE;
		}else{
			ptr = [self searchGemBySerialNo:(matrix[sg][sr] & 0xffff)];
            if(![ptr isEqual:[NSNull null]]){
                prev = ptr.typeIndex;
            }
		}
		sg--;
		sr++;
		for(int j = 1; j < ScDataUp_num[i]; j++ ){
			int aNum = matrix[sg][sr];
			if( aNum == VOIDSPACE) {
				if( chain >= 2 ){
					for(int k=0; k<=chain; k++){
						matrix[bg][br] |= SMASHED_FLAG;
						bg--;
						br++;
					}
					sessionLines += (chain - 1);
					chain = 0;
				}
				sg--;
				sr++;
				prev = VOIDSPACE;
				chain = 0;
				continue;
			}
			ptr = [self searchGemBySerialNo:(matrix[sg][sr] & 0xffff)];
            if(![ptr isEqual:[NSNull null]]){
                if( prev == ptr.typeIndex ){
                    if( chain == 0 ) {
                        bg = sg + 1;
                        br = sr - 1;
                    }
                    chain++;
                }else{
                    if( chain >= 2 ){
                        for(int k=0; k<=chain; k++){
                            matrix[bg][br] |= SMASHED_FLAG;
                            bg--;
                            br++;
                        }
                        sessionLines += (chain - 1);
                    }
                    chain = 0;
                }
                sg--;
                sr++;
                prev = ptr.typeIndex;
            }
		}
		if( chain >= 2 ){
			for(int k=0; k<=chain; k++){
				matrix[bg][br] |= SMASHED_FLAG;
				bg--;
				br++;
			}
			sessionLines += (chain - 1);
			chain = 0;
		}
	}
}

//落下チェック
//空白をチェックし落下モーション実行
- (void)checkFall
{
    phase = PHASE_FALLING;
    float maxdt = 0.0;
    for(int c = 0; c < GRIDSZ_W; c++){
        int fallCount = 0, totalAlt = 0;
        for(int l = GRIDSZ_H-1; l >= 0; l--){
            int no = matrix[l][c];
            if(no == 0){
                totalAlt++;
                fallCount = 0;
                continue;
            }else{
                if(totalAlt > 0){//落ちる
                    int newL = l + totalAlt;
                    float dt, tt;
                    matrix[newL][c] = no;//マトリックス更新
                    matrix[l][c] = 0;
                    Jewel *aJwl = (Jewel *)[self searchGemBySerialNo:no];
                    if(![aJwl isEqual:[NSNull null]]){
                        aJwl.line = newL;
                        dt = 0.08 * (float)fallCount;
                        tt = [aJwl fall:totalAlt*BLOCKSIZE delay:dt];//落下start
                    }
                    tt += dt;
                    if(tt > maxdt){
                        maxdt = tt;
                    }
                    //CCLOG(@"fall [%d][%d] delay=%d alt=%d", l, c, fallCount, totalAlt);
                    fallCount++;
                }else{
                    //落ちる必要なし
                }
            }
        }
    }
    
    CCLOG(@"Falltime %f", maxdt);
    //すべての着地まで待ってからスキャン開始
    [self performSelector:@selector(scanMatrix) withObject:nil afterDelay:maxdt];

}

- (void)_print_matrix
{
    //チェックコード++++
     for(int l = 0; l < GRIDSZ_H; l++){
         NSString *str = @"";
         for(int c = 0; c < GRIDSZ_W; c++){
             int idx = 0;
             if(matrix[l][c] > 0){
                 Jewel *jj = (Jewel *)[self searchGemBySerialNo:matrix[l][c]];
                 if(![jj isEqual:[NSNull null]]){
                     idx = jj.typeIndex;
                 }
             }
             NSString *nstr = [NSString stringWithFormat:@"%d", idx];
             str = [str stringByAppendingString:nstr];
         }
         CCLOG(@"%@", str);
     }
}


//ビンゴマークが入ったものをチェックし破裂エフェクト実行
- (void)checkSmash
{
    phase = PHASE_SMASHING;
    int smashed = 0;
    for(int l = 0; l < GRIDSZ_H; l++){
        for(int c = 0; c < GRIDSZ_W; c++){
            int ncode = matrix[l][c];
            int nid = ncode & 0xffff;
            if(ncode & SMASHED_FLAG){
                smashed++;
                Jewel *dieGem = (Jewel *)[self searchGemBySerialNo:nid];
                if(![dieGem isEqual:[NSNull null]]){
                    if(dieGem.mySprite){
                        [sprContainer removeChild:dieGem.mySprite cleanup:YES];
                    }
                }
                matrix[l][c] = 0;
                Jewel *delGem = (Jewel *)[self deleteGemBySerialNo:nid];
                if(![delGem isEqual:[NSNull null]]){
                    [delGem release];
                }
                CCLOG(@"smash[%d][%d]", l, c);
            }
        }
    }
    clearCount += smashed;
    if(smashed > 0){
        sessionChain++;
        //破裂が終わった頃に落下チェックへ
        [self performSelector:@selector(checkFall) withObject:nil afterDelay:0.5];
        if(sessionChain >= 2){
            CCLOG(@"%d COMBO!", sessionChain);
        }
    }else{
        //レベルアップ
        if( clearCount > (theLevel * 50 ) ){
            theLevel++;
            CCLOG(@"LevelUp Lv%d", theLevel);
            sessionInterval -= 0.2;
            if(sessionInterval < 0.2){
                sessionInterval = 0.2;
            }
        }
        //GENARATE NEXT GEMS
        phase = PHASE_SCORING;
        int sessionScore = 30 * theLevel * sessionLines * (sessionChain+1);
        [self addScore:sessionScore];
        [self nextSession];
    }
}

- (void)addScore:(int)score
{
    theScore += score;
    [label setString:[NSString stringWithFormat:@"SCORE : %ld    LEVEL %d", theScore, theLevel]];
    CCLOG(@"ADD SCORE(+%d)", score);
}

//破裂宝石なし　セッション終了
- (void)nextSession
{
    phase = PHASE_PREPARENEXT;
    CCLOG(@"NEW SESSION START");
    //chainクリア 次のmino生成 start
    sessionLines = 0;
    sessionChain = 0;
    if([self generateNextMino] == NO){//置くとこなし即ちゲームオーバー
        [self gameover];
    }else{
        //[self freeTimeStart];
        phase = PHASE_FREETIME;//オマケ
        [self performSelector:@selector(freeTimeStart) withObject:nil afterDelay:0.3];
    }
}

- (void)gameover
{
    phase = PHASE_DISABLE;
    CCLOG(@"GAME OVER !!!!!!!!");
    for(Jewel *ptr in piledGems){
        if(![ptr isEqual:[NSNull null]]){
            if(ptr.mySprite){
                ptr.mySprite.opacity = 128;
            }
        }
    }
    //sprContainer.opacity = 128;
}


//タッチ処理 -------------------------------------------------------
NSTimeInterval timestampBegan_ = 0.0;
CGPoint pointBegan_;
int MINTICK = 16;
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(phase != PHASE_FREETIME){
        return;
    }
    NSTimeInterval timeBegan2Ended = event.timestamp - timestampBegan_;
    if(timeBegan2Ended < 0.04){
        return;
    }
    UITouch *touch = [touches anyObject];
    timestampBegan_ = event.timestamp;
    pointBegan_ = [touch locationInView:[touch view]];
}

//-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    static int semaphore = 0;
    if(semaphore == 0){
        semaphore++;
        if(phase != PHASE_FREETIME || timestampBegan_ == 0.0){
            semaphore--;
            return;
        }
        UITouch *touch = [touches anyObject];
        CGPoint pointMoving = [touch locationInView:[touch view]];
        NSInteger distanceH = abs(pointMoving.x - pointBegan_.x);
        NSInteger distanceV = abs(pointMoving.y - pointBegan_.y);
        NSTimeInterval timeFromBegan = event.timestamp - timestampBegan_;
        if(timeFromBegan > 0.5){//遅い指の動き
            semaphore--;
            return;
        }
        if(distanceH >= MINTICK || distanceV >= MINTICK){
            if(distanceH > distanceV){
                if(pointMoving.x > pointBegan_.x){//右フリック
                    CCLOG(@">>");
                    [self mino_moveRight];
                    timestampBegan_ = 0.0;
                }else{//左クリック
                    CCLOG(@"<<");
                    [self mino_moveLeft];
                    timestampBegan_ = 0.0;
                }
            }else{
                if(pointMoving.y > pointBegan_.y){//下フリック
                    CCLOG(@"vv");
                    [self mino_rotate:1];
                    timestampBegan_ = 0.0;
                }else{//上フリック
                    CCLOG(@"^^");
                    [self mino_rotate:-1];
                    timestampBegan_ = 0.0;
                }
            }
        }
        semaphore--;
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(phase != PHASE_FREETIME || timestampBegan_ == 0.0){
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint pointEnded = [touch locationInView:[touch view]];
    NSInteger distanceH = abs(pointEnded.x - pointBegan_.x);
    NSInteger distanceV = abs(pointEnded.y - pointBegan_.y);
    NSTimeInterval timeBegan2Ended = event.timestamp - timestampBegan_;
    if(timeBegan2Ended < 0.04){ return; }
    if(distanceH < MINTICK && distanceV < MINTICK){
        CCLOG(@"<TICK");
        if(timeBegan2Ended < 0.5 && pointEnded.y > (BLOCKSIZE*11*screenScale)){//下の方をクリック
            //落下SPEED UP
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waitTimeEnd) object:nil];
            if([self mino_moveDown]){
                [self performSelector:@selector(waitTimeEnd) withObject:nil afterDelay:sessionInterval];
                [self addScore:theLevel*10];
            }else{
                [self waitTimeEnd];
            }
        }
        return;
    }
    if(timeBegan2Ended > 0.5){//遅い指の動き
        CCLOG(@">0.5");
        return;
    }
}

@end


