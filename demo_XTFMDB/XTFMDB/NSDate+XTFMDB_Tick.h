//
//  NSDate+XTFMDB_Tick.h
//  demo_XTFMDB
//
//  Created by teason23 on 2018/2/22.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kTIME_STR_FORMAT_1 = @"YYYYMMddHHmmss";
static NSString *const kTIME_STR_FORMAT_2 = @"yyyy年MM月dd日";
static NSString *const kTIME_STR_FORMAT_3 = @"yyyy 年 MM 月 dd 日";
static NSString *const kTIME_STR_FORMAT_4 = @"YYYY-MM-dd HH:mm:ss";
static NSString *const kTIME_STR_FORMAT_5 = @"YYYY-MM-dd HH:mm";
static NSString *const kTIME_STR_FORMAT_6 = @"YYYY-MM-dd";
static NSString *const kTIME_STR_FORMAT_7 = @"MM-dd HH:mm";
static NSString *const kTIME_STR_FORMAT_8 = @"MM-dd";
static const float kMillisecond           = 1000.0;
static const float kSecond                = 1.0;
#define kUnitConversion kSecond


@interface NSDate (XTFMDB_Tick)

/**
 get Tick
 */
+ (long long)xt_getNowTick;

- (long long)xt_getTick;

+ (long long)xt_getTickWithDateStr:(NSString *)dateStr
                            format:(NSString *)format;

/**
 compare tick
 */
+ (NSComparisonResult)xt_compareTick:(long long)tick1 and:(long long)tick2;

/**
 get time str
 @p fomat default is kTIME_STR_FORMAT_1
 */
+ (NSString *)xt_getStrWithTick:(long long)tick;

+ (NSString *)xt_getStrWithTick:(long long)tick format:(NSString *)format;

- (NSString *)xt_getStr;

- (NSString *)xt_getStrWithFormat:(NSString *)format;

- (NSString *)xt_timeInfo;

- (NSString *)xt_getMMDD;

/**
 get date
 @p fomat default is kTIME_STR_FORMAT_1
 */
+ (NSDate *)xt_getDateWithTick:(long long)tick;

+ (NSDate *)xt_getDateWithStr:(NSString *)dateStr;

+ (NSDate *)xt_getDateWithStr:(NSString *)dateStr format:(NSString *)format;

@end
