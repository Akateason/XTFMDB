//
//  ViewController.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Masonry.h"
#import "CustomDBModel.h"
#import "AnyModel.h"

#import "YYModel.h"
#import "DisplayViewController.h"
#import "XTFMDB.h"
#import "MainVCell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic) BOOL dBModelOrCustom ; // default is dBModel
@property (copy,nonatomic) NSArray *datasource ;
@end

@implementation ViewController

- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
    NSLog(@"%ld",(long)sender.selectedSegmentIndex) ;
}

- (BOOL)dBModelOrCustom {
    _dBModelOrCustom = self.segment.selectedSegmentIndex ;
    return _dBModelOrCustom ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.title = @"XTFMDB" ;
    self.datasource = @[
                        @"create" ,
                        @"select" ,
                        @"selectWhere" ,
                        @"insert" ,
                        @"update" ,
                        @"delete" ,
                        @"drop",
                        @"insertList",
                        @"updateList",
                        @"findFirst",
                        @"AlterAdd",
                        @"sum" ,
                        ] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainVCell"] ;
    cell.textLabel.text = self.datasource[indexPath.row] ;
    return cell ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40 ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strButtonName = [self.datasource[indexPath.row] stringByAppendingString:@"Action"] ;
    SEL methodSel = NSSelectorFromString(strButtonName) ;
    ((void (*)(id, SEL, id))objc_msgSend)(self, methodSel, nil) ;
}


#pragma mark - actions

- (void)createAction
{
    if (!self.dBModelOrCustom) {
        [CustomDBModel createTable] ;
    }
    else {
        [AnyModel xt_createTable] ;
    }
}

- (void)selectAction
{
    if (!self.dBModelOrCustom) {
        NSArray *list = [CustomDBModel selectAll] ;
        for (CustomDBModel *model in list) {
            NSLog(@"%d",model.pkid) ;
        }
    }
    else {
        NSArray *list = [AnyModel xt_selectAll] ;
        for (AnyModel *model in list) {
            NSLog(@"%d",model.pkid) ;
        }
    }
    
    [self displayJump] ;
}

- (void)selectWhereAction
{
    if (!self.dBModelOrCustom) {
        NSArray *list = [CustomDBModel selectWhere:@"title = 'jk4j3j43' "] ;
        NSLog(@"list : %@ \ncount:%@",list,@(list.count)) ;
    }
    else {
        NSArray *list = [AnyModel xt_selectWhere:@"title = 'jk4j3j43' "] ;
        NSLog(@"list : %@ \ncount:%@",list,@(list.count)) ;
    }
}

- (void)insertAction
{
    if (!self.dBModelOrCustom) {
        CustomDBModel *m1 = [CustomDBModel new] ; // 不需设置主键
        m1.age = arc4random() % 100 ;
        m1.floatVal = 3232.89f ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"atitle%d",arc4random()%999] ;
        m1.image = [UIImage imageNamed:@"kobe"] ;
        m1.myArr = @[@"2342423423432",@"asfads",@"ddxxxxzzz",@33] ;
        m1.myDic = @{@"k1":@"dafafadf",
                     @"k2":@44,
                     @"k3":@"klkkdlslll"} ;
        [m1 insert] ;
    }
    else {
        AnyModel *m1 = [AnyModel new] ; // 不需设置主键
        m1.age = arc4random() % 100 ;
        m1.floatVal = 3232.89f ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"atitle%d",arc4random()%999] ;
        m1.image = [UIImage imageNamed:@"kobe"] ;
        m1.myArr = @[@"2342423423432",@"asfads",@"ddxxxxzzz",@33] ;
        m1.myDic = @{@"k1":@"dafafadf",
                     @"k2":@44,
                     @"k3":@"klkkdlslll"} ;
        m1.today = [NSDate date] ;
        
        [m1 xt_insert] ;
    }
    
    [self displayJump] ;
}

- (void)updateAction
{
    if (!self.dBModelOrCustom) {
        CustomDBModel *m1 = [[CustomDBModel selectAll] lastObject] ;
        m1.image = nil ;
        m1.age = 4444444 ;
        m1.floatVal = 44.4444 ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"我就改你,r%d",arc4random() % 99] ;
        m1.myArr = @[@11111111111] ;
        m1.myDic = @{@"key":@"daafafafafaa1111aaa"} ;
        [m1 update] ;
    }
    else {
        AnyModel *m1 = [[AnyModel xt_selectAll] lastObject] ;
        m1.image = nil ;
        m1.age = 4444444 ;
        m1.floatVal = 44.4444 ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"我就改你,r%d",arc4random() % 99] ;
        m1.myArr = @[@11111111111] ;
        m1.myDic = @{@"key":@"daafafafafaa1111aaa"} ;
        [m1 xt_update] ;
    }
    
    [self displayJump] ;
}

