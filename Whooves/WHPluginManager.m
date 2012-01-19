//
//  WHPluginManager.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHPluginManager.h"

@implementation WHPluginManager {
	NSMutableSet *p_pluginRegistry;
}

+ (WHPluginManager *)sharedManager {
	static WHPluginManager *sharedManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[WHPluginManager alloc] init];
	});
	
	return sharedManager;
}

- (id)init {
	if((self = [super init])) {
		p_pluginRegistry = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (void)registerClass:(Class)klass {
	WHPlugin *plugin = [[klass alloc] init];
	
	[p_pluginRegistry addObject:plugin];
}

- (BOOL)havePluginsHandleMessage:(IRCMessage *)message {
	NSLog(@"%@", message.tags);
	
	for(WHPlugin *plugin in p_pluginRegistry) {
		if([plugin handleMessage:message]) {
			return YES;
		}
	}
	
	return NO;
}

@end
