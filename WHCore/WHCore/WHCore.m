//
//  WHCore.m
//  WHCore
//
//  Created by Grant Butler on 4/22/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "WHCore.h"

#import "WHPluginManager.h"

#import "WHDateTime.h"
#import "WHGreeting.h"
#import "WHOp.h"
#import "WHSilence.h"

@implementation WHCore

+ (void)loadPlugins {
	[[WHPluginManager sharedManager] registerClass:[WHDateTime class]];
	[[WHPluginManager sharedManager] registerClass:[WHGreeting class]];
	[[WHPluginManager sharedManager] registerClass:[WHOp class]];
	[[WHPluginManager sharedManager] registerClass:[WHSilence class]];
}

@end
