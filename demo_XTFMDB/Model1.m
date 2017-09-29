//
//  Model1.m
//  XTkit
//
//  Created by teason23 on 2017/5/2.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "Model1.h"

@implementation Model1

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
