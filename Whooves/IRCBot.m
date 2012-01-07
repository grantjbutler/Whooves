//
//  IRCBot.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCBot.h"

@implementation IRCBot

@synthesize connection = _connection;

@synthesize user = _user;
@synthesize nick = _nick;
@synthesize pass = _pass;

+ (NSString *)userAgent {
	return @"Whooves/1.0";
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

- (void)connectionDidConnectToServer:(IRCConnection *)connection {
	[connection write:[NSString stringWithFormat:@"USER %@ %@ %@ :%@", self.nick, [[self class] userAgent], self.nick, self.user]];
	[connection write:[NSString stringWithFormat:@"NICK %@", self.nick]];
}

- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message {
	if([message.command isEqualToString:@"PRIVMSG"]) {
		
	}
}

@end
