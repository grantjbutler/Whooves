//
//  IRCBot.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRCBot : NSObject

@property (strong) NSString *user;
@property (strong) NSString *nick;
@property (strong) NSString *pass;

@property (strong) NSString *owner;

@property (strong, readwrite) NSMutableArray *ops;

+ (IRCBot *)sharedBot;

- (void)connectToHost:(NSString *)host port:(NSUInteger)port;

- (void)join:(NSString *)channel;

- (void)loadSettingsFromFile:(NSString *)path;

- (void)write:(NSString *)format, ...;

@end
