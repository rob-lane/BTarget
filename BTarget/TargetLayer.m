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
-(void) loadAnimations;
-(CCAction*) createActionWithName:(NSString*)name frameCount:(int)count delay:(float)time thatRepeats:(BOOL) repeats;
-(CCSprite*) randomSpriteForDisplay;
-(CGPoint) randomDirectionForSprite;
@end

@implementation TargetLayer (hidden)

-(void) showActionsEnded
{
    _displayed = NO;
}

-(void) loadAnimations
{
    if (_spriteSheet)
    {
        
        if (_animDictionary)
        {
            [_animDictionary removeAllObjects];
        }
        else {
            _animDictionary = [[NSMutableDictionary alloc] init];
        }
        
        CCAction *action = [self createActionWithName:@"be" frameCount:4 delay:0.1f thatRepeats:NO];
        _bullseyeAnimation = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@%i", @"be", 1]];
        [_animDictionary setValue:action forKey:@"be"];
        [_spriteSheet addChild:_bullseyeAnimation];
        _bullseyeAnimation.position = _prop.position;
        _bullseyeAnimation.visible = NO;
        
        action = [self createActionWithName:@"he" frameCount:3 delay:0.1f thatRepeats:NO];
        _hitAnimation = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@%i", @"he", 1]];
        [_animDictionary setValue:action forKey:@"he"];
        [_spriteSheet addChild:_hitAnimation];
        _hitAnimation.position = _prop.position;
        _hitAnimation.visible = NO;
        
        
    }
}

