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
	WHPluginFirstTag;
	
	// There's a weird case when a capital What turns it into a noun. Not sure why...
	if(!([tag tag] == NSLinguisticTagPronoun || [tag tag] == NSLinguisticTagNoun) && [tag tag] != NSLinguisticTagVerb) {
		return NO;
	}
	
	NSString *target = message.nick;
	NSString *type = nil;
	
	if([tag isEqualToString:@"what"]) {
		for(index++; index < [tags count] && !type; index++) {
			tag = [tags objectAtIndex:index];
			
			if([tag tag] == NSLinguisticTagNoun) {
				type = [tag word];
			}
		}
	} else if([tag isEqualToString:@"tell"]) {
		index++;
		
		if(index < [tags count]) {
			tag = [tags objectAtIndex:index];
			
			if([tag tag] == NSLinguisticTagNoun || [tag tag] == NSLinguisticTagPronoun) {
				if([tag isEqualToString:@"me"]) {
					target = message.nick;
				} else if([tag isEqualToString:@"us"]) {
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
	
	if([type length] == 0 || !([type isEqualToString:@"date"] || [type isEqualToString:@"time"] || [type isEqualToString:@"day"])) {
		return NO;
	}
	
	NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
	NSDate *date = [NSDate date];
	
	index += 2; // Skip past "is" and "it".
	
	if(index < [tags count]) {
		tag = [tags objectAtIndex:index];
		
		if([tag isEqualToString:@"in"]) {
			index++;
			
			if(index < [tags count]) {
				tag = [tags objectAtIndex:index];
				
				if([[tag word] length] == 3 && (index + 1 == [tags count] || (index + 2 == [tags count] && [[(WHTag *)[tags objectAtIndex:index + 1] tag] isEqualToString:NSLinguisticTagNumber]))) {
					// Possible time zone.
					
					timeZone = [NSTimeZone timeZoneWithAbbreviation:[tag word]];
					
					if(index + 1 == [tags count] - 1 && [[(WHTag *)[tags objectAtIndex:index + 1] tag] isEqualToString:NSLinguisticTagNumber]) {
						
						NSRange location = [[message message] rangeOfString:[tag word]];
						
						NSString *operation = [[message message] substringWithRange:NSMakeRange(location.location + location.length, 1)];
						
						WHPluginNextTag;
						
						NSInteger secondsFromGMT = [timeZone secondsFromGMT];
						
						if([operation isEqualToString:@"+"]) {
							timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-(secondsFromGMT - [[tag word] intValue] * 3600)];
						} else if([operation isEqualToString:@"-"]) {
							timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-(secondsFromGMT + [[tag word] intValue] * 3600)];
						}
					}
					
					if(!timeZone) {
						timeZone = [NSTimeZone systemTimeZone];
					}
				} else {
					// Could be a location. Try to handle that.
					
					NSMutableString *response = [NSMutableString stringWithString:@"I don't handle locations yet"];
					
					if([target hasPrefix:@"#"]) {
						[response appendString:@"."];
					} else {
						[response appendFormat:@", %@.", target];
					}
					
					[[IRCBot sharedBot] write:@"PRIVMSG %@ :%@", message.responseTarget, response];
					
					return YES;
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
	} else if([type isEqualToString:@"day"]) {
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		
		[dateFormatter setDateFormat:@"EEEE"];
	}
	
	NSMutableString *response = [NSMutableString stringWithFormat:@"The %@ is %@", type, [dateFormatter stringFromDate:date]];
	
	if([target hasPrefix:@"#"]) {
		[response appendString:@"."];
	} else {
		[response appendFormat:@", %@.", target];
	}
	
	[[IRCBot sharedBot] write:@"PRIVMSG %@ :%@", message.responseTarget, response];
	
	return YES;
}

@end
