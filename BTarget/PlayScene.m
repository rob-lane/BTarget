//
//  PlayScene.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "PlayScene.h"
#import "PropertyList.h"

@interface PlayScene (hidden)
-(void) buildLevelFromDictionary:(NSDictionary*) levelCfg;
-(void) buildBG:(NSString*)bgFile;
-(void) buildTargetAreaFromDictionary:(NSDictionary*) areaCfg;
-(void) buildSpritesheet;
@end

@implementation PlayScene (hidden)

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
        BTargetSprite *target = [[BTargetSprite alloc] initWithFile:str_buffer];
        
        str_buffer = (NSString*)[areaCfg objectForKey:@"DecoyImage"];
        BTargetSprite *decoy = [[BTargetSprite alloc] initWithFile:str_buffer];
        
        str_buffer = (NSString*)[areaCfg objectForKey:@"PropImage"];
        CCSprite *prop = [[CCSprite alloc] initWithFile:str_buffer];
        
        CGPoint position = CGPointZero;
        NSNumber *num_buffer = (NSNumber*)[areaCfg objectForKey:@"X"];
        position.x = num_buffer.intValue;
        num_buffer = (NSNumber*)[areaCfg objectForKey:@"Y"];
        position.y = num_buffer.intValue;
        
        [prop setPosition:position];
        int targetY = position.y-(prop.contentSize.height/2) - ((prop.contentSize.height/2) + (target.contentSize.height/2));
        CGPoint targetPosition = ccp(position.x, targetY);
        [target setPosition:targetPosition];
        //[target setPosition:position];
        
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
        TargetLayer* layer = [[TargetLayer alloc] initWithProp:prop target:target decoy:decoy andSpritesheet:_spriteSheet];
        [layer setZOrder:0];
        [self addChild:layer];
        if (_targetAreas == nil)
        {
            _targetAreas = [[NSMutableArray alloc] init];
        }
        [_targetAreas addObject:layer];
    }
}

-(void) buildSpritesheet
{
    _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"Animations.png"];
    [_spriteSheet setZOrder:1];
    [self addChild:_spriteSheet];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations.plist" texture:_spriteSheet.texture];
}

@end


@implementation PlayScene

-(void) onEnter
{
    [super onEnter];
    [self buildSpritesheet];
    [self buildLevel:@"level1"];
    [self schedule:@selector(displayTarget)];
    [self schedule:@selector(checkTarget)];
    
}

-(void) buildLevel:(NSString *)levelFile
{
    PropertyList *plist = [PropertyList PropertyListWithFile:levelFile];
    NSMutableDictionary *levelCfg = [[NSMutableDictionary alloc] initWithDictionary:[plist readData]];
    [self buildLevelFromDictionary:levelCfg];
}

-(CCSpriteBatchNode*) getSpritesheet
{
    return _spriteSheet;
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
