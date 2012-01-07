//
//  IRCMessage.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCMessage.h"

@interface IRCMessage ()

@property (strong, readwrite) NSString *prefix;
@property (strong, readwrite) NSString *command;
@property (strong, readwrite) NSArray *args;

@property (strong, readwrite) NSString *message;

@property (strong, readwrite) NSString *nick;
@property (strong, readwrite) NSString *channel;

@property (readwrite, getter = isNumeric) BOOL numeric;

- (void)p_parse:(NSString *)line;

@end

@implementation IRCMessage

@synthesize prefix = _prefix;
@synthesize command = _command;
@synthesize args = _args;

@synthesize message = _message;

@synthesize nick = _nick;
@synthesize channel = _channel;

@synthesize numeric = _numeric;

- (id)initWithString:(NSString *)string {
	if((self = [super init])) {
		[self p_parse:string];
	}
	
	return self;
}

- (void)p_parse:(NSString *)line {
	static NSRegularExpression *messageRegex = nil;
	static NSRegularExpression *rawParamsRegex = nil;
	static NSRegularExpression *nickRegex = nil;
	
	if(!messageRegex) {
		messageRegex = [[NSRegularExpression alloc] initWithPattern:@"(^:(\\S+) )?(\\S+)(.*)" options:0 error:nil];
	}
	
	if(!rawParamsRegex) {
		rawParamsRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:^:| :)(.*)$" options:0 error:nil];
	}
	
	if(!nickRegex) {
		nickRegex = [[NSRegularExpression alloc] initWithPattern:@"^(\\S+)!" options:0 error:nil];
	}
	
	NSArray *matches = [messageRegex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
	
	for(NSTextCheckingResult *match in matches) {
		NSRange prefixRange = [match rangeAtIndex:2];
		NSRange commandRange = [match rangeAtIndex:3];
		NSRange rawArgsRange = [match rangeAtIndex:4];
		
		self.prefix = (prefixRange.location != NSNotFound) ? [line substringWithRange:prefixRange] : nil;
		self.command = [line substringWithRange:commandRange];
		NSString *rawArgs = [[line substringWithRange:rawArgsRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		NSArray *argMatches = [rawParamsRegex matchesInString:rawArgs options:0 range:NSMakeRange(0, [rawArgs length])];
		
		if([argMatches count] == 0) {
			for(NSTextCheckingResult *match in argMatches) {
				for(int i = 0; i < [match numberOfRanges]; i++) {
					NSLog(@"%@", [rawArgs substringWithRange:[match rangeAtIndex:i]]);
				}
			}
		} else {
			self.args = [rawArgs componentsSeparatedByString:@" "];
		}
		
		static NSRegularExpression *numericRegex = nil;
		
		if(!numericRegex) {
			numericRegex = [[NSRegularExpression alloc] initWithPattern:@"^\\d{3}$" options:0 error:nil];
		}
		
		self.numeric = ([numericRegex numberOfMatchesInString:self.command options:0 range:NSMakeRange(0, [self.command length])]> 0); 
		
		if(self.prefix) {
			NSArray *matches = [nickRegex matchesInString:self.prefix options:0 range:NSMakeRange(0, [self.prefix length])];
			
			for(NSTextCheckingResult *match in matches) {
				NSRange nickRange = [match rangeAtIndex:1];
				
				self.nick = (nickRange.location != NSNotFound) ? [self.prefix substringWithRange:nickRange] : nil;
			}
		}
		
		if(!self.isNumeric && [[self.args objectAtIndex:0] characterAtIndex:0] == '#') {
			self.channel = [self.args objectAtIndex:0];
		}
		
		if(!self.isNumeric) {
			self.message = [[[self.args subarrayWithRange:NSMakeRange(1, self.args.count - 1)] componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@":" withString:@""];
		}
	}
}
	

@end
