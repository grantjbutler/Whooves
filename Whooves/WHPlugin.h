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

// TODO: These really shouldn't be defines.

#define WHPluginFirstTag \
 \
NSArray *tags = message.tags; \
 \
NSInteger index = 0; \
 \
WHTag *tag = [tags objectAtIndex:index]; \
 \
if([tag isEqualToString:[[IRCBot sharedBot] nick]]) { \
	if(++index < [tags count]) { \
		tag = [tags objectAtIndex:index]; \
	} else { \
		tag = nil; \
	} \
}

#define WHPluginNextTag \
{ \
	if(++index < [tags count]) { \
		tag = [tags objectAtIndex:index]; \
	} else { \
		tag = nil; \
	} \
}

@interface WHPlugin : NSObject

- (BOOL)shouldHandleMessage:(IRCMessage *)message;

- (BOOL)handleObject:(id)obj forMessage:(IRCMessage *)message DEPRECATED_ATTRIBUTE;
- (BOOL)handleMessage:(IRCMessage *)message;

- (NSString *)helpDescription;

@end