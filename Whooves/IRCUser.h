//
//  IRCUser.h
//  Whooves
//
//  Created by Grant Butler on 3/3/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// v/+ - Voice
// h/% - Half-op
// o/@ - Op
// a/! - Admin
typedef NS_ENUM(NSUInteger, IRCUserRole) {
	IRCUserRoleNormal,
	IRCUserRoleVoice,
	IRCUserRoleHalfOp,
	IRCUserRoleOp,
	IRCUserRoleAdmin,
	IRCUserRoleOwner
};

@interface IRCUser : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong, readonly) NSMutableSet *channels;
@property (nonatomic, strong, readonly) NSMutableDictionary *channelRoles;

@property (nonatomic, strong, readonly) NSMutableDictionary *metadata;

+ (IRCUserRole)userRoleFromPrefix:(NSString *)prefix;
+ (IRCUserRole)userRoleFromMode:(NSString *)mode;

- (BOOL)isOpInChannel:(NSString *)channel;

- (void)joinChannel:(NSString *)channel role:(IRCUserRole)role;
- (void)changeRoleInChannel:(NSString *)channel toRole:(IRCUserRole)role;
- (void)partChannel:(NSString *)channel;

@end
