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

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		// TODO: Possibly re-work this to use DDCLI for CLI arg parsing?
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *appSupport = [[paths lastObject] stringByAppendingPathComponent:@"Whooves"];
		
		NSString *settingsPlist = [appSupport stringByAppendingPathComponent:@"settings.plist"];
		
		IRCBot *bot = [IRCBot sharedBot];
		
		[bot loadSettingsFromFile:settingsPlist];
		
		[[WHPluginManager sharedManager] reloadPlugins];
		
#ifdef DEBUG
		[bot join:@"#derpyhooves"];
#else
		[bot join:@"#reddit-mlp"];
#endif
		
		[[NSRunLoop currentRunLoop] run];
	}
	
    return 0;
}

