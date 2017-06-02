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
#import "Model1.h"
#import "YYModel.h"
#import "DisplayViewController.h"

#import "XTFMDB.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *btCreate ;
@property (strong, nonatomic) UIButton *btSelect ;
@property (strong, nonatomic) UIButton *btSelectWhere ;
@property (strong, nonatomic) UIButton *btInsert ;
@property (strong, nonatomic) UIButton *btUpdate ;
@property (strong, nonatomic) UIButton *btDelete ;
@property (strong, nonatomic) UIButton *btDrop ;
@property (strong, nonatomic) UIButton *btInsertList ;
@property (strong, nonatomic) UIButton *btUpdateList ;
@property (strong, nonatomic) UIButton *btFindFirst ;

@end

@implementation ViewController


static float const kBtFlex = 5 ;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.title = @"XTFMDB" ;
    [self layoutUI] ;
}

- (void)layoutUI
{
    self.btCreate = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"create" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.mas_equalTo(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btSelect = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"select" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btCreate.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btSelectWhere = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"selectWhere" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btSelect.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btInsert = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"insert" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btSelectWhere.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btUpdate = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"update" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btInsert.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btDelete = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"delete" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btUpdate.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btDrop = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"drop" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btDelete.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btInsertList = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"insertList" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btDrop.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btUpdateList = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"updateList" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btInsertList.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btFindFirst = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"findFirst" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btUpdateList.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    
}

- (void)btOnClick:(UIButton *)sender
{
    NSString *strButtonName = [sender.titleLabel.text stringByAppendingString:@"Action"] ;
    SEL methodSel = NSSelectorFromString(strButtonName) ;
    ((void (*)(id, SEL, id))objc_msgSend)(self, methodSel, nil) ;
}



#pragma mark --
#pragma mark - actions
- (void)createAction
{
    NSLog(@"%s",__func__) ;
    [Model1 xt_createTable] ;
}

- (void)selectAction
{
    NSLog(@"%s",__func__) ;
    NSArray *list = [Model1 xt_selectAll] ;
    for (Model1 *model in list) {
        NSLog(@"%d",model.pkid) ;
    }
}

- (void)selectWhereAction
{
    NSLog(@"%s",__func__) ;
    NSArray *list = [Model1 xt_selectWhere:@"title = 'jk4j3j43' "] ;
    NSLog(@"list : %@ \ncount:%@",list,@(list.count)) ;
}

- (void)insertAction
{
    NSLog(@"%s",__func__) ;
    Model1 *m1 = [Model1 new] ; // 不需设置主键
    m1.age = arc4random() % 100 ;
    m1.floatVal = 3232.89f ;
    m1.tick = 666666666666 ;
    m1.title = [NSString stringWithFormat:@"atitle%d",arc4random()%999] ;
    [m1 xt_insert] ;
    
    [self displayJump] ;
}

- (void)updateAction
{
    Model1 *m1 = [Model1 new] ;
    m1.pkid = ((Model1 *)[[Model1 xt_selectAll] lastObject]).pkid ;
    m1.age = 4444444 ;
    m1.floatVal = 44.4444 ;
    m1.tick = 666666666666 ;
    m1.title = [NSString stringWithFormat:@"我就改你,r%d",arc4random() % 99] ;
    
    [m1 xt_update] ;
    
    [self displayJump] ;
}

- (void)deleteAction
{
    NSString *titleDel = ((Model1 *)[[Model1 xt_selectAll] lastObject]).title ;
    [Model1 xt_deleteModelWhere:[NSString stringWithFormat:@"title == '%@'",titleDel]] ;
 
    [self displayJump] ;
}

- (void)dropAction
{
    [Model1 xt_dropTable] ;
    
    [self displayJump] ;
}

- (void)insertListAction
{
    NSMutableArray *list = [@[] mutableCopy] ;
    for (int i = 0 ; i < 10; i++)
    {
        Model1 *m1 = [Model1 new] ; // 插入不需设置主键
        m1.age = i + 1 ;
        m1.floatVal = i + 0.3 ;
        m1.tick = 666666666666 ;
        m1.title = [NSString stringWithFormat:@"title%d",i] ;
        
        [list addObject:m1] ;
    }
    [Model1 xt_insertList:list] ;
    
    
    [self displayJump] ;
}

- (void)updateListAction
{
    NSArray *getlist = [Model1 xt_selectWhere:@"age > 5"] ;
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    for (int i = 0 ; i < getlist.count ; i++)
    {
        Model1 *model = getlist[i] ;
        model.title = [model.title stringByAppendingString:[NSString stringWithFormat:@"+%d",model.age]] ;
        [tmplist addObject:model] ;
    }
    [Model1 xt_updateList:tmplist] ;
    
    [self displayJump] ;
}

- (void)findFirstAction
{
    Model1 *model = [Model1 xt_findFirstWhere:@"pkid == 2"] ;
    NSLog(@"m : %@",[model yy_modelToJSONObject]) ;
}


#pragma mark -

- (void)displayJump
{
    [self performSegueWithIdentifier:@"root2display" sender:nil] ;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{

    
}

@end
