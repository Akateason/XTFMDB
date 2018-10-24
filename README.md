

# XTFMDB
pod 'XTFMDB'

### 特性
1. Model直接CURD各种操作. 无需再转换
2. 脱离sql语句. 常规操作中无需写sql 
3. 主键自增. 插入不需设主键. pkid
4. 升级简单, 一行代码完成表升级. 只需设置一个新的数据库版本号
5. 任何操作. 线程安全
6. 批量操作默认支持实务. 支持操作失败事务回滚 
7. 支持 每个字段自定义设置关键字. 已经集成默认关键字, 以下情况无需再写( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 )
8. 支持忽略属性, 比如ViewModel 可指定哪些字段不参与CURD操作. 
9. 支持各容器类存储. NSArray, NSDictionary. 以及容器中带有自定义类等 NSArray<CutomCls *> ...
10. 支持NSData类型
11. 支持图片类型
12. 支持默认字段pkid, xt_createTime, xt_updateTime, xt_isDel
13. 也可用于不继承于XTDBModel的任意类型. 但自定义的Model必须满足一个属性必须是数字主键.且命名中须包含'pkid'
14. 常规运算,数量,求和,最值等等
15. 支持自动建表
16. 无基类, 无入侵性, 任意组合.


## 使用方法
## CocoaPod
pod 'XTFMDB'
 
导入 XTFMDB.h

### 初始化 在app启动时调用配置函数

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 在这初始化数据库
    [XTFMDBBase sharedInstance].isDebugMode = YES ;
    [[XTFMDBBase sharedInstance] configureDBWithPath:documentsDirectory] ;
    
    return YES;
}

```

---

### 使用CRUD
先创建一个自定义模型类`Model1`
任意创建一个类, 可以直接实现对数据库操作增删改查等.但需要手动设置主键pkid
```
@interface Model1 : NSObject
@property (nonatomic)           int             pkid        ; //必须加上pkid

// 基本类型, 什么都不用做
@property (nonatomic)           int             age         ;
@property (nonatomic)           float           floatVal    ;
@property (nonatomic)           long long       tick        ;
@property (nonatomic,copy)      NSString        *title      ;
@property (nonatomic,copy)      NSString        *abcabc     ;
@property (nonatomic,strong)    UIImage         *image      ;

// 处理容器和嵌套, 需配置, 见下示例
@property (nonatomic,copy)      NSArray<SomeInfo *>         *myArr      ;//Array<SomeInfo> , 
//@property (nonatomic,strong)  NSMutableDictionary         *myDic      ;//Dict <NSString,AccessObj> 可变
@property (nonatomic,copy)      NSDictionary                *myDic      ;//Dict <NSString,AccessObj> 不可变, 都可以
@property (strong, nonatomic)   NSDate          *today      ;
@property (strong, nonatomic)   SomeInfo        *sInfo      ; // 自动处理嵌套SomeInfo, 什么都不用做
@end
```


#### 可配置各个字段sqlite约束
注意:
1. 在.m中覆盖基类`modelPropertiesSqliteKeywords`方法.  假如想要多个关键字,以空格隔开即可 .
2. 无需添加`NOT NULL`,`DEFAULT`,`PRIMARY Key`关键字. (已集成) .

```
NOT NULL 约束：确保某列不能有 NULL 值。

DEFAULT 约束：当某列没有指定值时，为该列提供默认值。

UNIQUE 约束：确保某列中的所有值是不同的。

PRIMARY Key 约束：唯一标识数据库表中的各行/记录。 

CHECK 约束：CHECK 约束确保某列中的所有值满足一定条件。
```

e.g.
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
在.m中覆盖基类ignoreProperties方法. 列出不想参与建表的字段
```
+ (NSArray *)ignoreProperties
{
    return @[
                @"abcabc" ,
                    ...
            ] ;
}
```

#### 配置嵌套容器的字段. 
```
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
            @"myArr" : [SomeInfo class]    ,
            @"myDic" : [AccessObj class]   ,
            @"fatherList" : [SomeInfo class] ,
        } ;
}

```

###### 只需要导入`"XTFMDB.h"就可使用

#### 创建表
1. 马上创建一张名为`Model1`的数据库表(会自动创建可不写)
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


#### 更新 (默认根据客户端主键pkid)
1. 更新单个
```
Bool isSuccess = [aModel xt_update] ;
```
2. 批量更新
```
Bool isSuccess = [Model1 xt_updateList:modelList] ;
```


#### 更新 指定根据自定义某个字段
1. 更新单个
```
Bool isSuccess = [aModel xt_updateWhereByProp:@"userName"] ;
```
2. 批量更新
```
Bool isSuccess = [Model1 xt_updateList:modelList whereByProp:@"userName"] ;
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
5. 自定义sql语句的查询
```
多个
+ (NSArray *)xt_findWithSql:(NSString *)sql ;
单个
+ (instancetype)xt_findFirstWithSql:(NSString *)sql ;
```
6. 对结果排序
```
list = [[CustomDBModel selectAll] xt_orderby:@"age" descOrAsc:YES] ; // 对CustomDBModel结果集的age字段,做降序

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
+ (id)xt_anyFuncWithSql:(NSString *)sql ; // 自定义
+ (int)xt_count ;
+ (BOOL)xt_isEmptyTable ;
+ (double)xt_maxOf:(NSString *)property ;
+ (double)xt_minOf:(NSString *)property ;
+ (double)xt_sumOf:(NSString *)property ;
+ (double)xt_avgOf:(NSString *)property ;

```

#### 更新数据库版本 加字段 (一行代码)
```
将数据库版本更新为v2. 在Model1中加3个字段,只需要把字段名写入!
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Model1.class
                                      paramsAdd:@[@"a1",@"a2",@"a3"]
                                        version:2] ;

```

---


若有任何疑问或建议. 请issue或mail于我.
