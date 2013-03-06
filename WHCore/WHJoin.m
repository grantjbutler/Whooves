//
//  WHJoin.m
//  Whooves
//
//  Created by Grant Butler on 3/5/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHJoin.h"

@implementation WHJoin

- (NSString *)command {
	return @"join";
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if(![message senderIsOwner]) {
		return YES;
	}
	
	if([message.messageComponents count] < 2) {
		return YES;
	}
	
	NSString *channel = message.messageComponents[1];
	
	[message respond:[NSString stringWithFormat:@"Alright, I'll head right over to %@.", channel]];
	
	[[IRCBot sharedBot] join:channel];
	
	return YES;
}

@end
