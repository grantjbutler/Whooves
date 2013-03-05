//
//  WHKarma.m
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHKarma.h"
#import "WHKarmaInfo.h"

static NSString *const kWHKarmaUsernameKey = @"username";
static NSString *const kWHKarmaReasonKey = @"reason";

NSArray *ShuffleArray(NSArray *array);
NSArray *ShuffleArray(NSArray *array) {
	NSMutableArray *anArray = [array mutableCopy];
	
	NSUInteger count = [anArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [anArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
	
	return anArray;
}

@implementation WHKarma

- (NSString *)command {
	return @"karma";
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if([message.messageComponents count] < 2) {
		[message respond:@"Please specify a username."];
		
		return YES;
	}
	
	NSString *username = message.messageComponents[1];
	
	WHKarmaInfo *info = [self.localStorage objectForKey:username];
	
	if(!info) {
		[message respond:[NSString stringWithFormat:@"%@ has 0 karma.", username]];
		
		return YES;
	}
	
	NSMutableString *response = [[NSMutableString alloc] init];
	[response appendFormat:@"%@ has %ld karma.", username, info.karma];
	
	if([info.pros count] > 0) {
		NSArray *allPros = ShuffleArray(info.pros);
		
		NSMutableArray *pros = [NSMutableArray array];
		
		for(int i = 0; i < MIN(3, [allPros count]); i++) {
			NSDictionary *reason = allPros[i];
			
			[pros addObject:[NSString stringWithFormat:@"%@ (%@)", reason[kWHKarmaReasonKey], reason[kWHKarmaUsernameKey]]];
		}
		
		[response appendString:@" Pros: "];
		[response appendString:[pros componentsJoinedByString:@", "]];
		[response appendString:@"."];
	}
	
	if([info.cons count] > 0) {
		NSArray *allCons = ShuffleArray(info.cons);
		
		NSMutableArray *cons = [NSMutableArray array];
		
		for(int i = 0; i < MIN(3, [allCons count]); i++) {
			NSDictionary *reason = allCons[i];
			
			[cons addObject:[NSString stringWithFormat:@"%@ (%@)", reason[kWHKarmaReasonKey], reason[kWHKarmaUsernameKey]]];
		}
		
		[response appendString:@" Cons: "];
		[response appendString:[cons componentsJoinedByString:@", "]];
		[response appendString:@"."];
	}
	
	[message respond:response];
	
	return YES;
}

- (NSString *)helpDescription {
	return @"Implements a karma system. USERNAME++ will give karma, while USERNAME-- will take it away. Add a message at the end for a reason for the change.";
}

- (BOOL)handleRawMessage:(IRCMessage *)message {
	if(![message.messageComponents[0] hasSuffix:@"++"] && ![message.messageComponents[0] hasSuffix:@"--"]) {
		return NO;
	}
	
	NSString *command = message.messageComponents[0];
	
	NSString *username = [command substringToIndex:[command length] - 2];
	NSString *action = [command substringFromIndex:[command length] - 2];
	
	if([username isEqualToString:message.nick]) {
		return YES; // We don't want to handle this, but we do want to swallow it.
	}
	
	WHKarmaInfo *info = [self.localStorage objectForKey:username];
	
	if(!info) {
		info = [[WHKarmaInfo alloc] init];
		info.username = username;
		
		[self.localStorage setObject:info forKey:username];
	}
	
	if([action isEqualToString:@"++"]) {
		info.karma++;
	} else if([action isEqualToString:@"--"]) {
		info.karma--;
	}
	
	if([message.messageComponents count] > 1) {
		NSString *reason = [message.message substringFromIndex:[message.messageComponents[0] length] + 1]; // + 1 accounts for the space.
		
		NSDictionary *reasonInfo = (@{
									kWHKarmaUsernameKey: message.nick,
									kWHKarmaReasonKey: reason
									});
		
		if([action isEqualToString:@"++"]) {
			[info.pros addObject:reasonInfo];
		} else if([action isEqualToString:@"--"]) {
			[info.cons addObject:reasonInfo];
		}
	}
	
	[message respond:[NSString stringWithFormat:@"Karma for %@ is now %ld.", username, info.karma]];
	
	return YES;
}

@end
