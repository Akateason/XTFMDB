//
//  XTDBModel.h
//  XTlib
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teason. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((deprecated("Class XTDBModel is deprecated , use NSObject+XTFMDB.h instead!!!")))

@interface XTDBModel : NSObject

@property (nonatomic,assign)    int         pkid        ; // primaryKey
@property (nonatomic,assign)    long long   createTime  ;
@property (nonatomic,assign)    long long   updateTime  ;
@property (nonatomic,assign)    BOOL        isDel       ;

@end
