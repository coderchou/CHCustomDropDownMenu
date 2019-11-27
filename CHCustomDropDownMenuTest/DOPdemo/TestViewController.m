

//
//  TestViewController.m
//  DOPdemo
//
//  Created by 周灿华 on 2019/11/15.
//  Copyright © 2019年 tanyang. All rights reserved.
//

#import "TestViewController.h"
#import "CHCustomDropDownMenu.h"
#import "ThirdView.h"

@interface TestViewController ()<CHCustomDropDownMenuDataSource,CHCustomDropDownMenuDelegate>

@property (nonatomic, weak) CHCustomDropDownMenu *menu;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) ThirdView *thirdView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"CHCustomDropDownMenu";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"重新加载" style:UIBarButtonItemStylePlain target:self action:@selector(menuReloadData)];

    // 添加下拉菜单
    CHCustomDropDownMenu *menu = [[CHCustomDropDownMenu alloc] initWithOrigin:CGPointMake(0, 88) andHeight:44];
    menu.indicatorAlignType = CHIndicatorAlignTypeCloseToTitle;
    menu.indicatorImageNames = @[@""];

    menu.showBottomImage = YES;
    menu.delegate = self;
    menu.dataSource = self;
    [self.view addSubview:menu];
    _menu = menu;
}

- (void)menuReloadData
{
//    [_menu reloadData];
    
//    [self.menu updateTitle:@"问题" column:2 show:NO];
//    [self.menu showMenu:1];
    
    [self.menu hideMenu];
    
    
    NSLog(@"%@",[self.menu titleAtColumn:2]);
    
}


- (IBAction)selectIndexPathAction:(id)sender {
//    [_menu selectIndexPath:[DOPIndexPath indexPathWithCol:0 row:2 item:2]];
}


#pragma mark - CHCustomDropDownMenuDataSource

- (NSInteger)numberOfColumnsInMenu:(CHCustomDropDownMenu *)menu{
    return 3;
}


- (NSString *)menu:(CHCustomDropDownMenu *)menu titleAtColumn:(NSInteger)column {
    return [NSString stringWithFormat:@"第 %ld 个",column];
}


- (UIView *)menu:(CHCustomDropDownMenu *)menu customViewAtColumn:(NSInteger)column {
    if (column == 0) {
        return self.firstView;
        
    } else if (column == 1) {
        return self.secondView;
        
    } else if (column == 2) {
        return self.thirdView;
        
    }
    return nil;
}

///返回 menu 自定义view的高度
- (CGFloat)menu:(CHCustomDropDownMenu *)menu customHeightAtColumn:(NSInteger)column {
    if (column == 0) {
        return 100;
        
    } else if (column == 1) {
        return 300;
        
    } else if (column == 2) {
        return 500;
        
    }
    
    return 0;
}


-(void)menu:(CHCustomDropDownMenu *)menu didShow:(BOOL)isShow {
    NSLog(@"didShow:%d", isShow);
}


#pragma mark - property

- (UIView *)firstView {
    if (!_firstView) {
        _firstView  = [[UIView alloc] init];
        _firstView.backgroundColor = [UIColor blueColor];
    }
    return _firstView;
}


- (UIView *)secondView {
    if (!_secondView) {
        _secondView  = [[UIView alloc] init];
        _secondView.backgroundColor = [UIColor magentaColor];
    }
    return _secondView;
}


- (ThirdView *)thirdView {
    if (!_thirdView) {
        _thirdView  = [[ThirdView alloc] init];
        _thirdView.backgroundColor = [UIColor brownColor];
        
        __weak typeof(self) weakSelf = self;
        _thirdView.changeTitle = ^(NSString * _Nonnull title) {
            [weakSelf.menu updateTitle:title column:2 show:YES];
        };
    }
    return _thirdView;
}



- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}


@end
