//
//  XTDBModel+autoSql.m
//  XTlib
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBModel+autoSql.h"
#import "NSObject+XTFMDB_Reflection.h"
#import "XTFMDBConst.h"
#import "XTDBModel.h"
#import <FMDB/FMDB.h>
#import <UIKit/UIKit.h>

@implementation XTDBModel (autoSql)

+ (NSString *)sqlCreateTableWithClass:(Class)cls
{
    return [self getSqlUseRecursiveQuery:nil
                                   class:cls
                                    type:xt_type_create] ;
}

+ (NSString *)sqlInsertWithModel:(id)model
{
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_insert] ;
}

+ (NSString *)sqlUpdateWithModel:(id)model
{
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_update] ;
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

+ (NSString *)sqlAlterRenameOldTable:(NSString *)oldTableName
                      toNewTableName:(NSString *)newTableName
{
    return [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;",oldTableName,newTableName] ;
}


#pragma mark -- 
#pragma mark - private

typedef NS_ENUM(NSUInteger, TypeOfAutoSql) {
    xt_type_create = 1,
    xt_type_insert ,
    xt_type_update ,
} ;

+ (NSString *)appendCreate:(Class)cls {
    NSMutableString *strProperties = [@"" mutableCopy] ;
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++) {
        NSDictionary *dic   = propInfoList[i] ;
        NSString *name      = dic[@"name"] ;
        NSString *type      = dic[@"type"] ;
        NSString *sqlType   = [self sqlTypeWithType:type] ;
        
        NSString *strTmp    = nil ;
        if ([name containsString:kPkid]) {
            // pk AUTOINCREMENT .
            strTmp = [NSString stringWithFormat:@"%@ %@ PRIMARY KEY AUTOINCREMENT DEFAULT '1',",name,sqlType] ;
            [strProperties appendString:strTmp] ;
        }
        else {
            // ignore prop
            if ([self propIsIgnore:name class:cls]) continue ;
            // default prop
            strTmp = [NSString stringWithFormat:@"%@ %@ NOT NULL %@ %@,",
                      name,
                      sqlType,
                      [self defaultValWithSqlType:sqlType],
                      [self keywordsWithName:name class:cls]
                      ] ;
            [strProperties appendString:strTmp] ;
        }
    }
    return strProperties ;
}

+ (NSDictionary *)appendInsert:(Class)cls
                         model:(id)model
                      dicModel:(NSDictionary *)dicModel
{
    NSMutableString *strProperties = [@"" mutableCopy] ;
    NSMutableString *strQuestions  = [@"" mutableCopy] ;
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++) {
        id dicTmp           = propInfoList[i] ;
        NSString *name      = dicTmp[@"name"] ;
        // dont insert primary key
        if ([name containsString:kPkid]) continue ;
        // ignore prop
        if ([self propIsIgnore:name class:[model class]]) continue ;
        // ignore nil prop
        if ([self propIsNilOrNull:dicModel[name]]) continue ;
        
        // prop
        [strProperties appendString:[NSString stringWithFormat:@"%@ ,",name]] ;
        // question
        [strQuestions appendString:[NSString stringWithFormat:@"'%@' ,",dicModel[name]]] ;
    }
    return @{
             @"p" : strProperties ,
             @"q" : strQuestions
             } ;
}

+ (NSString *)appendUpdate:(Class)cls
                     model:(id)model
                  dicModel:(NSDictionary *)dicModel
{
    NSString *setsStr       = @"" ;
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++)
    {
        id dicTmp           = propInfoList[i] ;
        NSString *name      = dicTmp[@"name"] ;
        // dont update primary key
        if ([name containsString:kPkid]) continue ;
        // ignore prop
        if ([self propIsIgnore:name class:[model class]]) continue ;
        // ignore nil prop
        if ([self propIsNilOrNull:dicModel[name]]) continue ;
        
        // setstr
        NSString *tmpStr = [NSString stringWithFormat:@"%@ = '%@' ,",name,dicModel[name]] ;
        setsStr = [setsStr stringByAppendingString:tmpStr] ;
    }
    return setsStr ;
}

