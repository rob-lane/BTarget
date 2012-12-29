//
//  TouchLayer.h
//  BTarget
//
//  Created by Robert Lane on 12/28/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EventManager.h"

@interface TouchEvent : NSObject <Event> 

@property (nonatomic, retain) UITouch *touch;
@property (nonatomic, retain) UIEvent *event;
@property (assign) BOOL started;

+(id) getType;

@end

@interface TouchLayer : CCLayer {
    
}

@end
