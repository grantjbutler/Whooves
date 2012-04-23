//
//  WHOp.m
//  Whooves
//
//  Created by Grant Butler on 4/22/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHOp.h"

@implementation WHOp

- (BOOL)handleMessage:(IRCMessage *)message {
	if(![message senderIsOwner] && ![message senderIsOp]) {
		return NO;
	}
	
	WHPluginFirstTag;
	
	NSString *nick = [tag word];
	
	WHPluginNextTag;
	
	BOOL shouldAdd = YES;
	
	if([tag isEqualToString:@"is"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"not"] || [tag isEqualToString:@"n't"]) {
			shouldAdd = NO;
			
			WHPluginNextTag;
		}
	} else if([tag isEqualToString:@"isn't"]) {
		// Remove
		
		shouldAdd = NO;
		
		WHPluginNextTag;
	}
	
	if([tag isEqualToString:@"op"]) {
		if(shouldAdd) {
			[[[IRCBot sharedBot] ops] addObject:nick];
			
			[[IRCBot sharedBot] write:@"PRIVMSG %@ :Alright, I'll start listening to them.", message.responseTarget];
		} else {
			[[[IRCBot sharedBot] ops] removeObject:nick];
			
			[[IRCBot sharedBot] write:@"PRIVMSG %@ :Alright, I won't take orders from them anymore.", message.responseTarget];
		}
		
		return YES;
	}
	
	return NO;
}

@end
