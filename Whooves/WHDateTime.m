//
//  WHDateTime.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHDateTime.h"

@implementation WHDateTime

- (BOOL)handleObject:(id)obj forMessage:(IRCMessage *)message {
	NSMutableString *response = nil;
	
	NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
	NSDate *date = [NSDate date];
	
	NSString *type = @"";
	
	NSString *target = nil;
	
	if([obj isKindOfClass:[WHAction class]]) {
		WHAction *action = (WHAction *)obj;
		
		if([action.verb isEqualToString:@"tell"]) {
			type = action.what;
			
			target = action.target;
			
			if(action.preposition) {
				if([action.preposition isEqualToString:@"in"]) {
					if([action.condition length] == 3) {
						// We have a possible timezone. All right!
						
						timeZone = [NSTimeZone timeZoneWithAbbreviation:action.condition];
					} else {
						// TODO: A location. Try to figure out what timezone it's in.
					}
				}
			}
		}
	} else if([obj isKindOfClass:[WHAnswer class]]) {
		WHAnswer *answer = (WHAnswer *)obj;
		
		if([answer.pronoun isEqualToString:@"what"]) {
			type = answer.what;
			
			target = answer.target;
			
			if(answer.preposition) {
				if([answer.preposition isEqualToString:@"in"]) {
					if([answer.condition length] == 3) {
						// We have a possible timezone. All right!
						
						timeZone = [NSTimeZone timeZoneWithAbbreviation:answer.condition];
					} else {
						// TODO: A location. Try to figure out what timezone it's in.
					}
				}
			}
		}
	}
	
	if([type length] == 0 || (![type isEqualToString:@"date"] && ![type isEqualToString:@"time"])) {
		return NO;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:timeZone];
	
	if([type isEqualToString:@"time"]) {
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	} else if([type isEqualToString:@"date"]) {
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	response = [NSMutableString stringWithFormat:@"The %@ is %@", type, [dateFormatter stringFromDate:date]];
	
	if([target hasPrefix:@"#"]) {
		[response appendString:@"."];
	} else {
		[response appendFormat:@", %@.", target];
	}
	
	if(message.channel) {
		[[[IRCBot sharedBot] connection] write:@"PRIVMSG %@ :%@", message.channel, response];
	} else {
		[[[IRCBot sharedBot] connection] write:@"PRIVMSG %@ :%@", message.nick, response];
	}
	
	return YES;
}

@end
