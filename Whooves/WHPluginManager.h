//
//  WHPluginManager.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WHPlugin.h"

#import "IRCMessage.h"

@interface WHPluginManager : NSObject

@property (nonatomic, strong, readonly) NSSet *plugins;

+ (WHPluginManager *)sharedManager;

- (void)registerClass:(Class)klass;

- (BOOL)havePluginsHandleMessage:(IRCMessage *)message;

- (void)reloadPlugins;

@end
