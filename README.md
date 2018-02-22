

#XTFMDB

### 特性
1. Model直接存储.获取. 无需再转换
2. 增删改查. 脱离sql语句
3. 主键自增. 插入不需设主键. pkid
4. Model满足. 无嵌套. model的第一个属性必须是数字主键.且命名中须包含'pkid'.默认为pkid
5. 任何操作. 线程安全
6. 批量操作支持实务. 支持操作失败事务回滚. 且线程安全
7. 支持 每个字段自定义设置关键字. 已经集成默认关键字, 以下情况无需再写( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 )
8. 可指定哪些字段不参与建表.
9. 支持各容器类存储. NSArray, NSDictionary
10. 支持NSData类型
11. 支持图片存储
12. XTDBModel支持默认字段, createTime, updateTime, isDel
13. 一行代码完成数据库升级.
14. 常规运算, 求和,最值等

## 使用方法
## CocoaPod
pod 'XTFMDB'
 
导入 XTFMDB.h

### 初始化 在app启动时调用配置函数

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// 在这初始化数据库
[[XTFMDBbase sharedInstance] configureDB:@"akateason"] ;

return YES;
}

```

---

### 使用CRUD
先创建一个自定义模型类`Model1`

支持两种建模方式

方式1) XTDBModel的子类, 可以直接实现对数据库操作增删改查等.并且无需设置主键pkid
```
@interface Model1 : XTDBModel
// 无需设置主键 默认 pkid
@property (nonatomic)       int             age         ;
@property (nonatomic)       float           floatVal    ;
@property (nonatomic)       long long       tick        ;
@property (nonatomic,copy)  NSString        *title      ;
@property (nonatomic,copy)  NSString        *abcabc     ; // 不想在表里出现这个 !!
@property (nonatomic,strong)    UIImage         *image      ;
@property (nonatomic,copy)      NSArray         *myArr      ;
@property (nonatomic,copy)      NSDictionary    *myDic      ;
@end
```
方式2) 任意创建一个类, 可以直接实现对数据库操作增删改查等.但需要手动设置主键pkid
```
@interface Model1 : NSObject
@property (nonatomic)       int             pkid        ; // primary key
@property (nonatomic)       int             age         ;
@property (nonatomic)       float           floatVal    ;
@property (nonatomic)       long long       tick        ;
@property (nonatomic,copy)  NSString        *title      ;
@property (nonatomic,copy)  NSString        *abcabc     ; // 不想在表里出现这个 !!
@property (nonatomic,strong)    UIImage         *image      ;
@property (nonatomic,copy)      NSArray         *myArr      ;
@property (nonatomic,copy)      NSDictionary    *myDic      ;
@end
```
#### 可配置各个字段关键字
注意:
1. 在.m中覆盖基类`modelPropertiesSqliteKeywords`方法. 返回一个Dictionary. key为字段名. val为关键字, 加入想要多个关键字,以空格隔开即可 .
2. 无需添加`NOT NULL`和`DEFAULT`关键字. (已集成) .

```
+ (NSDictionary *)modelPropertiesSqliteKeywords
{
return @{
@"title" : @"UNIQUE" ,  // 
...           
} ;
}
```

#### 配置不想参与建表的字段
在.m中覆盖基类ignoreProperties方法. 返回Array. 列出不想参与建表的字段
```
+ (NSArray *)ignoreProperties
{
return @[
@"abcabc" ,
...
] ;
}
```

###### 只需要导入`"XTFMDB.h"就可使用

#### 创建表
1. 马上创建一张名为`Model1`的数据库表
```
[Model1 xt_createTable] ; // [Model1 createTable] ; 当Model1是XTDBModel子类时,也可以用这个方法.以下方法均可以同上.
```

#### 插入
1. 插入单个
```
// 生成aModel对象. 直接插入
int lastRowID = [aModel xt_insert] ; // 默认返回Sqlite LastRowId
```
2. 批量插入
```
Bool isSuccess = [Model1 xt_insertList:modelList] ;
```

