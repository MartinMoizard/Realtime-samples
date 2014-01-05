//
//  XBRealtimeObject.m
//  Realtime-sample
//
//  Created by Martin Moizard on 05/01/14.
//  Copyright (c) 2014 Martin Moizard. All rights reserved.
//

#import "XBRealtimeObject.h"

#import <Reachability/Reachability.h>
#import <SocketRocket/SRWebSocket.h>

NSString * const kXBWebSocketRawUrl = @"http://realtime-server.martinmoizard.cloudbees.net/ws/websocket";
NSString * const kXBWebSocketDidReceiveMessageNotification = @"kXBWebSocketDidReceiveMessageNotification";
NSString * const kXBWebSocketMessageKey = @"kXBWebSocketMessageKey";

static CGFloat XBWebSocketMaximumReconnectionDelay = 30.0f;

@interface XBRealtimeObject()

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, assign) CGFloat retryTimeInterval;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation XBRealtimeObject

- (id)init
{
    self = [super init];
    if (self) {
        [self connect:YES];
        [self registerForReachabilityChanges];
    }
    return self;
}

- (void)dealloc
{
    self.webSocket.delegate = nil;
    [self.webSocket close];
    
    [self.reachability stopNotifier];
    self.reachability = nil;
}

- (void)open
{
    BOOL socketAlreadyOpened = (self.webSocket != nil) && ((self.webSocket.readyState == SR_OPEN)
                                                           || (SR_CONNECTING == self.webSocket.readyState));
    
    // We should not try to open a socket if one is already opened or connecting
    if (!socketAlreadyOpened) {
        if (self.webSocket && self.webSocket.readyState == SR_OPEN) {
            [self.webSocket close];
        }
        
        self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:kXBWebSocketRawUrl]];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}

- (void)connect:(BOOL)force
{
    // If we want to force a connection, let's try to connect without any delay
	if (force) {
		self.retryTimeInterval = 0;
	} else {
        // Otherwise, let's increase the retry time interval
		self.retryTimeInterval = (self.retryTimeInterval >= 0.1 ? self.retryTimeInterval * 2 : 0.1);
		self.retryTimeInterval = MIN(XBWebSocketMaximumReconnectionDelay, self.retryTimeInterval);
	}
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.retryTimeInterval * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
                       [self open];
                   });
}

#pragma mark - Websocket delegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *aMessage = message; // In this example, message is a string
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXBWebSocketDidReceiveMessageNotification
                                                        object:self
                                                      userInfo:@{kXBWebSocketMessageKey : aMessage}];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen : %@", webSocket);
    
	self.retryTimeInterval = 0;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"webSocket:didFailWithError : %@", error);
    
    // If the websocket failed to connect, let's try again (delayed reconnection)
    [self connect:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"webSocket:didCloseWithCode : %i reason : %@", code, reason);
    
    [self connect:NO];
}

#pragma mark - Reachability

- (void)registerForReachabilityChanges
{
    __weak XBRealtimeObject *weakSelf = self;
    self.reachability = [Reachability reachabilityWithHostname:kXBWebSocketRawUrl];
    
    // In case the connection was lost and established again, we need to try to reopen the websocket ASAP
    self.reachability.reachableBlock = ^(Reachability *r) {
        [weakSelf connect:YES];
    };
    
    [self.reachability startNotifier];
}

@end
