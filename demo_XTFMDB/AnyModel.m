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
        @"myArr" : [SomeInfo class],
        @"myDic" : [AccessObj class],
        @"fatherList" : [SomeInfo class],
    };
}

+ (NSDictionary *)modelPropertiesSqliteKeywords {
    return @{ @"title" : @"UNIQUE" };
}

+ (instancetype)customRandomModel {
    int randomNum = arc4random() % 100;
    ;

    AnyModel *m1 = [AnyModel new]; // 需设置主键
    m1.age       = randomNum;
    m1.floatVal  = (float)randomNum / 100.0;
    m1.tick      = randomNum * 9999;
    m1.title     = [NSString stringWithFormat:@"title %d", randomNum];
    m1.image     = [UIImage imageNamed:@"kobe"];

    NSMutableArray *tmplist = [@[] mutableCopy];
    for (int i = 0; i < 1; i++) {
        SomeInfo *info = [SomeInfo new];
        info.infoID    = i + randomNum;
        info.infoStr   = [@(i + randomNum) stringValue];
        [tmplist addObject:info];
    }
    m1.myArr = tmplist;

    AccessObj *access = [AccessObj new];
    access.accessStr  = [@(randomNum) stringValue];
    m1.myDic          = @{
        @"k1" : access,
    };
    m1.today = [NSDate date];

    SomeInfo *info = [SomeInfo new];
    info.infoStr   = [@(randomNum) stringValue];
    info.infoID    = randomNum;
    m1.sInfo       = info;

    // super cls
    m1.fatherName = @"this prop is from super class";
    m1.fatherList = @[ info ];

    return m1;
}

@end
