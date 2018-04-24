//
//  NSObject+XTFMDB.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//
//### 特性
//1. Model直接存储.获取. 无需再转换
//2. 增删改查. 脱离sql语句
//3. 主键自增. 插入不需设主键. pkid
//4. Model满足. 无嵌套. model的第一个属性必须是数字主键.且命名中须包含'pkid'.默认为pkid
//5. 任何操作. 线程安全
//6. 批量操作支持实务. 支持操作失败事务回滚. 且线程安全
//7. 支持 每个字段自定义设置关键字. 已经集成默认关键字, 以下情况无需再写( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 )
//8. 可指定哪些字段不参与建表.
//9. 支持各容器类存储. NSArray<Obj *>, NSDictionary
//10. 支持NSData,UIImage,NSDate
//11. 支持自定义类作为属性
//12. 支持图片存储
//13. XTDBModel支持默认字段, createTime, updateTime, isDel
//14. 一行代码完成数据库升级.
//15. 常规运算, 求和,最值等


#import <Foundation/Foundation.h>

@interface NSObject (XTFMDB)

// primaryKey
@property (nonatomic,assign) int pkid ;

#pragma mark - tableIsExist
+ (BOOL)xt_tableIsExist ;

#pragma mark - create
+ (BOOL)xt_createTable ;

#pragma mark - insert
// insert or replace
- (int)xt_insert ; // return lastRowId .
+ (BOOL)xt_insertList:(NSArray *)modelList ;

#pragma mark - update
// update by pkid .
- (BOOL)xt_update ;
+ (BOOL)xt_updateList:(NSArray *)modelList ;

// update by custom key . 
- (BOOL)xt_updateWhereByProp:(NSString *)propName ;
+ (BOOL)xt_updateList:(NSArray *)modelList
          whereByProp:(NSString *)propName ;

#pragma mark - select
+ (NSArray *)xt_selectAll ;
+ (NSArray *)xt_selectWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (instancetype)xt_findFirstWhere:(NSString *)strWhere ;
+ (instancetype)xt_findFirst ;
+ (BOOL)xt_hasModelWhere:(NSString *)strWhere ;

// any sql execute Query
+ (NSArray *)xt_findWithSql:(NSString *)sql ;
+ (instancetype)xt_findFirstWithSql:(NSString *)sql ;

// func execute Statements
+ (id)xt_anyFuncWithSql:(NSString *)sql ;
+ (int)xt_count ;
+ (BOOL)xt_isEmptyTable ;
+ (double)xt_maxOf:(NSString *)property ;
+ (double)xt_minOf:(NSString *)property ;
+ (double)xt_sumOf:(NSString *)property ;
+ (double)xt_avgOf:(NSString *)property ;

#pragma mark - delete
- (BOOL)xt_deleteModel ;
+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)xt_dropTable ;

#pragma mark - alter

+ (BOOL)xt_alterAddColumn:(NSString *)name
                     type:(NSString *)type ;
+ (BOOL)xt_alterRenameToNewTableName:(NSString *)name ;

#pragma mark - Constraints
//props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set sqlite Constraints of property
// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties ;
// Container property , value should be Class or Class name. Same as YYmodel .
+ (NSDictionary *)modelContainerPropertyGenericClass ;

@end
