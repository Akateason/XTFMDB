//
//  AnyModel.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/10/9.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "AnyModel.h"

@implementation AnyModel

// yymodel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"myArr" : [SomeInfo class]    ,
                @"myDic" : [AccessObj class]   ,
                @"fatherList" : [SomeInfo class] ,
             } ;
}


+ (NSDictionary *)modelPropertiesSqliteKeywords
{
    return @{
             @"title" : @"UNIQUE"
             } ;
}

@end
