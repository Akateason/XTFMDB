# 设计初衷: 
快速一站式sqlite数据库搭建. 调用更轻.快. 无需关注细节 .

# 特性:
* 无基类, 无入侵性. 可直接在第三方类上建表 .
* 直接脱离项目中控制表的繁杂代码, Model直接进入CURD操作.脱离sql语句 .   
* 自带默认字段pkid, xt_createTime, xt_updateTime, xt_isDel. 无需关注主键和创建更新时间变化处理 .
* 自动建表 .
* 主键自增. 插入不需设主键. 默认pkid .
* 任何操作. 线程安全 .
* 批量操作默认实务.以及失败回滚  .
* 支持各容器类存储. NSArray, NSDictionary. 以及容器中带有自定义类等. 能处理任意嵌套组合 .
* 数据库升级简单, 一行代码完成数据库多表升级. 只需设置一个新的数据库版本号 .
* 每个字段可自定义设置关键字. 已经集成默认关键字, 无需再写非空和默认值( NOT NULL, DEFAULT''字符类型默认值,DEFAULT'0'数字类型默认值 ) .
* 支持忽略属性, 比如ViewModel 可指定哪些字段不参与CURD操作 .  
* 常规函数,数量,求和,最值等 .
* 支持NSData类型 .
* 支持UIImage类型 .

# 设计思路:
运用 iOS Runtime 在目前最权威的sqlite开源库FMDB之上增加ORM模型关系映射,  并使用Category的方式脱离基类, 并动态加入默认字段. 使任何类都能建表.




---
# 接入方式:
```
pod 'XTFMDB'
```
# 如何使用:
导入头文件  #import <XTFMDB.h>


* 启动时配置

在AppDelegate didFinishLaunchingWithOptions中完成配置
```
    [XTFMDBBase sharedInstance].isDebugMode = YES; //是否打印内部log
    NSString *yourDbPath = @".../shimoDB"; 
    [[XTFMDBBase sharedInstance] configureDBWithPath:yourDbPath];
    
```

* 插入
```
// insert
- (BOOL)xt_insert;
+ (BOOL)xt_insertList:(NSArray *)modelList;

// insert or ignore
- (BOOL)xt_insertOrIgnore;
+ (BOOL)xt_insertOrIgnoreWithList:(NSArray *)modelList;

// insert or replace
- (BOOL)xt_insertOrReplace;
+ (BOOL)xt_insertOrReplaceWithList:(NSArray *)modelList;

// upsert
- (BOOL)xt_upsertWhereByProp:(NSString *)propName;
```
以下m1代表AnyModel.class下的实例.
1. insert
```
    [m1 xt_insert];//单个
    [AnyModel xt_insertList:list];//批量
        
```
2. insert or ignore
```
    [m1 xt_insertOrIgnore]; //如果存在则忽略, 单个
    [AnyModel xt_insertOrIgnoreWithList:list]; //如果存在则忽略, 批量

```
3. insert or replace
```
    [m1 xt_insertOrReplace]; //如果存在则替换, 单个
    [AnyModel xt_insertOrReplaceWithList:list]; //如果存在则替换, 批量
    
```
4. upsert
```
    [m1 xt_upsertWhereByProp:@"name"];//存在则更新,不存在则插入.    
    
```

* 更新
```
// update by pkid .
- (BOOL)xt_update; // Update default update by pkid. if pkid nil, update by a unique prop if has .
+ (BOOL)xt_updateListByPkid:(NSArray *)modelList;//批量更新

// update by custom key
- (BOOL)xt_updateWhereByProp:(NSString *)propName;//单个
+ (BOOL)xt_updateList:(NSArray *)modelList whereByProp:(NSString *)propName;//批量

```
e.g.
1. 根据主键update整个model
```
    [m1 xt_update];//更新此对象(先找pkid,如果主键空,则寻找是否含有唯一的字段去更新.)
    [AnyModel xt_updateListByPkid:list];//批量
    
```
2. 指定根据某字段update整个model
```
    [m1 xt_updateWhereByProp:@"name"];//更新此对象(按手动指定某字段)
    [AnyModel xt_updateList:list whereByProp:@"name"];//批量
```

* 查询
```
+ (NSArray *)xt_findAll;
+ (NSArray *)xt_findWhere:(NSString *)strWhere; // param e.g. @" pkid = '1' "

+ (instancetype)xt_findFirstWhere:(NSString *)strWhere;
+ (instancetype)xt_findFirst;
+ (BOOL)xt_hasModelWhere:(NSString *)strWhere;

// any sql execute Query
+ (NSArray *)xt_findWithSql:(NSString *)sql;
+ (instancetype)xt_findFirstWithSql:(NSString *)sql;
```
e.g.
1. 列表查询
```
    list = [AnyModel xt_findAll]; //查询此表所有记录
    list = [AnyModel xt_findWhere:@"name == 'mamba'"];//条件查询

```
2. 单个查询    
```
    item = [AnyModel xt_findFirstWhere:@"name == 'mamba'"];//查询单个
    item = [AnyModel xt_findFirst];
    
```
3. 查是否存在
```
    bool has = [AnyModel xt_hasModelWhere:@"age < 4"] ; //是否存在满足条件的数据
    
```
4. 自定义查询
```
    list = [AnyModel xt_findWithSql:@"select * from AnyModel"] ;//自定义sql语句, 查询列表
    item = [AnyModel xt_findFirstWithSql:@"select * from AnyModel where age == 111"] ;//自定义sql语句, 查询单个
    
```

