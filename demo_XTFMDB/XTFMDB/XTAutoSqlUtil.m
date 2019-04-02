//
//  XTAutoSqlUtil.m
//  demo_XTFMDB
//
//  Created by teason23 on 2018/4/8.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "XTAutoSqlUtil.h"
#import "NSDate+XTFMDB_Tick.h"
#import "NSObject+XTFMDB.h"
#import "NSObject+XTFMDB_Reflection.h"
#import "XTFMDBConst.h"
#import <FMDB/FMDB.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>
#import <objc/message.h>
#import <objc/runtime.h>

#define SAFELY_LOG_FORMAT(strResult) \
    (strResult.length > 1000) ? [strResult substringToIndex:1000] : strResult


@interface XTAutoSqlUtil () {
    Class m_orginCls;
}
@end


@implementation XTAutoSqlUtil

- (NSString *)sqlCreateTableWithClass:(Class)cls {
    m_orginCls = cls;
    return [self getSqlUseRecursiveQuery:nil
                                   class:cls
                                    type:xt_type_create
                             whereByProp:nil];
}

- (NSString *)sqlInsertWithModel:(id)model {
    m_orginCls = [model class];
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_insert
                             whereByProp:nil];
}

- (NSString *)sqlInsertOrIgnoreWithModel:(id)model {
    m_orginCls = [model class];
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_insertOrIgnore
                             whereByProp:nil];
}

- (NSString *)sqlInsertOrReplaceWithModel:(id)model {
    m_orginCls = [model class];
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_insertOrReplace
                             whereByProp:nil];
}

- (NSString *)sqlUpdateSetWhereWithModel:(id)model
                                 whereBy:(NSString *)whereProp {
    m_orginCls = [model class];
    return [self getSqlUseRecursiveQuery:model
                                   class:nil
                                    type:xt_type_update
                             whereByProp:whereProp];
}

- (NSString *)sqlDeleteWithTableName:(NSString *)tableName
                               where:(NSString *)strWhere {
    return [NSString
        stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, strWhere];
}

- (NSString *)sqlDrop:(NSString *)tableName {
    return [NSString stringWithFormat:@"DROP TABLE %@", tableName];
}

