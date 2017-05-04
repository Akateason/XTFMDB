//
//  XTDBModel+autoSql.h
//  XTkit
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel.h"

@interface XTDBModel (autoSql)

+ (NSString *)sqlCreateTableWithClass:(Class)cls ;

+ (NSString *)sqlInsertWithModel:(id)model ;

+ (NSString *)sqlUpdateWithModel:(id)model ;

+ (NSString *)sqlDeleteWithTableName:(NSString *)tableName
                               where:(NSString *)strWhere ;

+ (NSString *)drop:(NSString *)tableName ;


@end
