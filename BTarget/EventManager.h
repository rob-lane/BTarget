//
//  EventManager.h
//  BTarget
//
//  Created by Robert Lane on 12/10/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol Event <NSObject>
@required
-(id) getType;
+(id) getTypeId;
@end

@protocol EventListener <NSObject>
@required
-(void) processEvent:(Protocol<Event>*)event;
@end

typedef Protocol<Event> Event;
typedef Protocol<EventListener> EventListener;

@interface EventManager : CCNode {
    NSMutableDictionary *_responderMap;
    NSMutableDictionary *_queueMap;
    NSMutableDictionary *_queueMapBuffer;
    uint _currentQueue;
    BOOL _dispatching;
    
    //Tweak these for performance of the event manager (not an implicitly performance heavy object).
    uint _maxDispatchPerFrame;
}

-(void) queueEvent:(Protocol<Event>*)event;

-(void) registerResponder:(Protocol<EventListener>*)listener forTypeId:(id) typeId;

-(BOOL) isDispatching;

+(EventManager*) sharedEventManager;

-(void) dispatch:(ccTime)dt;

@end

/* Event classes */
@interface PlayerEvent : NSObject <Event>

@property (assign) int pointDelta;
@property (assign) int lifeDelta;

@end

@interface TouchEvent : NSObject <Event> 

@property (nonatomic, retain) UITouch *touch;
@property (nonatomic, retain) UIEvent *event;
@property (assign) BOOL started;

@end

