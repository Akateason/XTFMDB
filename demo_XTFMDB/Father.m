//
//  Father.m
//  demo_XTFMDB
//
//  Created by teason23 on 2018/4/9.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "Father.h"
#import "SomeInfo.h"

@implementation Father

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"fatherList" : [SomeInfo class]    ,
             } ;
}

@end
