//
//  Player.h
//  CocosFirst
//
//  Created by Robert Lane on 12/8/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EventManager.h"

@interface Player : CCLayer <EventListener> { 
    NSMutableArray* _lifeIcons;
    CCLabelBMFont* _scoreLabel;
}

@property (readonly) int lives;
@property (readonly) int points;

@end
