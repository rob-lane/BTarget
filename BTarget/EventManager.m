//
//  EventManager.m
//  BTarget
//
//  Created by Robert Lane on 12/10/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "EventManager.h"

@interface EventManager (hidden)
-(void) dispatchEvents;
-(NSMutableDictionary*)_newQueue:(id)event;
@end

@implementation EventManager (hidden)

-(void) dispatchEvents
{

}

-(NSMutableDictionary*)_newQueue:(id)event
{
    NSMutableArray *queue = [NSMutableArray arrayWithObject:event];
    return [NSMutableDictionary dictionaryWithObject:queue forKey:[event getType] ];
}

@end


@implementation EventManager

+(id) sharedManager
{
    static EventManager *sharedEventManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventManager = [[self alloc ] init];
    });
    return sharedEventManager;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _queueSize = 30;
        _currentQueue = 0;
        _responderMap = [[NSMutableDictionary alloc] init];
        _queueMap = [[NSMutableDictionary alloc] init];
        _dispatching = NO;
    }
    return self;
}

-(void) queueEvent:(Protocol<Event> *)event
{
    id queueType = [event getType];
    NSMutableDictionary *queue_lookup = nil;
    
    int current_queue = (_dispatching) ? _currentQueue+1 : _currentQueue;
    NSString *queue_index = [NSString stringWithFormat:@"%i", current_queue];
    
    if (_queueMap.count > 0)
    {
        queue_lookup = [_queueMap objectForKey:queue_index];
        if (queue_lookup && _queueMap.count >= _queueSize)
        {
            queue_index = [NSString stringWithFormat:@"%i", (current_queue+1)];
            queue_lookup = [_queueMap objectForKey:queue_index];
            if (queue_lookup)
            {
                [queue_lookup removeAllObjects];
                NSMutableArray *queue = [NSMutableArray arrayWithObject:event];
                [queue_lookup setValue:queue forKey:queueType];
            }
        }
    }
    
    if (queue_lookup == nil)
    {
        [_queueMap setValue:[self _newQueue:event] forKey:queue_index];
    }
    else
    {
        NSMutableArray *queue = [NSMutableArray arrayWithObject:event];
        [queue_lookup setValue:queue forKey:queueType];   
    }
}

-(BOOL) isDispatching
{
    return _dispatching;
}
@end
