//
//  WHPlugin.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHPlugin.h"
#import "WHPluginManager.h"

@implementation WHPlugin

//+ (void)initialize {
//	if(self != [WHPlugin class]) {
//		[[WHPluginManager sharedManager] registerClass:self];
//	}
//}

- (BOOL)handleObject:(id)obj forMessage:(IRCMessage *)message {
	return NO;
}

- (BOOL)handleMessage:(IRCMessage *)message {
	return NO;
}

- (NSString *)helpDescription {
	return nil;
}

@end
