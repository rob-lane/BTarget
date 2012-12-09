//
//  Player.m
//  CocosFirst
//
//  Created by Robert Lane on 12/8/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize lives=_lives;
@synthesize points=_points;

-(id) init 
{ 
    self = [super init];
    if (self) {
        _lives = 3;
        _points = 0;
    }
    return self;
}

@end
