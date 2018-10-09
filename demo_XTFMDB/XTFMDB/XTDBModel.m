//
//  XTDBModel.m
//  XTlib
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel.h"
#import "XTFMDBBase.h"
#import <YYModel/YYModel.h>
#import "XTFMDBConst.h"
#import "NSDate+XTFMDB_Tick.h"
#import "XTAutoSqlUtil.h"

NSString *const kPkid = @"pkid";


@interface XTDBModel ()

@end

@implementation XTDBModel

#pragma mark --
#pragma mark - tableIsExist

+ (BOOL)tableIsExist {
    NSString *tableName = NSStringFromClass([self class]) ;
    return [[XTFMDBBase sharedInstance] isTableExist:tableName] ;
}

#pragma mark --
#pragma mark - create

+ (BOOL)createTable {
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
    else XTFMDBLog(@"xt_db %@ already exist",tableName) ;
    
    return bReturn ;
}

#pragma mark --
#pragma mark - insert

typedef NS_ENUM(NSUInteger, XTFMDB_insertWay) {
    xt_insertWay_insert,
    xt_insertWay_insertOrIgnore,
    xt_insertWay_insertOrReplace
};

- (BOOL)insertByWay:(XTFMDB_insertWay)way {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return -1 ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return -2 ;
    
    __block BOOL bSuccess ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        self.createTime = [NSDate xt_getNowTick] ;
        self.updateTime = [NSDate xt_getNowTick] ;
        
        switch (way) {
            case xt_insertWay_insert:           bSuccess = [db executeUpdate:[sqlUTIL sqlInsertWithModel:self]] ;           break ;
            case xt_insertWay_insertOrIgnore:   bSuccess = [db executeUpdate:[sqlUTIL sqlInsertOrIgnoreWithModel:self]] ;   break ;
            case xt_insertWay_insertOrReplace:  bSuccess = [db executeUpdate:[sqlUTIL sqlInsertOrReplaceWithModel:self]] ;  break ;
            default: break ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)insertList:(NSArray *)modelList byWay:(XTFMDB_insertWay)way {
    if (!modelList || !modelList.count) return FALSE ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++) {
            XTDBModel *model = [modelList objectAtIndex:i] ;
            model.createTime = [NSDate xt_getNowTick] ;
            model.updateTime = [NSDate xt_getNowTick] ;
            
            BOOL bSuccess ;
            switch (way) {
                case xt_insertWay_insert:           bSuccess = [db executeUpdate:[sqlUTIL sqlInsertWithModel:model]] ;           break ;
                case xt_insertWay_insertOrIgnore:   bSuccess = [db executeUpdate:[sqlUTIL sqlInsertOrIgnoreWithModel:model]] ;   break ;
                case xt_insertWay_insertOrReplace:  bSuccess = [db executeUpdate:[sqlUTIL sqlInsertOrReplaceWithModel:model]] ;  break ;
                default: break ;
            }
            
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
        
        if (bAllSuccess) {
            XTFMDBLog(@"xt_db transaction insert %@ all complete\n\n",NSStringFromClass([self class])) ;
        }
        else {
            XTFMDBLog(@"xt_db transaction insert %@ all fail\n\n",NSStringFromClass([self class])) ;
        }
        
    }] ;
    
    return bAllSuccess ;
}

- (BOOL)insert {
    return [self insertByWay:xt_insertWay_insert] ;
}

+ (BOOL)insertList:(NSArray *)modelList {
    return [self insertList:modelList byWay:xt_insertWay_insert] ;
}

- (BOOL)insertOrIgnore {
    return [self insertByWay:xt_insertWay_insertOrIgnore] ;
}

+ (BOOL)insertOrIgnoreWithList:(NSArray *)modelList {
    return [self insertList:modelList byWay:xt_insertWay_insertOrIgnore] ;
}

- (BOOL)insertOrReplace {
    return [self insertByWay:xt_insertWay_insertOrReplace] ;
}

+ (BOOL)insertOrReplaceWithList:(NSArray *)modelList {
    return [self insertList:modelList byWay:xt_insertWay_insertOrReplace] ;
}

- (BOOL)upsertWhereByProp:(NSString *)propName {
    BOOL exist = [[self class] hasModelWhere:[NSString stringWithFormat:@"%@ == '%@'",propName,[self valueForKey:propName]]] ;
    if (exist) {
        return [self updateWhereByProp:propName] ;
    }
    else {
        return [self insert] ;
    }
}

#pragma mark --
#pragma mark - update

// update by pkid .
- (BOOL)update {
    if (!self.pkid) {
        NSString *tableName = NSStringFromClass([self class]) ;
        XTFMDBLog(@"xt_db update fail from tb %@ \n Error pkid in nil \n",tableName) ;
        return NO ;
    }
    
    return [self updateWhereByProp:kPkid] ;
}

+ (BOOL)updateList:(NSArray *)modelList {
    return [self updateList:modelList whereByProp:kPkid] ;
}

