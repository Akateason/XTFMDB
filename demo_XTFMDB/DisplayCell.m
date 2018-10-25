//
//  DisplayCell.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "DisplayCell.h"
#import "AnyModel.h"
#import "NSDate+XTFMDB_Tick.h"
#import "NSObject+XTFMDB.h"
#import "SomeInfo.h"
#import <YYModel/YYModel.h>


@interface DisplayCell ()
@property (weak, nonatomic) IBOutlet UILabel *lbPkid;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@end


@implementation DisplayCell

- (void)configure:(id)model {
    if (!model)
        return;

    AnyModel *m1     = model;
    self.lbPkid.text = [@"pkid"
        stringByAppendingString:[NSString stringWithFormat:@": %d, %@", m1.pkid, m1.title]];
    self.img.image = m1.image;
    self.lbContent.text =
        [NSString stringWithFormat:@"%@", [model yy_modelToJSONObject]];
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
