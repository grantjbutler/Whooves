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

+ (WHPluginManager *)sharedManager;

- (void)registerClass:(Class)klass;

- (BOOL)havePluginsHandleObject:(id)obj forMessage:(IRCMessage *)message;

@end
