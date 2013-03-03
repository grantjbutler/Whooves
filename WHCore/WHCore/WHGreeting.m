//
//  WHGreeting.m
//  Whooves
//
//  Created by Grant Butler on 4/12/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHGreeting.h"

@implementation WHGreeting

+ (NSArray *)repsonses {
	static NSArray *responses = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		responses = [NSArray arrayWithObjects:
					 @"Greetings",
					 @"Hello there",
					 @"Hi",
					 @"Hey", 
					 @"Hello",
					 nil];
	});
	
	return responses;
}

+ (NSArray *)greetings {
	static NSArray *greetings = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		greetings = [NSArray arrayWithObjects:
					 @"Hello",
					 @"Hi",
					 @"Hey",
					 @"Hola",
					 @"How's it going",
					 @"Hows it going"
					 @"Good day"
					 @"Good afternoon"
					 @"Good evening",
					 @"Good night", nil];
	});
	
	return greetings;
}

- (BOOL)handleMessage:(IRCMessage *)message {
	for(NSString *greeting in [[self class] greetings]) {
		if([[message.message lowercaseString] hasPrefix:[greeting lowercaseString]]) {
			NSArray *responses = [[self class] repsonses];
			
			NSUInteger randomIndex = arc4random() % [responses count];
			
			NSString *response = [responses objectAtIndex:randomIndex];
			
			[[IRCBot sharedBot] write:@"PRIVMSG %@ :%@, %@.", message.responseTarget, response, message.nick];
			
			return YES;
		}
	}
	
	return NO;
}

@end
