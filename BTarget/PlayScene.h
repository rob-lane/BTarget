//
//  PlayScene.h
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import "TargetLayer.h"
#import "TouchLayer.h"

@interface PlayScene : CCScene {
    NSMutableArray *_targetAreas;
    NSMutableArray *_displayedTargets;
    Player *_player;
    CCSprite *_bg;
    uint _targetSpeed;
    uint _targetLife;
    uint _targetsAtOnce;
    TouchLayer *_touchLayer;
}

-(void) buildLevel:(NSString*) levelFile;

-(void) displayTarget;

@end
