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
		NSLog(@"Created local storage at path: %@", path);
		
		_path = path;
		
		if([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
			@try {
				_storage = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
			}
			@catch (NSException *exception) {
				_storage = nil;
			}
		}
		
		if(!_storage) {
			_storage = [NSMutableDictionary dictionary];
		}
	}
	
	return self;
}

- (void)synchronize {
	[NSKeyedArchiver archiveRootObject:_storage toFile:_path];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey {
	[_storage setObject:object forKey:aKey];
}

- (id)objectForKey:(id)aKey {
	return [_storage objectForKey:aKey];
}

@end
