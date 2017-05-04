# XTFMDB
对fmdb再封装.

### 特性
1. Model直接存储.获取. 无需再转换
2. 增删改查. 脱离sql语句
3. 主键自增. 插入不需设主键. pkid
4. Model满足. 无容器, 无嵌套. model的第一个属性必须是数字主键.且命名中须包含'pkid'.默认为pkid
5. 任何操作. 线程安全
6. 批量操作支持实务. 支持操作失败事务回滚. 且线程安全
7. 支持 每个字段自定义设置关键字. 已经集成默认关键字, 以下情况无需再写( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 )
8. 可指定哪些字段不参与建表.

## 使用方法
# `XTFMDB`数据库单例类. 
### 初始化
在app启动时调用配置函数
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 在这初始化数据库
    [[XTFMDB sharedInstance] configureDB:@"akateason"] ;
    
    return YES;
}

```

---

# `XTDBModel`模型制表基类.
### 使用
`XTDBModel`可以实现对数据库操作增删改查等.并且无需设置主键!
先创建一个`XTDBModel`的子类`Model1`
```

#import "XTDBModel.h"

@interface Model1 : XTDBModel
// 无需设置主键 默认 pkid
@property (nonatomic)       int             age         ;
@property (nonatomic)       float           floatVal    ;
@property (nonatomic)       long long       tick        ;
@property (nonatomic,copy)  NSString        *title      ;
@property (nonatomic,copy)  NSString        *abcabc     ;

@end

```
#### 可配置各个字段关键字
注意:
1. 在.m中覆盖基类modelPropertiesSqliteKeywords方法. 返回一个Dictionary. key为字段名. val为关键字, 加入想要多个关键字,以空格隔开即可.
2. 无需添加NOT NULL和DEFAULT关键字. (已集成)
例如,
```
+ (NSDictionary *)modelPropertiesSqliteKeywords
{
    return @{
                @"title" : @"UNIQUE" , 
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

#### 创建表
1. 马上创建一张名为`Model1`的数据库表
```
  [Model1 createTable] ;
```

#### 插入
1. 插入单个
```
    // 生成aModel对象. 直接插入
    int lastRowID = [aModel insert] ; // 默认返回Sqlite LastRowId
```
2. 批量插入
```
    Bool isSuccess = [Model1 insertList:modelList] ;
```

#### 更新
1. 更新单个
```
    Bool isSuccess = [aModel update] ;
```
2. 批量更新
```
    Bool isSuccess = [Model1 updateList:modelList] ;
```

#### 查询
1. 查询表中所有数据
```
  NSArray *list = [Model1 selectAll] ;
```
2. 按条件查询
```      
  NSArray *list = [Model1 selectWhere:@" title = 'aaaaaa' "] ; // 直接传入where条件即可
```
3. 按条件查询单个
```
  Model1 *model = [Model1 findFirstWhere:@"pkid == 2"] ;
```
4. 按条件查询是否包含
```
  BOOL isContained = [Model1 hasModelWhere:@"pkid == 1"] ;
```

#### 删除
1. 删除当前Model
```
  BOOL isDel = [aModel deleteModel] ;
```
2. 按条件删除某Model
```
  BOOL isDel = [Model1 deleteModelWhere:@" title == 'aaa' "] ;
```
3. 删除本表
```
  BOOL isDel = [Model1 dropTable] ;
```

---


有任何疑问或建议. 欢迎issue我.

