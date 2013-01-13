//
//  Player.m
//  CocosFirst
//
//  Created by Robert Lane on 12/8/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import "Player.h"
#import "ResourceManager.h"

@implementation Player

@synthesize lives=_lives;
@synthesize points=_points;

-(id) init 
{ 
    self = [super init];
    if (self) {
        _lives = 3;
        _points = 0;
        [[EventManager sharedEventManager] registerResponder:(Protocol<EventListener>*)self forTypeId:[PlayerEvent getTypeId]];
    }
    return self;
}

-(void) onEnter
{
    if (_lifeIcons == nil)
    {
        _lifeIcons = [[NSMutableArray alloc] init];
    }
    else { 
        [_lifeIcons removeAllObjects];
    }
    
    CCSprite* life_sprite = [[ResourceManager sharedResourceManager] spriteWithResourceName:@"life1"];
    self.position = CGPointMake( (life_sprite.contentSize.width/2) * _lives, life_sprite.contentSize.height/2);
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for(int i = 0; i < _lives; i++)
    {
        CCSprite* life_sprite = [[ResourceManager sharedResourceManager] spriteWithResourceName:@"life1"];
        [self addChild:life_sprite];
        life_sprite.position = CGPointMake((life_sprite.contentSize.width)*i + ((life_sprite.contentSize.width * 0.15)*i), (winSize.height - life_sprite.contentSize.height) );
        [_lifeIcons addObject:life_sprite];
    }
    
    if (_scoreLabel == nil)
    {
        _scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", _points] fntFile:@"Roughage.fnt"];
    }
    else { 
        _scoreLabel.string = [NSString stringWithFormat:@"%i", _points];
    }
    _scoreLabel.position = CGPointMake(winSize.width-(_scoreLabel.contentSize.width*2), winSize.height-_scoreLabel.contentSize.height/1.3);

    [_scoreLabel setAlignment:kCCTextAlignmentRight];
    [self addChild:_scoreLabel];
}

-(void) dealloc
{
    if (_scoreLabel)
    {
        [self removeChild:_scoreLabel cleanup:YES];
        _scoreLabel = nil;
    }
}

-(void) processEvent:(Protocol<Event> *)event
{
    if ([event isKindOfClass:[PlayerEvent class]]) {
        PlayerEvent *pe = (PlayerEvent*)event;
        int newLife = _lives + pe.lifeDelta;
        
        if (newLife > 0) { 
            _points += pe.pointDelta;
            _lives = newLife;
        }
        else { 
            _lives = 0;
        }
        
        if (_lives < [_lifeIcons count]) { 
            int diff = [_lifeIcons count] - _lives;
            while (diff > 0) { 
                diff--;
                CCSprite *sprite = [_lifeIcons objectAtIndex:[_lifeIcons count]-1];
                sprite.visible = NO;
                [_lifeIcons removeObject:sprite];
            }
        }
        [_scoreLabel setString:[NSString stringWithFormat:@"%i", _points]];
    }   
}

@end
