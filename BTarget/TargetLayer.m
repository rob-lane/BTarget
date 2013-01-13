//
//  TargetLayer.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "TargetLayer.h"
#import "ResourceManager.h"
#import "TouchLayer.h"

@interface TargetLayer (hidden)
-(void) showActionsEnded;
-(void) loadAnimations;
-(CCSprite*) loadAnimationWithName:(NSString*)name frameCount:(int)count delay:(float) time thatRepeats:(BOOL) repeats;
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
    if (_animDictionary)
    {
        [_animDictionary removeAllObjects];
    }
    else {
        _animDictionary = [[NSMutableDictionary alloc] init];
    }
    _bullseyeAnimation = [self loadAnimationWithName:@"be" frameCount:4 delay:0.1f thatRepeats:NO];
    [_bullseyeAnimation setZOrder:1];
    _hitAnimation = [self loadAnimationWithName:@"he" frameCount:3 delay:0.1f thatRepeats:NO];
    [_hitAnimation setZOrder:1];
    _decoyAnimation = [self loadAnimationWithName:@"smiley_touch" frameCount:2 delay:0.5f thatRepeats:YES];
    [_decoyAnimation setZOrder:1];
}

-(CCSprite*) loadAnimationWithName:(NSString*)name frameCount:(int)count delay:(float)time thatRepeats:(BOOL) repeats
{
    
    NSMutableArray* anim_frames = [NSMutableArray array];
    
    for (int i = 1; i <= count; i++) {
        NSString *frame_name = [NSString stringWithFormat:@"%@%i", name, i];
        CCSpriteFrame* frame = [[ResourceManager sharedResourceManager] spriteFrameWithResourceName:frame_name];
        if (frame) {
            [anim_frames addObject:frame];
        }
    }
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:anim_frames delay:time];
    CCAction *action = nil;
    if (repeats) {
        action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
    }
    else { 
        action = [CCAnimate actionWithAnimation:anim];
    }
    
    NSString *sprite_name = [NSString stringWithFormat:@"%@%i", name, 1];
    CCSprite *animation = [[ResourceManager sharedResourceManager] spriteWithResourceName:sprite_name];
    if (_animDictionary) {
        [_animDictionary setValue:action forKey:name];
    }
    [[[ResourceManager sharedResourceManager] spritesheet] addChild:animation];
    animation.position = _prop.position;
    animation.visible = NO;
    
    return animation;
}

-(CCSprite*) randomSpriteForDisplay
{
    if (_decoyWeight <= 0) { 
        _decoyWeight = 20;
    }
    else if (_decoyWeight >= 100) { 
        _decoyWeight = 0;
    }
    else { 
        _decoyWeight += 20;
    }
    int rand = arc4random_uniform(100);
    if (rand < _decoyWeight) { 
        _isDecoy = YES;
        return _decoy;
    }
    else { 
        _isDecoy = NO;
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

@synthesize timeDisplayed;
@synthesize bullseyeHit;

-(id) init
{
    self = [super init];
    if (self)
    {
        _prop = nil;
        _target = nil;
        _displayed = NO;
        _destroyed = NO;
        _isDecoy = NO;
        _bullseyeHit = NO;
        _decoyWeight = 0;
        _targetDirection = CGPointZero;
        self.zOrder = 0;
    }
    return self;
}

-(id) initWithProp:(CCSprite*)prop target:(BTargetSprite*)target andDecoy:(BTargetSprite*)decoy
{
    self = [super init];
    if(self)
    {
        _displayed = NO;
        _destroyed = NO;
        _isDecoy = NO;
        _bullseyeHit = NO;
        _decoyWeight = 0;
        _targetDirection = CGPointZero;
        [self setProp:prop];
        [self setDecoy:decoy];
        [self setTarget:target];
        [self loadAnimations];
    }
    return self;
}

-(void) onEnter
{
    [super onEnter];
    [[EventManager sharedEventManager] registerResponder:(Protocol<EventListener>*)self forTypeId:[TouchEvent getTypeId]];
}

-(void) dealloc
{
    if (_animDictionary)
    {
        [_animDictionary removeAllObjects];
        [_animDictionary dealloc];
        _animDictionary = nil;
    }
    if (_bullseyeAnimation)
    {
        [[[ResourceManager sharedResourceManager] spritesheet] removeChild:_bullseyeAnimation cleanup:YES];
        _bullseyeAnimation = nil;
    }
    if (_hitAnimation)
    {
        [[[ResourceManager sharedResourceManager] spritesheet] removeChild:_hitAnimation cleanup:YES];
        _hitAnimation = nil;
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

-(BOOL) isDecoy
{
    return _isDecoy;
}

-(void) processEvent:(Protocol<Event> *)event
{
    if ([event isKindOfClass:[TouchEvent class]]) {
        TouchEvent *te = (TouchEvent*)event;
        UITouch *touch = te.touch;
        CGPoint location = [[self parent] convertTouchToNodeSpace:touch];
        BTargetSprite *sprite = (_isDecoy ? _decoy : _target);
        if ([sprite doesPointCollide:location] && _animDictionary)
        {
            [_showAction stop];
            if (_isDecoy) {
                CCAction *action = [_animDictionary objectForKey:@"smiley_touch"];
                [sprite setVisible:NO];
                [_decoyAnimation setVisible:YES];
                [_decoyAnimation setPosition:location];
                [_decoyAnimation runAction:action];
                _destroyed = YES;
                id waitAction = [CCDelayTime actionWithDuration:2];
                id hideAnim = [CCMoveTo actionWithDuration:15 position:location];
                CCAction *sequence = [CCSequence actions:waitAction, hideAnim, nil];
                [_decoyAnimation runAction:sequence];
            }
            else {
                CCAction *action = nil;
                CCSprite *anim_sprite = nil;
                if ([_target isPointBullseye:location]) {
                    action = [_animDictionary objectForKey:@"be"];
                    anim_sprite = _bullseyeAnimation;
                    _bullseyeHit = YES;
                }
                else {
                    action = [_animDictionary objectForKey:@"he"]; 
                    anim_sprite = _hitAnimation;
                    anim_sprite.position = location;
                    _bullseyeHit = NO;
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
        
    }
    
}

-(void) showTargetForTime:(ccTime)time atSpeed:(float)speed
{
    BTargetSprite* sprite = (BTargetSprite*)[self randomSpriteForDisplay];
    if (sprite && !_displayed) {
        _timeDisplayed = [NSDate date];
        [_timeDisplayed retain];
        _displayed = YES;
        CGPoint direction = [self randomDirectionForSprite];
        CGPoint start = _prop.position;
        float distance = 0;
        if (direction.x == 0) { 
            if (direction.y < 0) { 
                start.y = _prop.position.y + (_prop.contentSize.height/2) + ((_prop.contentSize.height/2) + (sprite.contentSize.height/2));
            }
            else { 
                start.y = _prop.position.y - (_prop.contentSize.height/2) - ((_prop.contentSize.height/2) + (sprite.contentSize.height/2));
            }
            distance = abs(_prop.position.y - start.y);
        }
        else if (direction.x < 0) { 
            start.x = _prop.position.x + (_prop.contentSize.width/2) + ((_prop.contentSize.width/2) + (sprite.contentSize.width/2));
            distance = abs(_prop.position.x - start.x);
        }
        else { 
            start.x = _prop.position.x - (_prop.contentSize.width/2) - ((_prop.contentSize.width/2) + (sprite.contentSize.width/2));
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
