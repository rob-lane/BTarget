//
//  EventManager.m
//  BTarget
//
//  Created by Robert Lane on 12/10/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "EventManager.h"

@interface EventManager (hidden)
-(void) swapQueueBuffer;
@end

@implementation EventManager (hidden)
-(void) swapQueueBuffer
{
    if (_queueMap && _queueMapBuffer)
    {
        NSArray *buffer_keys = [_queueMapBuffer allKeys];
        for (id key in buffer_keys)
        {
            NSMutableArray *current_queue = [_queueMap objectForKey:key];
            NSArray *buffer_array = [_queueMapBuffer objectForKey:key];
            if (current_queue)
            {
                [current_queue addObjectsFromArray:buffer_array];
            }
            else 
            { 
                NSMutableArray *new_queue = [NSMutableArray arrayWithArray:buffer_array];
                [_queueMap setValue:new_queue forKey:key];
            }
        }
        [_queueMapBuffer removeAllObjects];
    }
}
@end


@implementation EventManager

static EventManager* _sharedEventManager;

+(EventManager*) sharedEventManager
{
    return _sharedEventManager;
}

+ (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        _sharedEventManager = [[EventManager alloc] init];
    }
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _currentQueue = 0;
        _responderMap = [[NSMutableDictionary alloc] init];
        _queueMap = [[NSMutableDictionary alloc] init];
        _queueMapBuffer = [[NSMutableDictionary alloc] init];
        _dispatching = NO;
        [self schedule:@selector(dispatch:)];
    }
    return self;
}

-(void) dealloc
{
    if (_responderMap)
    {
        [_responderMap removeAllObjects];
        [_responderMap release];
        _responderMap = nil;
    }
    if (_queueMap)
    {
        [_queueMap removeAllObjects];
        [_queueMap release];
        _queueMap = nil;
    }
    if (_queueMapBuffer)
    {
        [_queueMapBuffer removeAllObjects];
        [_queueMapBuffer release];
        _queueMap = nil;
    }
}

-(void) queueEvent:(Protocol<Event> *)event
{
    id queueType = [event getType];
    NSMutableDictionary *queue_lookup = (_dispatching ? _queueMapBuffer : _queueMap);
    NSMutableArray *queue = [queue_lookup objectForKey:queueType];
    if (queue == nil)
    {
        queue = [NSMutableArray arrayWithObject:event];
        [queue_lookup setValue:queue forKey:queueType];
    }
    
    [queue addObject:event];
    
}

-(void) registerResponder:(Protocol<EventListener> *)listener forTypeId:(id)typeId
{
    NSMutableArray *responder_array = nil;
    if (_responderMap.count <= 0) {
        responder_array = [NSMutableArray array];
    }
    else { 
        responder_array = [_responderMap objectForKey:typeId];
        if (!responder_array) { 
            responder_array = [NSMutableArray array];
        }
    }
    
    if (responder_array && responder_array.count <= 0) {
        [_responderMap setValue:responder_array forKey:typeId];
    }
    [responder_array addObject:listener];
}

-(BOOL) isDispatching
{
    return _dispatching;
}

-(void) dispatch: (ccTime) dt
{
    if (!_dispatching) { 
        _dispatching = YES;
        NSArray* event_types = [_queueMap allKeys];
        uint events_processed = 0;
        BOOL stop_dispatch = NO;
        for (id key in event_types)
        {
            NSArray *responder_array = [_responderMap objectForKey:key];
            NSMutableArray *queue = [_queueMap objectForKey:key];
            NSArray *queue_copy = [NSArray arrayWithArray:queue];
            
            for (Event *event in queue_copy)
            {
                for (EventListener *listener in responder_array)
                {
                    [listener processEvent:event];
                }
                [queue removeObject:event];
                
                if (++events_processed >= _maxDispatchPerFrame)
                {
                    stop_dispatch = YES;
                    break;
                }
            }
            if (stop_dispatch)
            {
                break;
            }
        }
        if (_queueMapBuffer && _queueMapBuffer.count > 0)
        {
            [self swapQueueBuffer];
        }
        _dispatching = NO;
    }
}

@end


/* Event classes */
@implementation PlayerEvent

@synthesize pointDelta=_pointDelta;
@synthesize lifeDelta=_lifeDelta;

-(id) getType
{
    return [PlayerEvent getTypeId];
}

+(id) getTypeId
{
    return (id)[NSString stringWithString:@"player"];
}

@end

@implementation TouchEvent

@synthesize touch;
@synthesize event;
@synthesize started;

-(id) getType
{
    return [TouchEvent getTypeId];
}

+(id) getTypeId { 
    return (id)[NSString stringWithString:@"touch"];
}

@end

@implementation TargetEvent

@synthesize destroyed;
@synthesize animating;
@synthesize decoy;
@synthesize bullseye;

-(id) getType
{
    return [TargetEvent getTypeId];
}

+(id) getTypeId {
    return (id)[NSString stringWithFormat:@"touch"];
}


@end


