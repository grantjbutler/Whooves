//
//  WHDigest.m
//  Whooves
//
//  Created by Grant Butler on 3/6/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHDigest.h"

static NSString *const kWHDigestKey = @"digest";
static NSString *const kWHDigestLastIDKey = @"lastID";

static NSString *const kWHDigestMessageKey = @"message";
static NSString *const kWHDigestIDKey = @"id";
static NSString *const kWHDigestAuthorKey = @"author";

@implementation WHDigest {
	NSMutableArray *_digest;
	NSInteger _lastID;
}

- (NSString *)command {
	return @"digest";
}

- (id)init {
	if((self = [super init])) {
		_digest = [[self.localStorage objectForKey:kWHDigestKey] mutableCopy];
		_lastID = [[self.localStorage objectForKey:kWHDigestLastIDKey] integerValue];
		
		if(!_digest) {
			_digest = [NSMutableArray array];
		}
	}
	
	return self;
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if([message.messageComponents count] <= 1) {
		// Just print out what's currently in the digest.
		if([_digest count] <= 0) {
			[message respond:@"There are currently no messages in the digest."];
			
			return YES;
		} else {
			[message respondWithFormat:@"There are %d messages in the digest.", [_digest count]];
			
			for(NSDictionary *entry in _digest) {
				[message respondWithFormat:@"Message %d by %@: %@", [entry[kWHDigestIDKey] integerValue], entry[kWHDigestAuthorKey], entry[kWHDigestMessageKey]];
			}
			
			return YES;
		}
	}
	
	NSString *action = message.messageComponents[1];
	
	if([action isEqualToString:@"add"]) {
		if([message.messageComponents count] <= 2) {
			[message respondWithFormat:@"No message specified."];
			
			return YES;
		}
		
		NSString *digestMessage = [message.message substringFromIndex:[message.messageComponents[0] length] + [message.messageComponents[1] length] + 2];
		
		_lastID++;
		
		NSDictionary *digestDictionary = (@{
										  kWHDigestIDKey: @(_lastID),
										  kWHDigestMessageKey: digestMessage,
										  kWHDigestAuthorKey: message.nick
										  });
		
		[_digest addObject:digestDictionary];
		
		[self.localStorage setObject:_digest forKey:kWHDigestKey];
		[self.localStorage setObject:@(_lastID) forKey:kWHDigestLastIDKey];
		[self.localStorage synchronize];
		
		[message respondWithFormat:@"Message added to digest with ID %d", _lastID];
		
		return YES;
	} else if([action isEqualToString:@"remove"]) {
		if([message.messageComponents count] <= 2) {
			[message respondWithFormat:@"No digest message ID specified."];
			
			return YES;
		}
		
		NSString *messageID = message.messageComponents[2];
		
		__block NSInteger index = NSNotFound;
		
		[_digest enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *digestItem = (NSDictionary *)obj;
			
			NSLog(@"DIGEST ID: %@", [digestItem objectForKey:kWHDigestIDKey]);
			
			if([[digestItem objectForKey:kWHDigestIDKey] integerValue] == [messageID integerValue]) {
				index = idx;
				
				*stop = YES;
			}
		}];
		
		if(index == NSNotFound) {
			[message respond:@"No digest item found that matches that ID."];
			
			return YES;
		}
		
		[_digest removeObjectAtIndex:index];
		
		[self.localStorage setObject:_digest forKey:kWHDigestKey];
		[self.localStorage synchronize];
		
		[message respondWithFormat:@"Message with ID %@ removed from digest.", messageID];
		
		return YES;
	} else if([action isEqualToString:@"edit"]) {
		if([message.messageComponents count] <= 2) {
			[message respondWithFormat:@"No digest message ID specified."];
			
			return YES;
		}
		
		NSString *messageID = message.messageComponents[2];
		
		__block NSInteger index = NSNotFound;
		
		[_digest enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *digestItem = (NSDictionary *)obj;
			
			if([[digestItem objectForKey:kWHDigestIDKey] integerValue] == [messageID integerValue]) {
				index = idx;
				
				*stop = YES;
			}
		}];
		
		if(index == NSNotFound) {
			[message respond:@"No digest item found that matches that ID."];
			
			return YES;
		}
		
		NSString *newMessage = [message.message substringFromIndex:[message.messageComponents[0] length] + [message.messageComponents[1] length] + [message.messageComponents[2] length] + 3];
		
		NSMutableDictionary *digestItem = [_digest[index] mutableCopy];
		
		[digestItem setObject:newMessage forKey:kWHDigestMessageKey];
		
		[_digest replaceObjectAtIndex:index withObject:digestItem];
		
		[self.localStorage setObject:_digest forKey:kWHDigestKey];
		[self.localStorage synchronize];
		
		[message respond:@"Message updated."];
		
		return YES;
	} else if([action isEqualToString:@"clear"]) {
		[message respond:@"Removing all items from the digest."];
		
		_digest = [[NSMutableArray alloc] init];
		
		[self.localStorage setObject:_digest forKey:kWHDigestKey];
		[self.localStorage synchronize];
		
		return YES;
	}
	
	[message respond:@"I do not understand that action."];
	
	return YES;
}

@end
