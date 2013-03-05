//
//  WHLocalStorage.m
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHLocalStorage.h"

@implementation WHLocalStorage {
	NSString *_path;
	NSMutableDictionary *_storage;
}

- (id)initWithPath:(NSString *)path {
	if((self = [super init])) {
		_path = path;
		
		if([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
			_storage = [NSMutableDictionary dictionaryWithContentsOfFile:_path];
		} else {
			_storage = [NSMutableDictionary dictionary];
		}
	}
	
	return self;
}

- (void)synchronize {
	[_storage writeToFile:_path atomically:YES];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey {
	[_storage setObject:object forKey:aKey];
}

- (id)objectForKey:(id)aKey {
	return [_storage objectForKey:aKey];
}

@end
