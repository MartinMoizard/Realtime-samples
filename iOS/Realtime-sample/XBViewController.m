//
//  XBViewController.m
//  Realtime-sample
//
//  Created by Martin Moizard on 05/01/14.
//  Copyright (c) 2014 Martin Moizard. All rights reserved.
//

#import "XBViewController.h"
#import "XBRealtimeObject.h"

@interface XBViewController ()

@end

@implementation XBViewController

- (void)dealloc
{
    [self removeRealtimeObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addRealtimeObserver];
}

#pragma mark - Observers

- (void)addRealtimeObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(realtimeMessageReceived:)
                                                 name:kXBWebSocketDidReceiveMessageNotification
                                               object:nil];
}

- (void)removeRealtimeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kXBWebSocketDidReceiveMessageNotification
                                                  object:nil];
}

- (void)realtimeMessageReceived:(NSNotification *)notification
{
    __block NSString *aMessage = notification.userInfo[kXBWebSocketMessageKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageLabel.text = aMessage;
    });
}

@end
