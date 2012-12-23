//
//  TargetLayer.h
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BTargetSprite.h"

@interface TargetLayer : CCLayer { 
    BTargetSprite * _target;
    BTargetSprite * _decoy;
    CCSprite *_prop;
    CGPoint _targetDirection;
    NSMutableDictionary *_animDictionary;
    CCSprite *_bullseyeAnimation;
    CCSprite *_hitAnimation;
    CCSpriteBatchNode* _spriteSheet;
    CCAction *_showAction;
    BOOL _displayed;
    BOOL _destroyed;
    int _decoyWeight;
}
-(void) setTarget:(BTargetSprite*) target;
-(BTargetSprite*) getTarget;
-(void) setDecoy:(BTargetSprite*) decoy;
-(BTargetSprite*) getDecoy;
-(void) setProp:(CCSprite*) prop;
-(CCSprite*) getProp;
-(BOOL) isDisplayed;
-(BOOL) isDestroyed;

-(id) initWithProp:(CCSprite*)prop target:(BTargetSprite*)target decoy:(BTargetSprite*)decoy andSpritesheet:(CCSpriteBatchNode*)spritesheet;

//Show a random target in a random area
-(void) showTargetForTime:(ccTime)time atSpeed:(float) speed;

@end
