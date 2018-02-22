//
//  XTFMDBBase.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "XTFMDBBase.h"
#import "XTFMDBConst.h"
#import "XTDBVersion.h"
#import "XTDBModel+autoSql.h"
#import "NSObject+XTFMDB_Reflection.h"

#define SQLITE_NAME( _name_ )   [name stringByAppendingString:@".sqlite"]

#define DB                      [XTFMDBBase sharedInstance].database

@interface XTFMDBBase ()
@property (nonatomic,strong,readwrite) FMDatabase         *database   ;
@end

@implementation XTFMDBBase
@synthesize version = _version ;

+ (XTFMDBBase *)sharedInstance
{
    static dispatch_once_t onceToken;
    static XTFMDBBase *singleton ;
    dispatch_once(&onceToken, ^{
        singleton = [[XTFMDBBase alloc] init] ;
    });
    return singleton ;
}

- (int)version
{
    return [XTDBVersion findFirst].version ;
}

- (void)setVersion:(int)version
{
    XTDBVersion *dbv = [XTDBVersion findFirst] ;
    dbv.version = version ;
    [dbv update] ;
    _version = version ;
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
    
    [XTDBVersion createTable] ;
    
    if (!self.version) {
        XTDBVersion *dbv = [XTDBVersion new] ;
        dbv.version = 1 ;
        [dbv insert] ;
    }
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

#pragma mark --

- (void)dbUpgradeTable:(Class)tableCls
             paramsAdd:(NSArray *)paramsAdd
               version:(int)version
{
    NSString *tableName = NSStringFromClass(tableCls) ;
    int dbVersion = self.version ;
    if (version <= dbVersion) {
        NSLog(@"xt_db already Upgraded. v%d",version) ;
        return ;
    }
    if (![self isTableExist:tableName]) {
        return ;
    }
    
    NSLog(@"xt_db upgrade start \ntable : %@ \nparamsAdd : %@\ndbversion : %d",tableName,paramsAdd,version) ;

    __block BOOL isError = NO ;
    [paramsAdd enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *iosType = [tableCls iosTypeWithPropName:key] ;
        NSString *sqlType = [XTDBModel sqlTypeWithType:iosType] ;
        if (!iosType) {
            NSLog(@"xt_db Upgraded fail no prop in %@",tableName) ;
            isError = YES ;
            *stop = YES ;
        }
        if (!isError) {
            [tableCls performSelector:@selector(alterAddColumn:type:)
                           withObject:key
                           withObject:sqlType] ;
        }
    }] ;
    if (isError) return ;
    
    self.version = version ;
    NSLog(@"xt_db Upgraded v%d complete",version) ;
}




@end
