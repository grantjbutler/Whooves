//
//  WHWho.m
//  Whooves
//
//  Created by Grant Butler on 1/18/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHWho.h"

NSString *const kDescription = @"I'm The Doctor. In pony form. Specifically, I'm an IRC bot written in Objective-C running on OS X. I'm also open source. Check me out at http://github.com/grantjbutler/Whooves/.";

@implementation WHWho

- (BOOL)handleMessage:(IRCMessage *)message {
	WHPluginFirstTag;
	
	if([tag isEqualToString:@"who"] || [tag isEqualToString:@"what"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"are"]) {
			WHPluginNextTag;
			
			if([tag isEqualToString:@"you"]) {
				[[IRCBot sharedBot] write:@"PRIVMSG %@ : %@", message.responseTarget, kDescription];
				
				return YES;
			}
		}
	}
	
	return NO;
}

@end
