//
//  IRCUser.m
//  Whooves
//
//  Created by Grant Butler on 3/3/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import "IRCUser.h"

@implementation IRCUser

+ (IRCUserRole)userRoleFromPrefix:(NSString *)prefix {
	if([prefix isEqualToString:@"+"]) {
		return IRCUserRoleVoice;
	} else if([prefix isEqualToString:@"%"]) {
		return IRCUserRoleHalfOp;
	} else if([prefix isEqualToString:@"@"]) {
		return IRCUserRoleOp;
	} else if([prefix isEqualToString:@"!"]) {
		return IRCUserRoleAdmin;
	} else {
		NSLog(@"Encountered unknown prefix: %@", prefix);
	}
	
	return IRCUserRoleNormal;
}

+ (IRCUserRole)userRoleFromMode:(NSString *)mode {
	IRCUserRole role = IRCUserRoleNormal;
	
	for(NSInteger i = 0; i < [mode length]; i++) {
		unichar aMode = [mode characterAtIndex:i];
		
		if(aMode == 'v') {
			if(role < IRCUserRoleVoice) {
				role = IRCUserRoleVoice;
			}
		} else if(aMode == 'h') {
			if(role < IRCUserRoleHalfOp) {
				role = IRCUserRoleHalfOp;
			}
		} else if(aMode == 'o') {
			if(role < IRCUserRoleOp) {
				role = IRCUserRoleOp;
			}
		} else if(aMode == 'a') {
			if(role < IRCUserRoleAdmin) {
				role = IRCUserRoleAdmin;
			}
		}
	}
	
	return role;
}

- (id)init {
	if((self = [super init])) {
		_channelRoles = [[NSMutableDictionary alloc] init];
		_channels = [[NSMutableSet alloc] init];
		
		_metadata = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[NSString class]]) {
		return [object isEqualToString:self.username];
	} else if([object isKindOfClass:[IRCUser class]]) {
		return [((IRCUser *)object).username isEqualToString:self.username];
	}
	
	return NO;
}

- (BOOL)isOpInChannel:(NSString *)channel {
	if(![self.channels containsObject:channel]) {
		return NO;
	}
	
	return ([self.channelRoles[channel] intValue] >= IRCUserRoleOp);
}

- (void)joinChannel:(NSString *)channel role:(IRCUserRole)role {
	if([_channels containsObject:channel]) {
		return;
	}
	
	[_channels addObject:channel];
	[_channelRoles setObject:[NSNumber numberWithInteger:role] forKey:channel];
}

- (void)changeRoleInChannel:(NSString *)channel toRole:(IRCUserRole)role {
	if(![_channels containsObject:channel]) {
		return;
	}
	
	[_channelRoles setObject:[NSNumber numberWithInteger:role] forKey:channel];
}

- (void)partChannel:(NSString *)channel {
	if(![_channels containsObject:channel]) {
		return;
	}
	
	[_channels removeObject:channel];
	[_channelRoles removeObjectForKey:channel];
}

@end