// update by custom key .
- (BOOL)updateWhereByProp:(NSString *)propName {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        self.updateTime = [NSDate xt_getNowTick] ;
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

+ (BOOL)updateList:(NSArray *)modelList
       whereByProp:(NSString *)propName
{
    if (!modelList || !modelList.count) return FALSE ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:NSStringFromClass([[modelList firstObject] class])]) return FALSE ;
    
    __block BOOL bAllSuccess = TRUE ;
    [QUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [modelList count]; i++) {
            
            XTDBModel *model = [modelList objectAtIndex:i] ;
            model.updateTime = [NSDate xt_getNowTick] ;
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

+ (NSArray *)selectAll {
    return [self selectWhere:nil] ;
}

+ (instancetype)findFirstWhere:(NSString *)strWhere {
    return [[self selectWhere:strWhere] firstObject] ;
}

+ (instancetype)findFirst {
    return [[self selectAll] firstObject] ;
}

+ (BOOL)hasModelWhere:(NSString *)strWhere {
    return [self findFirstWhere:strWhere] != nil ;
}

+ (NSArray *)selectWhere:(NSString *)strWhere {
    NSString *tableName = NSStringFromClass([self class]) ;
    NSString *sql = !strWhere
    ? [NSString stringWithFormat:@"SELECT * FROM %@",tableName]
    : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,strWhere] ;
    return [self findWithSql:sql] ;
}

// any sql execute Query
+ (NSArray *)findWithSql:(NSString *)sql {
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
            id result = [[self class] yy_modelWithDictionary:rstDic] ;
            result = [sqlUTIL resetDictionaryFromDBModel:rstDic resultItem:result] ;            
            [resultList addObject:result] ;
        }
        [rs close] ;
    }] ;
    
    return resultList ;
}

+ (instancetype)findFirstWithSql:(NSString *)sql {
    return [[self findWithSql:sql] firstObject] ;
}

// func execute Statements
+ (id)anyFuncWithSql:(NSString *)sql {
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

+ (BOOL)isEmptyTable {
    return ![self count] ;
}

+ (int)count {
    return [self countWhere:nil] ;
}

+ (int)countWhere:(NSString *)whereStr {
    whereStr = whereStr ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"" ;
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT count(*) FROM %@ %@",NSStringFromClass([self class]),whereStr]] intValue] ;
}

+ (double)maxOf:(NSString *)property {
    return [self maxOf:property where:nil] ;
}

+ (double)maxOf:(NSString *)property where:(NSString *)whereStr {
    whereStr = whereStr ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"" ;
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT max(%@) FROM %@ %@",property,NSStringFromClass([self class]),whereStr]] doubleValue] ;
}

+ (double)minOf:(NSString *)property {
    return [self minOf:property where:nil] ;
}

+ (double)minOf:(NSString *)property where:(NSString *)whereStr {
    whereStr = whereStr ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"" ;
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT min(%@) FROM %@ %@",property,NSStringFromClass([self class]),whereStr]] doubleValue] ;
}

+ (double)sumOf:(NSString *)property {
    return [self sumOf:property where:nil] ;
}
    
+ (double)sumOf:(NSString *)property where:(NSString *)whereStr {
    whereStr = whereStr ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"" ;
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT sum(%@) FROM %@ %@",property,NSStringFromClass([self class]),whereStr]] doubleValue] ;
}

+ (double)avgOf:(NSString *)property {
    return [self avgOf:property where:nil] ;
}

+ (double)avgOf:(NSString *)property where:(NSString *)whereStr {
    whereStr = whereStr ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"" ;
    return [[self anyFuncWithSql:[NSString stringWithFormat:@"SELECT avg(%@) FROM %@ %@",property,NSStringFromClass([self class]),whereStr]] doubleValue] ;
}

#pragma mark --
#pragma mark - delete

- (BOOL)deleteModel {
    return [[self class] deleteModelWhere:[NSString stringWithFormat:@"pkid = '%lu'",(unsigned long)self.pkid]] ;
}

+ (BOOL)deleteModelWhere:(NSString *)strWhere {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        
        bSuccess = [db executeUpdate:[sqlUTIL sqlDeleteWithTableName:tableName where:strWhere]] ;
        if (bSuccess) {
            XTFMDBLog(@"xt_db delete model success from tb %@\n\n",tableName) ;
        }
        else {
            XTFMDBLog(@"xt_db delete model fail from tb %@\n\n",tableName) ;
        }
    }] ;
    
    return bSuccess ;
}

+ (BOOL)dropTable {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlDrop:tableName]] ;
        if (bSuccess) XTFMDBLog(@"xt_db drop %@ success\n\n",tableName) ;
        else XTFMDBLog(@"xt_db drop %@ fail\n\n",tableName) ;
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
        bSuccess = [db executeUpdate:[sqlUTIL sqlAlterAdd:name
                                                     type:type
                                                    table:tableName]] ;
        if (bSuccess)
            XTFMDBLog(@"xt_db alter add %@ success\n\n",tableName) ;
        else
            XTFMDBLog(@"xt_db alter add %@fail\n\n",tableName) ;
    }] ;
    return bSuccess ;
}

+ (BOOL)alterRenameToNewTableName:(NSString *)name {
    NSString *tableName = NSStringFromClass([self class]) ;
    if (![[XTFMDBBase sharedInstance] verify]) return FALSE ;
    if (![[XTFMDBBase sharedInstance] isTableExist:tableName]) return FALSE ;
    
    __block BOOL bSuccess = FALSE ;
    [QUEUE inDatabase:^(FMDatabase *db) {
        bSuccess = [db executeUpdate:[sqlUTIL sqlAlterRenameOldTable:tableName
                                                      toNewTableName:name]] ;
        if (bSuccess) {
            XTFMDBLog(@"xt_db alter rename %@ success\n\n",tableName) ;
        }
        else {
            XTFMDBLog(@"xt_db alter rename %@ fail\n\n",tableName) ;
        }
    }] ;
    return bSuccess ;
}

#pragma mark --
#pragma mark - constrains ( rewrite in subClass if Needed .)
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






