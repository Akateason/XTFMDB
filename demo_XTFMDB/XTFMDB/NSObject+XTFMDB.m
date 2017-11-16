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
#import "XTFMDBConst.h"

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
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return -2 ;
    
    __block int lastRowId = 0 ;
    
    [QUEUE inDatabase:^(FMDatabase *db) {
        BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlInsertWithModel:self]] ;
        if (bSuccess)
        {
            lastRowId = (int)[db lastInsertRowId] ;
            NSLog(@"xt_db insert success lastRowID : %d \n\n",lastRowId) ;
        }
        else
        {
            NSLog(@"xt_db insert fail\n\n") ;
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
            NSLog(@"xt_db transaction insert all complete\n\n") ;
        }
        else {
            NSLog(@"xt_db transaction insert all fail\n\n") ;
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
            NSLog(@"xt_db update success\n\n") ;
        }
        else
        {
            NSLog(@"xt_db update fail\n\n") ;
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
            NSLog(@"xt_db transaction update all complete\n\n") ;
        }
        else {
            NSLog(@"xt_db transaction update all fail\n\n") ;
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
    return [self xt_findFirstWhere:strWhere] != nil ;
}

+ (NSArray *)xt_selectWhere:(NSString *)strWhere
{
    NSString *tableName = NSStringFromClass([self class]) ;
    NSString *sql = !strWhere
    ? [NSString stringWithFormat:@"SELECT * FROM %@",tableName]
    : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,strWhere] ;
    return [self xt_findWithSql:sql] ;
}

// any sql
+ (NSArray *)xt_findWithSql:(NSString *)sql
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return nil ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return nil ;
    
    __block NSMutableArray *resultList = [@[] mutableCopy] ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        NSLog(@"sql :\n %@",sql) ;
        FMResultSet *rs = [db executeQuery:sql] ;
        while ([rs next])
        {
            NSDictionary *rstDic = [XTDBModel getResultDicFromClass:[self class]
                                                          resultSet:rs] ;
            [resultList addObject:[[self class] yy_modelWithDictionary:rstDic]] ;
        }
        [rs close] ;
    }] ;
    
    return resultList ;
}

+ (instancetype)xt_findFirstWithSql:(NSString *)sql
{
    return [[self xt_findWithSql:sql] firstObject] ;
}

+ (id)xt_anyFuncWithSql:(NSString *)sql {
    __block id val ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        NSLog(@"sql :\n %@",sql) ;
        [db executeStatements:sql
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  val = [resultsDictionary.allValues lastObject] ;
                  return 0 ;
              }] ;
    }] ;
    return val ;
}

+ (int)xt_count {
    return [[self xt_anyFuncWithSql:[NSString stringWithFormat:@"SELECT count(*) FROM %@",NSStringFromClass([self class])]] intValue] ;
}

+ (BOOL)xt_isEmptyTable {
    return ![self xt_count] ;
}

+ (double)xt_maxOf:(NSString *)property {
    return [[self xt_anyFuncWithSql:[NSString stringWithFormat:@"SELECT max(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)xt_minOf:(NSString *)property {
    return [[self xt_anyFuncWithSql:[NSString stringWithFormat:@"SELECT min(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)xt_sumOf:(NSString *)property {
    return [[self xt_anyFuncWithSql:[NSString stringWithFormat:@"SELECT sum(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)xt_avgOf:(NSString *)property {
    return [[self xt_anyFuncWithSql:[NSString stringWithFormat:@"SELECT avg(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

#pragma mark --
#pragma mark - delete
- (BOOL)xt_deleteModel
{
    return [[self class] xt_deleteModelWhere:[NSString stringWithFormat:@"pkid = '%d'",self.pkid]] ;
}

+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlDeleteWithTableName:tableName where:strWhere]] ;
        if (bSuccess)
        {
            NSLog(@"xt_db delete model success\n\n") ;
        }
        else
        {
            NSLog(@"xt_db delete model fail\n\n") ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)xt_dropTable
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlDrop:tableName]] ;
        if (bSuccess)
        {
            NSLog(@"xt_db drop success\n\n") ;
        }
        else
        {
            NSLog(@"xt_db drop fail\n\n") ;
        }
    }] ;
    
    return bSuccess ;
}


#pragma mark - alter

+ (BOOL)xt_alterAddColumn:(NSString *)name
                     type:(NSString *)type
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlAlterAdd:name
                                                               type:type
                                                              table:tableName]] ;
        if (bSuccess) {
            NSLog(@"xt_db alter add success\n\n") ;
        }
        else {
            NSLog(@"xt_db alter add fail\n\n") ;
        }
    }] ;
    return bSuccess ;
}

+ (BOOL)xt_alterRenameToNewTableName:(NSString *)name
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlAlterRenameOldTable:tableName
                                                                toNewTableName:name]] ;
        if (bSuccess) {
            NSLog(@"xt_db alter add success\n\n") ;
        }
        else {
            NSLog(@"xt_db alter add fail\n\n") ;
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
