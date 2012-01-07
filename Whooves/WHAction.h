//
//  WHAction.h
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHAction : NSObject

@property (strong) NSString *verb;
@property (strong) NSString *target;
@property (strong) NSString *what;

@property (strong) NSString *preposition;
@property (strong) NSString *condition;

@end
