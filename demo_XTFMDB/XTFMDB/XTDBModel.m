//
//  XTDBModel.m
//  XTkit
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel.h"
#import "XTFMDBBase.h"
#import "XTDBModel+autoSql.h"
#import "YYModel.h"
#import "XTFMDBConst.h"
#import "NSDate+XTTick.h"

@interface XTDBModel ()

@end

@implementation XTDBModel

#pragma mark --
#pragma mark - tableIsExist

+ (BOOL)tableIsExist
{
    NSString *tableName = NSStringFromClass([self class]) ;
    return [[XTFMDBBase sharedInstance] isTableExist:tableName] ;
}

#pragma mark --
#pragma mark - create

+ (BOOL)createTable
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
            if (bReturn) NSLog(@"xt_db create %@ success",tableName) ;
            else NSLog(@"xt_db create %@ fail",tableName) ;
        }] ;
    }
    else
        NSLog(@"xt_db %@ already exist",tableName) ;
    
    return bReturn ;
}

#pragma mark --
#pragma mark - insert

- (int)insert
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return -1 ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return -2 ;
    
    __block int lastRowId = 0 ;
    
    [QUEUE inDatabase:^(FMDatabase *db) {
        self.createTime = [NSDate xt_getNowTick] ;
        self.updateTime = [NSDate xt_getNowTick] ;
        BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlInsertWithModel:self]] ;
        if (bSuccess) {
            lastRowId = (int)[db lastInsertRowId] ;
            NSLog(@"xt_db insert success lastRowID : %d \n\n",lastRowId) ;
        }
        else {
            NSLog(@"xt_db insert fail\n\n") ;
            lastRowId = -3 ;
        }
    }] ;
    
    return lastRowId ;
}

+ (BOOL)insertList:(NSArray *)modelList
{
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++)
        {
            XTDBModel *model = [modelList objectAtIndex:i] ;
            model.createTime = [NSDate xt_getNowTick] ;
            model.updateTime = [NSDate xt_getNowTick] ;
            BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlInsertWithModel:model]] ;
            if (bSuccess) {
                NSLog(@"xt_db transaction insert Successfrom index :%d",i) ;
            }
            else {  // error
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

- (BOOL)update
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        self.updateTime = [NSDate xt_getNowTick] ;
        bSuccess = [db executeUpdate:[[XTDBModel class] sqlUpdateWithModel:self]] ;
        if (bSuccess) {
            NSLog(@"xt_db update success\n\n") ;
        }
        else {
            NSLog(@"xt_db update fail\n\n") ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)updateList:(NSArray *)modelList
{
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++) {
            
            XTDBModel *model = [modelList objectAtIndex:i] ;
            model.updateTime = [NSDate xt_getNowTick] ;
            BOOL bSuccess = [db executeUpdate:[[XTDBModel class] sqlUpdateWithModel:model]] ;
            if (bSuccess) {
                NSLog(@"xt_db transaction update Successfrom index :%d",i) ;
            }
            else {
                // error
                NSLog(@"xt_db transaction update Failure from index :%d",i) ;
                *rollback = TRUE ;
                bAllSuccess = FALSE ;
                break ;
            }
        }
        
        if (bAllSuccess) {
            NSLog(@"xt_db transaction update all complete \n\n") ;
        }
        else {
            NSLog(@"xt_db transaction update all fail \n\n") ;
        }
        
    }] ;
    
    return bAllSuccess ;
}

#pragma mark --
#pragma mark - select

+ (NSArray *)selectAll
{
    return [self selectWhere:nil] ;
}

+ (instancetype)findFirstWhere:(NSString *)strWhere
{
    return [[self selectWhere:strWhere] firstObject] ;
}

+ (instancetype)findFirst
{
    return [[self selectAll] firstObject] ;
}

+ (BOOL)hasModelWhere:(NSString *)strWhere
{
    return [self findFirstWhere:strWhere] != nil ;
}

+ (NSArray *)selectWhere:(NSString *)strWhere
{
    NSString *tableName = NSStringFromClass([self class]) ;
    NSString *sql = !strWhere
    ? [NSString stringWithFormat:@"SELECT * FROM %@",tableName]
    : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,strWhere] ;
    return [self findWithSql:sql] ;
}

// any sql execute Query
+ (NSArray *)findWithSql:(NSString *)sql
{
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return nil ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return nil ;
    
    __block NSMutableArray *resultList = [@[] mutableCopy] ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        NSLog(@"sql :\n %@",sql) ;
        FMResultSet *rs = [db executeQuery:sql] ;
        while ([rs next]) {
            NSDictionary *rstDic = [XTDBModel getResultDicFromClass:[self class]
                                                          resultSet:rs] ;
            [resultList addObject:[[self class] yy_modelWithDictionary:rstDic]] ;
        }
        [rs close] ;
    }] ;
    
    return resultList ;
}

+ (instancetype)findFirstWithSql:(NSString *)sql
{
    return [[self findWithSql:sql] firstObject] ;
}

// func execute Statements
+ (id)anyFuncWithSql:(NSString *)sql {
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

+ (int)count {
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT count(*) FROM %@",NSStringFromClass([self class])]] intValue] ;
}

+ (BOOL)isEmptyTable
{
    return ![self count] ;
}

+ (double)maxOf:(NSString *)property {
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT max(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)minOf:(NSString *)property {
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT min(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)sumOf:(NSString *)property {
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT sum(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

+ (double)avgOf:(NSString *)property {
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT avg(%@) FROM %@",property,NSStringFromClass([self class])]] doubleValue] ;
}

#pragma mark --
#pragma mark - delete

- (BOOL)deleteModel
{
    return [[self class] deleteModelWhere:[NSString stringWithFormat:@"pkid = '%d'",self.pkid]] ;
}

+ (BOOL)deleteModelWhere:(NSString *)strWhere
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

+ (BOOL)dropTable
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

+ (BOOL)alterAddColumn:(NSString *)name
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

+ (BOOL)alterRenameToNewTableName:(NSString *)name
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
#pragma mark - constrains

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






