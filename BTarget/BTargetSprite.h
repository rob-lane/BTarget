//
//  BTargetSprite.h
//  BTarget
//
//  Created by Robert Lane on 12/22/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BTargetSprite : CCSprite 

-(BOOL) doesPointCollide:(CGPoint) point;
-(BOOL) isPointBullseye:(CGPoint) point;

@property (assign) BOOL enableMask;
@property (assign) CGRect mask;
@property (assign) CGPoint slideDirection;


@end
