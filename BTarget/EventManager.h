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
@end

@interface EventManager : CCNode {
    NSMutableDictionary *_responderMap;
    //_queueMap[(NSNumber*)queueNumber][NSDictionary*][(id)queueType][(NSMutableArray*)eventArray]
    NSMutableDictionary *_queueMap;
    uint _currentQueue;
    uint _queueSize;
    BOOL _dispatching;
}

-(void) queueEvent:(Protocol<Event>*)event;

-(BOOL) isDispatching;

+ (id)sharedManager;

@end
