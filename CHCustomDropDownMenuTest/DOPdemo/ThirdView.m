
//
//  ThirdView.m
//  DOPdemo
//
//  Created by 周灿华 on 2019/11/15.
//  Copyright © 2019年 tanyang. All rights reserved.
//

#import "ThirdView.h"


@interface ThirdView ()
@property (nonatomic, strong) UIButton *changeBtn;

@end

@implementation ThirdView


- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        UISwitch *swithc= [[UISwitch alloc] initWithFrame:CGRectMake(50, 50, 80, 80)];
        [self addSubview:swithc];
        
        UILabel *label = [UILabel new];
        label.text = @"我是一个正式的label";
        label.frame = CGRectMake(50, 100, 100, 30);
        [self addSubview:label];
        [self addSubview:self.changeBtn];
        
        self.changeBtn.frame = CGRectMake(50, 200, 100, 50);
        
        self.layer.masksToBounds = YES;
    }
    return self;
    
}


- (void)click {
    if (self.changeTitle) {
        static NSInteger count = 1;
        
        self.changeTitle([NSString stringWithFormat:@"我是%ld",count]);
        count++;
    }
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.backgroundColor = [UIColor blueColor];
        [_changeBtn setTitle:@"我是最新的文字" forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}



@end
