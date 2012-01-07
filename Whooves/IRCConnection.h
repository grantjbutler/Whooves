//
//  IRCConnection.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "IRCMessage.h"

@class IRCConnection;

@protocol IRCConnectionDelegate <NSObject>

@optional
- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message;
- (void)connectionDidConnectToServer:(IRCConnection *)connection;

@end

@interface IRCConnection : NSObject <GCDAsyncSocketDelegate>

@property (strong, readonly) GCDAsyncSocket *socket;

@property (weak) id<IRCConnectionDelegate> delegate;

- (BOOL)connectToHost:(NSString *)host port:(NSUInteger)port error:(NSError **)error;
- (void)write:(NSString *)string;

@end
