# Original intention:

OC/Swift iOS fast one-stop SQLite database setup. Call lighter. Faster. No need to pay attention to details.

# Precautions for Swift access

Just add '@objc dynamic' before each attribute var. Other uses are the same as objective-C


# features:

- No base class, no invasion. You can build tables directly on third-party classes.
- Directly from the project control table complex code, Model directly into the CURD operation. Detach from SQL statements.
- Built-in default fields pKID, xt_createTime, xt_updateTime, xt_isDel. Do not worry about primary keys and create update time changes handling.
- Automatic table building.
- The primary key is added automatically. You do not need to set the primary key. Pkid by default.
- Any operation. Thread safe.
- Batch operation Default practice. And failed rollback.
- Supports storage of various container classes. NSArray, NSDictionary. And containers with custom classes. Can handle arbitrary nested combinations.
- Easy database upgrade. One line of code can upgrade multiple database tables. Just set a new database version number.
- You can customize the keyword for each field. The DEFAULT keyword is already integrated, so there is no need to write non-null and DEFAULT values (NOT NULL, DEFAULT'' character type DEFAULT,DEFAULT'0' numeric type DEFAULT).
- Support for ignoring properties, such as ViewModel to specify which fields do not participate in CURD operations.
- General functions, quantities, sums, maxima, etc.
- Supports the NSData type.
- Supports THE UIImage type.

# Design idea:

Use iOS Runtime to add ORM model relational mapping on FMDB, the most authoritative SQLite open source library, and use the way of Category to separate from the base class, and add the default field dynamically. Enable any class to build tables.

---

Access mode:

```
pod 'XTFMDB'
```

# How to use:

Import header file #import < xtfMDB.h >

- Configuration at startup

Complete the configuration in the AppDelegate didFinishLaunchingWithOptions

```
[XTFMDBBase sharedInstance].isDebugMode = YES; // Whether to print the internal log
NSString *yourDbPath = @"... /your_DB_Name";
[[XTFMDBBase sharedInstance] configureDBWithPath:yourDbPath];

```

- Insert

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

The following M1 represents instances under anyModel.class.

1. insert

```
[m1 xt_insert]; / / a single
[AnyModel xt_insertList:list]; / / batch

```

2. insert or ignore

```
[m1 xt_insertOrIgnore]; // If there is one, ignore it
[AnyModel xt_insertOrIgnoreWithList:list]; // If there is one, ignore it

```

3. insert or replace

```
[m1 xt_insertOrReplace]; // If there is one, replace it
[AnyModel xt_insertOrReplaceWithList:list]; // If there is one, replace it

```

4. upsert

```
[m1 xt_upsertWhereByProp:@"name"]; // Update if it exists, insert if it does not.

```

- update

```
// update by pkid .
- (BOOL)xt_update; // Update default update by pkid. if pkid nil, update by a unique prop if has .
+ (BOOL)xt_updateListByPkid:(NSArray *)modelList; // Batch update

// update by custom key
- (BOOL)xt_updateWhereByProp:(NSString *)propName; / / a single
+ (BOOL)xt_updateList:(NSArray *)modelList whereByProp:(NSString *)propName; / / batch

```

e.g.

1. Update the entire model based on the primary key

```
[m1 xt_update]; // Update this object (pkid first, if the primary key is empty, find if there is a unique field to update.)
[AnyModel xt_updateListByPkid:list]; / / batch

```

2. Specify that the entire model is updated based on a field

```
[m1 xt_updateWhereByProp:@"name"]; // Update this object (manually specify a field)
[AnyModel xt_updateList:list whereByProp:@"name"]; / / batch
```

- query

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

1. List query

```
list = [AnyModel xt_findAll]; // Query all records in this table
list = [AnyModel xt_findWhere:@"name == 'mamba'"]; // Conditional query

```

2. Single query

```
item = [AnyModel xt_findFirstWhere:@"name == 'mamba'"]; // Query a single item
item = [AnyModel xt_findFirst];

```

3. Check whether it exists

```
bool has = [AnyModel xt_hasModelWhere:@"age < 4"] ; // Check whether there is data that meets the condition

```

4. Customize the query