+ (BOOL)propIsNilOrNull:(id)val {
    return !val || [val isKindOfClass:[NSNull class]] || ([val isKindOfClass:[NSString class]] && [val isEqualToString:@"<null>"]) ;
}

+ (NSString *)getSqlUseRecursiveQuery:(id)model
                                class:(Class)class
                                 type:(TypeOfAutoSql)type
{
    Class cls = class ?: [model class] ;
    NSString *tableName = NSStringFromClass(cls) ;
    NSMutableString *strProperties = [@"" mutableCopy] ;
    NSMutableString *strQuestions  = [@"" mutableCopy] ;
    NSDictionary *dicModel = [self changeSpecifiedValToUTF8StringVal:[model propertyDictionary]] ;
    
    // Recursive Query
    while ( 1 ) {
        
        // APPEND SQL STRING .
        switch (type) {
            case xt_type_create: {
                [strProperties appendString:[self appendCreate:cls]] ;
            }
                break ;
            case xt_type_insert: {
                NSDictionary *resDic = [self appendInsert:cls
                                                    model:model
                                                 dicModel:dicModel] ;
                [strProperties appendString:resDic[@"p"]] ;
                [strQuestions appendString:resDic[@"q"]] ;
            }
                break ;
            case xt_type_update: {
                [strProperties appendString:[self appendUpdate:cls
                                                         model:model
                                                      dicModel:dicModel]] ;
            }
                break ;
            default:
                break ;
        }
        
        // RETURN IF NEEDED .
        if ([cls isEqual:[XTDBModel class]] || [cls.superclass isEqual:[NSObject class]]) {
            switch (type) {
                case xt_type_create: {
                    NSString *resultSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ )",
                                           tableName,
                                           [strProperties substringToIndex:strProperties.length - 1]] ;
                    XTFMDBLog(@"xt_db sql create : \n%@\n\n",resultSql) ;
                    return resultSql ;
                }
                    break ;
                case xt_type_insert: {
                    strProperties = [[strProperties substringToIndex:strProperties.length - 1] mutableCopy] ;
                    strQuestions = [[strQuestions substringToIndex:strQuestions.length - 1] mutableCopy] ;
                    NSString *strResult = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ( %@ ) VALUES ( %@ )",tableName,strProperties,strQuestions] ;
                    XTFMDBLog(@"xt_db sql insert : \n%@\n\n",strResult) ;
                    return strResult ;
                }
                    break ;
                case xt_type_update: {
                    strProperties = [[strProperties substringToIndex:strProperties.length - 1] mutableCopy] ;
                    NSString *whereStr = [NSString stringWithFormat:@"%@ = %@",kPkid,dicModel[kPkid]] ;
                    NSString *strResult = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,strProperties,whereStr] ;
                    XTFMDBLog(@"xt_db sql update : \n%@",strResult) ;
                    return strResult ;
                }
                    break ;
                default:
                    break ;
            }
        }
        
        // NEXT LOOP IF NEEDED .
        cls = [cls superclass] ;
    }
}

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
    else if ([strType containsString:@"BOOL"] || [strType containsString:@"bool"]) {
        return @"BOOLEAN" ;
    }
    else if ([strType containsString:@"NSData"]) {
        return @"TEXT" ;
    }
    else if ([strType containsString:@"NSArray"]) {
        return @"TEXT" ;
    }
    else if ([strType containsString:@"NSDictionary"]) {
        return @"TEXT" ;
    }
    else if ([strType containsString:@"NSSet"]) {
        return @"TEXT" ;
    }
    else if ([strType containsString:@"UIImage"]) {
        return @"TEXT" ;
    }
    XTFMDBLog(@"xt_db no type to transform !!") ;
    return nil ;
}

