//
//  NSObject+XTFMDB.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teaason. All rights reserved.
//

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
- (BOOL)xt_update ;
+ (BOOL)xt_updateList:(NSArray *)modelList ;

#pragma mark - select
+ (NSArray *)xt_selectAll ;
+ (instancetype)xt_findFirstWhere:(NSString *)strWhere ;
+ (BOOL)xt_hasModelWhere:(NSString *)strWhere ;
+ (NSArray *)xt_selectWhere:(NSString *)strWhere ;

// any sql
+ (NSArray *)xt_findWithSql:(NSString *)sql ;
+ (instancetype)xt_findFirstWithSql:(NSString *)sql ;

#pragma mark - delete
- (BOOL)xt_deleteModel ;
+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)xt_dropTable ;

#pragma mark - alter

+ (BOOL)xt_alterAddColumn:(NSString *)name
                     type:(NSString *)type ;

#pragma mark - Constraints
//props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set Constraints of property
//ignore Properties
+ (NSArray *)ignoreProperties ;

@end
