//
//  WHPluginManager.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHPluginManager.h"

#import "WHReloadPlugins.h"

@implementation WHPluginManager {
	NSMutableSet *p_pluginRegistry;
	
	NSMutableSet *p_loadedBundles;
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
		p_loadedBundles = [[NSMutableSet alloc] init];
		
		[self registerClass:[WHReloadPlugins class]];
	}
	
	return self;
}

- (NSSet *)plugins {
	return p_pluginRegistry;
}

- (void)reloadPlugins {
	for(NSBundle *bundle in p_loadedBundles) {
		[bundle unload];
		
		[p_loadedBundles removeObject:bundle];
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *appSupport = [[paths lastObject] stringByAppendingPathComponent:@"Whooves"];
	NSString *pluginsFolder = [appSupport stringByAppendingPathComponent:@"Plugins"];
	
	BOOL isDir;
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:pluginsFolder isDirectory:&isDir] || !isDir) {
		NSLog(@"WARNING! Could not find plugins directory at %@", pluginsFolder);
		
		return;
	}
	
	// Alright, load the plugins.
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsFolder error:nil];
	NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.whplugin'"];
	NSArray *plugins = [dirContents filteredArrayUsingPredicate:fltr];
	
	for(NSString *pluginPath in plugins) {
		NSBundle *bundle = [NSBundle bundleWithPath:[pluginsFolder stringByAppendingPathComponent:pluginPath]];
		
		if(!bundle) {
			return;
		}
		
		[bundle load];
		
		Class principalClass = [bundle principalClass];
		
		if([principalClass instancesRespondToSelector:@selector(handleMessage:)]) {
			[self registerClass:principalClass];
		} else if([principalClass respondsToSelector:@selector(loadPlugins)]) {
			[principalClass performSelector:@selector(loadPlugins)];
		} else {
			NSLog(@"Plugin '%@' not valid.", pluginPath);
			
			[bundle unload];
			
			continue;
		}
		
		[p_loadedBundles addObject:bundle];
	}
}

- (void)registerClass:(Class)klass {
	if(![klass isSubclassOfClass:[WHPlugin class]]) {
		return;
	}
	
	WHLog(@"Registered plugin class %@", NSStringFromClass(klass));
	
	WHPlugin *plugin = [[klass alloc] init];
	
	[p_pluginRegistry addObject:plugin];
}

- (BOOL)havePluginsHandleMessage:(IRCMessage *)message {
//	[p_pluginRegistry makeObjectsPerformSelector:@selector(reset)];
	
//	WHLog(@"%@", [message tags]);
	
	for(WHPlugin *plugin in p_pluginRegistry) {
		if(![plugin shouldHandleMessage:message]) {
			return YES; // We didn't do anything, but we need to swallow the message.
		}
	}
	
	for(WHPlugin *plugin in p_pluginRegistry) {
		if([plugin handleMessage:message]) {
			return YES;
		}
	}
	
	return NO;
}

@end
