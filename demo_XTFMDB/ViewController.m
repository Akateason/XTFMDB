//
//  ViewController.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.

// this is a zample .

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Masonry.h"
#import "AnyModel.h"
#import "YYModel.h"
#import "DisplayViewController.h"
#import "XTFMDB.h"
#import "MainVCell.h"
#import "SomeInfo.h"
#import "AccessObj.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy,nonatomic) NSArray *datasource ;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.title = @"XTFMDB" ;
    self.datasource = @[
                        @"create" ,
                        @"select" ,
                        @"selectWhere" ,
                        @"insert" ,
                        @"insertOrIgnore" ,
                        @"insertOrReplace" ,
                        @"update" ,
                        @"upsert" ,
                        @"delete" ,
                        @"drop",
                        @"insertList",
                        @"updateList",
                        @"findFirst",
                        @"AlterAdd",
                        @"sum" ,
                        @"orderBy" ,
                        ] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainVCell"] ;
    cell.textLabel.text = self.datasource[indexPath.row] ;
    return cell ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {return 40 ;}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strButtonName = [self.datasource[indexPath.row] stringByAppendingString:@"Action"] ;
    SEL methodSel = NSSelectorFromString(strButtonName) ;
    ((void (*)(id, SEL, id))objc_msgSend)(self, methodSel, nil) ;
}

#pragma mark - actions

- (void)createAction {
    [AnyModel xt_createTable] ;
}

- (void)selectAction {
    NSArray *list = [AnyModel xt_selectAll] ;
    for (AnyModel *model in list) {
        NSLog(@"%d",model.pkid) ;
    }
    
    [self displayJump] ;
}

- (void)selectWhereAction {
    NSArray *list = [AnyModel xt_selectWhere:@"age > 10 "] ;
    NSLog(@"list : %@ \ncount:%@",list,@(list.count)) ;
}

- (void)insertAction {

    AnyModel *m1 = [AnyModel new] ; // 需设置主键
    m1.age = arc4random() % 100 ;
    m1.floatVal = 3232.89f ;
    m1.tick = 666666666666 ;
    m1.title = [NSString stringWithFormat:@"atitle%d",arc4random()%999] ;
    m1.image = [UIImage imageNamed:@"kobe"] ;
    
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    for (int i = 0; i<4; i++) {
        SomeInfo *info = [SomeInfo new] ;
        info.infoID = i+330 ;
        info.infoStr = @"fffff3333" ;
        [tmplist addObject:info] ;
    }
    m1.myArr = tmplist;
    
    AccessObj *access = [AccessObj new] ;
    access.accessStr = @"acce333" ;
    m1.myDic = @{@"k1":access,
                 @"k2":access,
                 @"k3":access} ;
    
    m1.today = [NSDate date] ;
    
    SomeInfo *info = [SomeInfo new] ;
    info.infoStr = @"test3232311111.dddddr" ;
    info.infoID = 884 ;
    m1.sInfo = info ;
    
    // super cls
    m1.fatherName = @"this prop is from super class" ;
    m1.fatherList = @[info] ;
    
    [m1 xt_insert] ;

    
    [self displayJump] ;
}

- (void)insertOrIgnoreAction {

        AnyModel *m1 = [AnyModel new] ;
        m1.age = 1 ;
        m1.floatVal = 2 ;
        m1.tick = 1 ;
        m1.title = @"insert or ignore" ;
        [m1 xt_insertOrIgnore] ;
    
    
    [self displayJump] ;
}

- (void)insertOrReplaceAction {
    
    
        AnyModel *m1 = [AnyModel new] ;
        m1.age = 5 ;
        m1.floatVal = 3 ;
        m1.tick = 13 ;
        m1.title = @"insert or replace" ;
        [m1 xt_insertOrReplace] ;
    
    
    [self displayJump] ;
}

- (void)upsertAction {
        AnyModel *m1 = [AnyModel new] ;
        m1.age = arc4random() % 100 ;
        m1.floatVal = 4 ;
        m1.tick = 14 ;
        m1.title = @"upsert" ;
        [m1 xt_upsertWhereByProp:@"title"] ;
    
    
    [self displayJump] ;
}

- (void)updateAction {
        AnyModel *m1 = [[AnyModel xt_selectAll] lastObject] ;
        m1.image = nil ;
        m1.age = 4444444 ;
        m1.floatVal = 44.4444 ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"我就改你,r%d",arc4random() % 99] ;
        m1.myArr = @[@11111111111] ;
        m1.myDic = @{@"key":@"daafafafafaa1111aaa"} ;
        [m1 xt_update] ;
    
    
    [self displayJump] ;
}

- (void)deleteAction {

        NSString *titleDel = ((AnyModel *)[[AnyModel xt_selectAll] lastObject]).title ;
        [AnyModel xt_deleteModelWhere:[NSString stringWithFormat:@"title == '%@'",titleDel]] ;
 
    [self displayJump] ;
}

- (void)dropAction {
    
        [AnyModel xt_dropTable] ;
    
    
    [self displayJump] ;
}

- (void)insertListAction {


        NSMutableArray *list = [@[] mutableCopy] ;
        for (int i = 0 ; i < 10; i++) {
            AnyModel *m1 = [AnyModel new] ; // 插入不需设置主键
            m1.age = i + 1 ;
            m1.floatVal = i + 0.3 ;
            m1.tick = 666666666666 ;
            m1.title = [NSString stringWithFormat:@"title%d",i] ;
            m1.image = [UIImage imageNamed:@"kobe"] ;
            m1.myArr = @[@"2342423423432",
                         @"asfads",
                         @"ddxxxxzzz",@33] ;
            m1.myDic = @{@"k1":@"dafafadf",
                         @"k2":@44,
                         @"k3":@"klkkdlslll"} ;
            m1.today = [NSDate date] ;
            
            [list addObject:m1] ;
        }
        [AnyModel xt_insertList:list] ;
    
    
    [self displayJump] ;
}

- (void)updateListAction {
    
        NSArray *getlist = [AnyModel xt_selectWhere:@"age > 5"] ;
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        for (int i = 0 ; i < getlist.count ; i++) {
            AnyModel *model = getlist[i] ;
            model.title = [model.title stringByAppendingString:[NSString stringWithFormat:@"+%d",model.age]] ;
            model.myArr = @[@15] ;
            model.myDic = @{@"y":@"9339"} ;
            model.today = [NSDate date] ;

            [tmplist addObject:model] ;
        }
        [AnyModel xt_updateListByPkid:tmplist] ;
    
    
    [self displayJump] ;
}

- (void)findFirstAction {
    
        AnyModel *model = [AnyModel xt_findFirstWhere:@"pkid == 2"] ;
        NSLog(@"m : %@",[model yy_modelToJSONObject]) ;
    
}

- (void)AlterAddAction {
    
        [AnyModel xt_alterAddColumn:@"adddddddddd"
                               type:@"INTEGER default 0 NOT NULL"] ;
    
}

- (void)sumAction {
    
        double sumOfAges = [AnyModel xt_sumOf:@"age"] ;
        NSLog(@"sum of ages : %lf",sumOfAges) ;
    
}

- (void)orderByAction {
    NSArray *result = [[AnyModel xt_selectAll] xt_orderby:@"age" descOrAsc:YES] ;
    NSLog(@"order by  ???? \n: %@",[result yy_modelToJSONObject]) ;
}

#pragma mark -

- (void)displayJump {
    [self performSegueWithIdentifier:@"root2display"
                              sender:nil] ;
}

@end
