//
//  SpriteManager.m (Singleton)
//  volumns
//
//  Created by administrator on 13/05/01.
//
//  画像データの管理　addTextureで登録／getTextureで取り出し
//  (Singleton)
//

#import "SpriteManager.h"

@implementation SpriteManager

@synthesize textures;

static SpriteManager* _sharedManager = nil;

- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
    }
    return self;
}

+ (SpriteManager*)sharedManager {
    @synchronized(self) {
        if (_sharedManager == nil) {
            (void) [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [super allocWithZone:zone];
            return _sharedManager;  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)retain {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}

- (unsigned)retainCount {
    return UINT_MAX;  // 解放できないインスタンスを表すため unsigned int 値の最大値 UINT_MAX を返す
}

- (id)autorelease {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}


//画像登録 PNGファイルパス キー名
- (CCTexture2D *)addTexture:(NSString *)path key:(NSString *)idKey
{
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:path];
    if(tex != nil){
        if(!textures) {
            textures = [[NSMutableDictionary alloc]init];//<-- [NSMutableDictionary dictionary]ではダメ!
        }
        [textures setObject:tex forKey:idKey];
    }
    return tex;
}

//指定の画像データ取得
- (CCTexture2D *)getTexture:(NSString *)idKey
{
    return [textures objectForKey:idKey];
}

@end
