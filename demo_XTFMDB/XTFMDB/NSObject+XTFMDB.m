//
//  NSObject+XTFMDB.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "NSObject+XTFMDB.h"
#import "XTFMDBConst.h"
#import "XTFMDBBase.h"
#import <YYModel/YYModel.h>
#import <objc/runtime.h>
#import "NSDate+XTFMDB_Tick.h"
#import "XTDBModel.h"


static void *key_pkid = &key_pkid ;

@implementation NSObject (XTFMDB)

#pragma mark --

- (void)setPkid:(int)pkid {
    objc_setAssociatedObject(self, &key_pkid, @(pkid), OBJC_ASSOCIATION_ASSIGN) ;
}

- (int)pkid {
    return [objc_getAssociatedObject(self, &key_pkid) intValue] ;
}


#pragma mark --
#pragma mark - tableIsExist
+ (BOOL)xt_tableIsExist {
    NSString *tableName = NSStringFromClass([self class]) ;
    return [[XTFMDBBase sharedInstance] isTableExist:tableName] ;
}

#pragma mark --
#pragma mark - create
+ (BOOL)xt_createTable {
    NSString *tableName = NSStringFromClass([self class]) ;
    
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    
    __block BOOL bReturn = FALSE ;
    
    if(![[XTFMDBBase sharedInstance] isTableExist:tableName]) {
        [QUEUE inDatabase:^(FMDatabase *db) {
            // create table
            NSString *sql = [sqlUTIL sqlCreateTableWithClass:[self class]] ;
            bReturn = [db executeUpdate:sql] ;
            if (bReturn) XTFMDBLog(@"xt_db create %@ success",tableName) ;
            else XTFMDBLog(@"xt_db create %@ fail",tableName) ;
        }] ;
    }
    else
        XTFMDBLog(@"xt_db %@ already exist",tableName) ;
    
    return bReturn ;
}

#pragma mark --
#pragma mark - insert

- (int)xt_insert {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return -1 ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return -2 ;
    
    __block int lastRowId = 0 ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        BOOL bSuccess = [db executeUpdate:[sqlUTIL sqlInsertWithModel:self]] ;
        if (bSuccess) {
            lastRowId = (int)[db lastInsertRowId] ;
            XTFMDBLog(@"xt_db insert success lastRowID : %d fromTB %@ \n\n",lastRowId,tableName) ;
        }
        else {
            XTFMDBLog(@"xt_db insert fail fromTB %@\n\n",tableName) ;
            lastRowId = -3 ;
        }
    }] ;
    
    return lastRowId ;
}

+ (BOOL)xt_insertList:(NSArray *)modelList {
    if (!modelList || !modelList.count) FALSE ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++) {
            id model = [modelList objectAtIndex:i] ;
            BOOL bSuccess = [db executeUpdate:[sqlUTIL sqlInsertWithModel:model]] ;
            if (bSuccess) {
                XTFMDBLog(@"xt_db transaction insert Successfrom index :%d",i) ;
            }
            else {  // error
                XTFMDBLog(@"xt_db transaction insert Failure from index :%d",i) ;
                *rollback = TRUE ;
                bAllSuccess = FALSE ;
                break ;
            }
        }
        
        if (bAllSuccess)
            XTFMDBLog(@"xt_db transaction insert all complete in %@\n\n",NSStringFromClass([self class])) ;
        else
            XTFMDBLog(@"xt_db transaction insert all fail in %@\n\n",NSStringFromClass([self class])) ;
    }] ;
    
    return bAllSuccess ;
}



#pragma mark --
#pragma mark - update

// update by pkid .
- (BOOL)xt_update {
    return [self xt_updateWhereByProp:kPkid] ;
}

+ (BOOL)xt_updateList:(NSArray *)modelList {
    return [self xt_updateList:modelList whereByProp:kPkid] ;
}

// update by custom key .
- (BOOL)xt_updateWhereByProp:(NSString *)propName {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlUpdateSetWhereWithModel:self whereBy:propName]] ;
        if (bSuccess) {
            XTFMDBLog(@"xt_db update success from tb %@ \n\n",tableName) ;
        }
        else {
            XTFMDBLog(@"xt_db update fail from tb %@ \n\n",tableName) ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)xt_updateList:(NSArray *)modelList
          whereByProp:(NSString *)propName
{
    if (!modelList || !modelList.count) return FALSE ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++) {
            
            id model = [modelList objectAtIndex:i] ;
            BOOL bSuccess = [db executeUpdate:[sqlUTIL sqlUpdateSetWhereWithModel:model whereBy:propName]] ;
            if (bSuccess) {
                XTFMDBLog(@"xt_db transaction update Successfrom index :%d",i) ;
            }
            else {
                // error
                XTFMDBLog(@"xt_db transaction update Failure from index :%d",i) ;
                *rollback = TRUE ;
                bAllSuccess = FALSE ;
                break ;
            }
        }
        
        if (bAllSuccess)
            XTFMDBLog(@"xt_db transaction update all complete \n\n") ;
        else
            XTFMDBLog(@"xt_db transaction update all fail \n\n") ;
    }] ;
    
    return bAllSuccess ;
}