* 删除
```
- (BOOL)xt_deleteModel;
+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere; // param e.g. @" pkid = '1' "
+ (BOOL)xt_dropTable;
```
e.g.
1. 删除当前Model
```
    [m1 xt_deleteModel];//删除记录
    
```
2. 删除指定Model
```
    [AnyModel xt_deleteModelWhere:@"name == 'peter'"];
    
```
3. 删除表
```
    [AnyModel xt_dropTable]; //删除表
    
```

* 常用函数
```
// func execute Statements
+ (id)xt_anyFuncWithSql:(NSString *)sql;
+ (BOOL)xt_isEmptyTable;
+ (int)xt_count;
+ (int)xt_countWhere:(NSString *)whereStr;
+ (double)xt_maxOf:(NSString *)property;
+ (double)xt_maxOf:(NSString *)property where:(NSString *)whereStr;
+ (double)xt_minOf:(NSString *)property;
+ (double)xt_minOf:(NSString *)property where:(NSString *)whereStr;
+ (double)xt_sumOf:(NSString *)property;
+ (double)xt_sumOf:(NSString *)property where:(NSString *)whereStr;
+ (double)xt_avgOf:(NSString *)property;
+ (double)xt_avgOf:(NSString *)property where:(NSString *)whereStr;
```
e.g.
1. 常用函数
```
    int count = [AnyModel xt_count] ;
    int count = [AnyModel xt_countWhere:@"age < 10"] ;

    double max = [AnyModel xt_maxOf:@"age"] ;
    double max = [AnyModel xt_maxOf:@"age" where:@"location == 'shanghai'"] ;
    
```
2. 自定义函数
```
id val = [AnyModel shmdb_anyFuncWithSql:@"..."] ;

```


* 排序
```
/**
Order by . (in memory)
@param columnName  --- must be a int column
@param descOrAsc   BOOL  desc - 1 , asc - 0
@return a sorted list
*/
- (NSArray *)shmdb_orderby:(NSString *)columnName
descOrAsc:(BOOL)descOrAsc;
```
e.g.
```
    [list shmdb_orderby:@"age" descOrAsc:1]; //按年龄降序排列
```

* 配置约束

需要更深入的配置建表, 在AnyModel类中重载三个方法
```
// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords; // set sqlite Constraints of property

// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties;

// Container property , value should be Class or Class name. Same as YYmodel .
+ (NSDictionary *)modelContainerPropertyGenericClass;

```

1.  配置属性约束

modelPropertiesSqliteKeywords , 配置属性约束, 非空与默认值已经加入无需配置, 例如在这里可以指定某字段的唯一性
```
+ (NSDictionary *)modelPropertiesSqliteKeywords {
  return @{@"name":@"UNIQUE"} ;
}
```
1. 配置不想参加建表的字段

ignoreProperties, 配置不想参加建表的字段. 例如ViewModel相关的属性等.
```
+ (NSArray *)ignoreProperties {
  return @[@"a1",@"a2"] ;
}
```
1. 配置容器类中的所需要存放的数据类型

modelContainerPropertyGenericClass, 处理在容器类型中嵌套有其他类.
```
@class Shadow, Border, Attachment;

@interface Attributes
@property NSString *name;
@property NSArray *shadows; //Array<Shadow>
@property NSSet *borders; //Set<Border>
@property NSMutableDictionary *attachments; //Dict<NSString,Attachment>
@end

@implementation Attributes
// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shadows" : [Shadow class],
             @"borders" : Border.class,
             @"attachments" : @"Attachment" };
}
@end
```

* 升级
```
/**
 DB Version Upgrade
 @param tableCls    Class
 @param paramsAdd   @[propName1 ,propName2 ,... ,]
 @param version (int) start from 1
 */
- (void)dbUpgradeTable:(Class)tableCls
             paramsAdd:(NSArray *)paramsAdd
               version:(int)version;
```
e.g. 一行代码完成数据库升级.
```
[[XTFMDBBase sharedInstance] dbUpgradeTable:AnyModel1.class
                                      paramsAdd:@[ @"b1",@"b2",@"b3" ]
                                        version:2];
//只需传入对应表,新增字段数组,和对应数据库版本号.版本号默认从1开始. 逐次升级后递增.
以此版本号为标识.
[[XTFMDBBase sharedInstance] dbUpgradeTable:AnyModel2.class
                                      paramsAdd:@[ @"c1",@"c2",@"c3" ]
                                        version:3];
```




<end>

# 附:
* mac上的sqlite可视化工具推荐 SQLite Professional
* 使用中如有任何疑问,请issue于我 Akateason 

