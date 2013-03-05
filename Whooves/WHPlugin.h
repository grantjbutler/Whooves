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

#import "WHLocalStorage.h"

@protocol WHPlugin <NSObject>

// Although optional, you must implement at least one of these.
@optional
- (BOOL)handleMessage:(IRCMessage *)message;
- (BOOL)handleRawMessage:(IRCMessage *)message;

// If you're implementing handleMessage:, implement one of the following:
@property (nonatomic, strong, readonly) NSArray *commands; // Override this if you provide multiple commands.
@property (nonatomic, strong, readonly) NSString *command; // Override this if you provide just one command.
														   // If you need to provide custom regex, override this.

@end

@interface WHPlugin : NSObject <WHPlugin>

@property (nonatomic, strong, readonly) WHLocalStorage *localStorage;

- (BOOL)shouldHandleMessage:(IRCMessage *)message;
- (NSString *)helpDescription;

- (void)unload;

@end