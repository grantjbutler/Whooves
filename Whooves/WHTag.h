//
//  WHTag.h
//  Whooves
//
//  Created by Grant Butler on 1/8/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHTag : NSObject

@property (strong, readonly) NSString *tag;
@property (strong, readonly) NSString *word;

- (id)initWithTag:(NSString *)tag word:(NSString *)word;

- (BOOL)isEqualToString:(NSString *)string;

@end
