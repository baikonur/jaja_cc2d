//
//  GameScreen.h
//  volumns
//
//  Created by 原田 正隆 on 13/04/29.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SpriteManager.h"
#import "Jewel.h"

//スクリーン情報
struct ScreenInfoDef {
    int screen_h;
    int screen_w;
    int stageOffset_x;
    int stageOffset_y;
    int margin_top;
};
typedef struct ScreenInfoDef ScreenInfo;
//テトリミノ情報
struct ColumnsMinoDef {
    CCSprite *sprMino;//グループsprite
    NSMutableArray *order;//並び順　[上、中、下] (Jewel *)
    int line;
    int col;
    int type;// 0:normal 1:mahou
};
typedef struct ColumnsMinoDef ColumnsMino;

@interface GameScreen : CCLayer
{
    ColumnsMino mino;
}

+(CCScene *) scene;
- (void)mino_setpos:(int)l col:(int)c;
- (void)mino_rotate:(int)order;
- (void)mino_moveRight;
- (void)mino_moveLeft;
- (BOOL)mino_moveDown;
- (id)searchGemBySerialNo:(int)no;
- (id)searchGemByLC:(int)l col:(int)c;
- (id)deleteGemBySerialNo:(int)no;

@property (nonatomic,assign)ColumnsMino mino;
@property (nonatomic,retain)SpriteManager *sprMgr;
@property (nonatomic)int phase;


#define BLOCKSIZE   24
#define NUM_REGULER_TYPE 5
#define GRIDSZ_H    13
#define GRIDSZ_W    6
#define MARGIN_TOP  24
#define VOIDSPACE   0
#define SMASHED_FLAG    0x10000
#define PHASE_DISABLE   -1
#define PHASE_FREETIME  0
#define PHASE_CHECKING  1
#define PHASE_SMASHING  2
#define PHASE_FALLING   3
#define PHASE_SCORING   4
#define PHASE_PREPARENEXT 5

@end
