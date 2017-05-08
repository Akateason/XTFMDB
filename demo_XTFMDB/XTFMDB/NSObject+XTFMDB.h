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
+ (BOOL)tableIsExist ;

#pragma mark - create
+ (BOOL)createTable ;

#pragma mark - insert
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

#pragma mark - delete
- (BOOL)deleteModel ;
+ (BOOL)deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)dropTable ;

#pragma mark - Constraints
//props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set Constraints of property
//ignore Properties
+ (NSArray *)ignoreProperties ;

@end
