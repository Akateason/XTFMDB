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
- (int)xt_insert ; // return lastRowId .
+ (BOOL)xt_insertList:(NSArray *)modelList ;

#pragma mark - update
- (BOOL)xt_update ;
+ (BOOL)xt_updateList:(NSArray *)modelList ;

#pragma mark - select
+ (NSArray *)xt_selectAll ;
+ (NSArray *)xt_selectWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (instancetype)xt_findFirstWhere:(NSString *)strWhere ;
+ (BOOL)xt_hasModelWhere:(NSString *)strWhere ;

#pragma mark - delete
- (BOOL)xt_deleteModel ;
+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)xt_dropTable ;

#pragma mark - Constraints
//props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set Constraints of property
//ignore Properties
+ (NSArray *)ignoreProperties ;

@end
