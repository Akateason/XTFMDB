//
//  XTFMDBBase.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

#define QUEUE                         [XTFMDBBase sharedInstance].queue
#define DB                            [XTFMDBBase sharedInstance].database

@interface XTFMDBBase : NSObject

+ (XTFMDBBase *)sharedInstance ;

@property (nonatomic,strong,readonly) FMDatabase         *database   ;
@property (nonatomic,strong)          FMDatabaseQueue    *queue      ;
@property (nonatomic)                 int                version     ;

#pragma mark --

/**
 db prepare config db in - [(AppDelegate *) AppDidLaunchFinish]
 also create table of dbVersion .
 
 @param name dbname
 @param path inpath
 */
- (void)configureDB:(NSString *)name
               path:(NSString *)path ;
- (void)configureDB:(NSString *)name ;

- (BOOL)verify ;

- (BOOL)isTableExist:(NSString *)tableName ;

/**
 DB Version Upgrade
 
 @param tableCls    Class
 @param paramsAdd   @[
                        propName1 ,
                        propName2 ,
                        ... ,
                    ]
 @param version (int) start from 1
 */
- (void)dbUpgradeTable:(Class)tableCls
             paramsAdd:(NSArray *)paramsAdd
               version:(int)version ;

@end
