//
//  PlayScene.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "PlayScene.h"
#import "PropertyList.h"
#import "ResourceManager.h"

@interface PlayScene (hidden)
-(void) buildPlayer;
-(void) buildLevelFromDictionary:(NSDictionary*) levelCfg;
-(void) buildBG:(NSString*)bgFile;
-(void) buildTargetAreaFromDictionary:(NSDictionary*) areaCfg;
@end

@implementation PlayScene (hidden)
-(void) buildPlayer
{
    if (_player == nil)
    {
        _player = [[Player alloc] init];
    }
    [self addChild:_player];
    [_player setZOrder:3];
}

-(void) buildLevelFromDictionary:(NSDictionary *)levelCfg
{
    
    for (NSString *key in levelCfg)
    {
        if ([key compare:@"Background"] == NSOrderedSame)
        {
            [self buildBG:(NSString*)[levelCfg objectForKey:key]];
        }
        else if ([key compare:@"TargetsAtOnce"] == NSOrderedSame)
        {
            NSNumber *value = (NSNumber*)[levelCfg objectForKey:key];
            _targetsAtOnce = value.intValue;
        }
        else if ([key compare:@"TargetSpeed"] == NSOrderedSame)
        {
            NSNumber *value = (NSNumber*)[levelCfg objectForKey:key];
            _targetSpeed = value.intValue;
        }
        else if ([key compare:@"TargetLife"] == NSOrderedSame)
        {
            NSNumber *value = (NSNumber*)[levelCfg objectForKey:key];
            _targetLife = value.intValue;
        }
        else if ([key compare:@"TargetLayers"] == NSOrderedSame)
        {
            NSArray *layers = (NSArray*)[levelCfg objectForKey:key];
            for (NSDictionary *cfg in layers)
            {
                [self buildTargetAreaFromDictionary:cfg];
            }
        }
        else if ([key compare:@"BullseyeMaxValue"] == NSOrderedSame)
        {
            NSNumber *value = (NSNumber*)[levelCfg objectForKey:key];
            _maxBullseyeValue = value.intValue;
        }
        else if ([key compare:@"TargetMaxValue"] == NSOrderedSame)
        {
            NSNumber *value = (NSNumber*)[levelCfg objectForKey:key];
            _maxTargetValue = value.intValue;
        }
    }
}

-(void) buildBG:(NSString*)bgFile
{
    if (_bg)
    {
        [self removeChild:_bg cleanup:YES];
        [_bg release];
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _bg = [CCSprite spriteWithFile:bgFile];
    _bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_bg];
}

-(void) buildTargetAreaFromDictionary:(NSDictionary*) areaCfg
{
    if (areaCfg)
    {
        NSString *str_buffer = (NSString*)[areaCfg objectForKey:@"TargetImage"];
        CCSpriteFrame *frame_buffer = [[ResourceManager sharedResourceManager] spriteFrameWithResourceName:str_buffer];
        BTargetSprite *target = [BTargetSprite spriteWithSpriteFrame:frame_buffer];
        
        str_buffer = (NSString*)[areaCfg objectForKey:@"DecoyImage"];
        frame_buffer = [[ResourceManager sharedResourceManager] spriteFrameWithResourceName:str_buffer];
        BTargetSprite *decoy = [BTargetSprite spriteWithSpriteFrame:frame_buffer];
        
        str_buffer = (NSString*)[areaCfg objectForKey:@"PropImage"];
        CCSprite *prop = [[ResourceManager sharedResourceManager] spriteWithResourceName:str_buffer];
        
        CGPoint position = CGPointZero;
        NSNumber *num_buffer = (NSNumber*)[areaCfg objectForKey:@"X"];
        position.x = num_buffer.intValue;
        num_buffer = (NSNumber*)[areaCfg objectForKey:@"Y"];
        position.y = num_buffer.intValue;
        
        [prop setPosition:position];
        int targetY = position.y-(prop.contentSize.height/2) - ((prop.contentSize.height/2) + (target.contentSize.height/2));
        CGPoint targetPosition = ccp(position.x, targetY);
        [target setPosition:targetPosition];
        [decoy setPosition:targetPosition];
        
        CGRect margin = CGRectZero;
        NSDictionary *margin_cfg = [areaCfg objectForKey:@"Margin"];
        num_buffer = (NSNumber*)[margin_cfg objectForKey:@"X"];
        margin.origin.x = num_buffer.intValue;
        num_buffer = (NSNumber*)[margin_cfg objectForKey:@"Y"];
        margin.origin.y = num_buffer.intValue;
        num_buffer = (NSNumber*)[margin_cfg objectForKey:@"Width"];
        margin.size.width = num_buffer.intValue;
        num_buffer = (NSNumber*)[margin_cfg objectForKey:@"Height"];
        margin.size.height = num_buffer.intValue;
        
        int maskX = position.x - (prop.contentSize.width/2)+(margin.origin.x);
        int maskY = position.y - (prop.contentSize.height/2)+(margin.origin.y);
        CGRect mask = CGRectMake(maskX, maskY, (prop.contentSize.width-margin.size.width), 
                                 (prop.contentSize.height-margin.size.height) );
        [target setMask:mask];
        [target setEnableMask:YES];
        [decoy setMask:mask];
        [decoy setEnableMask:YES];
        TargetLayer* layer = [[TargetLayer alloc] initWithProp:prop target:target andDecoy:decoy];
        [self addChild:layer];
        [layer setZOrder:0];
        if (_targetAreas == nil)
        {
            _targetAreas = [[NSMutableArray alloc] init];
        }
        [_targetAreas addObject:layer];
    }
}

