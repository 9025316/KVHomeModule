//
//  UIView+CornerRadius.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 2022/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CornerRadius)

/**
 * setCornerRadius   给view设置圆角
 * @param value      圆角大小
 * @param rectCorner 圆角位置
 **/
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner;

@end

NS_ASSUME_NONNULL_END
