//
//  UIView+CornerRadius.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han Pro on 2022/1/14.
//

#import "UIView+CornerRadius.h"

@implementation UIView (CornerRadius)

/**
 * setCornerRadius   给view设置圆角
 * @param value      圆角大小
 * @param rectCorner 圆角位置
 **/
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner {
    
    [self layoutIfNeeded];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(value, value)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}

@end
