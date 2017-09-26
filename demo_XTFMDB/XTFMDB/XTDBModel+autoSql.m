//
//  XTDBModel+autoSql.m
//  XTkit
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel+autoSql.h"
#import "NSObject+Reflection.h"
#import "XTFMDBConst.h"
#import "NSString+JKBase64.h"
#import <FMDB.h>

@implementation XTDBModel (autoSql)

+ (NSString *)sqlCreateTableWithClass:(Class)cls
{
    NSString *tableName = NSStringFromClass(cls) ;
    NSMutableString *strProperties = [@"" mutableCopy] ;
    
    // pk in super cls 主键在父类里 , 若用父类XTDBModel创建 .
    Class superCls = [cls superclass] ;
    NSArray *superPropInfoList = [superCls propertiesInfo] ;
    for (int i = 0; i < superPropInfoList.count; i++)
    {
        NSDictionary *dic   = superPropInfoList[i] ;
        NSString *name      = dic[@"name"] ;
        NSString *type      = dic[@"type"] ;
        NSString *sqlType   = [self sqlTypeWithType:type] ;
        
        NSString *strTmp    = nil ;
        if ([name containsString:kPkid])
        {
            // pk AUTOINCREMENT .
            strTmp = [NSString stringWithFormat:@"%@ %@ PRIMARY KEY AUTOINCREMENT DEFAULT '1',",name,sqlType] ;
            [strProperties appendString:strTmp] ;
            break ;
        }
    }
    
    // other props in sub cls 当前类
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++)
    {
        NSDictionary *dic   = propInfoList[i] ;
        NSString *name      = dic[@"name"] ;
        NSString *type      = dic[@"type"] ;
        NSString *sqlType   = [self sqlTypeWithType:type] ;
        NSString *strTmp    = nil ;
        // dont insert primary key . already insert in supercls
        if ([name containsString:kPkid]) continue ;
        // ignore prop
        if ([self propIsIgnore:name class:cls]) continue ;
        
        // default prop
        strTmp = [NSString stringWithFormat:@"%@ %@ %@ %@,", // @"%@ %@ NOT NULL %@ %@,",
                  name,
                  sqlType,
                  [self defaultValWithSqlType:sqlType],
                  [self keywordsWithName:name class:cls]
                  ] ;
        [strProperties appendString:strTmp] ;
    }
    
    
    NSString *resultSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ )",
                           tableName,
                           [strProperties substringToIndex:strProperties.length - 1] ] ;
    NSLog(@"xt_db sql create : \n%@",resultSql) ;
    return resultSql ;
}

+ (NSString *)sqlInsertWithModel:(id)model
{
    NSDictionary *dicModel = [model propertyDictionary] ;
    dicModel = [self changeNSDataValToUTF8StringVal:dicModel] ;
    NSString *tableName = NSStringFromClass([model class]) ;
    
    NSString *propertiesStr = @"" ;
    NSString *questionStr   = @"" ;

    NSArray *propInfoList = [[model class] propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++)
    {
        id dicTmp           = propInfoList[i] ;
        NSString *name      = dicTmp[@"name"] ;
        // dont insert primary key
        if ([name containsString:kPkid]) continue ;
        // ignore prop
        if ([self propIsIgnore:name class:[model class]]) continue ;
        // ignore nil prop
        if (!dicModel[name]) continue ;
        
        // prop
        propertiesStr = [propertiesStr stringByAppendingString:[NSString stringWithFormat:@"%@ ,",name]] ;
        // question
        questionStr = [questionStr stringByAppendingString:[NSString stringWithFormat:@"'%@' ,",dicModel[name]]] ;
    }
    
    propertiesStr = [propertiesStr substringToIndex:propertiesStr.length - 1] ;
    questionStr = [questionStr substringToIndex:questionStr.length - 1] ;
    
    NSString *strResult = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ( %@ ) VALUES ( %@ )",tableName,propertiesStr,questionStr] ;
    NSLog(@"xt_db sql insert : \n%@",strResult) ;
    return strResult ;
}


