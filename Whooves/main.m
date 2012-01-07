//
//  main.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRCBot.h"

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		IRCBot *bot = [[IRCBot alloc] init];
		
		bot.nick = @"Whooves";
		bot.user = @"Whooves";
		
		[bot connectToHost:@"irc.freenode.net" port:6667];
		
		[[NSRunLoop currentRunLoop] run];
		
//		dispatch_queue_t mainQueue = dispatch_get_main_queue();
//		
//		dispatch_async(mainQueue, ^{
//			IRCBot *bot = [[IRCBot alloc] init];
//			[bot connectToHost:@"irc.freenode.net" port:6667];
//		});
//		
//		dispatch_main();
	}
	
    return 0;
}