#### 更新
1. 更新单个
```
Bool isSuccess = [aModel xt_update] ;
```
2. 批量更新
```
Bool isSuccess = [Model1 xt_updateList:modelList] ;
```

#### 查询
1. 查询表中所有数据
```
NSArray *list = [Model1 xt_selectAll] ;
```
2. 按条件查询
```      
NSArray *list = [Model1 xt_selectWhere:@" title = 'aaaaaa' "] ; // 直接传入where条件即可
```
3. 按条件查询单个
```
Model1 *model = [Model1 xt_findFirstWhere:@"pkid == 2"] ;
```
4. 按条件查询是否包含
```
BOOL isContained = [Model1 xt_hasModelWhere:@"pkid == 1"] ;
```

#### 删除
1. 删除当前Model
```
BOOL isDel = [aModel xt_deleteModel] ;
```
2. 按条件删除某Model
```
BOOL isDel = [Model1 xt_deleteModelWhere:@" title == 'aaa' "] ;
```
3. 删除本表
```
BOOL isDel = [Model1 xt_dropTable] ;
```

#### 运算操作 求和,最值,平均值等
```
// func execute Statements
+ (id)anyFuncWithSql:(NSString *)sql ;
+ (int)count ;
+ (BOOL)isEmptyTable ;
+ (double)maxOf:(NSString *)property ;
+ (double)minOf:(NSString *)property ;
+ (double)sumOf:(NSString *)property ;
+ (double)avgOf:(NSString *)property ;
```

#### 更新数据库版本 加字段 (一行代码)
```
将数据库版本更新为v2. 在Model1中加3个字段,只需要把字段名写入!
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Model1.class
                                      paramsAdd:@[@"a1",@"a2",@"a3"]
                                        version:2] ;

```

---


```
@interface XTFMDBBase : NSObject
+ (XTFMDBBase *)sharedInstance ;
@property (nonatomic,strong,readonly) FMDatabase         *database   ;
@property (nonatomic,strong)          FMDatabaseQueue    *queue      ;

#pragma mark --

// config db in "- [(AppDelegate *) AppDidLaunchFinish]"
- (void)configureDB:(NSString *)name ;
- (void)configureDB:(NSString *)name
path:(NSString *)path ;

- (BOOL)verify ;

- (BOOL)isTableExist:(NSString *)tableName ;

@end
```

```
@interface XTDBModel : NSObject

// primaryKey
@property (nonatomic,assign) int pkid ;

#pragma mark - tableIsExist

+ (BOOL)tableIsExist ;

#pragma mark - create

+ (BOOL)createTable ;

#pragma mark - insert

// insert or replace
- (int)insert ; // return lastRowId .
+ (BOOL)insertList:(NSArray *)modelList ;

#pragma mark - update

- (BOOL)update ;
+ (BOOL)updateList:(NSArray *)modelList ;

#pragma mark - select

+ (NSArray *)selectAll ;
+ (NSArray *)selectWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (instancetype)findFirstWhere:(NSString *)strWhere ;
+ (BOOL)hasModelWhere:(NSString *)strWhere ;

// any sql
+ (NSArray *)findWithSql:(NSString *)sql ;
+ (instancetype)findFirstWithSql:(NSString *)sql ;

#pragma mark - delete

- (BOOL)deleteModel ;
+ (BOOL)deleteModelWhere:(NSString *)strWhere ; // param e.g. @" pkid = '1' "
+ (BOOL)dropTable ;

#pragma mark - alter

+ (BOOL)alterAddColumn:(NSString *)name
type:(NSString *)type ;


#pragma mark - Constraints

// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords ; // set Constraints of property
// ignore Properties
+ (NSArray *)ignoreProperties ;

@end
```



你的star是我的动力

有任何疑问或建议. 欢迎在github或博客里issue我. 
