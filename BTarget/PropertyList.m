//
//  PropertyList.m
//  BTarget
//
//  Created by Robert Lane on 12/9/12.
//  Copyright (c) 2012 Fluid Apps LLC. All rights reserved.
//

#import "PropertyList.h"

@interface PropertyList (hidden)
-(NSDictionary*) readPropertyListData:(NSData*)listData;
@end

@implementation PropertyList (hidden)

-(NSDictionary*) readPropertyListData:(NSData *)listData
{
    NSString *error;
    NSPropertyListFormat format;
    NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:listData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
    if (plist == nil)
    {
        NSException *ex = [NSException exceptionWithName:@"Cant read property list" reason:error userInfo:nil];
        @throw ex;
    }
    return plist;
}

@end

@implementation PropertyList

@synthesize data=_data;

-(id) initWithFile:(NSString*) fileName
{
    self = [super init];
    if (self)
    {
        _fileName = fileName;
    }
    return self;
}

+(PropertyList*) PropertyListWithFile:(NSString *)fileName
{
    PropertyList* plist = [[PropertyList alloc] initWithFile:fileName];
    return plist;
}

-(NSDictionary*) readData
{
    if (_fileName != nil)
    {
        return [self readDataWithFile:_fileName];
    }
    else 
    { 
        NSException *ex = [NSException exceptionWithName:@"Cant read property list" reason:@"Property list object has not file name set..." userInfo:nil];
        @throw ex;
    }
}

-(NSDictionary*) readDataWithFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    if (filePath)
    {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData)
        {
            if (_data)
            {
                [_data removeAllObjects];
                [_data release];
            }
            _data = [[NSMutableDictionary alloc] initWithDictionary:[self readPropertyListData:fileData]];

        }
        else
        {
            NSString *errorName = [NSString stringWithFormat:@"Cant read property list '%@'", fileName];
            NSString *error = [NSString stringWithFormat:@"Data from '%@' returned nil", filePath];
            NSException *ex = [NSException exceptionWithName:errorName reason:error userInfo:nil];
            @throw ex;
        }
    }
    else
    {
        NSString *errorName = [NSString stringWithFormat:@"Cant read property list '%@'", fileName];
        NSString *error = [NSString stringWithFormat:@"No resource found for file name '%@'", fileName];
        NSException *ex = [NSException exceptionWithName:errorName reason:error userInfo:nil];
        @throw ex;
    }
    return _data;
}

-(void) writeData
{
    if (_fileName != nil)
    {
        [self writeDataWithFile:_fileName];
    }
    else 
    {
        NSException *ex = [NSException exceptionWithName:@"Cant write property list" reason:@"Missing filename attribute" userInfo: nil];
        @throw ex;
    }
}

-(void) writeDataWithFile:(NSString *)fileName
{
    if (_data != nil)
    {
        NSString *error;
        NSData *plistBuffer = [NSPropertyListSerialization dataFromPropertyList:_data format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
        if (plistBuffer)
        {
            NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
            if (![plistBuffer writeToFile:filePath atomically:YES] )
            {
                NSString *errorName = [NSString stringWithFormat:@"Cant write property list file '%@'", fileName];
                NSString *error = [NSString stringWithFormat:
                                   @"Write funciton returned false for path '%@'", filePath];
                NSException *ex = [NSException exceptionWithName:errorName reason:error userInfo:nil];
                @throw ex;
            }
        }
    }
    else
    {
        NSString *errorName = [NSString stringWithFormat:@"Cant write property list file '%@'", fileName];
        NSException *ex = [NSException exceptionWithName:errorName reason:@"No data available to write..." userInfo:nil];
        @throw ex;
    }

}

@end
