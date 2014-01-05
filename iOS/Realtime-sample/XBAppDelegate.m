//
//  XBAppDelegate.m
//  Realtime-sample
//
//  Created by Martin Moizard on 05/01/14.
//  Copyright (c) 2014 Martin Moizard. All rights reserved.
//

#import "XBAppDelegate.h"
#import "XBRealtimeObject.h"

@interface XBAppDelegate()

@property (nonatomic, strong) XBRealtimeObject *realTimeObject;

@end

@implementation XBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.realTimeObject = [[XBRealtimeObject alloc] init];
    
    return YES;
}

@end
