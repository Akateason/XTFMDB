//
//  XTFMDBConst.h
//  XTlib
//
//  Created by teason23 on 2017/7/24.
//  Copyright © 2017年 teason. All rights reserved.
//

#import "XTFMDBBase.h"

#ifndef XTFMDBConst_h
#define XTFMDBConst_h

#define XTFMDBLog1(format, ...)              \
    do {                                     \
        fprintf(stderr, "🌙🌙🌙xtfmdb🌙🌙🌙\n");   \
        (NSLog)((format), ##__VA_ARGS__);    \
        fprintf(stderr, "🌙🌙🌙xtfmdb🌙🌙🌙\n\n"); \
    } while (0)

#define XTFMDBLog(format, ...)               \
    if (XTFMDB_isDebug) {                    \
        XTFMDBLog1((format), ##__VA_ARGS__); \
    };

#endif /* XTFMDBConst_h */
