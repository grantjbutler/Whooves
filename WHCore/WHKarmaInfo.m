//
//  WHKarmaInfo.m
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHKarmaInfo.h"

static NSString *const kWHKarmaInfoUsernameKey = @"username";
static NSString *const kWHKarmaInfoKarmaKey = @"karma";
static NSString *const kWHKarmaInfoProsKey = @"pros";
static NSString *const kWHKarmaInfoConsKey = @"cons";

@implementation WHKarmaInfo

- (id)init {
	if((self = [super init])) {
		_pros = [[NSMutableArray alloc] init];
		_cons = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super init])) {
		_username = [aDecoder decodeObjectForKey:kWHKarmaInfoUsernameKey];
		_karma = [aDecoder decodeIntegerForKey:kWHKarmaInfoKarmaKey];
		_pros = [aDecoder decodeObjectForKey:kWHKarmaInfoProsKey];
		_cons = [aDecoder decodeObjectForKey:kWHKarmaInfoConsKey];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.username forKey:kWHKarmaInfoUsernameKey];
	[aCoder encodeInteger:self.karma forKey:kWHKarmaInfoKarmaKey];
	[aCoder encodeObject:self.pros forKey:kWHKarmaInfoProsKey];
	[aCoder encodeObject:self.cons forKey:kWHKarmaInfoConsKey];
}

@end
