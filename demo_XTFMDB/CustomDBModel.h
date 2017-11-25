//
//  CustomDBModel.h
//  demo_XTFMDB
//
//  Created by teason23 on 2017/10/9.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "XTDBModel.h"
#import <UIKit/UIKit.h>

@interface CustomDBModel : XTDBModel
@property (nonatomic)           int             age         ;
@property (nonatomic)           float           floatVal    ;
@property (nonatomic)           long long       tick        ;
@property (nonatomic,copy)      NSString        *title      ;
@property (nonatomic,copy)      NSString        *abcabc     ;
@property (nonatomic,strong)    UIImage         *image      ;
@property (nonatomic,copy)      NSArray         *myArr      ;
@property (nonatomic,copy)      NSDictionary    *myDic      ;

//// add in db v 2 .
//@property (nonatomic)       int             a1 ;
//@property (nonatomic,strong)NSData          *a2 ;
//@property (nonatomic,strong)UIImage         *a3 ;
//
//// add in db v 3 .
//@property (nonatomic)       double          b1 ;
//@property (nonatomic,strong)NSString        *b2 ;
//@property (nonatomic,strong)NSArray         *b3 ;

@end