```
list = [AnyModel xt_findWithSql:@"select * from AnyModel"] ; // Custom SQL statement, query list
item = [AnyModel xt_findFirstWithSql:@"select * from AnyModel where age == 111"] ; // Custom SQL statement, query a single

```

- delete

```
- (BOOL)xt_deleteModel;
+ (BOOL)xt_deleteModelWhere:(NSString *)strWhere; // param e.g. @" pkid = '1' "
+ (BOOL)xt_dropTable;
```

e.g.

1. Delete the current Model

```
[m1 xt_deleteModel]; // Delete the record

```

2. Delete the specified Model

```
[AnyModel xt_deleteModelWhere:@"name == 'peter'"];

```

3. Delete table

```
[AnyModel xt_dropTable]; / / delete table

```

- Common functions

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

1. Common functions

```
int count = [AnyModel xt_count] ;
int count = [AnyModel xt_countWhere:@"age < 10"] ;

double max = [AnyModel xt_maxOf:@"age"] ;
double max = [AnyModel xt_maxOf:@"age" where:@"location == 'shanghai'"] ;

```

2. Custom functions

```
id val = [AnyModel shmdb_anyFuncWithSql:@"..."] ;

```

- Sort

```
/ * *
Order by . (in memory)
@param columnName  --- must be a int column
@param descOrAsc   BOOL  desc - 1 , asc - 0
@return a sorted list
* /
- (NSArray *)shmdb_orderby:(NSString *)columnName
descOrAsc:(BOOL)descOrAsc;
```

e.g.

```
[list shmdb_orderby:@"age" descOrAsc:1]; // In descending order of age
```

- Configuration Constraints

To further configure the table, override three methods in the AnyModel class

```
// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords; // set sqlite Constraints of property

// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties;

// Container property , value should be Class or Class name. Same as YYmodel .
+ (NSDictionary *)modelContainerPropertyGenericClass;

```

1. Configure attribute constraints

ModelPropertiesSqliteKeywords, configuration properties, a default value is not empty and has joined without configuration, for example, in here you can specify the uniqueness of a particular field

```
+ (NSDictionary *)modelPropertiesSqliteKeywords {
return @{@"name":@"UNIQUE"} ;
}
```

1. Configure the fields that you do not want to participate in table building

IgnoreProperties, which configures fields that do not want to participate in table building. For example, viewModel-related properties.

```
+ (NSArray *)ignoreProperties {
return @[@"a1",@"a2"] ;
}
```

1. Configure the data types to be stored in container classes

ModelContainerPropertyGenericClass, dealing with nested in the container types have other classes.

```
@class Shadow, Border, Attachment;

@interface Attributes
@property NSString *name;
@property NSArray *shadows; //Array<Shadow>
@property NSSet *borders; //Set<Border>
@property NSMutableDictionary *attachments; //Dict<NSString,Attachment>
@end

@implementation Attributes
// Return the data type (Class or Class Name) that needs to be stored in the container Class.
+ (NSDictionary *)modelContainerPropertyGenericClass {
return @{@"shadows" : [Shadow class],
@"borders" : Border.class,
@"attachments" : @"Attachment" };
}
@end
```

- Upgrade

```
/ * *
The DB Version Upgrade
@ param tableCls Class
@param paramsAdd @[propName1,propName2...]
@param version (int) start from 1
* /
- (void)dbUpgradeTable:(Class)tableCls
ParamsAdd paramsAdd: (NSArray *)
Version: (int) version;
```

e.g. One line of code completes the database upgrade.

```
[[XTFMDBBase sharedInstance] dbUpgradeTable:AnyModel1.class
ParamsAdd: @ @ "b1" @ "b2" @ "b3"]
Version: 2];
// Just pass in the corresponding table, the new field array, and the corresponding database version number. The version number starts from 1 by default. Each upgrade increases incrementally.
Identified by this version number.
[[XTFMDBBase sharedInstance] dbUpgradeTable:AnyModel2.class
paramsAdd:@[ @"c1",@"c2",@"c3" ]
version:3];
```

<end>

# attached:

- SqLite Professional is recommended for MAC visualization
- If you have any questions, please issue me Akateason
