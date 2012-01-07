//
//  IRCConnection.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

@interface IRCConnection : NSObject

@property (strong, readonly) GCDAsyncSocket *socket;

@end
