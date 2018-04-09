//
//  AnyModel.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/10/9.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//@class SomeInfo,AccessObj ;
#import "SomeInfo.h"
#import "AccessObj.h"

@interface AnyModel : NSObject

@property (nonatomic)           int             pkid        ;

@property (nonatomic)           int             age         ;
@property (nonatomic)           float           floatVal    ;
@property (nonatomic)           long long       tick        ;
@property (nonatomic,copy)      NSString        *title      ;
@property (nonatomic,copy)      NSString        *abcabc     ;
@property (nonatomic,strong)    UIImage         *image      ;

@property (nonatomic,copy)      NSArray<SomeInfo *>                  *myArr      ;//Array<SomeInfo>
@property (nonatomic,copy)      NSDictionary<NSString *,AccessObj *> *myDic      ;//Dict <NSString,AccessObj>
@property (strong, nonatomic)   NSDate          *today      ;
@property (strong, nonatomic)   SomeInfo        *sInfo      ;//什么都不用做

@end