+ (NSString *)sqlUpdateWithModel:(id)model
{
    NSString *tableName = NSStringFromClass([model class]) ;
    NSMutableDictionary *dic = [[self changeNSDataValToUTF8StringVal:[model propertyDictionary]] mutableCopy] ;
    
    NSString *setsStr       = @"" ;
    NSString *whereStr      = @"" ;
    
    NSArray *propInfoList = [[model class] propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++)
    {
        id dicTmp           = propInfoList[i] ;
        NSString *name      = dicTmp[@"name"] ;
        // dont update primary key
        if ([name containsString:kPkid]) continue ;
        // ignore prop
        if ([self propIsIgnore:name class:[model class]]) continue ;
        // ignore nil prop
        if (!dic[name]) continue ;
        // setstr
        NSString *tmpStr = [NSString stringWithFormat:@"%@ = '%@' ,",name,dic[name]] ;
        setsStr = [setsStr stringByAppendingString:tmpStr] ;
    }
    
    setsStr = [setsStr substringToIndex:setsStr.length - 1] ;
    whereStr = [NSString stringWithFormat:@"%@ = %@",kPkid,dic[kPkid]] ;
    
    NSString *strResult = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,setsStr,whereStr] ;
    NSLog(@"xt_db sql update : \n%@",strResult) ;
    return strResult ;
}

+ (NSString *)sqlDeleteWithTableName:(NSString *)tableName
                               where:(NSString *)strWhere
{
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,strWhere] ;
}


+ (NSString *)sqlDrop:(NSString *)tableName
{
    return [NSString stringWithFormat:@"DROP TABLE %@",tableName] ;
}

+ (NSString *)sqlAlterAdd:(NSString *)name
                     type:(NSString *)type
                    table:(NSString *)tableName
{
    return [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,name,type] ;
}


#pragma mark -- 
#pragma mark - private

+ (NSString *)sqlTypeWithType:(NSString *)strType
{
    if ([strType containsString:@"int"] || [strType containsString:@"Integer"]) {
        return @"INTEGER" ;
    }
    else if ([strType containsString:@"float"] || [strType containsString:@"double"]) {
        return @"DOUBLE" ;
    }
    else if ([strType containsString:@"long"]) {
        return @"BIGINT" ;
    }
    else if ([strType containsString:@"NSString"] || [strType containsString:@"char"]) {
        return @"TEXT" ;
    }
    else if ([strType containsString:@"NSData"]) {
        return @"TEXT" ;
    }
    NSLog(@"xt_db no type to transform !!") ;
    return nil ;
}

+ (NSString *)defaultValWithSqlType:(NSString *)sqlType
{
    if ([sqlType containsString:@"TEXT"] || [sqlType containsString:@"char"])
    {
        return @" DEFAULT ''" ;
    }
    else return @" DEFAULT '0'" ;
}

+ (NSString *)keywordsWithName:(NSString *)name
                         class:(Class)cls
{
    id dic = [cls modelPropertiesSqliteKeywords] ;
    if ( !dic || !dic[name] ) return @"" ;
    return dic[name] ;
}

+ (BOOL)propIsIgnore:(NSString *)name
               class:(Class)cls
{
    id list = [cls ignoreProperties] ;
    if (!list) return FALSE ;
    return [list containsObject:name] ;
}

+ (NSDictionary *)changeNSDataValToUTF8StringVal:(NSDictionary *)dic {
    NSMutableDictionary *tmpDic = [dic mutableCopy] ;
    for (NSString *key in dic) {
        id val = dic[key] ;
        if ([val isKindOfClass:[NSData class]]) {
            NSString *encodingString = [val base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] ;
            [tmpDic setObject:encodingString forKey:key] ;
        }
    }
    return tmpDic ;
}

+ (NSDictionary *)getResultDicFromClass:(Class)cls resultSet:(FMResultSet *)resultSet {
    NSMutableDictionary *tmpDic = [[resultSet resultDictionary] mutableCopy] ;
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++) {
        NSDictionary *dic   = propInfoList[i] ;
        NSString *name      = dic[@"name"] ;
        NSString *type      = dic[@"type"] ;
        if ([type containsString:@"NSData"]) {
            NSString *valFromFMDB = tmpDic[name] ;
            NSData *tmpData = [[NSData alloc] initWithBase64EncodedString:valFromFMDB options:NSDataBase64DecodingIgnoreUnknownCharacters] ;
            [tmpDic setObject:tmpData forKey:name] ;
        }
    }
    return tmpDic ;
}

@end
