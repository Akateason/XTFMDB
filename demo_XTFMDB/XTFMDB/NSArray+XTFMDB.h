//
//  NSArray+XTFMDB.h
//  demo_XTFMDB
//
//  Created by teason23 on 2018/6/6.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (XTFMDB)

/**
 Order by . (in memory)
 @param columnName  --- must be a int column
 @param descOrAsc   BOOL  desc - 1 , asc - 0
 @return a sorted list
 */
- (NSArray *)xt_orderby:(NSString *)columnName descOrAsc:(BOOL)descOrAsc;

@end
