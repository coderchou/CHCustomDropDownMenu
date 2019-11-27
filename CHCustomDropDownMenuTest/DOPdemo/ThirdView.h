//
//  ThirdView.h
//  DOPdemo
//
//  Created by 周灿华 on 2019/11/15.
//  Copyright © 2019年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThirdView : UIView

@property (nonatomic, strong) void(^changeTitle)(NSString *title);

@end

NS_ASSUME_NONNULL_END
