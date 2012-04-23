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

+ (NSMutableArray *)greetings {
	static NSMutableArray *greetings = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		greetings = [[NSMutableArray alloc] init];
	});
	
	return greetings;
}

- (id)init {
	if((self = [super init])) {
		NSMutableArray *greetings = [[self class] greetings];
		
		[greetings addObject:@"Hello"];
		[greetings addObject:@"Hi"];
		[greetings addObject:@"Hey"];
		[greetings addObject:@"Hola"];
		[greetings addObject:@"How's it going"];
		[greetings addObject:@"Hows it going"];
		[greetings addObject:@"Good day"];
		[greetings addObject:@"Good afternoon"];
		[greetings addObject:@"Good evening"];
		[greetings addObject:@"Good night"];
	}
	
	return self;
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
