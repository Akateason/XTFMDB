//
//  ViewController.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.

// this is a zample .

#import "ViewController.h"
#import "AccessObj.h"
#import "AnyModel.h"
#import "DisplayViewController.h"
#import "MainVCell.h"
#import "Masonry.h"
#import "SomeInfo.h"
#import "XTFMDB.h"
#import "YYModel.h"
#import <objc/message.h>
#import <objc/runtime.h>


@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *             datasource;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title                  = @"XTFMDB";
    self.datasource             = @[
        @"create",
        @"select",
        @"selectWhere",
        @"insert",
        @"insertOrIgnore",
        @"insertOrReplace",
        @"update",
        @"upsert",
        @"delete",
        @"drop",
        @"insertList",
        @"updateList",
        @"findFirst",
        @"AlterAdd",
        @"sum",
        @"orderBy",
    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainVCell *cell     = [tableView dequeueReusableCellWithIdentifier:@"MainVCell"];
    cell.textLabel.text = self.datasource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strButtonName =
        [self.datasource[indexPath.row] stringByAppendingString:@"Action"];
    SEL methodSel = NSSelectorFromString(strButtonName);
    ((void (*)(id, SEL, id))objc_msgSend)(self, methodSel, nil);
}

#pragma mark - actions

- (void)createAction {
    [AnyModel xt_createTable];
}

- (void)selectAction {
    NSArray *list = [AnyModel xt_selectAll];
    for (AnyModel *model in list) {
        NSLog(@"%d", model.pkid);
    }

    [self displayJump];
}

- (void)selectWhereAction {
    NSArray *list = [AnyModel xt_selectWhere:@"age > 10 "];
    NSLog(@"list : %@ \ncount:%@", list, @(list.count));
}

- (void)insertAction {
    AnyModel *m1 = [AnyModel customRandomModel];
    [m1 xt_insert];

    [self displayJump];
}

- (void)insertOrIgnoreAction {
    AnyModel *m1 = [AnyModel customRandomModel];
    m1.title     = @"insert or ignore";
    [m1 xt_insertOrIgnore];

    [self displayJump];
}

- (void)insertOrReplaceAction {
    AnyModel *m1 = [AnyModel customRandomModel];
    m1.title     = @"insert or replace";
    [m1 xt_insertOrReplace];

    [self displayJump];
}

- (void)upsertAction {
    AnyModel *m1 = [AnyModel customRandomModel];
    m1.title     = @"upsert 知道么";
    [m1 xt_upsertWhereByProp:@"title"];

    [self displayJump];
}

- (void)updateAction {
    AnyModel *m1 = [[AnyModel xt_selectAll] firstObject];
    m1.title     = @"我就改第一个";
    [m1 xt_update];

    [self displayJump];
}

- (void)deleteAction {
    NSString *titleDel = ((AnyModel *)[[AnyModel xt_selectAll] lastObject]).title;
    [AnyModel xt_deleteModelWhere:[NSString stringWithFormat:@"title == '%@'",
                                                             titleDel]];
    [self displayJump];
}

- (void)dropAction {
    [AnyModel xt_dropTable];
    [self displayJump];
}

- (void)insertListAction {
    NSMutableArray *list = [@[] mutableCopy];
    for (int i = 0; i < 10; i++) {
        AnyModel *m1 = [AnyModel customRandomModel];
        m1.age       = i + 1;
        m1.floatVal  = i + 0.3;
        m1.title     = [NSString stringWithFormat:@"insert list%d", i];
        [list addObject:m1];
    }
    [AnyModel xt_insertList:list];

    [self displayJump];
}

- (void)updateListAction {
    NSArray *       getlist = [AnyModel xt_selectWhere:@"age > 5"];
    NSMutableArray *tmplist = [@[] mutableCopy];
    for (int i = 0; i < getlist.count; i++) {
        AnyModel *model = getlist[i];
        model.title     = [model.title
            stringByAppendingString:[NSString stringWithFormat:@">5的都改了.+%d",
                                                               model.age]];
        [tmplist addObject:model];
    }
    [AnyModel xt_updateListByPkid:tmplist];

    [self displayJump];
}

- (void)findFirstAction {
    AnyModel *model = [AnyModel xt_findFirstWhere:@"pkid == 1"];
    NSLog(@"m : %@", [model yy_modelToJSONObject]);
}

- (void)AlterAddAction {
    [[XTFMDBBase sharedInstance] dbUpgradeTable:AnyModel.class
                                      paramsAdd:@[ @"lztmjyxjzdzmy" ]
                                        version:2];
}

- (void)sumAction {
    double sumOfAges = [AnyModel xt_sumOf:@"age"];
    NSLog(@"sum of ages : %lf", sumOfAges);
}

- (void)orderByAction {
    NSArray *result = [[AnyModel xt_selectAll] xt_orderby:@"age" descOrAsc:YES];
    NSLog(@"order by  ???? \n: %@", [result yy_modelToJSONObject]);
}

#pragma mark -

- (void)displayJump {
    [self performSegueWithIdentifier:@"root2display" sender:nil];
}

@end
