//
//  BTargetSprite.m
//  BTarget
//
//  Created by Robert Lane on 12/22/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import "BTargetSprite.h"


@implementation BTargetSprite

@synthesize enableMask=_enableMask;
@synthesize mask=_mask;
@synthesize slideDirection=_slideDirection;

-(BOOL) doesPointCollide:(CGPoint) point
{
    CGPoint center = self.position;
    float radius = self.contentSize.width/2;
    
    return pow(point.x - center.x, 2) + pow(point.y - center.y, 2) < pow(radius, 2);
}

-(BOOL) isPointBullseye:(CGPoint)point
{
    CGPoint center = self.position;
    return( (point.x >= (center.x-10) && point.x <= (center.x+10)) &&
           (point.y >= (center.y-10) && point.y <= (center.y+10)) );
}

-(void) draw
{
    if (_enableMask)
    {
        glEnable(GL_SCISSOR_TEST);
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
