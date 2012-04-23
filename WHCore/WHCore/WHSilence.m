//
//  WHSilence.m
//  Whooves
//
//  Created by Grant Butler on 4/21/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHSilence.h"

@implementation WHSilence {
	BOOL p_silenced;
	NSString *p_who;
}

+ (NSArray *)silencedResponses {
	static NSArray *responses = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		responses = [NSArray arrayWithObjects:
					 @"Oh, I'm sorry, was I being too loud. I'll be quieter. *meep*",
					 @"Aww, pony feathers. Looks like I'm being too disruptive.",
					 @"Gotta run. Wibbly wobbly, timey wimey things to do!",
					 nil];
	});
	
	return responses;
}

- (void)p_silence:(IRCMessage *)message {
	NSArray *responses = [[self class] silencedResponses];
	
	NSString *response = [responses objectAtIndex:arc4random() % [responses count]];
	
	[[IRCBot sharedBot] write:@"PRIVMSG %@ :%@", message.responseTarget, response];
	
	p_silenced = YES;
}

+ (NSArray *)comeBackResponses {
	static NSArray *responses = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		responses = [NSArray arrayWithObjects:
					 @"Yay, I'm back!",
					 @"Whew. Feels good to have that gag out of my mouth.",
					 nil];
	});
	
	return responses;
}

- (void)p_comeBack:(IRCMessage *)message {
	NSArray *responses = [[self class] comeBackResponses];
	
	NSString *response = [responses objectAtIndex:arc4random() % [responses count]];
	
	[[IRCBot sharedBot] write:@"PRIVMSG %@ :%@", message.responseTarget, response];
	
	p_silenced = NO;
}

- (BOOL)shouldHandleMessage:(IRCMessage *)message {
	if(!p_silenced) {
		return YES;
	} else {
		return ([message senderIsOwner] || [message senderIsOp]);
	}
}

- (BOOL)handleMessage:(IRCMessage *)message {
	// TODO: Only shut up for mods and owner.
	if(![message senderIsOwner] && ![message senderIsOp]) {
		return NO;
	}
	
	WHPluginFirstTag;
	
	if([tag isEqualToString:@"silence"] || [tag isEqualToString:@"quiet"] || [tag isEqualToString:@"STFU"]) {
		[self p_silence:message];
		
		return YES;
	} else if([tag isEqualToString:@"shut"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"up"]) {
			[self p_silence:message];
			
			return YES;
		}
	} else if([tag isEqualToString:@"be"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"quiet"]) {
			[self p_silence:message];
			
			return YES;
		}
	} else if([tag isEqualToString:@"speak"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"up"]) {
			[self p_comeBack:message];
			
			return YES;
		}
	} else if([tag isEqualToString:@"come"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"back"]) {
			[self p_comeBack:message];
			
			return YES;
		}
	}
	
	return NO;
}

@end
