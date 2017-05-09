//
//  NSObject+XTFMDB.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "NSObject+XTFMDB.h"
#import "XTFMDBBase.h"
#import "XTDBModel+autoSql.h"
#import "YYModel.h"
#import <objc/runtime.h>


static void *key_pkid = &key_pkid;

@implementation NSObject (XTFMDB)

#pragma mark --
- (void)setPkid:(int)pkid
{
    objc_setAssociatedObject(self, &key_pkid, @(pkid), OBJC_ASSOCIATION_ASSIGN) ;
}

- (int)pkid
{
    return [objc_getAssociatedObject(self, &key_pkid) intValue] ;
}


#pragma mark --
#pragma mark - tableIsExist
+ (BOOL)xt_tableIsExist
{
    NSString *tableName = NSStringFromClass([self class]) ;
    return [[XTFMDBBase sharedInstance] isTableExist:tableName] ;
}

#pragma mark --
#pragma mark - create
+ (BOOL)xt_createTable
{
    NSString *tableName = NSStringFromClass([self class]) ;
    
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    
    __block BOOL bReturn = FALSE ;
    
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName])
    {
        [QUEUE inDatabase:^(FMDatabase *db) {
            // create table
            NSString *sql = [[XTDBModel class] sqlCreateTableWithClass:[self class]] ;
            bReturn = [db executeUpdate:sql] ;
            if (bReturn) NSLog(@"xt_db create success") ;
            else NSLog(@"xt_db create fail") ;
        }] ;
    }
    else
        NSLog(@"xt_db already exist") ;
    
    return bReturn ;
}

#pragma mark --
#pragma mark - insert

- (int)xt_insert
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return -1 ;
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName]) return -2 ;
    
    __block int lastRowId = 0 ;
    
    [QUEUE inDatabase:^(FMDatabase *db) {
        BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlInsertWithModel:self]] ;
        if (bSuccess)
        {
            lastRowId = (int)[db lastInsertRowId] ;
            NSLog(@"xt_db insert success lastRowID : %d",lastRowId) ;
        }
        else
        {
            NSLog(@"xt_db insert fail") ;
            lastRowId = -3 ;
        }
    }] ;
    
    return lastRowId ;
}

+ (BOOL)xt_insertList:(NSArray *)modelList
{
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++)
        {
            id model = [modelList objectAtIndex:i] ;
            BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlInsertWithModel:model]] ;
            if (bSuccess)
            {
                NSLog(@"xt_db transaction insert Successfrom index :%d",i) ;
            }
            else
            {  // error
                NSLog(@"xt_db transaction insert Failure from index :%d",i) ;
                *rollback = TRUE ;
                bAllSuccess = FALSE ;
                break ;
            }
        }
        
        if (bAllSuccess) {
            NSLog(@"xt_db transaction insert all complete") ;
        }
        else {
            NSLog(@"xt_db transaction insert all fail") ;
        }
        
    }] ;
    
    return bAllSuccess ;
}



#pragma mark --
#pragma mark - update
- (BOOL)xt_update
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlUpdateWithModel:self]] ;
        if (bSuccess)
        {
            NSLog(@"xt_db update success") ;
        }
        else
        {
            NSLog(@"xt_db update fail") ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)xt_updateList:(NSArray *)modelList
{
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++)
        {
            id model = [modelList objectAtIndex:i] ;
            BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlUpdateWithModel:model]] ;
            if (bSuccess)
            {
                NSLog(@"xt_db transaction update Successfrom index :%d",i) ;
            }
            else
            {
                // error
                NSLog(@"xt_db transaction update Failure from index :%d",i) ;
                *rollback = TRUE ;
                bAllSuccess = FALSE ;
                break ;
            }
        }
        
        if (bAllSuccess) {
            NSLog(@"xt_db transaction update all complete") ;
        }
        else {
            NSLog(@"xt_db transaction update all fail") ;
        }
        
    }] ;
    
    return bAllSuccess ;
}

#pragma mark --
#pragma mark - select
+ (NSArray *)xt_selectAll
{
    return [self xt_selectWhere:nil] ;
}

+ (instancetype)xt_findFirstWhere:(NSString *)strWhere
{
    return [[self xt_selectWhere:strWhere] firstObject] ;
}

+ (BOOL)xt_hasModelWhere:(NSString *)strWhere
{
    return [self xt_selectWhere:strWhere].count > 0 ;
}

+ (NSArray *)xt_selectWhere:(NSString *)strWhere
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return nil ;
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName]) return nil ;
    
    __block NSMutableArray *resultList = [@[] mutableCopy] ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        
        NSString *sql = !strWhere
        ? [NSString stringWithFormat:@"SELECT * FROM %@",tableName]
        : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,strWhere] ;
        NSLog(@"sql :\n %@",sql) ;
        FMResultSet *rs = [db executeQuery:sql] ;
        while ([rs next])
        {
            [resultList addObject:[[self class] yy_modelWithDictionary:[rs resultDictionary]]] ;
        }
        [rs close] ;
    }] ;
    
    return resultList ;
}

#pragma mark --
#pragma mark - delete
- (BOOL)xt_deleteModel
{
    return [[self class] deleteModelWhere:[NSString stringWithFormat:@"pkid = '%d'",self.pkid]] ;
}

+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlDeleteWithTableName:tableName where:strWhere]] ;
        if (bSuccess)
        {
            NSLog(@"xt_db delete model success") ;
        }
        else
        {
            NSLog(@"xt_db delete model fail") ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)xt_dropTable
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[[XTDBModel class] drop:tableName]] ;
        if (bSuccess)
        {
            NSLog(@"xt_db drop success") ;
        }
        else
        {
            NSLog(@"xt_db drop fail") ;
        }
    }] ;
    
    return bSuccess ;
}

#pragma mark --
#pragma mark -
// rewrite in subClass if Needed .
// set constraints of properties
+ (NSDictionary *)modelPropertiesSqliteKeywords
{
    return nil ;
}

// rewrite in subClass if Needed .
// ignore Properties
+ (NSArray *)ignoreProperties
{
    return nil ;
}

@end
