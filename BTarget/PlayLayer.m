//
//  PlayLayer.m
//  BTarget
//
//  Created by Robert Lane on 12/8/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "PlayLayer.h"


@implementation PlayLayer

+ (CCScene*) scene
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlayLayer *layer = [PlayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) onEnter
{
    [super onEnter];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _background = [CCSprite spriteWithFile:@"BG_Simple.gif"];
    _background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_background];
    
    //Do this from some external data/scripting
    CCSprite *window1 = [CCSprite spriteWithFile:@"window.png"];
    window1.position = ccp(100, 220);
    window1.opacity = 0.0f;
    [self addProp:window1 name:@"window1"];
    CCSprite *window2 = [CCSprite spriteWithFile:@"Window.png"];
    window2.position = ccp(280, 220);
    window2.opacity = 0.0f;
    [self addProp:window2 name:@"window2"];
    [self scheduleOnce:@selector(fadeInPropsWithDelay:) delay:1];
    [self scheduleOnce:@selector(testMoveTarget:)delay:1.5];
}

-(void) addProp: (CCSprite *)node name:(NSString *)name
{
    if (_props == nil)
    {
        _props = [[NSMutableDictionary alloc] init];
    }
    if (node != nil && [_props objectForKey:name] == nil) 
    {
        [self addChild:node];
    }
    [_props setValue:node forKey:name];

}

-(void) fadeInPropsWithDelay:(ccTime)delay
{
    if ([_props count] > 0) { 
        for (NSString *name in _props)
        {
            [self fadeInPropWithName:name withDelay:delay];
        }
    }
}

-(void) fadeInPropWithName:(NSString *)name withDelay:(ccTime)delay
{
    id fadeAction = [CCFadeIn actionWithDuration:delay];
    CCSprite *prop = [_props objectForKey:name];
    [prop runAction:fadeAction];
}

-(void) testMoveTarget:(ccTime)delay
{
 //   CCSprite *targetSprite = [target1 targetSprite];
   // [self addChild:targetSprite];
    //targetSprite.position = ccp(120, 180);
}
    
@end
