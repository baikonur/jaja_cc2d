//
//  Jewel.m
//  volumns
//
//  Created by administrator on 13/05/01.
//
//

#import "Jewel.h"
#import "SpriteManager.h"

@implementation Jewel

@synthesize serialNo;
@synthesize typeIndex;
@synthesize mySprite;
@synthesize mustErase;
@synthesize col;
@synthesize line;

ScreenInfo *theScreenInfo;

- (id)initWithScreenInfo:(id)sinfo
{
    ScreenInfo *ps = (ScreenInfo *)sinfo;
    theScreenInfo = ps;
    offset_x = ps->stageOffset_x;
    offset_y = ps->stageOffset_y;
    screen_w = ps->screen_w;
    screen_h = ps->screen_h;
    return self;
}

- (CCSprite *)createGemSprite:(int)typeIdx
{
    typeIndex = typeIdx;
    [self _getGemSprite:typeIdx];
    return mySprite;
}

- (void)clearTexture
{
    
}

//登録済み画像からSprite取得
- (CCSprite *)_getGemSprite:(int)index
{
    //index = abs(index) % 6;
    NSString *strIndex = [NSString stringWithFormat:@"%d", index];
    mySprite = [CCSprite spriteWithTexture:[[SpriteManager sharedManager]getTexture:strIndex] rect:CGRectMake(0,0,24,24)];
    return mySprite;
}

- (void)setGemPos:(int)posX y:(int)posY
{
    mySprite.position = CGPointMake(posX, posY);
}

//ポジション設定 Line/Column
- (void)setPosByLC:(int)l col:(int)c
{
    line = l;
    col = c;
    int xPos = c * BLOCKSIZE + offset_x;
    int yPos = screen_h - ((l * BLOCKSIZE) + offset_y);
    [self setGemPos:xPos y:yPos];
    [self refreshLC];
}

//現在のpositionからL/Cを再計算
- (void)refreshLC
{
    int xPos = mySprite.position.x;
    int yPos = mySprite.position.y;
    float c = (float)(xPos - offset_x) / (float)BLOCKSIZE;
    float l = (float)(screen_h - (yPos + offset_y)) / (float)BLOCKSIZE;
    //CCLOG(@"l %d %2.2f c %d %2.2f  ", line ,l, col, c);
    self.line = (int)l;
    self.col = (int)c;
    //CCLOG(@"l %d c %d", line, col);
}

//落下 altPx=落下距離px
- (float)fall:(int)altPx delay:(float)delaySec
{
    //CCAnimate CCSequence
    float tsec = (altPx / BLOCKSIZE - 1) * 0.1 + 0.2;
    //落ちる
    CCMoveTo *anm = [CCMoveTo actionWithDuration:tsec
                                        position:CGPointMake(mySprite.position.x,mySprite.position.y-altPx)];
    CCEaseSineIn *easemove = [CCEaseSineIn actionWithAction:anm];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:delaySec];
    //跳ねる
    float jsec1 = 0.3, jsec2 = 0.15;
    CCJumpBy *jmp1 = [CCJumpBy actionWithDuration:jsec1 position:CGPointMake(0,0) height:BLOCKSIZE/2 jumps:1];
    CCJumpBy *jmp2 = [CCJumpBy actionWithDuration:jsec2 position:CGPointMake(0,0) height:BLOCKSIZE/5 jumps:1];
    CCCallFunc *cbf = [CCCallFunc actionWithTarget:self selector:@selector(cbFallend)];
    CCSequence *actionOrder = [CCSequence actions:delay, easemove, jmp1, jmp2, cbf, nil];
    [mySprite runAction:actionOrder];
    float yoin = 0.1;//微妙にdelay
    return tsec + delaySec + jsec1 + jsec2 + yoin;
}

- (void)cbFallend
{
    //[self refreshLC];　いらないかな？
}
/*
//位置調整情報
- (void)setAdjustInfo:(int)ofsX offsetY:(int)ofsY screenW:(int)screenWidth screenH:(int)screenHeight
{
    offset_x = ofsX;
    offset_y = ofsY;
    screen_w = screenWidth;
    screen_h = screenHeight;
}
*/
 
@end
