//
//  DisplayCell.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "DisplayCell.h"
#import "NSObject+XTFMDB.h"
#import "CustomDBModel.h"
#import "AnyModel.h"
#import "NSDate+XTFMDB_Tick.h"
#import <YYModel/YYModel.h>
#import "SomeInfo.h"

@interface DisplayCell ()
@property (weak, nonatomic) IBOutlet UILabel *lbPkid;
@property (weak, nonatomic) IBOutlet UILabel *lbAge;
@property (weak, nonatomic) IBOutlet UILabel *lbFloatVal;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lbArr;
@property (weak, nonatomic) IBOutlet UILabel *lbDic;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbObj;

@end

@implementation DisplayCell


- (void)configure:(id)model
{
    if (!model) return ;
    
    if ([model isKindOfClass:[XTDBModel class]]) {
        CustomDBModel *m1 = model ;
        self.lbPkid.text = [@"pkid" stringByAppendingString:[NSString stringWithFormat:@": %lu",(unsigned long)m1.pkid]] ;
        self.lbAge.text = [@"age" stringByAppendingString:[NSString stringWithFormat:@": %d",m1.age]] ;
        self.lbFloatVal.text = [@"floatVal" stringByAppendingString:[NSString stringWithFormat:@": %f",m1.floatVal]] ;
        self.lbTitle.text = [@"title" stringByAppendingString:[NSString stringWithFormat:@": %@",m1.title]] ;
        self.img.image = m1.image ;
        self.lbArr.text = [NSString stringWithFormat:@"%@",m1.myArr] ;
        self.lbDic.text = [NSString stringWithFormat:@"%@",m1.myDic] ;
    }
    else if ([model isKindOfClass:[AnyModel class]]) {
        AnyModel *m1 = model ;
        self.lbPkid.text = [@"pkid" stringByAppendingString:[NSString stringWithFormat:@": %d",m1.pkid]] ;
        self.lbAge.text = [@"age" stringByAppendingString:[NSString stringWithFormat:@": %d",m1.age]] ;
        self.lbFloatVal.text = [@"floatVal" stringByAppendingString:[NSString stringWithFormat:@": %f",m1.floatVal]] ;
        self.lbTitle.text = [@"title" stringByAppendingString:[NSString stringWithFormat:@": %@",m1.title]] ;
        self.img.image = m1.image ;
        self.lbArr.text = [NSString stringWithFormat:@"%@",m1.myArr] ;
        self.lbDic.text = [NSString stringWithFormat:@"%@",m1.myDic] ;
        self.lbDate.text = [NSDate xt_getStrWithTick:[m1.today xt_getTick]] ;
        self.lbObj.text = [m1.sInfo yy_modelToJSONString] ;
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