- (NSString *)sqlAlterAdd:(NSString *)name
                     type:(NSString *)type
                    table:(NSString *)tableName {
    return [NSString
        stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", tableName, name, type];
}

- (NSString *)sqlAlterRenameOldTable:(NSString *)oldTableName
                      toNewTableName:(NSString *)newTableName {
    return [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;",
                                      oldTableName,
                                      newTableName];
}

#pragma mark--
#pragma mark - private

typedef NS_ENUM(NSUInteger, TypeOfAutoSql) {
    xt_type_create = 1,
    xt_type_insert,
    xt_type_insertOrIgnore,
    xt_type_insertOrReplace,
    xt_type_update,
};

- (NSString *)appendCreate:(Class)cls propInfoList:(NSArray *)propInfoList {
    NSMutableString *strProperties = [@"" mutableCopy];
    for (int i = 0; i < propInfoList.count; i++) {
        NSDictionary *dic = propInfoList[i];
        NSString *name    = dic[@"name"];
        NSString *type    = dic[@"type"];
        NSString *sqlType = [self sqlTypeWithType:type];

        NSString *strTmp = nil;
        if ([name containsString:kPkid]) {
            // pk AUTOINCREMENT .
            strTmp = [NSString
                stringWithFormat:@"%@ %@ PRIMARY KEY AUTOINCREMENT DEFAULT '1',",
                                 name,
                                 sqlType];
            [strProperties appendString:strTmp];
        }
        else {
            // ignore prop
            if ([self propIsIgnore:name])
                continue;
            // default prop
            strTmp =
                [NSString stringWithFormat:@"%@ %@ NOT NULL %@ %@,", name, sqlType, [self defaultValWithSqlType:sqlType], [self keywordsWithName:name]];
            [strProperties appendString:strTmp];
        }
    }
    return strProperties;
}

- (NSDictionary *)appendInsert:(Class)cls
                         model:(id)model
                  propInfoList:(NSArray *)propInfoList
                      dicModel:(NSDictionary *)dicModel {
    NSMutableString *strProperties = [@"" mutableCopy];
    NSMutableString *strQuestions  = [@"" mutableCopy];
    for (int i = 0; i < propInfoList.count; i++) {
        id dicTmp      = propInfoList[i];
        NSString *name = dicTmp[@"name"];
        // dont insert primary key
        if ([name containsString:kPkid])
            continue;
        // ignore prop
        if ([self propIsIgnore:name])
            continue;
        // ignore nil prop
        if ([self propIsNilOrNull:dicModel[name]])
            continue;

        // prop
        [strProperties appendString:[NSString stringWithFormat:@"%@ ,", name]];
        // question
        [strQuestions
            appendString:[NSString stringWithFormat:@"'%@' ,", dicModel[name]]];
    }
    return @{ @"p" : strProperties,
              @"q" : strQuestions };
}

- (NSString *)appendUpdate:(Class)cls
                     model:(id)model
              propInfoList:(NSArray *)propInfoList
                  dicModel:(NSDictionary *)dicModel {
    NSString *setsStr = @"";
    for (int i = 0; i < propInfoList.count; i++) {
        id dicTmp      = propInfoList[i];
        NSString *name = dicTmp[@"name"];
        // dont update primary key
        if ([name containsString:kPkid])
            continue;
        // dont update xt_createTime
        if ([name containsString:@"createTime"])
            continue;
        // ignore prop
        if ([self propIsIgnore:name])
            continue;
        // ignore nil prop
        if ([self propIsNilOrNull:dicModel[name]])
            continue;

        // setstr
        NSString *tmpStr =
            [NSString stringWithFormat:@"%@ = '%@' ,", name, dicModel[name]];
        setsStr = [setsStr stringByAppendingString:tmpStr];
    }
    return setsStr;
}

- (BOOL)propIsNilOrNull:(id)val {
    return !val || [val isKindOfClass:[NSNull class]] ||
        ([val isKindOfClass:[NSString class]] &&
         [val isEqualToString:@"<null>"]);
}

- (NSString *)getSqlUseRecursiveQuery:(id)model
                                class:(Class) class
                                 type:(TypeOfAutoSql)type
                          whereByProp:(NSString *)whereByProp
{
    Class cls                      = class ?: [model class];
    NSString *tableName            = NSStringFromClass(cls);
    NSMutableString *strProperties = [@"" mutableCopy];
    NSMutableString *strQuestions  = [@"" mutableCopy];
    NSDictionary *dicModel =
        [self changeSpecifiedValToUTF8StringVal:model fromClass:cls];
    BOOL isFirst = NO;

    // Recursive Query
    while (1) {
        NSArray *propInfoList =
            !isFirst ? [self xt_autosql_propertiesInfo:cls] : [cls propertiesInfo];

        // APPEND SQL STRING .
        switch (type) {
            case xt_type_create: {
                [strProperties
                    appendString:[self appendCreate:cls propInfoList:propInfoList]];
            } break;
            case xt_type_insert:
            case xt_type_insertOrIgnore:
            case xt_type_insertOrReplace: {
                NSDictionary *resDic = [self appendInsert:cls
                                                    model:model
                                             propInfoList:propInfoList
                                                 dicModel:dicModel];
                [strProperties appendString:resDic[@"p"]];
                [strQuestions appendString:resDic[@"q"]];
            } break;
            case xt_type_update: {
                [strProperties appendString:[self appendUpdate:cls
                                                         model:model
                                                  propInfoList:propInfoList
                                                      dicModel:dicModel]];
            } break;
            default:
                break;
        }

        // RETURN IF NEEDED .
        if ([cls.superclass isEqual:[NSObject class]]) {
            switch (type) {
                case xt_type_create: {
                    NSString *resultSql = [NSString
                        stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ )", tableName, [strProperties substringToIndex:strProperties.length - 1]];
                    XTFMDBLog(@"xt_db sql create : \n%@\n\n", resultSql);
                    return resultSql;
                } break;
                case xt_type_insert: {
                    strProperties = [[strProperties
                        substringToIndex:strProperties.length - 1] mutableCopy];
                    strQuestions = [[strQuestions substringToIndex:strQuestions.length - 1]
                        mutableCopy];
                    NSString *strResult =
                        [NSString stringWithFormat:@"INSERT INTO %@ ( %@ ) VALUES ( %@ )",
                                                   tableName,
                                                   strProperties,
                                                   strQuestions];
                    XTFMDBLog(@"xt_db sql insert : \n%@\n\n", SAFELY_LOG_FORMAT(strResult));
                    return strResult;
                } break;
                case xt_type_insertOrIgnore: {
                    strProperties = [[strProperties
                        substringToIndex:strProperties.length - 1] mutableCopy];
                    strQuestions = [[strQuestions substringToIndex:strQuestions.length - 1]
                        mutableCopy];
                    NSString *strResult = [NSString
                        stringWithFormat:@"INSERT OR IGNORE INTO %@ ( %@ ) VALUES ( %@ )",
                                         tableName,
                                         strProperties,
                                         strQuestions];
                    XTFMDBLog(@"xt_db sql insert : \n%@\n\n", SAFELY_LOG_FORMAT(strResult));
                    return strResult;
                } break;
                case xt_type_insertOrReplace: {
                    strProperties = [[strProperties
                        substringToIndex:strProperties.length - 1] mutableCopy];
                    strQuestions = [[strQuestions substringToIndex:strQuestions.length - 1]
                        mutableCopy];
                    NSString *strResult = [NSString
                        stringWithFormat:@"INSERT OR REPLACE INTO %@ ( %@ ) VALUES ( %@ )",
                                         tableName,
                                         strProperties,
                                         strQuestions];
                    XTFMDBLog(@"xt_db sql insert : \n%@\n\n", SAFELY_LOG_FORMAT(strResult));
                    return strResult;
                } break;
                case xt_type_update: {
                    strProperties = [[strProperties
                        substringToIndex:strProperties.length - 1] mutableCopy];
                    NSString *whereStr = [NSString
                        stringWithFormat:@"%@ = '%@'", whereByProp, dicModel[whereByProp]];
                    NSString *strResult =
                        [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", tableName, strProperties, whereStr];
                    XTFMDBLog(@"xt_db sql update : \n%@", SAFELY_LOG_FORMAT(strResult));
                    return strResult;
                } break;
                default:
                    break;
            }
        }

        // NEXT LOOP IF NEEDED .
        cls     = [cls superclass];
        isFirst = YES;
    }
}

    - (NSString *)sqlTypeWithType : (NSString *)strType {
    if ([strType containsString:@"int"] || [strType containsString:@"Integer"]) {
        return @"INTEGER";
    }
    else if ([strType containsString:@"float"] ||
             [strType containsString:@"double"]) {
        return @"DOUBLE";
    }
    else if ([strType containsString:@"long"]) {
        return @"BIGINT";
    }
    else if ([strType containsString:@"NSString"] ||
             [strType containsString:@"char"] ||
             [strType containsString:@"NSMutableString"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"NSData"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"BOOL"] ||
             [strType containsString:@"bool"]) {
        return @"BOOLEAN";
    }
    else if ([strType containsString:@"NSArray"] ||
             [strType containsString:@"NSMutableArray"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"NSDictionary"] ||
             [strType containsString:@"NSMutableDictionary"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"NSSet"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"UIImage"]) {
        return @"TEXT";
    }
    else if ([strType containsString:@"NSDate"]) {
        return @"BIGINT";
    }
    XTFMDBLog(@"xt_db no type to transform !!");
    return @"TEXT"; // custom Cls or default
}

- (NSString *)defaultValWithSqlType:(NSString *)sqlType {
    if ([sqlType containsString:@"TEXT"] || [sqlType containsString:@"char"]) {
        return @" DEFAULT ''";
    }
    else
        return @" DEFAULT '0'";
}

- (NSString *)keywordsWithName:(NSString *)name {
    id dic = [m_orginCls modelPropertiesSqliteKeywords];
    if (!dic || !dic[name])
        return @"";
    return dic[name];
}

- (BOOL)propIsIgnore:(NSString *)name {
    id list = [[self defaultIgnoreProps]
        arrayByAddingObjectsFromArray:[m_orginCls ignoreProperties]];
    if (!list)
        return FALSE;
    return [list containsObject:name];
}

- (NSMutableArray *)defaultIgnoreProps {
    return [@[ @"hash", @"superclass", @"description", @"debugDescription" ]
        mutableCopy];
}

- (NSDictionary *)changeSpecifiedValToUTF8StringVal:(id)model
                                          fromClass:(Class)cls {
    NSMutableDictionary *dic =
        [[model propertyDictionary] mutableCopy]; // propModel
    NSArray *ignoreList = [m_orginCls ignoreProperties];
    for (NSString *key in ignoreList) {
        [dic removeObjectForKey:key];
    }

    [dic setObject:[model valueForKey:kPkid] forKey:kPkid];
    [dic setObject:[model valueForKey:@"xt_createTime"] forKey:@"xt_createTime"];
    [dic setObject:[model valueForKey:@"xt_updateTime"] forKey:@"xt_updateTime"];
    [dic setObject:[model valueForKey:@"xt_isDel"] forKey:@"xt_isDel"];

    NSMutableDictionary *tmpDic = [dic mutableCopy];
    for (NSString *key in dic) {
        id val = dic[key];
        if ([val isKindOfClass:[NSNull class]] || !val) {
            continue;
        }
        else if ([val isKindOfClass:[NSData class]]) {
            [tmpDic setObject:[self encodingB64String:val] forKey:key];
        }
        else if ([val isKindOfClass:[NSArray class]] ||
                 [val isKindOfClass:[NSMutableArray class]]) {
            NSString *json = [val yy_modelToJSONString];
            [tmpDic setObject:json forKey:key];
        }
        else if ([val isKindOfClass:[NSDictionary class]] ||
                 [val isKindOfClass:[NSDictionary class]]) {
            NSString *json = [val yy_modelToJSONString];
            [tmpDic setObject:json forKey:key];
        }
        else if ([val isKindOfClass:[UIImage class]]) {
            NSData *data =
                UIImageJPEGRepresentation(val, 1) ?: UIImagePNGRepresentation(val);
            [tmpDic setObject:[self encodingB64String:data] forKey:key];
        }
        else if ([val isKindOfClass:[NSDate class]]) {
            [tmpDic setObject:@([(NSDate *)val xt_getTick]) forKey:key];
        }
        else if ([self isAbnormalType:val]) { // custom Cls
            [tmpDic setObject:[val yy_modelToJSONString] forKey:key];
        }
    }
    return tmpDic;
}

- (BOOL)isAbnormalType:(id)val {
    if ([val isKindOfClass:[NSNumber class]] ||
        [val isKindOfClass:[NSString class]] ||
        [val isKindOfClass:[NSData class]] ||
        [val isKindOfClass:[NSArray class]] ||
        [val isKindOfClass:[NSMutableArray class]] ||
        [val isKindOfClass:[NSDictionary class]] ||
        [val isKindOfClass:[NSMutableDictionary class]] ||
        [val isKindOfClass:[NSSet class]] ||
        [val isKindOfClass:[UIImage class]] ||
        [val isKindOfClass:[NSDate class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)isAbnormalTypeString:(NSString *)strType {
    if ([strType containsString:@"int"] || [strType containsString:@"Integer"] ||
        [strType containsString:@"float"] || [strType containsString:@"double"] ||
        [strType containsString:@"long"] ||
        [strType containsString:@"NSString"] ||
        [strType containsString:@"char"] || [strType containsString:@"NSData"] ||
        [strType containsString:@"BOOL"] || [strType containsString:@"bool"] ||
        [strType containsString:@"NSArray"] ||
        [strType containsString:@"NSMutableArray"] ||
        [strType containsString:@"NSDictionary"] ||
        [strType containsString:@"NSMutableDictionary"] ||
        [strType containsString:@"NSSet"] ||
        [strType containsString:@"UIImage"] ||
        [strType containsString:@"NSDate"]) {
        return NO;
    }
    return YES;
}

- (NSString *)encodingB64String:(NSData *)data {
    return [data
        base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSDictionary *)getResultDicFromClass:(Class)cls
                              resultSet:(FMResultSet *)resultSet {
    m_orginCls                  = cls;
    NSMutableDictionary *tmpDic = [[resultSet resultDictionary] mutableCopy];
    if (!tmpDic)
        return nil;

    BOOL isFirst = NO;
    while (1) {
        NSArray *propInfoList = (!isFirst) ? [self xt_autosql_propertiesInfo:cls] : [cls propertiesInfo];
        for (int i = 0; i < propInfoList.count; i++) {
            NSDictionary *dic     = propInfoList[i];
            NSString *name        = dic[@"name"];
            NSString *type        = dic[@"type"];
            NSString *valFromFMDB = tmpDic[name];
            if (!valFromFMDB || [valFromFMDB isKindOfClass:[NSNull class]])
                continue;
            if ([valFromFMDB isKindOfClass:[NSString class]] && !valFromFMDB.length)
                continue;

            if ([type containsString:@"NSData"]) {
                NSData *tmpData = [[NSData alloc]
                    initWithBase64EncodedString:
                        valFromFMDB options:
                                        NSDataBase64DecodingIgnoreUnknownCharacters];
                [tmpDic setObject:tmpData forKey:name];
            }
            else if ([type containsString:@"NSArray"] ||
                     [type containsString:@"NSMutableArray"]) {
                Class containerCls =
                    [m_orginCls modelContainerPropertyGenericClass][name];
                NSArray *resultArr =
                    [NSArray yy_modelArrayWithClass:containerCls json:valFromFMDB];
                if (!resultArr)
                    continue;
                [tmpDic setObject:resultArr forKey:name];
            }
            else if ([type containsString:@"NSDictionary"] ||
                     [type containsString:@"NSMutableDictionary"]) {
                Class containerCls =
                    [m_orginCls modelContainerPropertyGenericClass][name];
                NSDictionary *resultDic =
                    [NSDictionary yy_modelDictionaryWithClass:containerCls
                                                         json:valFromFMDB];
                if (!resultDic)
                    continue;
                [tmpDic setObject:resultDic forKey:name];
            }
            else if ([type containsString:@"UIImage"]) {
                NSData *tmpData = [[NSData alloc]
                    initWithBase64EncodedString:
                        valFromFMDB options:
                                        NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *image = [UIImage imageWithData:tmpData];
                if (!image)
                    continue;
                [tmpDic setObject:image forKey:name];
            }
            else if ([type containsString:@"NSDate"]) {
                long long tmpTick = [valFromFMDB longLongValue];
                NSDate *tmpDate   = [NSDate xt_getDateWithTick:tmpTick];
                if (!tmpDate)
                    continue;
                [tmpDic setObject:tmpDate forKey:name];
            }
            else if ([self isAbnormalTypeString:type]) { // custom cls
                Class cls    = NSClassFromString([type substringToIndex:type.length - 1]);
                SEL testFunc = NSSelectorFromString(@"yy_modelWithJSON:");
                id obj =
                    ((id (*)(id, SEL, id))objc_msgSend)(cls, testFunc, valFromFMDB);
                [tmpDic setObject:obj forKey:name];
            }
        }

        if ([cls.superclass isEqual:[NSObject class]]) {
            break;
        }
        // NEXT LOOP IF NEEDED .
        cls     = [cls superclass];
        isFirst = YES;
    }

    return tmpDic;
}

/**
 结果处理
 1. 处理yymodel无法解析嵌套对象的字典的问题.
 2. 注入默认字段
 */
- (id)resetDictionaryFromDBModel:(NSDictionary *)dbModel resultItem:(id)item {
    m_orginCls   = [item class];
    Class cls    = m_orginCls;
    BOOL isFirst = NO;

    while (1) {
        NSArray *propInfoList =
            !isFirst ? [self xt_autosql_propertiesInfo:cls] : [cls propertiesInfo];
        for (int i = 0; i < propInfoList.count; i++) {
            NSDictionary *dic = propInfoList[i];
            NSString *name    = dic[@"name"];
            NSString *type    = dic[@"type"];
            id valFromFMDB    = dbModel[name];
            if (!valFromFMDB || [valFromFMDB isKindOfClass:[NSNull class]])
                continue;
            if ([valFromFMDB isKindOfClass:[NSString class]] &&
                !((NSString *)valFromFMDB).length)
                continue;

            if ([type containsString:@"NSDictionary"] ||
                [type containsString:@"NSMutableDictionary"]) {
                SEL selector = NSSelectorFromString(
                    [[@"set" stringByAppendingString:[self myCapitalizedString:name]]
                        stringByAppendingString:@":"]);
                IMP imp = [item methodForSelector:selector];
                void (*func)(id, SEL, id) = (void *)imp;
                func(item, selector, valFromFMDB);
            }
        }

        if ([cls.superclass isEqual:[NSObject class]])
            break;

        // NEXT LOOP IF NEEDED .
        cls     = [cls superclass];
        isFirst = YES;
    }

    item = [self injectDefaultColumnFromDBModel:dbModel resultItem:item];

    return item;
}

// add default column . pkid, xt_createTime ...
- (id)injectDefaultColumnFromDBModel:(NSDictionary *)dbModel
                          resultItem:(id)item {
    m_orginCls = [item class];
    [item setValue:dbModel[kPkid] forKey:kPkid];
    [item setValue:dbModel[@"xt_createTime"] forKey:@"xt_createTime"];
    [item setValue:dbModel[@"xt_updateTime"] forKey:@"xt_updateTime"];
    [item setValue:dbModel[@"xt_isDel"] forKey:@"xt_isDel"];

    return item;
}

- (NSString *)myCapitalizedString:(NSString *)orgString {
    NSString *prefix = [orgString substringToIndex:1];
    prefix           = [prefix uppercaseString];
    return [orgString stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                              withString:prefix];
}

- (NSArray *)xt_autosql_propertiesInfo:(Class)cls {
    return [self appendDefaultPropInfoFromArray:[cls propertiesInfo]];
}

- (NSArray *)appendDefaultPropInfoFromArray:(NSArray *)array {
    NSMutableArray *list = [@[
        @{
            @"attribute" : @[ @"nonatomic" ],
            @"isDynamic" : @0,
            @"name" : kPkid,
            @"type" : @"int",
        },
        @{
            @"attribute" : @[ @"nonatomic" ],
            @"isDynamic" : @0,
            @"name" : @"xt_createTime",
            @"type" : @"long long",
        },
        @{
            @"attribute" : @[ @"nonatomic" ],
            @"isDynamic" : @0,
            @"name" : @"xt_updateTime",
            @"type" : @"long long",
        },
        @{
            @"attribute" : @[ @"nonatomic" ],
            @"isDynamic" : @0,
            @"name" : @"xt_isDel",
            @"type" : @"BOOL",
        }
    ] mutableCopy];
    [list addObjectsFromArray:array];
    return list;
}

@end
