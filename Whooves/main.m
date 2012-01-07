//
//  main.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRCBot.h"

#import "WHPluginManager.h"

#import "WHDateTime.h"

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		[[WHPluginManager sharedManager] registerClass:[WHDateTime class]];
		
		IRCBot *bot = [IRCBot sharedBot];
		
		bot.nick = @"Whooves";
		bot.user = @"Whooves";
		
		[bot connectToHost:@"irc.freenode.net" port:6667];
		
		[bot join:@"#derpyhooves"];
		
		[[NSRunLoop currentRunLoop] run];
	}
	
    return 0;
}

