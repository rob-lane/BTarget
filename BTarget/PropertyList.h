//
//  PropertyList.h
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyList : NSObject { 
    NSString *_fileName;
}

@property (readonly) NSMutableDictionary* data;

+(PropertyList*) PropertyListWithFile:(NSString*) fileName;

-(NSDictionary*) readData;
-(NSDictionary*) readDataWithFile:(NSString*) fileName;

-(void) writeData;
-(void) writeDataWithFile:(NSString*) fileName;

@end
