//
//  XBRealtimeObject.h
//  Realtime-sample
//
//  Created by Martin Moizard on 05/01/14.
//  Copyright (c) 2014 Martin Moizard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRWebSocketDelegate;

extern NSString * const kXBWebSocketDidReceiveMessageNotification;
extern NSString * const kXBWebSocketMessageKey;

@interface XBRealtimeObject : NSObject<SRWebSocketDelegate>

@end
