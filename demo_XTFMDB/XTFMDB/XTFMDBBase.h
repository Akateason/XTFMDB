//
//  XTFMDBBase.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define QUEUE                         [XTFMDBBase sharedInstance].queue


@interface XTFMDBBase : NSObject
+ (XTFMDBBase *)sharedInstance ;
@property (nonatomic,strong,readonly) FMDatabase         *database   ;
@property (nonatomic,strong)          FMDatabaseQueue    *queue      ;

#pragma mark --

// config db in "- [(AppDelegate *) AppDidLaunchFinish]"
- (void)configureDB:(NSString *)name ;
- (void)configureDB:(NSString *)name
               path:(NSString *)path ;

- (BOOL)verify ;

- (BOOL)isTableExist:(NSString *)tableName ;

@end
