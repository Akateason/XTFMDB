//
//  CustomDBModel.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/10/9.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "CustomDBModel.h"

@implementation CustomDBModel

+ (NSDictionary *)modelPropertiesSqliteKeywords
{
    return @{
             @"title" : @"UNIQUE"
             } ;
}

+ (NSArray *)ignoreProperties
{
    return @[
             @"abcabc"
             ] ;
}

@end
