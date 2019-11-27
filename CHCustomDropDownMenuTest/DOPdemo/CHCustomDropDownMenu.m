//
//  CHCustomDropDownMenu.m
//  DOPdemo
//
//  Created by 周灿华 on 2019/11/15.
//  Copyright © 2019年 tanyang. All rights reserved.
//

#import "CHCustomDropDownMenu.h"

#define kButtomImageViewHeight 21
#define kMarginBetweenImageAndLabel 3

#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kTextSelectColor [UIColor colorWithRed:246/255.0 green:79/255.0 blue:0/255.0 alpha:1]
#define kSeparatorColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]


@interface CHCustomDropDownMenu ()
@property (nonatomic, assign) NSInteger currentColumn;  // 当前选中列

@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfColumn;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, weak)   UIView *bottomShadow;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UIImageView *buttomImageView;

//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;
@property (nonatomic, assign) BOOL indicatorIsImageView;
@property (nonatomic, assign) CGFloat dropDownViewWidth;    // 以属性的形式，方便以后修改

@end


@implementation CHCustomDropDownMenu

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

#pragma mark - setter
- (void)setDataSource:(id<CHCustomDropDownMenuDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfColumn = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfColumn = 1;
    }
    
    [self.titles makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.bgLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if (self.indicatorImageNames && self.indicatorImageNames.count) {
        self.indicatorIsImageView = YES;
        [self.indicators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }else {
        self.indicatorIsImageView = NO;
        [self.indicators makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }
    
    //text 的间距
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfColumn * 2);
    //分割线的间距
    CGFloat separatorLineInterval = self.frame.size.width / _numOfColumn;
    
    //背景的flayer
    CGFloat bgLayerInterval = self.frame.size.width / _numOfColumn;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfColumn];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfColumn];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfColumn];
    
    for (int i = 0; i < _numOfColumn; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer]; //底部layer
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        
        NSString *titleString;
        //不可点击,但是有二级列表
        
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(menu:titleAtColumn:)]) {
            titleString = [_dataSource menu:self titleAtColumn:i];
        }
        
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        //indicator
        if (self.indicatorIsImageView) {
            CGFloat textMaxX = CGRectGetMaxX(title.frame);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(textMaxX + 1, self.frame.size.height / 2, 8, 4)];
            
            if (self.indicatorImageNames && self.indicatorImageNames.count > i)
            {
                UIImage *indicatarImage = [UIImage imageNamed:self.indicatorImageNames[i]];
                //更具图片的尺寸来设置frame
                CGSize imageViewSize = indicatarImage.size;
                CGRect frame = imageView.frame;
                frame.size = imageViewSize;
                frame.origin.y = (self.frame.size.height - imageViewSize.height)/2;//居中
                imageView.frame = frame;
                imageView.image = indicatarImage;
            }else
            {
                imageView.image = [UIImage imageNamed:@"dop_icon_default_indicator"];
            }
            
            [self addSubview:imageView];
            imageView.tag = i;
            [tempIndicators addObject:imageView];
        }else {
            CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake((i + 1)*separatorLineInterval - 10, self.frame.size.height / 2)];
            [self.layer addSublayer:indicator];
            [tempIndicators addObject:indicator];
        }
        //separator
        if (self.showSeparator) {
            if (i != _numOfColumn - 1) {
                CGPoint separatorPosition = CGPointMake(ceilf((i + 1) * separatorLineInterval-1), self.frame.size.height / 2);
                CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
                [self.layer addSublayer:separator];
            }
        }
        
        [self layoutIndicator:tempIndicators[i] withTitle:tempTitles[i]];
    }
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
}


#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    return [self initWithOrigin:origin width:[UIScreen mainScreen].bounds.size.width andHeight:height];
}

- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width andHeight:(CGFloat)height {
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, width, height)];
    if (self) {
        _origin = origin;
        _currentColumn = -1;
        self.show = NO;
        _fontSize = 14;
        _showSeparator = YES;
        _separatorColor = kSeparatorColor;
        _separatorHeighPercent = 0.5;
        _textColor = kTextColor;
        _textSelectedColor = kTextSelectColor;
        _indicatorColor = kTextColor;
        _dropDownViewWidth = [UIScreen mainScreen].bounds.size.width;
        _indicatorAlignType = CHIndicatorAlignTypeRight;
        CGSize dropDownViewSize = CGSizeMake(_dropDownViewWidth, [UIScreen mainScreen].bounds.size.height);
        
      
        _buttomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, dropDownViewSize.width, kButtomImageViewHeight)];
        _buttomImageView.image = [UIImage imageNamed:@"icon_chose_bottom"];
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y + height, dropDownViewSize.width, dropDownViewSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, width, 0.5)];
        bottomShadow.backgroundColor = kSeparatorColor;
        bottomShadow.hidden = NO;
        [self addSubview:bottomShadow];
        _bottomShadow = bottomShadow;
    }
    return self;
}

