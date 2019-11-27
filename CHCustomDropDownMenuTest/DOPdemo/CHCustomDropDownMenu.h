//
//  CHCustomDropDownMenu.h
//  DOPdemo
//
//  Created by 周灿华 on 2019/11/15.
//  Copyright © 2019年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CHIndicatorAlignType) {
    CHIndicatorAlignTypeRight = 0,     //指示图标居右
    CHIndicatorAlignTypeCloseToTitle,  //指示图标挨着文字，有一个默认间距设置为3
};


@class CHCustomDropDownMenu;
@protocol CHCustomDropDownMenuDataSource <NSObject>
@optional
///返回 menu 有多少列 ，默认1列
- (NSInteger)numberOfColumnsInMenu:(CHCustomDropDownMenu *)menu;

@required
///返回 menu 默认标题
- (NSString *)menu:(CHCustomDropDownMenu *)menu titleAtColumn:(NSInteger)column;

///返回 menu 自定义view
- (UIView *)menu:(CHCustomDropDownMenu *)menu customViewAtColumn:(NSInteger)column;

///返回 menu 自定义view的高度
- (CGFloat)menu:(CHCustomDropDownMenu *)menu customHeightAtColumn:(NSInteger)column;

@end


@protocol CHCustomDropDownMenuDelegate <NSObject>
@optional
- (void)menu:(CHCustomDropDownMenu *)menu didShow:(BOOL)isShow;

@end


/**
 作为一个dropDown载体, 提供显示和隐藏的方法
 实现dataSource的方法, 自定义下拉的视图
 参考自 [DOPDropDownMenu-Enhanced](https://github.com/12207480/DOPDropDownMenu-Enhanced)
 */
@interface CHCustomDropDownMenu : UIView

@property (nonatomic, weak) id<CHCustomDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id<CHCustomDropDownMenuDelegate> delegate;


/******以下属性, 在设置dataSource之前调用才会生效************/

/// 文字title颜色
@property (nonatomic, strong) UIColor *textColor;
/// 文字title选中颜色
@property (nonatomic, strong) UIColor *textSelectedColor;
/// 字体大小
@property (nonatomic, assign) NSInteger fontSize;


/// 是否展示column 之间的分割线, 默认为NO
@property (nonatomic, assign) BOOL showBottomLine;
/// 是否展示column 之间的分割线, 默认为YES
@property (nonatomic, assign) BOOL showSeparator;
/// 分割线颜色
@property (nonatomic, strong) UIColor *separatorColor;
/// 分割线高度占比，默认 50%，值范围为 0-1
@property (nonatomic, assign) CGFloat separatorHeighPercent;


/// 指示器对齐方式
@property (nonatomic, assign) CHIndicatorAlignType indicatorAlignType;
/// 默认的三角指示器颜色
@property (nonatomic, strong) UIColor *indicatorColor;
/// 自定义指示器图片
@property (nonatomic, strong) NSArray<NSString *> *indicatorImageNames;
/// 自定义指示器图片是否可以transform
@property (nonatomic, strong) NSArray<NSNumber *> *indicatorAnimates;


/// 底部的图是否展示 default YES
@property (nonatomic, assign) BOOL showBottomImage;



///menu默认为屏幕宽度
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

///menu指定宽度
- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width andHeight:(CGFloat)height;




///更新标题
- (void)updateTitle:(NSString *)title
             column:(NSInteger)column
               show:(BOOL)show;

///获取title
- (NSString *)titleAtColumn:(NSInteger)column;


- (void)reloadData;

- (void)showMenu:(NSInteger)column;

- (void)hideMenu;

@end


