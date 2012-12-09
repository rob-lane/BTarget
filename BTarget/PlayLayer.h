//
//  PlayLayer.h
//  BTarget
//
//  Created by Robert Lane on 12/8/12.
//  Copyright 2012 Fluid Apps LLC. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface PlayLayer : CCLayer {
    CCSprite *_background;
    NSMutableDictionary *_props;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

//
-(void) addProp: (CCSprite*)node name:(NSString*)name;

-(void) fadeInPropsWithDelay: (ccTime) delay;

-(void) fadeInPropWithName: (NSString*)name withDelay:(ccTime)delay;


@end
