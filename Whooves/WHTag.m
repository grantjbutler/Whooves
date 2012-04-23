//
//  WHTag.m
//  Whooves
//
//  Created by Grant Butler on 1/8/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHTag.h"

@implementation WHTag

@synthesize tag = _tag;
@synthesize word = _word;

- (id)initWithTag:(NSString *)tag word:(NSString *)word {
	if((self = [super init])) {
		_tag = tag;
		_word = word;
	}
	
	return self;
}

- (BOOL)isEqualToString:(NSString *)string {
	return ([_word compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

- (NSString *)description {
	NSString *superDescription = [super description];
	
	return [superDescription stringByReplacingOccurrencesOfString:@">" withString:[NSString stringWithFormat:@": %@ - %@>", _tag, _word]];
}

@end
