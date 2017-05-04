//
//  XTFMDB.m
//  XTkit
//
//  Created by teason23 on 2017/4/28.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTFMDB.h"

#define SQLITE_NAME( _name_ )   [name stringByAppendingString:@".sqlite"]

#define DB                      [XTFMDB sharedInstance].database


@interface XTFMDB ()

@property (nonatomic,strong,readwrite) FMDatabase         *database   ;

@end



@implementation XTFMDB

+ (XTFMDB *)sharedInstance
{
    static dispatch_once_t onceToken;
    static XTFMDB *singleton ;                                      \
    dispatch_once(&onceToken, ^{
        singleton = [[XTFMDB alloc] init] ;
    });
    return singleton ;
}

#pragma mark --
#pragma mark - configure
- (void)configureDB:(NSString *)name
{
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
    NSString *documentPath = [filePath firstObject] ;
    NSLog(@"xt_db documentPath :\n%@", documentPath) ;
    NSLog(@"xt_db sqlName  : %@",name) ;
    NSString *path = [documentPath stringByAppendingPathComponent:SQLITE_NAME(name)] ;
    DB = [FMDatabase databaseWithPath:path] ;
    [DB open] ;
    QUEUE = [FMDatabaseQueue databaseQueueWithPath:path] ;
}

#pragma mark --

- (BOOL)verify
{
    if (!DB) {
        NSLog(@"xt_db not exist") ;
        return FALSE;
    }
    if (![DB open]) {
        NSLog(@"xt_db open failed") ;
        return FALSE;
    }
    
    return TRUE ;
}

- (BOOL)isTableExist:(NSString *)tableName
{
    BOOL bExist = [DB tableExists:tableName] ;
    if (!bExist) NSLog(@"xt_db table not created") ;
    return bExist ;
}

@end
