//
//  XTAutoSqlUtil.h
//  demo_XTFMDB
//
//  Created by teason23 on 2018/4/8.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;


@interface XTAutoSqlUtil : NSObject

- (NSString *)sqlCreateTableWithClass:(Class)cls;

- (NSString *)sqlInsertWithModel:(id)model;
- (NSString *)sqlInsertOrIgnoreWithModel:(id)model;
- (NSString *)sqlInsertOrReplaceWithModel:(id)model;

- (NSString *)sqlUpdateSetWhereWithModel:(id)model
                                 whereBy:(NSString *)whereProp;

- (NSString *)sqlDeleteWithTableName:(NSString *)tableName
                               where:(NSString *)strWhere;

- (NSString *)sqlDrop:(NSString *)tableName;

- (NSString *)sqlAlterAdd:(NSString *)name
                     type:(NSString *)type
                    table:(NSString *)tableName;

- (NSString *)sqlAlterRenameOldTable:(NSString *)oldTableName
                      toNewTableName:(NSString *)newTableName;

- (NSDictionary *)getResultDicFromClass:(Class)cls
                              resultSet:(FMResultSet *)resultSet;

- (NSString *)sqlTypeWithType:(NSString *)strType;

- (id)resetDictionaryFromDBModel:(NSDictionary *)dbModel resultItem:(id)item;

@end