#pragma mark - init support
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    
    layer.position = position; //中心的的位置
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfColumn, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    
    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    
    return layer;
}

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    CGFloat height = CGRectGetHeight(self.frame) * _separatorHeighPercent;
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, height)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfColumn) - 25) ? size.width : self.frame.size.width / _numOfColumn - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = _fontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.truncationMode = kCATruncationEnd;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    //CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:_fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(ceilf(size.width)+2, size.height);
}

#pragma mark - gesture handle

- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    if (_dataSource == nil) {
        return;
    }
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfColumn);
    
    [self showMenu:tapIndex];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender {
    [self animateIdicator:_indicators[_currentColumn] background:_backGroundView title:_titles[_currentColumn] column:_currentColumn forward:NO complecte:^{
        self.show = NO;
        if (self.delegate && [_delegate respondsToSelector:@selector(menu:didShow:)]) {
            [self.delegate menu:self didShow:self.show];
        }
    }];
}


#pragma mark - Private Method

- (void)layoutIndicator:(id)indicator withTitle:(CATextLayer *)title {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfColumn) - 25 -kMarginBetweenImageAndLabel) ? size.width : self.frame.size.width / _numOfColumn - 25 - kMarginBetweenImageAndLabel;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (self.indicatorAlignType == CHIndicatorAlignTypeCloseToTitle) {
        if (self.indicatorIsImageView) {
            CGRect indicatorFrame = ((UIImageView *)indicator).frame;
            indicatorFrame.origin.x = CGRectGetMaxX(title.frame) + kMarginBetweenImageAndLabel;
            ((UIImageView *)indicator).frame = indicatorFrame;
        }else {
            CGRect indicatorFrame = ((CAShapeLayer *)indicator).frame;
            indicatorFrame.origin.x = CGRectGetMaxX(title.frame) + kMarginBetweenImageAndLabel;
            ((CAShapeLayer *)indicator).frame = indicatorFrame;
        }
    }
}

#pragma mark - animation method

- (void)animateIndicator:(id)indicator Forward:(BOOL)forward complete:(void(^)(void))complete {
    if (self.indicatorIsImageView) {
        [self animateIndicatorImageView:(UIImageView *)indicator Forward:forward complete:complete];
    }else {
        [self animateIndicatorShapeLayer:(CAShapeLayer *)indicator Forward:forward complete:complete];
    }
}

- (void)animateIndicatorShapeLayer:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)(void))complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (forward) {
        // 展开
        indicator.fillColor = _textSelectedColor.CGColor;
    } else {
        // 收缩
        indicator.fillColor = _textColor.CGColor;
    }
    
    complete();
}

- (void)animateIndicatorImageView:(UIImageView *)indicator
                          Forward:(BOOL)forward
                         complete:(void(^)(void))complete {
    
    NSInteger tapedIndex = indicator.tag;
    BOOL canTransform = YES;
    if (self.indicatorAnimates && self.indicatorAnimates.count > tapedIndex) {
        canTransform = [self.indicatorAnimates[tapedIndex] boolValue];
    }
    if (forward && canTransform) {
        indicator.transform =  CGAffineTransformMakeRotation(M_PI);
    }else{
        indicator.transform = CGAffineTransformIdentity;
    }
    
    complete();
}

