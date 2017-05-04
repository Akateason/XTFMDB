//
//  XTFMDB.h
//  XTkit
//
//  Created by teason23 on 2017/4/28.
//  Copyright © 2017年 teason. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define QUEUE                         [XTFMDB sharedInstance].queue

@interface XTFMDB : NSObject

+ (XTFMDB *)sharedInstance ;

@property (nonatomic,strong,readonly) FMDatabase         *database   ;
@property (nonatomic,strong)          FMDatabaseQueue    *queue      ;

#pragma mark --

// config db in "- [(AppDelegate *) AppDidLaunchFinish]"
- (void)configureDB:(NSString *)name ;

- (BOOL)verify ;

- (BOOL)isTableExist:(NSString *)tableName ;

@end
