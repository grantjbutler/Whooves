//
//  IRCBot.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCBot.h"

#import "WHAction.h"
#import "WHAnswer.h"

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

+ (NSArray *)unknownActionResponses {
	return [NSArray arrayWithObjects:
			@"I don't know how to do that.",
			@"I'm afraid I can't do that.",
			@"I can't do that! I'm not a mad man with a box!",
			@"It'd be easier for me to grow wings and fly than for me to do that.",
			nil];
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


- (void)handleObject:(id)obj forMessage:(IRCMessage *)message {
	if(![[WHPluginManager sharedManager] havePluginsHandleObject:obj forMessage:message]) {
		if([obj isKindOfClass:[WHAction class]]) {
			[_connection write:@"PRIVMSG %@ :%@", message.channel, [[[self class] unknownActionResponses] objectAtIndex:arc4random() % [[[self class] unknownActionResponses] count]]];
		} else if([obj isKindOfClass:[WHAnswer class]]) {
			[_connection write:@"PRIVMSG %@ :%@", message.channel, [[[self class] unknownQuestionResponses] objectAtIndex:arc4random() % [[[self class] unknownQuestionResponses] count]]];
		} else {
			[_connection write:@"PRIVMSG %@ :Derp!", message.channel];
		}
	}
}

#pragma mark - IRCConnection Delegate Methods

- (void)connectionDidConnectToServer:(IRCConnection *)connection {
	[connection write:@"USER %@ %@ %@ :%@", self.nick, [[self class] userAgent], self.nick, self.user];
	[connection write:@"NICK %@", self.nick];
}

- (void)connection:(IRCConnection *)connection didReceiveMessage:(IRCMessage *)message {
	if([message.command isEqualToString:@"PRIVMSG"]) {
		if([message.message hasPrefix:self.nick]) {
			NSLog(@"%@", message.message);
			
			NSLinguisticTagger *lingusticTagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSArray arrayWithObject:NSLinguisticTagSchemeLexicalClass] options:NSLinguisticTaggerJoinNames | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerOmitWhitespace];
			[lingusticTagger setString:message.message];
			
			__block id obj = nil;
			__block int tagNum = -1;
			
			[lingusticTagger enumerateTagsInRange:NSMakeRange(0, [message.message length]) scheme:NSLinguisticTagSchemeLexicalClass options:NSLinguisticTaggerJoinNames | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerOmitWhitespace usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
				
				NSLog(@"%@ - %@", tag, [message.message substringWithRange:tokenRange]);
				
				tagNum++;
				
				if(tokenRange.location == 0) {
					return; // This is "WHOOVES".
				}
				
				if(!obj && tagNum == 1) {
					if(tag == NSLinguisticTagVerb) {
						obj = [[WHAction alloc] init];
						
						((WHAction *)obj).verb = [message.message substringWithRange:tokenRange];
					} else if(tag == NSLinguisticTagPronoun) {
						obj = [[WHAnswer alloc] init];
						
						((WHAnswer *)obj).pronoun = [message.message substringWithRange:tokenRange];
					}
				}
				
				if([obj isKindOfClass:[WHAction class]]) {
					WHAction *action = (WHAction *)obj;
					
					if(!action.target && (tag == NSLinguisticTagNoun || tag == NSLinguisticTagPronoun)) {
						NSString *target = [message.message substringWithRange:tokenRange];
						
						if(tag == NSLinguisticTagNoun) {
							action.target = target;
						} else if(tag == NSLinguisticTagPronoun) {
							if([target isEqualToString:@"me"]) {
								action.target = message.nick;
							} else if([target isEqualToString:@"us"]) {
								action.target = message.channel;
							}
						}
					} else if(!action.what && tag == NSLinguisticTagNoun) {
						action.what = [message.message substringWithRange:tokenRange];
					} else if(!action.preposition && tag == NSLinguisticTagPreposition) {
						action.preposition = [message.message substringWithRange:tokenRange];
					} else if(!action.condition && action.preposition && tag == NSLinguisticTagNoun) {
						action.condition = [message.message substringWithRange:tokenRange];
					}
				} else if([obj isKindOfClass:[WHAnswer class]]) {
					WHAnswer *answer = (WHAnswer *)obj;
					
					if(!answer.what && tag == NSLinguisticTagNoun) {
						answer.what = [message.message substringWithRange:tokenRange];
					} else if(!answer.preposition && tag == NSLinguisticTagPreposition) {
						answer.preposition = [message.message substringWithRange:tokenRange];
					} else if(!answer.condition && answer.preposition && tag == NSLinguisticTagNoun) {
						answer.condition = [message.message substringWithRange:tokenRange];
					}
				}
			}];
			
			if([obj isKindOfClass:[WHAnswer class]]) {
				((WHAnswer *)obj).target = message.nick;
			}
			
			[self handleObject:obj forMessage:message];
		}
	}
}

@end
