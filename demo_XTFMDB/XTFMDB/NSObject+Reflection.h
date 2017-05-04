//
//  NSObject+Reflection.h
//  NSObject-Reflection
//
//  Created by teason on 15/12/22.
//  Copyright © 2015年 teason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Reflection)

- (NSDictionary *)propertyDictionary;

//属性名称列表
- (NSArray*)propertyKeys;
+ (NSArray *)propertyKeys;

//属性详细信息列表
- (NSArray *)propertiesInfo;
+ (NSArray *)propertiesInfo;

//格式化后的属性列表
+ (NSArray *)propertiesWithCodeFormat;

+ (NSString *)decodeType:(const char *)cString ;

@end
