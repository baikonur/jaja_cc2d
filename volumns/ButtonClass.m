//
//  ButtonClass.m
//  volumns
//
//  Created by administrator on 13/04/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "ButtonClass.h"


@implementation ButtonClass

-(void) onEnter
{
    //TouchEventディスパッチャー
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0    //タッチを受け取る優先順位
                                                       swallowsTouches:YES  //通常はYES
     ];
    [super onEnter];
}


-(void)onExit
{
     //TouchEvent解除
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}


-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL isBlock = NO;
    CGPoint touchLocation = [touch locationInView:touch.view];
    CGPoint location = [[CCDirector sharedDirector]convertToGL:touchLocation];
    if(CGRectContainsPoint(self.boundingBox, location)){
        CCLOG(@"Touched Button");
        isBlock = YES;
    }
    return isBlock;
}


-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    return;
}


-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    return;
}


@end
