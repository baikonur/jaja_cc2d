//
//  SpriteManager.h
//  volumns
//
//  Created by administrator on 13/05/01.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//Singleton
@interface SpriteManager : NSObject
{
    NSMutableDictionary *textures;
}

+ (SpriteManager*)sharedManager;
- (CCTexture2D *)addTexture:(NSString *)path key:(NSString *)idKey;
- (CCTexture2D *)getTexture:(NSString *)idKey;

@property (nonatomic,retain)NSMutableDictionary *textures;
@end
