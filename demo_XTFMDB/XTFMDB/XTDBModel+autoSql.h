//
//  XTDBModel+autoSql.h
//  XTkit
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel.h"
@class FMResultSet ;

@interface XTDBModel (autoSql)

+ (NSString *)sqlCreateTableWithClass:(Class)cls ;

+ (NSString *)sqlInsertWithModel:(id)model ;

+ (NSString *)sqlUpdateWithModel:(id)model ;

+ (NSString *)sqlDeleteWithTableName:(NSString *)tableName
                               where:(NSString *)strWhere ;

+ (NSString *)sqlDrop:(NSString *)tableName ;

+ (NSString *)sqlAlterAdd:(NSString *)name
                     type:(NSString *)type
                    table:(NSString *)tableName ;

+ (NSDictionary *)getResultDicFromClass:(Class)cls
                              resultSet:(FMResultSet *)resultSet ;

@end
