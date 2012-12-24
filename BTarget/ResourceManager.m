//
//  ResourceManager.m
//  BTarget
//
//  Created by Robert Lane on 12/24/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import "ResourceManager.h"

@implementation ResourceManager

static ResourceManager* _sharedResourceManager;

+(ResourceManager*) sharedResourceManager 
{ 
    return _sharedResourceManager;
}

+ (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        _sharedResourceManager = [[ResourceManager alloc] init];
    }
}

@end
