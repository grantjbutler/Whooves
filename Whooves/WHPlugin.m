//
//  WHPlugin.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHPlugin+Private.h"
#import "WHPluginManager.h"

static NSString *kWHPluginLocalStoragePath = nil;

@implementation WHPlugin {
	NSRegularExpression *_commandRegex;
	
	WHLocalStorage *_localStorage;
}

+ (void)initialize {
	if(self == [WHPlugin class]) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *appSupport = [[paths lastObject] stringByAppendingPathComponent:@"Whooves"];
		kWHPluginLocalStoragePath = [appSupport stringByAppendingPathComponent:@"LocalStorage"];
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:kWHPluginLocalStoragePath]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:kWHPluginLocalStoragePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
}

- (BOOL)shouldHandleMessage:(IRCMessage *)message {
	return YES;
}

- (NSString *)helpDescription {
	return @"";
}

- (NSArray *)commands {
	return @[self.command];
}

- (NSString *)command {
	return @"";
}

- (NSRegularExpression *)commandRegex {
	if(!_commandRegex) {
		NSString *command = @"";
		
		if([self.command length] > 0) {
			command = self.command;
		} else if([self.commands count] > 1) {
			command = [NSString stringWithFormat:@"(%@)", [self.commands componentsJoinedByString:@"|"]];
		}
		
		_commandRegex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"^%@$", command] options:0 error:nil];
	}
	
	return _commandRegex;
}

- (WHLocalStorage *)localStorage {
	if(!_localStorage) {
		NSString *pluginStoragePath = [kWHPluginLocalStoragePath stringByAppendingPathComponent:NSStringFromClass([self class])];
		pluginStoragePath = [pluginStoragePath stringByAppendingPathExtension:@"lstorage"];
		
		_localStorage = [[WHLocalStorage alloc] initWithPath:pluginStoragePath];
	}
	
	return _localStorage;
}

- (void)unload {
	if(_localStorage) {
		[_localStorage synchronize];
	}
}

@end