- (void)deleteAction
{
    if (!self.dBModelOrCustom) {
        NSString *titleDel = ((CustomDBModel *)[[CustomDBModel selectAll] lastObject]).title ;
        [CustomDBModel deleteModelWhere:[NSString stringWithFormat:@"title == '%@'",titleDel]] ;
    }
    else {
        NSString *titleDel = ((AnyModel *)[[AnyModel xt_selectAll] lastObject]).title ;
        [AnyModel xt_deleteModelWhere:[NSString stringWithFormat:@"title == '%@'",titleDel]] ;
    }
 
    [self displayJump] ;
}

- (void)dropAction
{
    if (!self.dBModelOrCustom) {
        [CustomDBModel dropTable] ;
    }
    else {
        [AnyModel xt_dropTable] ;
    }
    
    [self displayJump] ;
}

- (void)insertListAction
{
    if (!self.dBModelOrCustom) {
        NSMutableArray *list = [@[] mutableCopy] ;
        for (int i = 0 ; i < 10; i++)
        {
            CustomDBModel *m1 = [CustomDBModel new] ; // 插入不需设置主键
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
            
            [list addObject:m1] ;
        }
        [CustomDBModel insertList:list] ;
    }
    else {
        NSMutableArray *list = [@[] mutableCopy] ;
        for (int i = 0 ; i < 10; i++)
        {
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
    }
    
    [self displayJump] ;
}

- (void)updateListAction
{
    if (!self.dBModelOrCustom) {
        NSArray *getlist = [CustomDBModel selectWhere:@"age > 5"] ;
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        for (int i = 0 ; i < getlist.count ; i++)
        {
            CustomDBModel *model = getlist[i] ;
            model.title = [model.title stringByAppendingString:[NSString stringWithFormat:@"+%d",model.age]] ;
            model.myArr = @[@15] ;
            model.myDic = @{@"y":@"9339"} ;
            
            [tmplist addObject:model] ;
        }
        [CustomDBModel updateList:tmplist] ;
    }
    else {
        NSArray *getlist = [AnyModel xt_selectWhere:@"age > 5"] ;
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        for (int i = 0 ; i < getlist.count ; i++)
        {
            AnyModel *model = getlist[i] ;
            model.title = [model.title stringByAppendingString:[NSString stringWithFormat:@"+%d",model.age]] ;
            model.myArr = @[@15] ;
            model.myDic = @{@"y":@"9339"} ;
            model.today = [NSDate date] ;

            [tmplist addObject:model] ;
        }
        [AnyModel xt_updateList:tmplist] ;
    }
    
    [self displayJump] ;
}

- (void)findFirstAction
{
    if (!self.dBModelOrCustom) {
        CustomDBModel *model = [CustomDBModel findFirstWhere:@"pkid == 2"] ;
        NSLog(@"m : %@",[model yy_modelToJSONObject]) ;
    }
    else {
        AnyModel *model = [AnyModel xt_findFirstWhere:@"pkid == 2"] ;
        NSLog(@"m : %@",[model yy_modelToJSONObject]) ;
    }
}

- (void)AlterAddAction
{
    if (!self.dBModelOrCustom) {
        [CustomDBModel alterAddColumn:@"adddddddddd"
                                 type:@"INTEGER default 0 NOT NULL"] ;
    }
    else {
        [AnyModel xt_alterAddColumn:@"adddddddddd"
                               type:@"INTEGER default 0 NOT NULL"] ;
    }
}

- (void)sumAction {
    if (!self.dBModelOrCustom) {
        double sumOfAges = [CustomDBModel sumOf:@"age"] ;
        NSLog(@"sum of ages : %lf",sumOfAges) ;
    }
    else {
        double sumOfAges = [AnyModel xt_sumOf:@"age"] ;
        NSLog(@"sum of ages : %lf",sumOfAges) ;
    }
}

#pragma mark -

- (void)displayJump {
    [self performSegueWithIdentifier:@"root2display"
                              sender:@(self.dBModelOrCustom)] ;
}


#pragma mark - storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    DisplayViewController *displayVC = [segue destinationViewController] ;
    displayVC.dbModelOrCustom = [sender boolValue] ;
}

@end
