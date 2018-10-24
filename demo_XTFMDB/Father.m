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



+ (instancetype)randomAFather {
    int randomNum = arc4random() % 100 ; ;

    Father *f = [Father new] ;
    f.fatherName = [NSString stringWithFormat:@"我是你爹%d",randomNum] ;
    
    SomeInfo *info = [SomeInfo new] ;
    info.infoStr = [@(randomNum) stringValue] ;
    info.infoID = randomNum ;
    f.fatherList = @[info] ;
    
    return f ;
}

@end
