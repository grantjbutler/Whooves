//
//  IRCBot.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRCConnection.h"

@interface IRCBot : NSObject <IRCConnectionDelegate>

@property (strong, readonly) IRCConnection *connection;

@property (strong) NSString *user;
@property (strong) NSString *nick;
@property (strong) NSString *pass;

- (void)connectToHost:(NSString *)host port:(NSUInteger)port;

@end
