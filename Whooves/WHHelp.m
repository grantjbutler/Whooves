//
//  WHHelp.m
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHHelp.h"
#import "WHPluginManager.h"
#import "WHPlugin+Private.h"

@implementation WHHelp

- (NSString *)command {
	return @"help";
}

- (BOOL)handleMessage:(IRCMessage *)message {
	if([message.messageComponents count] > 1) {
		NSString *command = message.messageComponents[1];
		
		if([command hasPrefix:[[IRCBot sharedBot] commandPrefix]]) {
			command = [command substringFromIndex:[[[IRCBot sharedBot] commandPrefix] length]];
		}
		
		for(WHPlugin *plugin in [[WHPluginManager sharedManager] plugins]) {
			if([plugin.commandRegex numberOfMatchesInString:command options:0 range:NSMakeRange(0, [command length])] <= 0) {
				continue;
			}
			
			NSString *response = [NSString stringWithFormat:@"Help for !%@: %@", command, plugin.helpDescription];
			
			[message respond:response];
			
			return YES;
		}
		
		[message respond:[NSString stringWithFormat:@"No plugin installed to handle command '%@%@'.", [[IRCBot sharedBot] commandPrefix], command]];
		
		return YES;
	}
	
	NSMutableArray *pluginCommands = [@[] mutableCopy];
	
	for(WHPlugin *plugin in [[WHPluginManager sharedManager] plugins]) {
		if([plugin.command length] > 0) {
			[pluginCommands addObject:[NSString stringWithFormat:@"%@%@", [[IRCBot sharedBot] commandPrefix], plugin.command]];
		} else if([plugin.commands count] > 1) {
			for(NSString *command in plugin.commands) {
				[pluginCommands addObject:[NSString stringWithFormat:@"%@%@", [[IRCBot sharedBot] commandPrefix], command]];
			}
		}
	}
	
	[message respond:[NSString stringWithFormat:@"I support the following commands. Type '%@help <command>' for more details.", [[IRCBot sharedBot] commandPrefix]]];
	[message respond:[pluginCommands componentsJoinedByString:@", "]];
	
	return YES;
}

@end
