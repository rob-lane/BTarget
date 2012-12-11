//
//  TargetLayer.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "TargetLayer.h"

@interface TargetLayer (hidden)
-(void) showActionsEnded;
@end

@implementation TargetLayer (hidden)

-(void) showActionsEnded
{
    _displayed = NO;
}

@end

@implementation TargetLayer

-(id) init
{
    self = [super init];
    if (self)
    {
        _prop = nil;
        _target = nil;
    }
    return self;
}

-(id) initWithProp:(CCSprite*)prop andTarget:(Target*) target
{
    self = [super init];
    if(self)
    {
        [self setProp:prop];
        [self setTarget:target];
    }
    return self;
}

-(void) setTarget:(Target*) target
{
    if (_target != nil)
    {
        [self removeChild:_target cleanup:YES];
    }
    _target = target;
    if (_target)
    {
        [self addChild:_target];
    }
}

-(Target*) getTarget
{
    return _target;
}

-(void) setProp:(CCSprite*) prop
{
    if (_prop != nil)
    {
        [self removeChild:_prop cleanup:YES];
    }
    _prop = prop;
    if (_prop)
    {
        [self addChild:_prop];
    }
}
-(CCSprite*) getProp
{
    return _prop;
}

-(BOOL) isDisplayed
{
    return _displayed;
}

-(void) showTargetForTime:(ccTime)time atSpeed:(float)speed
{
    float y = _prop.position.y - (_prop.contentSize.height/2) - ((_prop.contentSize.height/2) + (_target.contentSize.height/2));
//    position.y-(prop.contentSize.height/2) - ((prop.contentSize.height/2) + (target.contentSize.height/2))
    float x = _prop.position.x;
    _target.position = ccp(x, y);
    _displayed = YES;

    float distance = abs(_prop.position.y - _target.position.y);
    float duration = distance * (1/speed);
    id showAnim = [CCMoveTo actionWithDuration:duration position:(_prop.position)];
    
    //TODO: Add prop animation here...
    //
    
    id waitAction = [CCDelayTime actionWithDuration:time];
    id hideAnim = [CCMoveTo actionWithDuration:duration position:_target.position];
    id endAction = [CCCallFunc actionWithTarget:self selector:@selector(showActionsEnded)];
    
    id sequence = [CCSequence actions:showAnim, waitAction, hideAnim, endAction, nil];
//    id sequence = [CCSequence actions:showAnim, waitAction, nil];

    [_target runAction:sequence];
}


@end