+ (NSString *)defaultValWithSqlType:(NSString *)sqlType
{
    if ([sqlType containsString:@"TEXT"] || [sqlType containsString:@"char"]) {
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
    id list = [[self defaultIgnoreProps] arrayByAddingObjectsFromArray:[cls ignoreProperties]] ;
    if (!list) return FALSE ;
    return [list containsObject:name] ;
}

+ (NSMutableArray *)defaultIgnoreProps {
    return [@[@"hash",@"superclass",@"description",@"debugDescription"] mutableCopy] ;
}

+ (NSDictionary *)changeSpecifiedValToUTF8StringVal:(NSDictionary *)dic {
    NSMutableDictionary *tmpDic = [dic mutableCopy] ;
    for (NSString *key in dic) {
        id val = dic[key] ;
        if ([val isKindOfClass:[NSData class]]) {
            [tmpDic setObject:[self encodingB64String:val]
                       forKey:key] ;
        }
        else if ([val isKindOfClass:[NSArray class]]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(NSArray *)val] ;
            [tmpDic setObject:[self encodingB64String:data]
                       forKey:key] ;
        }
        else if ([val isKindOfClass:[NSDictionary class]]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(NSDictionary *)val] ;
            [tmpDic setObject:[self encodingB64String:data]
                       forKey:key] ;
        }
        else if ([val isKindOfClass:[UIImage class]]) {
            NSData *data = UIImageJPEGRepresentation(val, 1) ?: UIImagePNGRepresentation(val) ;
            [tmpDic setObject:[self encodingB64String:data]
                       forKey:key] ;
        }
    }
    return tmpDic ;
}

+ (NSString *)encodingB64String:(NSData *)data {
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] ;
}

+ (NSDictionary *)getResultDicFromClass:(Class)cls resultSet:(FMResultSet *)resultSet {
    NSMutableDictionary *tmpDic = [[resultSet resultDictionary] mutableCopy] ;
    if (!tmpDic) return nil ;
    
    NSArray *propInfoList = [cls propertiesInfo] ;
    for (int i = 0; i < propInfoList.count; i++) {
        NSDictionary *dic   = propInfoList[i] ;
        NSString *name      = dic[@"name"] ;
        NSString *type      = dic[@"type"] ;
        NSString *valFromFMDB = tmpDic[name] ;
        if (!valFromFMDB || [valFromFMDB isKindOfClass:[NSNull class]]) continue ;
        
        if ([type containsString:@"NSData"]) {
            NSData *tmpData = [[NSData alloc] initWithBase64EncodedString:valFromFMDB   options:NSDataBase64DecodingIgnoreUnknownCharacters] ;
            [tmpDic setObject:tmpData
                       forKey:name] ;
        }
        else if ([type containsString:@"NSArray"]) {
            NSData *tmpData = [[NSData alloc] initWithBase64EncodedString:valFromFMDB   options:NSDataBase64DecodingIgnoreUnknownCharacters] ;
            NSArray *resultArr = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData] ;
            if (!resultArr) continue ;
            [tmpDic setObject:resultArr
                       forKey:name] ;
        }
        else if ([type containsString:@"NSDictionary"]) {
            NSData *tmpData = [[NSData alloc] initWithBase64EncodedString:valFromFMDB   options:NSDataBase64DecodingIgnoreUnknownCharacters] ;
            NSDictionary *resultDic = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData] ;
            if (!resultDic) continue ;
            [tmpDic setObject:resultDic
                       forKey:name] ;
        }
        else if ([type containsString:@"UIImage"]) {
            NSData *tmpData = [[NSData alloc] initWithBase64EncodedString:valFromFMDB   options:NSDataBase64DecodingIgnoreUnknownCharacters] ;
            UIImage *image = [UIImage imageWithData:tmpData] ;
            if (!image) continue ;
            [tmpDic setObject:image
                       forKey:name] ;
        }
    }
    return tmpDic ;
}

@end