-(CCAction*) createActionWithName:(NSString*)name frameCount:(int)count delay:(float)time thatRepeats:(BOOL) repeats
{
    
    NSMutableArray* anim_frames = [NSMutableArray array];
    
    for (int i = 1; i <= count; i++) {
        [anim_frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%i", name, i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:anim_frames delay:time];
    CCAction *action = nil;
    if (repeats) {
        action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
    }
    else { 
        action = [CCAnimate actionWithAnimation:anim];
    }
    return action;
}

-(CCSprite*) randomSpriteForDisplay
{
    if (_decoyWeight <= 0) { 
        _decoyWeight = 10;
    }
    else if (_decoyWeight >= 100) { 
        _decoyWeight = 100;
    }
    else { 
        _decoyWeight += 10;
    }
    int rand = arc4random_uniform(100);
    if (rand < _decoyWeight) { 
        return _decoy;
    }
    else { 
        return _target;
    }   
}

-(CGPoint) randomDirectionForSprite
{
    int rand = arc4random_uniform(100);
    _targetDirection = CGPointZero;
    if (rand <= 30) { 
        _targetDirection.x = -1;
    }
    else if (rand <= 60) {
        _targetDirection.x = 1;
    }
    else { 
        _targetDirection.x = 0;
    }
    
    if (_targetDirection.x == 0) { 
        rand = arc4random_uniform(100);
        if (rand <= 50) { 
            _targetDirection.y = -1;
        }
        else { 
            _targetDirection.y = 1;
        }
    }
    return _targetDirection;
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
        _displayed = NO;
        _destroyed = NO;
        _decoyWeight = 0;
        _targetDirection = CGPointZero;
        self.isTouchEnabled = YES;
        self.zOrder = 0;
    }
    return self;
}

-(id) initWithProp:(CCSprite*)prop target:(BTargetSprite*)target decoy:(BTargetSprite*)decoy andSpritesheet:(CCSpriteBatchNode*)spritesheet
{
    self = [super init];
    if(self)
    {
        _spriteSheet = spritesheet;
        _displayed = NO;
        _destroyed = NO;
        _decoyWeight = 0;
        _targetDirection = CGPointZero;
        [self setProp:prop];
        [self setDecoy:decoy];
        [self setTarget:target];
        [self loadAnimations];
        self.isTouchEnabled = YES;
    }
    return self;
}

-(void) dealloc
{
    if (_animDictionary)
    {
        [_animDictionary removeAllObjects];
        [_animDictionary dealloc];
        _animDictionary = nil;
    }
    if (_spriteSheet)
    {
        if (_bullseyeAnimation)
        {
            [_spriteSheet removeChild:_bullseyeAnimation cleanup:YES];
            _bullseyeAnimation = nil;
        }
        if (_hitAnimation)
        {
            [_hitAnimation removeChild:_hitAnimation cleanup:YES];
            _hitAnimation = nil;
        }
        _spriteSheet = nil;
    }
}

-(void) setTarget:(BTargetSprite*) target
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

-(BTargetSprite*) getTarget
{
    return _target;
}

-(void) setDecoy:(BTargetSprite *)decoy
{
    if (_decoy != nil)
    {
        [self removeChild:_decoy cleanup:YES];
    }
    _decoy = decoy;
    if (_decoy)
    {
        [self addChild:_decoy];
    }
}

-(BTargetSprite*) getDecoy
{
    return _decoy;
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

-(BOOL) isDestroyed
{
    return _destroyed;
}

-(void) registerWithTouchDispatcher
{
    CCTouchDispatcher *sharedDispatcher = [[CCDirector sharedDirector] touchDispatcher];
    [sharedDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[self parent] convertTouchToNodeSpace:touch];
    if ([_target doesPointCollide:location] && _animDictionary)
    {
        CCAction *action = nil;
        CCSprite *anim_sprite = nil;
        if ([_target isPointBullseye:location]) {
            action = [_animDictionary objectForKey:@"be"];
            anim_sprite = _bullseyeAnimation;
        }
        else {
            action = [_animDictionary objectForKey:@"he"]; 
            anim_sprite = _hitAnimation;
            anim_sprite.position = location;
        }
        if (action && anim_sprite)
        {
            [anim_sprite setVisible:YES];
            [anim_sprite runAction:action];
            [_target setVisible:NO];
            id endAction = [CCCallFunc actionWithTarget:self selector:@selector(showActionsEnded)];
            [_target runAction:endAction];
            CCFadeOut* fadeExplosion = [CCFadeOut actionWithDuration:1.0f];
            [anim_sprite runAction:fadeExplosion];
            _destroyed = YES;
        }
    }
    
    
}

-(void) showTargetForTime:(ccTime)time atSpeed:(float)speed
{
    BTargetSprite* sprite = (BTargetSprite*)[self randomSpriteForDisplay];
    if (sprite) {
        CGPoint direction = [self randomDirectionForSprite];
        CGPoint start = _prop.position;
        float distance = 0;
        if (direction.x == 0) { 
            if (direction.y < 0) { 
                start.y = _prop.position.y + (_prop.contentSize.height/2) + ((_prop.contentSize.height/2) + (_target.contentSize.height/2));
            }
            else { 
                start.y = _prop.position.y - (_prop.contentSize.height/2) + ((_prop.contentSize.height/2) + (_target.contentSize.height/2));
            }
            distance = abs(_prop.position.y - start.y);
        }
        else if (direction.x < 0) { 
            start.x = _prop.position.x + (_prop.contentSize.width/2) + ((_prop.contentSize.width/2) + (_target.contentSize.width/2));
            distance = abs(_prop.position.x - start.x);
        }
        else { 
            start.x = _prop.position.x - (_prop.contentSize.width/2) - ((_prop.contentSize.width/2) + (_target.contentSize.width/2));
            distance = abs(_prop.position.x - start.x);
        }
        sprite.position = start;
        float duration = distance * (1/speed);
        id showAnim = [CCMoveTo actionWithDuration:duration position:(_prop.position)];
        
        id waitAction = [CCDelayTime actionWithDuration:time];
        id hideAnim = [CCMoveTo actionWithDuration:duration position:_target.position];
        id endAction = [CCCallFunc actionWithTarget:self selector:@selector(showActionsEnded)];
        
        _showAction = [CCSequence actions:showAnim, waitAction, hideAnim, endAction, nil];
        
        [sprite runAction:_showAction];
    }
}


@end
