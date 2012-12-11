//
//  TargetLayer.h
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Target.h"

@interface TargetLayer : CCLayer { 
    Target * _target;
    CCSprite *_prop;
    BOOL _displayed;
}
-(void) setTarget:(Target*) target;
-(Target*) getTarget;
-(void) setProp:(CCSprite*) prop;
-(CCSprite*) getProp;
-(BOOL) isDisplayed;

-(id) initWithProp:(CCSprite*)prop andTarget:(Target*) target;

//Show a random target in a random area
-(void) showTargetForTime:(ccTime)time atSpeed:(float) speed;

@end
