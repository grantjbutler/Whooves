//
//  WHLocalStorage.h
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHLocalStorage : NSObject

- (id)initWithPath:(NSString *)path;

- (void)synchronize;

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey;
- (id)objectForKey:(id)aKey;

@end
