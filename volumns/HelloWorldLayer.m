//
//  HelloWorldLayer.m
//  volumns
//
//  Created by administrator on 13/04/26.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "GameScreen.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "ButtonClass.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

int box[4][4] = {
    {1,2,0,0},
    {0,1,0,0},
    {0,0,1,0},
    {0,0,0,1}
};


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    NSArray *ary = @[@1,@2,@3];
    CCLOG(@">>%@", ary[1]);
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{

	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		//CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		//label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		//[self addChild: label];
		
		
	//	ButtonClass *image = [ButtonClass spriteWithFile:@"btn_quest.png"];
    //    CGSize winSize = [[CCDirector sharedDirector]winSize];
    //    image.position = CGPointMake(winSize.width/2, winSize.height-50/*winSize.height/2*/);
    //    [self addChild:image];
        
        //ボタン
        CCMenuItemImage *menuItem = [CCMenuItemImage itemWithNormalImage:@"j5.png"
                                                           selectedImage:@"j5.png"
                                                                   block:^(id sender){
                                                                       //CCLOG(@"%d", box[0][0]);
                                                                       //CCLOG(@"%d", box[0][1]);
                                                                       [self menu_gameStart];
                                                               }
                                 ];
        CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
        //[menu alignItemsVerticallyWithPadding:10.0];
        menuItem.scaleX = 2.0;
        menuItem.scaleY = 2.0;
        [self addChild:menu];
        //[menu setOpacity:0];
        //CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
        //CCFadeIn *fd = [CCFadeIn actionWithDuration:2];
        //CCSequence *ao = [CCSequence actions:delay, fd, nil];
        //[menu runAction:ao];
        
//        CCParticleSystemQuad *particle = [CCParticleExplosion node];
//        particle.texture = [[CCTextureCache sharedTextureCache]addImage:@"wbox8.png"];
        //particle.life = 1;
        //particle.startRadius = 0;
        //particle.endRadius = 100;
        /*
        particle.life = 1.5;
        particle.endRadius = 42;
        particle.emissionRate = 12 * 1.5;
        ccColor4F sc = {1,1,1,1};
        particle.startColor = sc;
        ccColor4F ec = {1,1,1,0.0};
        particle.endColor = ec;
         */
        /*
        CCParticleSystemQuad *particle = [[[CCParticleSystemQuad alloc] initWithTotalParticles:12] autorelease];
        particle.duration = -1; // パーティクルを吐き出す時間
            particle.emitterMode = kCCParticleModeRadius; // 回転モード
            particle.startRadius = 4.0; // 中心からエミッターへの距離(スタート時）
            particle.startRadiusVar = 0.0;
        //particle.radialAccel = -1.0;
            particle.endRadius = 32.0; // 中心からエミッターへの距離(終了時)
            particle.endRadiusVar = 0.0;
//            particle.rotatePerSecond = 100000.0; // 1秒当たりのエミッターの回転角度(degree)。かなり大きくしないと動いているのが見える
//            particle.rotatePerSecondVar = 1000.0; // ばらつきを与えないとパターンが見える
            
           // particle.position = ccp(100, 2000); //親がバッチノードだと使う側で本当の親に合わせて設定する必要あり
            particle.position = CGPointMake(100, 200);
            particle.posVar = ccp(0, 0);
            particle.positionType = kCCPositionTypeFree; // 親ノードに合わせて動かない。Batchノードは動かないので無意味？
            
            particle.startSize = 1.0; // スタート時のパーティクルの大きさ
            particle.startSizeVar = 0.0;
            particle.endSize = 16.0; // 終了時のパーティクルの大きさ
            particle.endSizeVar = 0.0;
            
            particle.angle = 0.0; // エミッターの開始時の角度
            particle.angleVar = 10000.0;
            
            particle.life = 1.0; // パーティクルが消えるまでの時間
            particle.lifeVar = 0.0;
            
            particle.emissionRate = particle.totalParticles/particle.life; // 1秒間に吐き出すスピード
            particle.totalParticles = 12; // 最大のパーティクル数
            
            particle.startColor = (ccColor4F) {1.0,1.0,1.0, 1.0}; // スタート時のRGBα
            particle.startColorVar = (ccColor4F) {1.0, 1.0, 1.0, 1.0};
            
            particle.endColor = (ccColor4F) {1.0, 1.0, 1.0, 0.0}; // 終了時のRGBα
            //particle.endColorVar = (ccColor4F) {0.0, 0.0, 0.0, 0.0};
            
            particle.blendAdditive = YES; // パーティクルが重なると明るく光って見えるブレンドモード
            
            particle.texture = [[CCTextureCache sharedTextureCache] addImage:@"wbox8.png"];
        */
//        [self addChild:particle];
		//
		// Leaderboards and Achievements
		//
/*
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
			[achivementViewController release];
		}
									   ];

		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
			[leaderboardViewController release];
		}
									   ];
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
 */

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

//押された
-(void)menu_gameStart
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScreen scene] withColor:ccBLACK]];
}

#pragma mark GameKit delegate
/*
-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
 */
@end
