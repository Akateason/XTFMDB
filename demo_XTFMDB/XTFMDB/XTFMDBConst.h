//
//  XTFMDBConst.h
//  XTlib
//
//  Created by teason23 on 2017/7/24.
//  Copyright © 2017年 teason. All rights reserved.
//

#ifndef XTFMDBConst_h
#define XTFMDBConst_h

#define xtfmdb_DEBUG    1

#if xtfmdb_DEBUG

#define XTFMDBLog(format, ...) do {                                         \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "🌙🌙🌙xtfmdb🌙🌙🌙\n");                                           \
} while (0)

#else
#   define XTFMDBLog(...)
#endif

#endif /* XTFMDBConst_h */
