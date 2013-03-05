//
//  WHAbout.m
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "WHAbout.h"

NSString *const kDescription = @"I'm The Doctor. In pony form. Specifically, I'm an IRC bot written in Objective-C running on OS X. I'm also open source. Check me out at http://github.com/grantjbutler/Whooves/.";

@implementation WHAbout

- (NSString *)command {
	return @"about";
}

- (BOOL)handleMessage:(IRCMessage *)message {
	[message respond:kDescription];
	
	return YES;
}

@end
