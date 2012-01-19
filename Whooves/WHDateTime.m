//
//  WHDateTime.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHDateTime.h"

@implementation WHDateTime

- (BOOL)handleMessage:(IRCMessage *)message {
	NSArray *tags = message.tags;
	
	NSInteger index = 1;
	
	WHTag *tag = [tags objectAtIndex:index];
	
	if([tag tag] != NSLinguisticTagPronoun && [tag tag] != NSLinguisticTagVerb) {
		return NO;
	}
	
	NSString *target = message.nick;
	NSString *type = nil;
	
	if([tag tag] == NSLinguisticTagPronoun && [[tag word] isEqualToString:@"what"]) {
		for(; index < [tags count] && !type; index++) {
			tag = [tags objectAtIndex:index];
			
			if([tag tag] == NSLinguisticTagNoun) {
				type = [tag word];
			}
		}
	} else if([tag tag] == NSLinguisticTagVerb && [[tag word] isEqualToString:@"tell"]) {
		index++;
		
		if(index < [tags count]) {
			tag = [tags objectAtIndex:index];
			
			if([tag tag] == NSLinguisticTagNoun || [tag tag] == NSLinguisticTagPronoun) {
				if([[tag word] isEqualToString:@"me"]) {
					target = message.nick;
				} else if([[tag word] isEqualToString:@"us"]) {
					target = message.channel;
				} else {
					target = tag.word;
				}
				
				index += 2; // The next one should be "the", so skip that.
				
				if(index < [tags count]) {
					tag = [tags objectAtIndex:index];
					
					if([tag tag] == NSLinguisticTagNoun) {
						type = [tag word];
					}
				}
			}
		}
	}
	
	if([type length] == 0 || !([type isEqualToString:@"date"] || [type isEqualToString:@"time"])) {
		return NO;
	}
	
	NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
	NSDate *date = [NSDate date];
	
	index = [tags count] - 2;
	
	if(index < [tags count]) {
		tag = [tags objectAtIndex:index];
		
		if([tag tag] == NSLinguisticTagPreposition && [[tag word] isEqualToString:@"in"]) {
			index++;
			
			if(index < [tags count]) {
				tag = [tags objectAtIndex:index];
				
				if([[tag word] length] == 3) {
					// Possible time zone.
					
					timeZone = [NSTimeZone timeZoneWithAbbreviation:[tag word]];
					
					if(!timeZone) {
						timeZone = [NSTimeZone systemTimeZone];
					}
				}
			}
		}
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
	
	NSMutableString *response = [NSMutableString stringWithFormat:@"The %@ is %@", type, [dateFormatter stringFromDate:date]];
	
	if([target hasPrefix:@"#"]) {
		[response appendString:@"."];
	} else {
		[response appendFormat:@", %@.", target];
	}
	
	[[[IRCBot sharedBot] connection] write:@"PRIVMSG %@ :%@", message.target, response];
	
	return YES;
}

@end
