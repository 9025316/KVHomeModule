//
//  ZSDPageControl.h
//  ZSD_Business
//
//  Created by Kevin_han Pro on 2022/01/05.
//

#import <UIKit/UIKit.h>

@class ZSDPageControl;
@protocol ZSDPageControlDelegate <NSObject>

-(void)ellipsePageControlClick:(ZSDPageControl*)pageControl index:(NSInteger)clickIndex;

@end
@interface ZSDPageControl : UIControl

/*
 分页数量
 */
@property(nonatomic) NSInteger numberOfPages;
/*
 当前点所在下标
*/
@property(nonatomic) NSInteger currentPage;
/*
 点的大小
*/
@property(nonatomic) NSInteger controlSize;

@property(nonatomic) NSInteger controlHeight;

/*
点的间距
*/
@property(nonatomic) NSInteger controlSpacing;
/*
 其他未选中点颜色
*/
@property(nonatomic,strong) UIColor *otherColor;
/*
  当前点颜色
*/
@property(nonatomic,strong) UIColor *currentColor;
/*
 当前点背景图片
*/
@property(nonatomic,strong) UIImage *currentBkImg;
@property(nonatomic,weak)id<ZSDPageControlDelegate> delegate;
@end
