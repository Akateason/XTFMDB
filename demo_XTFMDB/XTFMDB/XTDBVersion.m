//
//  XTDBVersion.m
//  XTlib
//
//  Created by teason23 on 2017/11/25.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTDBVersion.h"


@implementation XTDBVersion

+ (NSDictionary *)modelPropertiesSqliteKeywords {
    return @{ @"version" : @"UNIQUE" };
}

@end
