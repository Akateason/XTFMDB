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
@property (strong, nonatomic) UIButton *btAlterAdd ;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@property (nonatomic) BOOL dBModelOrCustom ; // default is dBModel

@end

@implementation ViewController

static float const kBtFlex      = 2 ;
static float const kBtHeight    = 35. ;

- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
    
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
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
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btUpdateList.mas_bottom).offset(kBtFlex) ;
        }] ;
        bt ;
    }) ;
    
    self.btAlterAdd = ({
        UIButton *bt = [UIButton new] ;
        [bt setTitle:@"AlterAdd" forState:0] ;
        bt.backgroundColor = [UIColor grayColor] ;
        bt.titleLabel.textColor = [UIColor whiteColor] ;
        [bt addTarget:self action:@selector(btOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, kBtHeight)) ;
            make.centerX.equalTo(self.view) ;
            make.top.equalTo(self.btFindFirst.mas_bottom).offset(kBtFlex) ;
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

#pragma mark -

- (void)displayJump
{
    [self performSegueWithIdentifier:@"root2display"
                              sender:@(self.dBModelOrCustom)] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    DisplayViewController *displayVC = [segue destinationViewController] ;
    displayVC.dbModelOrCustom = [sender boolValue] ;
}

@end