- (void)animateBackGroundView:(UIView *)view
                         show:(BOOL)show
                     complete:(void(^)(void))complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateColumn:(NSInteger)column
                 show:(BOOL)show
             complete:(void(^)(void))complete {
    
    UIView *preView = [self.dataSource menu:self customViewAtColumn:self.currentColumn];
    preView.clipsToBounds = YES;
    
    UIView *currentView = [self.dataSource menu:self customViewAtColumn:column];
    currentView.clipsToBounds = YES;
    
    
    if (show) {
        currentView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 0);
        [self.superview addSubview:currentView];
        
        if (_showBottomImage) {
            _buttomImageView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, kButtomImageViewHeight);
            [self.superview addSubview:_buttomImageView];
        }
        
        //设置展示的高度
        CGFloat showHeight = 0;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(menu:customHeightAtColumn:)]) {
            showHeight = [self.dataSource menu:self customHeightAtColumn:column];
        }
        
        
        [UIView animateWithDuration:0.2 animations:^{
            currentView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, showHeight);
//            [currentView layoutIfNeeded];
            
            if (_showBottomImage) {
                _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(currentView.frame)-2, _dropDownViewWidth, kButtomImageViewHeight);
            }
        }];
        
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            currentView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 0);
//            [currentView layoutIfNeeded];
            
            if (_showBottomImage) {
                _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(currentView.frame)-2, _dropDownViewWidth, kButtomImageViewHeight);
            }
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
            if (_showBottomImage) {
                [_buttomImageView removeFromSuperview];
            }
        }];
    }
    
    if (column != self.currentColumn && preView) {
        [UIView animateWithDuration:0.2 animations:^{
            preView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 0);
            
//            if (_showBottomImage) {
//                _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(currentView.frame)-2, _dropDownViewWidth, kButtomImageViewHeight);
//            }
        } completion:^(BOOL finished) {
            [preView removeFromSuperview];
//            if (_showBottomImage) {
//                [_buttomImageView removeFromSuperview];
//            }
        }];
        
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)(void))complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfColumn) - 25) ? size.width : self.frame.size.width / _numOfColumn - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (!show) {
        title.foregroundColor = _textColor.CGColor;
    } else {
        title.foregroundColor = _textSelectedColor.CGColor;
    }
    complete();
}

- (void)animateIdicator:(id)indicator
             background:(UIView *)background
                  title:(CATextLayer *)title
                 column:(NSInteger)column
                forward:(BOOL)forward
              complecte:(void(^)(void))complete {
    
    if (self.indicatorAlignType == CHIndicatorAlignTypeCloseToTitle) {
        [self layoutIndicator:indicator withTitle:title];
    }
    
    //先指示器 > 标题 > 背景 > 展示的view
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                
                [self animateColumn:column show:forward complete:^{
                    
                }];
            }];
        }];
    }];
    
    complete();
}


#pragma mark - public method

- (void)setShowBottomLine:(BOOL)showBottomLine {
    _showBottomLine = showBottomLine;
    self.bottomShadow.hidden = !showBottomLine;
    
}

- (NSString *)titleAtColumn:(NSInteger)column {
    if (column >= self.numOfColumn) { //超过最大的菜单数量
        return nil;
    }
    
    CATextLayer *textLayer = (CATextLayer *)_titles[column];
    return textLayer.string;
}

- (void)updateTitle:(NSString *)title
             column:(NSInteger)column
               show:(BOOL)show {
    
    if (column >= self.numOfColumn) {
        return ;
    }
    
    CATextLayer *textLayer = (CATextLayer *)_titles[column];
    textLayer.string = title;
    
//    [self animateIdicator:_indicators[column]
//               background:_backGroundView
//                    title:textLayer
//                   column:column
//                  forward:NO
//                complecte:^{
//
//    }];
//
    
    [self hideMenu];
}


- (void)reloadData {
    
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateColumn:self.currentColumn show:NO complete:^{
            self.show = NO;
            id VC = self.dataSource;
            self.dataSource = nil;
            self.dataSource = VC;
        }];
    }];
    
}



- (void)showMenu:(NSInteger)column {
    
    for (int i = 0; i < _numOfColumn; i++) {
        if (i != column) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
        }
    }
    
    if (column == _currentColumn && _show) {
        
        [self animateIdicator:_indicators[_currentColumn] background:_backGroundView title:_titles[_currentColumn] column:column forward:NO complecte:^{
            _currentColumn = column;
            self.show = NO;
            if (self.delegate && [_delegate respondsToSelector:@selector(menu:didShow:)]) {
                [self.delegate menu:self didShow:self.show];
            }
        }];
        
    } else {
        
        [self animateIdicator:_indicators[column] background:_backGroundView title:_titles[column] column:column forward:YES complecte:^{
            self.show = YES;
            
            _currentColumn = column;
            if (self.delegate && [_delegate respondsToSelector:@selector(menu:didShow:)]) {
                [self.delegate menu:self didShow:self.show];
            }
        }];
        
    }
}

- (void)hideMenu {
    if (_show) {
        [self backgroundTapped:nil];
    }
}


@end

