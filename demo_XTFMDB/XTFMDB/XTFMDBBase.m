//
//  XTFMDBBase.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "XTFMDBBase.h"
#import "NSObject+XTFMDB.h"
#import "NSObject+XTFMDB_Reflection.h"
#import "XTDBVersion.h"
#import "XTFMDBConst.h"

#define SQLITE_NAME(_name_) [_name_ stringByAppendingString:@".sqlite"]


@interface XTFMDBBase ()
@property (nonatomic, strong, readwrite) FMDatabase *database;
@end


@implementation XTFMDBBase
@synthesize version = _version;

+ (XTFMDBBase *)sharedInstance {
    static dispatch_once_t onceToken;
    static XTFMDBBase *singleton;
    dispatch_once(&onceToken, ^{
        singleton = [[XTFMDBBase alloc] init];
    });
    return singleton;
}

- (int)version {
    return [XTDBVersion xt_findFirst].version;
}

- (void)setVersion:(int)version {
    XTDBVersion *dbv = [XTDBVersion xt_findFirst];
    dbv.version      = version;
    [dbv xt_update];
    _version = version;
}

#pragma mark--
#pragma mark - configure
// deprecated
- (void)configureDB:(NSString *)name {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [self configureDB:name path:documentPath];
}
// deprecated
- (void)configureDB:(NSString *)name path:(NSString *)path {
    if (![name containsString:@".sqlite"]) name = SQLITE_NAME(name);

    XTFMDBLog(@"xt_db sqlName  : %@", name);
    NSString *finalPath = [path stringByAppendingPathComponent:name];
    [self configureDBWithPath:finalPath];
}

- (void)configureDBWithPath:(NSString *)finalPath {
    if (![finalPath containsString:@".sqlite"]) finalPath = SQLITE_NAME(finalPath);

    XTFMDBLog(@"xt_db path :\n%@", finalPath);
    DB = [FMDatabase databaseWithPath:finalPath];
    [DB open];

    QUEUE = [FMDatabaseQueue databaseQueueWithPath:finalPath];

    sqlUTIL = [[XTAutoSqlUtil alloc] init];

    [XTDBVersion xt_createTable];

    if (!self.version) {
        XTDBVersion *dbv = [XTDBVersion new];
        dbv.version      = 1;
        [dbv xt_insert];
    }
}

#pragma mark--

- (BOOL)verify {
    if (!DB) {
        XTFMDBLog(@"xt_db not exist");
        return FALSE;
    }
    if (![DB open]) {
        XTFMDBLog(@"xt_db open failed");
        return FALSE;
    }

    return TRUE;
}

- (BOOL)isTableExist:(NSString *)tableName {
    __block BOOL bExist;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bExist = [db tableExists:tableName];
        if (!bExist) {
            XTFMDBLog(@"xt_db %@ table not created", tableName);
        }
    }];
    return bExist;
}

#pragma mark--

- (void)dbUpgradeTable:(Class)tableCls
             paramsAdd:(NSArray *)paramsAdd
               version:(int)version {
    NSString *tableName = NSStringFromClass(tableCls);
    int dbVersion       = self.version;
    if (version <= dbVersion) {
        XTFMDBLog(@"xt_db already Upgraded. v%d for table %@", version, tableName);
        return;
    }
    if (![self isTableExist:tableName]) {
        return;
    }

    XTFMDBLog(
        @"xt_db upgrade start \ntable : %@ \nparamsAdd : %@\ndbversion : %d",
        tableName,
        paramsAdd,
        version);

    __block BOOL isError = NO;
    [paramsAdd enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *iosType = [tableCls iosTypeWithPropName:key];
        NSString *sqlType = [sqlUTIL sqlTypeWithType:iosType];
        if (!iosType) {
            XTFMDBLog(@"xt_db Upgraded fail no prop in %@", tableName);
            isError = YES;
            *stop   = YES;
        }
        if (!isError) {
            [tableCls performSelector:@selector(xt_alterAddColumn:type:)
                           withObject:key
                           withObject:sqlType];
        }
    }];
    if (isError)
        return;

    self.version = version;
    XTFMDBLog(@"xt_db Upgraded v%d complete", version);
}

@end