#pragma mark --
#pragma mark - select

+ (NSArray *)xt_selectAll {
    return [self xt_selectWhere:nil] ;
}

+ (instancetype)xt_findFirstWhere:(NSString *)strWhere {
    return [[self xt_selectWhere:strWhere] firstObject] ;
}

+ (instancetype)xt_findFirst {
    return [[self xt_selectAll] firstObject] ;
}

+ (BOOL)xt_hasModelWhere:(NSString *)strWhere {
    return [self xt_findFirstWhere:strWhere] != nil ;
}

+ (NSArray *)xt_selectWhere:(NSString *)strWhere {
    NSString *tableName = NSStringFromClass([self class]) ;
    NSString *sql = !strWhere
    ? [NSString stringWithFormat:@"SELECT * FROM %@",tableName]
    : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,strWhere] ;
    return [self xt_findWithSql:sql] ;
}

// any sql
+ (NSArray *)xt_findWithSql:(NSString *)sql {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return nil ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return nil ;
    
    __block NSMutableArray *resultList = [@[] mutableCopy] ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        XTFMDBLog(@"sql :\n %@",sql) ;
        FMResultSet *rs = [db executeQuery:sql] ;
        while ([rs next]) {
            NSDictionary *rstDic = [sqlUTIL getResultDicFromClass:[self class]
                                                        resultSet:rs] ;
            id resultItem = [[self class] yy_modelWithJSON:rstDic] ;
            resultItem = [sqlUTIL resetDictionaryFromDBModel:rstDic resultItem:resultItem] ;
            [resultList addObject:resultItem] ;
        }
        [rs close] ;
    }] ;
    
    return resultList ;
}

+ (instancetype)xt_findFirstWithSql:(NSString *)sql {
    return [[self xt_findWithSql:sql] firstObject] ;
}

+ (id)xt_anyFuncWithSql:(NSString *)sql {
    __block id val ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        XTFMDBLog(@"sql :\n %@",sql) ;
        [db executeStatements:sql
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  val = [resultsDictionary.allValues lastObject] ;
                  return 0 ;
              }] ;
    }] ;
    return !((NSNull *)val == [NSNull null]) ? val : nil ;
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
- (BOOL)xt_deleteModel {
    return [[self class] xt_deleteModelWhere:[NSString stringWithFormat:@"pkid = '%lu'",(unsigned long)self.pkid]] ;
}

+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlDeleteWithTableName:tableName where:strWhere]] ;
        if (bSuccess)
            XTFMDBLog(@"xt_db delete model success in %@\n\n",tableName) ;
        else
            XTFMDBLog(@"xt_db delete model fail in %@\n\n",tableName) ;
    }] ;
    
    return bSuccess ;
}

+ (BOOL)xt_dropTable {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlDrop:tableName]] ;
        if (bSuccess)
            XTFMDBLog(@"xt_db drop %@ success\n\n",tableName) ;
        else
            XTFMDBLog(@"xt_db drop %@ fail\n\n",tableName) ;
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
        bSuccess = [db executeUpdate:[sqlUTIL sqlAlterAdd:name
                                                               type:type
                                                              table:tableName]] ;
        if (bSuccess)
            XTFMDBLog(@"xt_db alter add success in %@\n\n",tableName) ;
        else
            XTFMDBLog(@"xt_db alter add fail in %@\n\n",tableName) ;
    }] ;
    return bSuccess ;
}

+ (BOOL)xt_alterRenameToNewTableName:(NSString *)name {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlAlterRenameOldTable:tableName
                                                      toNewTableName:name]] ;
        if (bSuccess)
            XTFMDBLog(@"xt_db alter rename success in %@\n\n",tableName) ;
        else
            XTFMDBLog(@"xt_db alter rename fail in %@\n\n",tableName) ;
    }] ;
    return bSuccess ;
}

#pragma mark --
#pragma mark - rewrite in subClass if Needed .

// set constraints of properties
+ (NSDictionary *)modelPropertiesSqliteKeywords
{
    return nil ;
}

// ignore Properties
+ (NSArray *)ignoreProperties
{
    return nil ;
}

// Container property , value should be Class or Class name. Same as YYmodel .
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return nil ;
}

@end
