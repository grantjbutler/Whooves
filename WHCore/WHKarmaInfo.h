//
//  WHKarmaInfo.h
//  Whooves
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHKarmaInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) NSInteger karma;
@property (nonatomic, strong, readonly) NSMutableArray *pros;
@property (nonatomic, strong, readonly) NSMutableArray *cons;

@end
