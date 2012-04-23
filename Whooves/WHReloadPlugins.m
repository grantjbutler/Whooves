//
//  WHReloadPlugins.m
//  Whooves
//
//  Created by Grant Butler on 4/22/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHReloadPlugins.h"
#import "WHPluginManager.h"

@implementation WHReloadPlugins

- (BOOL)handleMessage:(IRCMessage *)message {
	if(![message senderIsOwner]) {
		return NO;
	}
	
	WHPluginFirstTag;
	
	if([tag isEqualToString:@"reload"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"your"]) {
			WHPluginNextTag;
		}
		
		if([tag isEqualToString:@"plugins"]) {
			[[WHPluginManager sharedManager] reloadPlugins];
			
			[[IRCBot sharedBot] write:@"PRIVMSG %@ :All plugins have been reloaded.", message.responseTarget];
			
			return YES;
		}
	}
	
	return NO;
}

@end
