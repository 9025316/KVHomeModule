//
//  UIView+ZSDBezierDrawCorners.m
//  ZhuShiDaMobile
//
//  Created by 童星 on 2021/9/2.
//

#import "UIView+ZSDBezierDrawCorners.h"

@implementation UIView (ZSDBezierDrawCorners)

/// 画圆角
/// @param cornerRadius UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerBottomLeft;
/// @param borderWidth 线宽
/// @param borderColor 线颜色
/// @param corners 圆角大小

- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius
                      borderWidth:(CGFloat)borderWidth
                      borderColor:(UIColor *)borderColor
                             type:(UIRectCorner)corners {
    
    [self layoutIfNeeded];
     
    //    UIRectCorner type = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
     
    //1. 加一个layer 显示形状
    CGRect rect = CGRectMake(borderWidth/2.0, borderWidth/2.0,
                             CGRectGetWidth(self.frame)-borderWidth, CGRectGetHeight(self.frame)-borderWidth);
    CGSize radii = CGSizeMake(cornerRadius, borderWidth);
     
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
     
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = borderColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
     
    shapeLayer.lineWidth = borderWidth;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
     
    [self.layer addSublayer:shapeLayer];
     
     
     
     
    //2. 加一个layer 按形状 把外面的减去
    CGRect clipRect = CGRectMake(0, 0,
                                 CGRectGetWidth(self.frame)-1, CGRectGetHeight(self.frame)-1);
    CGSize clipRadii = CGSizeMake(cornerRadius, borderWidth);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:clipRect byRoundingCorners:corners cornerRadii:clipRadii];
     
    CAShapeLayer *clipLayer = [CAShapeLayer layer];
    clipLayer.strokeColor = borderColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
 
    clipLayer.lineWidth = 1;
    clipLayer.lineJoin = kCALineJoinRound;
    clipLayer.lineCap = kCALineCapRound;
    clipLayer.path = clipPath.CGPath;
 
    self.layer.mask = clipLayer;
}

@end
