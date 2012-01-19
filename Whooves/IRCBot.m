//
//  IRCBot.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCBot.h"

#import "WHPluginManager.h"

@implementation IRCBot

@synthesize connection = _connection;

@synthesize user = _user;
@synthesize nick = _nick;
@synthesize pass = _pass;

+ (NSArray *)unknownQuestionResponses {
	return [NSArray arrayWithObjects:
			@"I do not know the answer to that.",
			@"I haven't got a clue.",
			@"I don't know. I'm a doctor, not an encyclopedia!",
			@"The answer: it eludes me.",
			nil];
}

+ (NSString *)randomUnknownQuestionResponse {
	NSArray *unknownQuestionResponses = [[self class] unknownQuestionResponses] ;
	
	return [unknownQuestionResponses objectAtIndex:arc4random() % [unknownQuestionResponses count]];
}

+ (NSArray *)unknownActionResponses {
	return [NSArray arrayWithObjects:
			@"I don't know how to do that.",
			@"I'm afraid I can't do that.",
			@"I can't do that! I'm not a mad man with a box!",
			@"It'd be easier for me to grow wings and fly than for me to do that.",
			nil];
}

+ (NSString *)randomUnknownActionResponse {
	NSArray *unknownActionResponses = [[self class] unknownActionResponses] ;
	
	return [unknownActionResponses objectAtIndex:arc4random() % [unknownActionResponses count]];
}

+ (NSString *)userAgent {
	return @"Whooves/1.0";
}

+ (IRCBot *)sharedBot {
	static IRCBot *sharedBot = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedBot = [[IRCBot alloc] init];
	});
	
	return sharedBot;
}

- (id)init {
	if((self = [super init])) {
		_connection = [[IRCConnection alloc] init];
		_connection.delegate = self;
	}
	
	return self;
}

- (void)connectToHost:(NSString *)host port:(NSUInteger)port {
	NSError *err;
	
	if(![_connection connectToHost:host port:port error:&err]) {
		NSLog(@"%@", err);
	}
}

- (void)join:(NSString *)channel {
	[_connection write:@"JOIN %@", channel];
}


//- (void)handleObject:(id)obj forMessage:(IRCMessage *)message {
//	if(![[WHPluginManager sharedManager] havePluginsHandleObject:obj forMessage:message]) {
//		if([obj isKindOfClass:[WHAction class]]) {
//			[_connection write:@"PRIVMSG %@ :%@", message.channel, [[self class] randomUnknownQuestionResponse]];
//		} else if([obj isKindOfClass:[WHAnswer class]]) {
//			[_connection write:@"PRIVMSG %@ :%@", message.channel, [[self class] randomUnknownQuestionResponse]];
//		} else {
//			[_connection write:@"PRIVMSG %@ :Derp!", message.channel];
//		}
//	}
//}

- (void)handleMessage:(IRCMessage *)message {
	if(![[WHPluginManager sharedManager] havePluginsHandleMessage:message]) {
		if([[message tags] count] > 2 && [[[message tags] objectAtIndex:0] isEqualToString:self.nick]) {
			WHTag *tag = [message.tags objectAtIndex:1];
			
			if(tag.tag == NSLinguisticTagPronoun) {
				[_connection write:@"PRIVMSG %@ :%@", message.target, [[self class] randomUnknownQuestionResponse]];
			} else if(tag.tag == NSLinguisticTagVerb) {
				[_connection write:@"PRIVMSG %@ :%@", message.target, [[self class] randomUnknownActionResponse]];
			} else {
				[_connection write:@"PRIVMSG %@ :Derp!", message.target];
			}
		} else {
			[_connection write:@"PRIVMSG %@ :Derp!", message.target];
		}
	}
}

#pragma mark - IRCConnection Delegate Methods

- (void)connectionDidConnectToServer:(IRCConnection *)connection {
	[connection write:@"USER %@ %@ %@ :%@, created by legosjedi.", self.nick, [[self class] userAgent], self.nick, [[self class] userAgent]];
	[connection write:@"NICK %@", self.nick];
}

- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message {
	if([message.command isEqualToString:@"PRIVMSG"]) {
		if([[message tags] count] > 0) {
			if((message.channel && [[[message tags] objectAtIndex:0] isEqualToString:self.nick])) {
				[self handleMessage:message];
			}
		}
	}
}

@end
