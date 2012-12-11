//
//  Target.h
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Target : CCSprite {
    CGRect _mask;
}
-(void) setMask:(CGRect)mask;
-(CGRect) getMask;

@property (assign) BOOL enableMask;

@end
