//
//  IRCBot.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCBot.h"

#import "WHPluginManager.h"

#import "IRCConnection.h"

@interface IRCBot () <IRCConnectionDelegate>

@property (strong, readonly) IRCConnection *connection;

@end

@implementation IRCBot

@synthesize connection = _connection;

@synthesize user = _user;
@synthesize nick = _nick;
@synthesize pass = _pass;

@synthesize owner = _owner;

@synthesize ops = _ops;

+ (NSArray *)unknownQuestionResponses {
	return [NSArray arrayWithObjects:
			@"I do not know the answer to that.",
			@"I haven't got a clue.",
			@"I don't know. I'm a doctor, not an encyclopedia!",
			@"The answer: it eludes me.",
			nil];
}

+ (NSString *)randomUnknownQuestionResponse {
	NSArray *unknownQuestionResponses = [[self class] unknownQuestionResponses];
	
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
	NSArray *unknownActionResponses = [[self class] unknownActionResponses];
	
	return [unknownActionResponses objectAtIndex:arc4random() % [unknownActionResponses count]];
}

+ (NSString *)userAgent {
#ifdef DEBUG
	return @"Whooves-Dev/1.0";
#else
	return @"Whooves/1.0";
#endif
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
		
		_ops = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)loadSettingsFromFile:(NSString *)path {
	// TODO: Try to load some settings from a config file.
	if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return;
	}
	
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	self.user = [settings objectForKey:@"user"];
	self.nick = [settings objectForKey:@"nick"];
	self.pass = [settings objectForKey:@"pass"];
	
	self.owner = [settings objectForKey:@"owner"];
	
	[self connectToHost:[settings objectForKey:@"host"] port:[[settings objectForKey:@"port"] intValue]];
}

- (void)connectToHost:(NSString *)host port:(NSUInteger)port {
	NSError *err;
	
	if(![_connection connectToHost:host port:port error:&err]) {
		NSLog(@"Connect to host error: %@", err);
	}
}

- (void)join:(NSString *)channel {
	[_connection write:@"JOIN %@", channel];
}

- (void)write:(NSString *)format, ... {
	va_list list;
	va_start(list, format);
	
	[_connection write:format args:list];
	
	va_end(list);
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
		if([[message tags] count] > 0) {
			WHTag *tag = [message.tags objectAtIndex:0];
			
			if([tag isEqualToString:self.nick] && [[message tags] count] > 1) {
				tag = [message.tags objectAtIndex:1];
			}
			
			if(tag.tag == NSLinguisticTagPronoun) {
				[_connection write:@"PRIVMSG %@ :%@", message.responseTarget, [[self class] randomUnknownQuestionResponse]];
			} else if(tag.tag == NSLinguisticTagVerb) {
				[_connection write:@"PRIVMSG %@ :%@", message.responseTarget, [[self class] randomUnknownActionResponse]];
			} else {
				[_connection write:@"PRIVMSG %@ :Derp!", message.responseTarget];
			}
		} else {
			[_connection write:@"PRIVMSG %@ :Derp!", message.responseTarget];
		}
	}
}

#pragma mark - IRCConnection Delegate Methods

- (void)connectionDidConnectToServer:(IRCConnection *)connection {
	[connection write:@"USER %@ %@ %@ :%@, created by legosjedi.", self.nick, [[self class] userAgent], self.nick, [[self class] userAgent]];
	[connection write:@"NICK %@", self.nick];
	
	if(self.pass) {
		[connection write:@"PASS %@", self.pass];
	}
}

- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message {
	if([message.command isEqualToString:@"PRIVMSG"]) {
		if([[message tags] count] > 0) {
			if((message.channel && [[[message tags] objectAtIndex:0] isEqualToString:self.nick]) || (!message.channel && message.responseTarget)) {
				[self handleMessage:message];
			}
		}
	}
}

@end
