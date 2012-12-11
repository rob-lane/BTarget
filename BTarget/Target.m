//
//  Target.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "Target.h"


@implementation Target

@synthesize enableMask=_enableMask;

-(void) setMask:(CGRect)mask
{/*
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    switch(orientation) {
        case UIInterfaceOrientationLandscapeLeft: 
        {
            float tmp = mask.origin.x;
            mask.origin.x = mask.origin.y;
            mask.origin.y = winSize.width-mask.size.width-tmp;
            tmp = mask.size.width;
            mask.size.width = mask.size.height;
            mask.size.height = tmp;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            float tmp = mask.origin.y;
            mask.origin.y = mask.origin.x;
            mask.origin.x = winSize.height-mask.size.height-tmp;
            tmp = mask.size.width;
            mask.size.width = mask.size.height;
            mask.size.height = tmp;
        }
            break;
        default:
            break;       
    }*/
    _mask = mask;
}

-(CGRect) getMask
{
    return _mask;
}

-(void) draw
{
    if (_enableMask)
    {
        glEnable(GL_SCISSOR_TEST);
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float x = _mask.origin.x;
        float y = _mask.origin.y;
        float w = _mask.size.width;
        float h = _mask.size.height;
        glScissor(x, y, w, h);
        [super draw];
        glDisable(GL_SCISSOR_TEST);
        
    }
    else { 
        [super draw];
    }
}

@end
