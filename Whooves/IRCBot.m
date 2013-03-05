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
#import "IRCUser.h"

@interface IRCBot () <IRCConnectionDelegate>

@property (strong, readonly) IRCConnection *connection;

@end

@implementation IRCBot {
	NSMutableArray *_users;
}

@synthesize connection = _connection;

@synthesize user = _user;
@synthesize nick = _nick;
@synthesize pass = _pass;

@synthesize owner = _owner;

@synthesize users = _users;

+ (NSCharacterSet *)ircUsernameCharacterSet {
	static NSMutableCharacterSet *ircUsernameCharacterSet = nil;
	
	if(!ircUsernameCharacterSet) {
		ircUsernameCharacterSet = [[NSMutableCharacterSet alloc] init];
		[ircUsernameCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[ircUsernameCharacterSet addCharactersInString:@"-_[]{}\\|`<"];
	}
	
	return ircUsernameCharacterSet;
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
		
		_users = [[NSMutableArray alloc] init];
		
		_commandPrefix = @"!";
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
	
	if([settings objectForKey:@"prefix"]) {
		self.commandPrefix = [settings objectForKey:@"prefix"];
	}
	
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

- (void)shutdown {
	[[WHPluginManager sharedManager] unloadPlugins];
	
	[_connection close];
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
	if(![message.message hasPrefix:self.commandPrefix]) {
		return;
	}
	
	if(![[WHPluginManager sharedManager] havePluginsHandleMessage:message]) {
		[_connection write:@"PRIVMSG %@ :%@", message.responseTarget, [[self class] randomUnknownActionResponse]];
//		[_connection write:@"PRIVMSG %@ :Derp!", message.responseTarget];
	}
}

- (void)handleRawMessage:(IRCMessage *)message {
	[[WHPluginManager sharedManager] havePluginsHandleRawMessage:message];
}

#pragma mark - IRCConnection Delegate Methods

- (void)connectionDidConnectToServer:(IRCConnection *)connection {
	[connection write:@"USER %@ %@ %@ :%@, created by %@.", self.nick, [[self class] userAgent], self.nick, [[self class] userAgent], self.owner];
	[connection write:@"NICK %@", self.nick];
	
	if(self.pass) {
		[connection write:@"PASS %@", self.pass];
	}
}

- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message {
	if([message.command isEqualToString:@"PRIVMSG"]) {
		if([message.message hasPrefix:self.commandPrefix]) {
			[self handleMessage:message];
		} else {
			[self handleRawMessage:message];
		}
	} else if([message.command isEqualToString:@"353"]) {
		NSString *channel = message.args[2];
		
		for(NSInteger i = 3; i < [message.args count]; i++) {
			NSString *username = [message.args[i] stringByTrimmingCharactersInSet:[[[self class] ircUsernameCharacterSet] invertedSet]];
			
			IRCUserRole role = IRCUserRoleNormal;
			
			if([[username substringToIndex:1] rangeOfCharacterFromSet:[[self class] ircUsernameCharacterSet]].location == NSNotFound) {
				NSString *prefix = [username substringToIndex:1];
				username = [username substringFromIndex:1];
				
				role = [IRCUser userRoleFromPrefix:prefix];
			}
			
			IRCUser *user = nil;
			
			NSInteger index = [_users indexOfObject:username];
			
			if(index != NSNotFound) {
				user = _users[index];
			}
			
			if(!user) {
				user = [[IRCUser alloc] init];
				user.username = username;
				[_users addObject:user];
			}
			
			if([user.channels containsObject:channel]) {
				[user changeRoleInChannel:channel toRole:role];
			} else {
				[user joinChannel:channel role:role];
			}
		}
	} else if([message.command isEqualToString:@"352"]) {
		NSString *channel = message.args[0];
		NSString *username = message.args[4];
		NSString *status = message.args[5];
		IRCUserRole role = IRCUserRoleNormal;
		
		if([[status substringFromIndex:[status length] - 1] rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
			role = [IRCUser userRoleFromPrefix:[status substringFromIndex:[status length] - 1]];
		}
		
		IRCUser *user = nil;
		
		NSInteger index = [_users indexOfObject:username];
		
		if(index != NSNotFound) {
			user = _users[index];
		}
		
		if(!user) {
			user = [[IRCUser alloc] init];
			user.username = username;
			[_users addObject:user];
		}
		
		if([user.channels containsObject:channel]) {
			[user changeRoleInChannel:channel toRole:role];
		} else {
			[user joinChannel:channel role:role];
		}
	} else if([message.command isEqualToString:@"MODE"]) {
		if([message.args count] < 3) {
			return;
		}
		
		NSString *channel = message.args[0];
		NSString *mode = message.args[1];
		NSString *username = message.args[2];
		
		NSString *action = [mode substringToIndex:1];
		mode = [mode substringFromIndex:1];
		
		IRCUserRole role = [IRCUser userRoleFromMode:mode];
		
		IRCUser *user = nil;
		
		NSInteger index = [_users indexOfObject:username];
		
		if(index != NSNotFound) {
			user = _users[index];
		}
		
		if(!user) {
			return;
		}
		
		if(![user.channels containsObject:channel]) {
			return;
		}
		
		if([action isEqualToString:@"+"]) {
			[user changeRoleInChannel:channel toRole:role];
		} else if([action isEqualToString:@"-"]) {
			[user changeRoleInChannel:channel toRole:IRCUserRoleNormal];
		}
	} else if([message.command isEqualToString:@"NICK"]) {
		NSString *oldUsername = message.nick;
		NSString *newUsername = message.args[0];
		
		IRCUser *user = nil;
		
		NSInteger index = [_users indexOfObject:oldUsername];
		
		if(index != NSNotFound) {
			user = _users[index];
		}
		
		if(!user) {
			return;
		}
		
		user.username = newUsername;
	} else if([message.command isEqualToString:@"JOIN"]) {
		IRCUser *user = nil;
		
		NSInteger index = [_users indexOfObject:message.nick];
		
		if(index != NSNotFound) {
			user = _users[index];
		}
		
		if(!user) {
			user = [[IRCUser alloc] init];
			user.username = message.nick;
			[_users addObject:user];
		}
		
		NSString *channel = [message.args[0] stringByReplacingOccurrencesOfString:@":" withString:@""];
		
		[user joinChannel:channel role:IRCUserRoleNormal];
	} else if([message.command isEqualToString:@"PART"]) {
		NSString *channel = message.args[0];
		
		IRCUser *user = nil;
		
		NSInteger index = [_users indexOfObject:message.nick];
		
		if(index != NSNotFound) {
			user = _users[index];
		}
		
		if(!user) {
			return;
		}
		
		[user partChannel:channel];
	} else if([message.command isEqualToString:@"QUIT"]) {
		if([_users containsObject:message.nick]) {
			[_users removeObject:message.nick];
		}
	}
}

@end
