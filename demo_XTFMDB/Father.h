//
//  Father.h
//  demo_XTFMDB
//
//  Created by teason23 on 2018/4/9.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SomeInfo ;

@interface Father : NSObject

@property (copy, nonatomic) NSString            *fatherName ;
@property (copy, nonatomic) NSArray<SomeInfo *> *fatherList ;

@end
