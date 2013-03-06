//
//  WHCore.m
//  WHCore
//
//  Created by Grant Butler on 4/22/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHCore.h"

#import "WHPluginManager.h"

#import "WHAbout.h"
#import "WHKarma.h"
#import "WHJoin.h"
#import "WHDigest.h"
#import "WHLeave.h"

@implementation WHCore

+ (void)loadPlugins {
	[[WHPluginManager sharedManager] registerClass:[WHAbout class]];
	[[WHPluginManager sharedManager] registerClass:[WHKarma class]];
	[[WHPluginManager sharedManager] registerClass:[WHJoin class]];
	[[WHPluginManager sharedManager] registerClass:[WHDigest class]];
	[[WHPluginManager sharedManager] registerClass:[WHLeave class]];
}

@end
