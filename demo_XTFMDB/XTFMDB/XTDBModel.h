//
//  XTDBModel.h
//  XTlib
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
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
//9. 支持各容器类存储. NSArray, NSDictionary
//10. 支持NSData类型
//11. 支持图片存储
//12. XTDBModel支持默认字段, createTime, updateTime, isDel
//13. 一行代码完成数据库升级.
//14. 常规运算, 求和,最值等


#import <Foundation/Foundation.h>

extern NSString *const kPkid ;

__attribute__((deprecated("Class XTDBModel is deprecated , use NSObject+XTFMDB.h instead!!!")))

@interface XTDBModel : NSObject

@property (nonatomic,assign)    int         pkid        ; // primaryKey
@property (nonatomic,assign)    long long   createTime  ;
@property (nonatomic,assign)    long long   updateTime  ;
@property (nonatomic,assign)    BOOL        isDel       ;

#pragma mark - tableIsExist

+ (BOOL)tableIsExist ;
+ (BOOL)autoCreateIfNotExist ;

#pragma mark - create

+ (BOOL)createTable ;

#pragma mark - insert

// insert
- (BOOL)insert ;
+ (BOOL)insertList:(NSArray *)modelList ;

// insert or ignore
- (BOOL)insertOrIgnore ;
+ (BOOL)insertOrIgnoreWithList:(NSArray *)modelList ;

// insert or replace
- (BOOL)insertOrReplace ;
+ (BOOL)insertOrReplaceWithList:(NSArray *)modelList ;

// upsert
- (BOOL)upsertWhereByProp:(NSString *)propName ;

#pragma mark - update
- (BOOL)update ; //  default update by pkid. if pkid nil, update by a unique prop if has .
+ (BOOL)updateList:(NSArray *)modelList ; // update by pkid .

// update by custom key .
- (BOOL)updateWhereByProp:(NSString *)propName ;
+ (BOOL)updateList:(NSArray *)modelList
       whereByProp:(NSString *)propName ;

#pragma mark - select

+ (NSArray *)selectAll ;
+ (NSArray *)selectWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (instancetype)findFirstWhere:(NSString *)strWhere ;
+ (instancetype)findFirst ;
+ (BOOL)hasModelWhere:(NSString *)strWhere ;

// any sql execute Query
+ (NSArray *)findWithSql:(NSString *)sql ;
+ (instancetype)findFirstWithSql:(NSString *)sql ;

// func execute Statements
+ (id)anyFuncWithSql:(NSString *)sql ;
+ (BOOL)isEmptyTable ;
+ (int)count ;
+ (int)countWhere:(NSString *)whereStr ;
+ (double)maxOf:(NSString *)property ;
+ (double)maxOf:(NSString *)property where:(NSString *)whereStr ;
+ (double)minOf:(NSString *)property ;
+ (double)minOf:(NSString *)property where:(NSString *)whereStr ;
+ (double)sumOf:(NSString *)property ;
+ (double)sumOf:(NSString *)property where:(NSString *)whereStr ;
+ (double)avgOf:(NSString *)property ;
+ (double)avgOf:(NSString *)property where:(NSString *)whereStr ;

#pragma mark - delete

- (BOOL)deleteModel ;
+ (BOOL)deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)dropTable ;

#pragma mark - alter

+ (BOOL)alterAddColumn:(NSString *)name
                  type:(NSString *)type ;
+ (BOOL)alterRenameToNewTableName:(NSString *)name ;

#pragma mark - Constraints

// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set sqlite Constraints of property
// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties ;
// Container property , value should be Class or Class name. Same as YYmodel .
+ (NSDictionary *)modelContainerPropertyGenericClass ;

@end
