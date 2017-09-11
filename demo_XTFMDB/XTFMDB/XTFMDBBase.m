//
//  XTFMDBBase.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "XTFMDBBase.h"
#import "XTFMDBConst.h"

#define SQLITE_NAME( _name_ )   [name stringByAppendingString:@".sqlite"]

#define DB                      [XTFMDBBase sharedInstance].database

@interface XTFMDBBase ()
@property (nonatomic,strong,readwrite) FMDatabase         *database   ;
@end

@implementation XTFMDBBase

+ (XTFMDBBase *)sharedInstance
{
    static dispatch_once_t onceToken;
    static XTFMDBBase *singleton ;
    dispatch_once(&onceToken, ^{
        singleton = [[XTFMDBBase alloc] init] ;
    });
    return singleton ;
}

#pragma mark --
#pragma mark - configure
- (void)configureDB:(NSString *)name
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] ;
    [self configureDB:name
                 path:documentPath] ;
}

- (void)configureDB:(NSString *)name
               path:(NSString *)path
{
    NSLog(@"xt_db path :\n%@", path) ;
    NSLog(@"xt_db sqlName  : %@",name) ;
    NSString *finalPath = [path stringByAppendingPathComponent:SQLITE_NAME(name)] ;
    
    DB = [FMDatabase databaseWithPath:finalPath] ;
    [DB open] ;
    QUEUE = [FMDatabaseQueue databaseQueueWithPath:finalPath] ;
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
