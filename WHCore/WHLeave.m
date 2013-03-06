//
//  WHLeave.m
//  Whooves
//
//  Created by Grant Butler on 3/6/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHLeave.h"

@implementation WHLeave

- (NSArray *)commands {
	return (@[
			@"leave",
			@"part"
			]);
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if(![message senderIsOp] && ![message senderIsOwner]) {
		return YES;
	}
	
	if(!message.channel) {
		return YES;
	}
	
	[message respond:@"Alright, I'll see you guys later."];
	
	[[IRCBot sharedBot] write:@"PART %@", message.channel];
	
	return YES;
}

@end
