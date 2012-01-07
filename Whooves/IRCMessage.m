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

- (void)p_parse:(NSString *)line;

@end

@implementation IRCMessage

@synthesize prefix = _prefix;
@synthesize command = _command;
@synthesize args = _args;

- (id)initWithString:(NSString *)string {
	if((self = [super init])) {
		[self p_parse:string];
	}
	
	return self;
}

- (void)p_parse:(NSString *)line {
	static NSRegularExpression *messageRegex = nil;
	static NSRegularExpression *rawParamsRegex = nil;
	
	if(!messageRegex) {
		messageRegex = [[NSRegularExpression alloc] initWithPattern:@"(^:(\\S+) )?(\\S+)(.*)" options:0 error:nil];
	}
	
	if(!rawParamsRegex) {
		rawParamsRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:^:| :)(.*)$" options:0 error:nil];
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
	}
}

@end
