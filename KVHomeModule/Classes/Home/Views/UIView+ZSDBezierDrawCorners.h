//
//  UIView+ZSDBezierDrawCorners.h
//  ZhuShiDaMobile
//
//  Created by 童星 on 2021/9/2.
//

/*
 *  用贝泽尔曲线画圆角 
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZSDBezierDrawCorners)

/// 画圆角
/// @param cornerRadius UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerBottomLeft;
/// @param borderWidth 线宽
/// @param borderColor 线颜色
/// @param corners 圆角大小
- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius
                      borderWidth:(CGFloat)borderWidth
                      borderColor:(UIColor *)borderColor
                             type:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
