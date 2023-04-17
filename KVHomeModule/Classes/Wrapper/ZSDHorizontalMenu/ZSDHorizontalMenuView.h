//
//  ZSDHorizontalMenuView.h
//  ZSD_Business
//
//  Created by Kevin_han Pro on 2022/01/05.
//

#import <UIKit/UIKit.h>
#import "ZSDPageControl.h"


typedef enum {
    ZSDHorizontalMenuViewPageControlAlimentRight,    //右上角靠右
    ZSDHorizontalMenuViewPageControlAlimentCenter,   //下面居中
} ZSDHorizontalMenuViewPageControlAliment;

typedef enum {
    ZSDHorizontalMenuViewPageControlStyleClassic,    //系统自带经典样式
    ZSDHorizontalMenuViewPageControlStyleAnimated,   //动画效果
    ZSDHorizontalMenuViewPageControlStyleNone,       //不显示pageControl
}ZSDHorizontalMenuViewPageControlStyle;


@class ZSDHorizontalMenuView;

@protocol ZSDHorizontalMenuViewDataSource <NSObject>
@optional

/**
 数据的num

 @param horizontalMenuView 控件本身
 @return 返回数量
 */
- (NSInteger)numberOfItemsInHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;
/**
每个菜单的title

 @param horizontalMenuView 控件本身
 @param index 当前下标
 @return 返回标题
 */
- (NSString *)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView titleForItemAtIndex:(NSInteger )index;

/**
 每个菜单的图片地址路径

 @param horizontalMenuView 当前控件
 @param index 当前下标
 @return 返回图片的URL路径
 */
- (NSURL *)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView iconURLForItemAtIndex:(NSInteger)index;

- (NSString *)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView localIconStringForItemAtIndex:(NSInteger)index;

- (NSString *)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView hotStringForItemAtIndex:(NSInteger)index;

@end


@protocol ZSDHorizontalMenuViewDelegate <NSObject>
@optional

/**
 设置每页的行数,默认 2
 
 @param horizontalMenuView 当前控件
 @return 行数
 */
- (NSInteger)numOfRowsPerPageInHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;

/**
 设置每页的列数 默认 4
 
 @param horizontalMenuView 当前控件
 @return 列数
 */
- (NSInteger)numOfColumnsPerPageInHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;
/**
 菜单中图片的尺寸

 @param horizontalMenuView 当前控件
 @return 图片的尺寸
 */
- (CGSize)iconSizeForHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;

/**
 菜单标题Font/Size

 @param horizontalMenuView 当前控件
 @return 菜单标题Font
 */
- (UIFont *)titleFontSizwForHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;

/**
 返回当前页数的pageControl的颜色

 @param horizontalMenuView 当前控件
 @return 颜色
 */
- (UIColor *)colorForCurrentPageControlInHorizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView;
/**
 当选项被点击回调
 
 @param horizontalMenuView 当前控件
 @param index 点击下标
 */
- (void)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSInteger)index;

- (void)horizontalMenuView:(ZSDHorizontalMenuView *)horizontalMenuView WillEndDraggingWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

// 不需要自定义轮播cell的请忽略以下两个的代理方法

// ========== 轮播自定义cell ==========

/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的class。 */
- (Class)customCollectionViewCellClassForHorizontalMenuView:(ZSDHorizontalMenuView *)view;
/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的Nib。 */
- (UINib *)customCollectionViewCellNibForHorizontalMenuView:(ZSDHorizontalMenuView *)view;

/** 如果你自定义了cell样式，请在实现此代理方法为你的cell填充数据以及其它一系列设置 */
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index horizontalMenuView:(ZSDHorizontalMenuView *)view;
@end

@interface ZSDHorizontalMenuView : UIView

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,weak) id<ZSDHorizontalMenuViewDataSource> dataSource;

@property (nonatomic,weak) id<ZSDHorizontalMenuViewDelegate>   delegate;

/** pagecontrol 样式，默认为动画样式 */
@property (nonatomic,assign) ZSDHorizontalMenuViewPageControlStyle pageControlStyle;
/** 分页控件位置 */
@property (nonatomic,assign) ZSDHorizontalMenuViewPageControlAliment pageControlAliment;

@property (strong, nonatomic)   UIImage                         *defaultImage;

/** 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量 */
@property (nonatomic,assign) CGFloat pageControlBottomOffset;

/** 分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlRightOffset;

/** 分页控件小圆标大小 */
@property (nonatomic, assign) CGSize pageControlDotSize;

/** 当前分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/** 其他分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *pageDotColor;

/** 当前分页控件小圆标图片 */
@property (nonatomic, strong) UIImage *currentPageDotImage;

/** 其他分页控件小圆标图片 */
@property (nonatomic, strong) UIImage *pageDotImage;

/** 圆点之间的距离 默认 10*/
@property (nonatomic, assign) CGFloat controlSpacing;
/** 是否在只有一张图时隐藏pagecontrol，默认为YES */
@property(nonatomic) BOOL hidesForSinglePage;
/**
 刷新
 */
- (void)reloadData;
/**
 几页
 */
-(NSInteger)numOfPage;


















@end