@end


@implementation PlayScene

-(void) onEnter
{
    [super onEnter];
    [self addChild:[ResourceManager sharedResourceManager]];
    [self buildPlayer];
    [self buildLevel:@"level1"];
    [self schedule:@selector(displayTarget)];
    [self schedule:@selector(checkTarget)];
    _touchLayer = [[TouchLayer alloc] init];
    [self addChild:_touchLayer];
    [self addChild:[EventManager sharedEventManager]];
}

-(void) buildLevel:(NSString *)levelFile
{
    PropertyList *plist = [PropertyList PropertyListWithFile:levelFile];
    NSMutableDictionary *levelCfg = [[NSMutableDictionary alloc] initWithDictionary:[plist readData]];
    [self buildLevelFromDictionary:levelCfg];
}

-(void) dealloc
{
    if (_targetAreas && [_targetAreas count] > 0)
    {
        for (TargetLayer* layer in _targetAreas)
        {
            [self removeChild:layer cleanup:YES];
            [layer release];
        }
        [_targetAreas removeAllObjects];
    }
    if (_touchLayer)
    {
        [self removeChild:_touchLayer cleanup:YES];
        _touchLayer = nil;
    }
    [super dealloc];
}

-(void) displayTarget
{
    if ( (_displayedTargets == nil || [_displayedTargets count] < _targetsAtOnce)
        && (_targetAreas.count > 0) )
    {
        if (_displayedTargets == nil)
        {
            _displayedTargets = [[NSMutableArray alloc] init];
        }
        uint targetIndex = arc4random_uniform([_targetAreas count]);
        TargetLayer *tl = [_targetAreas objectAtIndex:targetIndex];
        [tl showTargetForTime:_targetLife atSpeed:_targetSpeed];
        [_displayedTargets addObject:tl];
    }
}

-(void) checkTarget
{
    NSMutableArray *old_tls = [NSMutableArray array];
    if (_displayedTargets && [_displayedTargets count] > 0)
    {
        for (TargetLayer *tl in _displayedTargets)
        {
            if (tl.isDisplayed == NO)
            {
                [old_tls addObject:tl];
            }
            else if (tl.isDestroyed == YES)
            {
                PlayerEvent *event = [[PlayerEvent alloc] init];
                if (tl.isDecoy) {
                    event.lifeDelta -= 0;
                }
                else {
                    NSTimeInterval timeDiff = [tl.timeDisplayed timeIntervalSinceNow];
                    if (tl.bullseyeHit) { 
                        event.pointDelta = _maxBullseyeValue - (timeDiff * _maxBullseyeValue);
                    }
                    else { 
                        event.pointDelta = _maxTargetValue - (timeDiff * _maxTargetValue);
                    }
                }
                [[EventManager sharedEventManager] queueEvent:(Protocol<Event>*)event];
                [old_tls addObject:tl];
            }
        }
        if ( [old_tls count] > 0)
        {
            for (TargetLayer *tl in old_tls)
            {
                [_displayedTargets removeObject:tl];
                if ( tl.isDestroyed )
                {
                    [_targetAreas removeObject:tl];
                }
            }
        }
    }
}

@end
