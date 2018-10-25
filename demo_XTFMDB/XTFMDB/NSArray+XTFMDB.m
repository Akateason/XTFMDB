//
//  NSArray+XTFMDB.m
//  demo_XTFMDB
//
//  Created by teason23 on 2018/6/6.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "NSArray+XTFMDB.h"
#import "NSObject+XTFMDB_Reflection.h"
#import <objc/message.h>
#import <objc/runtime.h>


@implementation NSArray (XTFMDB)

- (NSArray *)xt_orderby:(NSString *)columnName descOrAsc:(BOOL)descOrAsc {
    return [self sortedArrayUsingComparator:^NSComparisonResult(
                     id _Nonnull obj1, id _Nonnull obj2) {
        int dval1 = ((int (*)(id, SEL))objc_msgSend)(
            obj1, NSSelectorFromString(columnName));
        int dval2 = ((int (*)(id, SEL))objc_msgSend)(
            obj2, NSSelectorFromString(columnName));

        if (descOrAsc) {
            return dval1 < dval2 ? NSOrderedDescending : NSOrderedAscending;
        }
        else {
            return dval1 > dval2 ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
}

@end
