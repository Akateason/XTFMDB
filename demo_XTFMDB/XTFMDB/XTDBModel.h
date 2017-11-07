//
//  XTDBModel.h
//  XTkit
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//
// 特性
// 1.Model直接存储.获取. 无需转换
// 2.增删改查. 脱离sql语句
// 3.主键自增. 插入不需设主键. pkid
// 4.Model满足. 无容器, 无嵌套. model的第一个属性必须是数字主键.且命名中须包含'pkid'.默认为pkid
// 5.任何操作. 线程安全
// 6.批量操作支持实务. 支持失败后回滚. 且线程安全
// 7.支持 每个字段自定义设置关键字. 已经集成默认关键字, 以下情况无需再写( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 )
// 8.指定哪些字段不参与建表.
// 9. 支持各容器类存储. NSArray, NSDictionary
// 10. 支持NSData类型
// 11. 支持图片存储
// 12. XTDBModel支持默认字段, createTime, updateTime, isDel
//

#import <Foundation/Foundation.h>

static NSString *const kPkid = @"pkid" ;

@interface XTDBModel : NSObject

@property (nonatomic,assign)    int         pkid        ; // primaryKey
@property (nonatomic,assign)    long long   createTime  ;
@property (nonatomic,assign)    long long   updateTime  ;
@property (nonatomic,assign)    BOOL        isDel       ;

#pragma mark - tableIsExist

+ (BOOL)tableIsExist ;

#pragma mark - create

+ (BOOL)createTable ;

#pragma mark - insert

// insert or replace
- (int)insert ; // return lastRowId .
+ (BOOL)insertList:(NSArray *)modelList ;

#pragma mark - update

- (BOOL)update ;
+ (BOOL)updateList:(NSArray *)modelList ;

#pragma mark - select

+ (NSArray *)selectAll ;
+ (NSArray *)selectWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (instancetype)findFirstWhere:(NSString *)strWhere ;
+ (BOOL)hasModelWhere:(NSString *)strWhere ;

// any sql
+ (NSArray *)findWithSql:(NSString *)sql ;
+ (instancetype)findFirstWithSql:(NSString *)sql ;

// func
+ (id)anyFuncWithSql:(NSString *)sql ;
+ (int)count ;
+ (double)maxOf:(NSString *)property ;
+ (double)minOf:(NSString *)property ;
+ (double)sumOf:(NSString *)property ;
+ (double)avgOf:(NSString *)property ;

#pragma mark - delete

- (BOOL)deleteModel ;
+ (BOOL)deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)dropTable ;

#pragma mark - alter

+ (BOOL)alterAddColumn:(NSString *)name
                  type:(NSString *)type ;


#pragma mark - Constraints

// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set Constraints of property
// ignore Properties
+ (NSArray *)ignoreProperties ;

@end
