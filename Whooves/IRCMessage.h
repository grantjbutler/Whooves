//
//  IRCMessage.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WHTag.h"

@interface IRCMessage : NSObject

@property (strong, readonly) NSString *prefix;
@property (strong, readonly) NSString *command;
@property (strong, readonly) NSArray *args;

@property (strong, readonly) NSString *nick;
@property (strong, readonly) NSString *channel;

@property (strong, readonly) NSString *messageTarget;
@property (strong, readonly) NSString *responseTarget;

@property (strong, readonly) NSString *message;
@property (strong, readonly) NSArray *messageComponents;

@property (strong, readonly) NSArray *tags;

@property (assign, readonly) BOOL senderIsOp;
@property (assign, readonly) BOOL senderIsOwner;

@property (readonly, getter = isNumeric) BOOL numeric;

- (id)initWithString:(NSString *)string;

@end
