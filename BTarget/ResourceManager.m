//
//  ResourceManager.m
//  BTarget
//
//  Created by Robert Lane on 12/24/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import "ResourceManager.h"

@implementation ResourceManager

@synthesize spritesheet=_spritesheet;

static ResourceManager* _sharedResourceManager;

+(ResourceManager*) sharedResourceManager 
{ 
    return _sharedResourceManager;
}

+ (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        _sharedResourceManager = [[ResourceManager alloc] init];
    }
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"Animations.png"];
        [self addChild:_spritesheet];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations.plist" texture:_spritesheet.texture];
        zOrder_ = 100;
    }
    return self;
}

-(CCSprite*) spriteWithResourceName:(NSString*)name
{
    return [CCSprite spriteWithSpriteFrameName:name];
}

-(CCSpriteFrame*) spriteFrameWithResourceName:(NSString*)name
{
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
}

@end
