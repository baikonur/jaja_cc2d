//
//  Jewel.h
//  volumns
//
//  Created by administrator on 13/05/01.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScreen.h"

@interface Jewel : NSObject
{
    int offset_x;
    int offset_y;
    int screen_w;
    int screen_h;
}
- (id)initWithScreenInfo:(id)sinfo;
- (CCSprite *)createGemSprite:(int)typeIndex;
- (void)setGemPos:(int)posX y:(int)posY;
- (void)setPosByLC:(int)l col:(int)c;
- (float)fall:(int)altPx delay:(float)delaySec;
- (void)refreshLC;
- (void)clearTexture;
@property int col;
@property int line;
@property int typeIndex;
@property int serialNo;
@property (nonatomic,retain) CCSprite *mySprite;
@property int mustErase;

@end
