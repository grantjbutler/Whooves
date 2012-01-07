//
//  IRCMessage.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRCMessage : NSObject

@property (strong, readonly) NSString *prefix;
@property (strong, readonly) NSString *command;
@property (strong, readonly) NSArray *args;

- (id)initWithString:(NSString *)string;

@end
