//
//  TouchLayer.m
//  BTarget
//
//  Created by Robert Lane on 12/28/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "TouchLayer.h"

@implementation TouchEvent

@synthesize touch;
@synthesize event;
@synthesize started;

+(id) getType { 
    return (id)[NSString stringWithString:@"touch"];
}

-(id) getType {
    return [TouchEvent getType];
}

@end

@interface TouchLayer (hidden)

-(Protocol<Event>*) eventWithTouch:(UITouch*)touch andUIEvent:(UIEvent*)event isEnding:(BOOL)ending; 

@end

@implementation TouchLayer (hidden)

-(Protocol<Event>*) eventWithTouch:(UITouch*)touch andUIEvent:(UIEvent*)event isEnding:(BOOL)ending 
{
    TouchEvent *te = [[TouchEvent alloc] init];
    te.started = !(ending);
    te.touch = touch;
    te.event = event;
    
    return (Protocol<Event>*)te;
}

@end
    


@implementation TouchLayer

-(id) init 
{
    self = [super init];
    if (self) {
        self.isTouchEnabled = YES;
    }
    return self;
}


-(void) registerWithTouchDispatcher
{
    CCTouchDispatcher *sharedDispatcher = [[CCDirector sharedDirector] touchDispatcher];
    [sharedDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    Protocol<Event>* touch_event = [self eventWithTouch:touch andUIEvent:event isEnding:NO];
    [[EventManager sharedEventManager] queueEvent:touch_event];
    
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    Protocol<Event>* touch_event = [self eventWithTouch:touch andUIEvent:event isEnding:YES];
    [[EventManager sharedEventManager] queueEvent:touch_event];
}
    

@end
