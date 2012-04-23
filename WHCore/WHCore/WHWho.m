//
//  WHWho.m
//  Whooves
//
//  Created by Grant Butler on 1/18/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHWho.h"

@implementation WHWho

- (BOOL)handleMessage:(IRCMessage *)message {
	WHPluginFirstTag;
	
	if([tag isEqualToString:@"who"] || [tag isEqualToString:@"what"]) {
		WHPluginNextTag;
		
		if([tag isEqualToString:@"are"]) {
			WHPluginNextTag;
			
			if([tag isEqualToString:@"you"]) {
				// Alright, explain yourself.
			}
		}
	}
	
	return YES;
}

@end
