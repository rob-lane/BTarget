//
//  ResourceManager.h
//  BTarget
//
//  Created by Robert Lane on 12/24/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ResourceManager : CCNode 
@property (readonly) CCSpriteBatchNode *spritesheet;

+(ResourceManager*)sharedResourceManager;

-(CCSprite*) spriteWithResourceName:(NSString*)name;
-(CCSpriteFrame*) spriteFrameWithResourceName:(NSString*)name;

@end
