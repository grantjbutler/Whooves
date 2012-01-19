//
//  WHPlugin.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRCMessage.h"

#import "IRCBot.h"

@interface WHPlugin : NSObject

- (BOOL)handleObject:(id)obj forMessage:(IRCMessage *)message;
- (BOOL)handleMessage:(IRCMessage *)message;

- (NSString *)helpDescription;

@end