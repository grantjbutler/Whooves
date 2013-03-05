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

- (NSString *)command {
	return @"reload";
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if(![message senderIsOwner]) {
		return NO;
	}
	
	[[WHPluginManager sharedManager] reloadPlugins];

	[message respond:@"All plugins have been reloaded"];

	return YES;
}

@end
