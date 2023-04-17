//
//  ZSDHorizontalMenuView.m
//  ZSD_Business
//
//  Created by Kevin_han Pro on 2022/01/05.
//

#import "ZSDHorizontalMenuView.h"

//#import <Masonry.h>
//#import <UIImageView+WebCache.h>
#import "ZSDHorizontalMenuCollectionLayout.h"
#import "UIView+ZSDBezierDrawCorners.h"
#import "UIView+CornerRadius.h"

#define kHorizontalMenuViewInitialPageControlDotSize CGSizeMake(6, 6)

@interface ZSDHorizontalMenuViewCell:UICollectionViewCell

@property (nonatomic,strong) UILabel *menuTile;

@property (nonatomic,strong) UIImageView *menuIcon;
///热门标签  默认隐藏
@property (nonatomic,strong) UILabel *hotLabel;

@end

@implementation ZSDHorizontalMenuViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.menuTile = [UILabel new];
        self.menuTile.textAlignment = 1;
        self.menuTile.font = [UIFont boldSystemFontOfSize:13];
        self.menuTile.textColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0];
        [self.contentView addSubview:self.menuTile];
        
        self.menuIcon = [UIImageView new];
        [self.contentView addSubview:self.menuIcon];
        
        self.hotLabel = [UILabel new];
        self.hotLabel.hidden = YES;
        self.hotLabel.textAlignment = 1;
        self.hotLabel.font = [UIFont boldSystemFontOfSize:8];
        self.hotLabel.textColor = UIColor.whiteColor;
        self.hotLabel.backgroundColor = [UIColor colorWithRed:220/255.0 green:53/255.0 blue:61/255.0 alpha:1];
        [self.contentView addSubview:self.hotLabel];
        
        [self.menuIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.menuTile mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.right.mas_equalTo(-8);
            make.top.mas_equalTo(self.menuIcon.mas_bottom).offset(10);
            make.height.mas_equalTo(17);
        }];
        
        [self.hotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.menuIcon.mas_centerX);
            make.centerY.mas_equalTo(self.menuIcon.mas_top);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(27);
        }];
        
        [self.hotLabel setCornerRadius:7.0 addRectCorners:UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerTopLeft];
        
    }
    return self;
}

@end

static NSString *ZSDHorizontalMenuViewCellID = @"ZSDHorizontalMenuViewCell";
@interface ZSDHorizontalMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,ZSDHorizontalMenuViewDelegate>

//@property (nonatomic,strong) UICollectionView *collectionView;

@property (strong,nonatomic) UIControl         *pageControl;

@property (strong,nonatomic) ZSDHorizontalMenuCollectionLayout         *layout;

@end

@implementation ZSDHorizontalMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self  = [super initWithFrame:frame]) {
        _pageControlDotSize = kHorizontalMenuViewInitialPageControlDotSize;
        _pageControlAliment = ZSDHorizontalMenuViewPageControlAlimentCenter;
        _pageControlBottomOffset = 0;
        _pageControlRightOffset = 0;
        _controlSpacing = 10;
        _pageControlStyle = ZSDHorizontalMenuViewPageControlStyleAnimated;
        _currentPageDotColor = [UIColor whiteColor];
        _pageDotColor = [UIColor lightGrayColor];
        _hidesForSinglePage = YES;
    }
    return self;
}

- (void)setUpPageControl {
    if (_pageControl) {
        [_pageControl removeFromSuperview];//重新加载数据时调整
    }
    if (([self.layout currentPageCount] == 1) && self.hidesForSinglePage) {//一页并且单页隐藏pageControl
        return;
    }
    switch (self.pageControlStyle) {
        case ZSDHorizontalMenuViewPageControlStyleAnimated:
        {
            ZSDPageControl *pageControl = [[ZSDPageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPage = 0;
            pageControl.controlSize = self.pageControlDotSize.width;
            pageControl.controlSpacing = self.controlSpacing;
            pageControl.currentColor = self.currentPageDotColor;
            pageControl.otherColor = self.pageDotColor;
            pageControl.delegate = self;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case ZSDHorizontalMenuViewPageControlStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = 0;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        default:
            break;
    }
    
    if (self.pageControlStyle != ZSDHorizontalMenuViewPageControlStyleNone) {
        //重设pageControlDot图片
        if (self.currentPageDotImage) {
            self.currentPageDotImage = self.currentPageDotImage;
        }
        if (self.pageDotImage) {
            self.pageDotImage = self.pageDotImage;
        }
        
        NSInteger count = self.numOfPage;
        CGFloat pageWidth = (count - 1)*self.pageControlDotSize.width + self.pageControlDotSize.width * 2 + (count - 1) *self.controlSpacing;
        CGSize size = CGSizeMake(pageWidth, self.pageControlDotSize.height);
        CGFloat x = (self.frame.size.width - size.width) * 0.5;
        CGFloat y = self.frame.size.height - size.height;
        if (self.pageControlAliment == ZSDHorizontalMenuViewPageControlAlimentRight) {
            x = self.frame.size.width - size.width - 15;
            y = 0;
        }
        if ([self.pageControl isKindOfClass:[ZSDPageControl class]]) {
            ZSDPageControl *pageControl = (ZSDPageControl *)_pageControl;
            [pageControl sizeToFit];
        }
        CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
        pageControlFrame.origin.y -= self.pageControlBottomOffset;
        pageControlFrame.origin.x -= self.pageControlRightOffset;
        self.pageControl.frame = pageControlFrame;
        [self addSubview:_pageControl];
    }
}

- (UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        self.layout = [ZSDHorizontalMenuCollectionLayout new];
        
        //设置行数
        if (self.delegate && [self.delegate respondsToSelector:@selector(numOfRowsPerPageInHorizontalMenuView:)]) {
            self.layout.rowCount = [self.delegate numOfRowsPerPageInHorizontalMenuView:self];
        }else{
            self.layout.rowCount = 2;
        }
        // 设置列数
        if(self.delegate && [self.delegate respondsToSelector:@selector(numOfColumnsPerPageInHorizontalMenuView:)]) {
            self.layout.columCount = [self.delegate numOfColumnsPerPageInHorizontalMenuView:self];
        } else {
            self.layout.columCount = 4;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        //        _collectionView.scrollEnabled
        [_collectionView registerClass:[ZSDHorizontalMenuViewCell class] forCellWithReuseIdentifier:ZSDHorizontalMenuViewCellID];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            if (self.pageControlStyle != ZSDHorizontalMenuViewPageControlStyleNone) {
                make.bottom.mas_equalTo(-15);
            }
            make.bottom.mas_equalTo(0);
        }];
    }
    return _collectionView;
}

/**
 刷新
 */
- (void)reloadData {
    //    self.pageControl.numberOfPages = [self.layout pageCount];
    //    self.pageControl.currentPage = 0;
    //设置行数
    if (self.delegate && [self.delegate respondsToSelector:@selector(numOfRowsPerPageInHorizontalMenuView:)]) {
        self.layout.rowCount = [self.delegate numOfRowsPerPageInHorizontalMenuView:self];
    } else {
        self.layout.rowCount = 2;
    }
    [self.collectionView reloadData];
    
    [self setUpPageControl];
}


#pragma mark - properties
- (void)setDelegate:(id<ZSDHorizontalMenuViewDelegate>)delegate {
    _delegate = delegate;
    
    if ([self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.collectionView registerClass:[self.delegate customCollectionViewCellClassForHorizontalMenuView:self] forCellWithReuseIdentifier:ZSDHorizontalMenuViewCellID];
    } else if ([self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.collectionView registerNib:[self.delegate customCollectionViewCellNibForHorizontalMenuView:self] forCellWithReuseIdentifier:ZSDHorizontalMenuViewCellID];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.pageControl isKindOfClass:[ZSDPageControl class]]) {
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPage = targetContentOffset->x / self.frame.size.width;
    if ([self.pageControl isKindOfClass:[ZSDPageControl class]]) {
        ZSDPageControl *pageControl = (ZSDPageControl *)_pageControl;
        pageControl.currentPage = currentPage;
    }
    if ([self.delegate respondsToSelector:@selector(horizontalMenuView:WillEndDraggingWithVelocity:targetContentOffset:)]) {
        [self.delegate horizontalMenuView:self WillEndDraggingWithVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInHorizontalMenuView:)]) {
        count = [self.dataSource numberOfItemsInHorizontalMenuView:self];
    }
    return count;
}

- (ZSDHorizontalMenuViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZSDHorizontalMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZSDHorizontalMenuViewCellID forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
        [self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
    }else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
              [self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
    }
    NSString *title = @"";
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:titleForItemAtIndex:)]) {
        title = [self.dataSource horizontalMenuView:self titleForItemAtIndex:indexPath.row];
    }
    cell.menuTile.text = title;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:iconURLForItemAtIndex:)]) {
        NSURL *url = [self.dataSource horizontalMenuView:self iconURLForItemAtIndex:indexPath.row];
        if(self.defaultImage) {
            [cell.menuIcon sd_setImageWithURL:url placeholderImage:self.defaultImage];
        } else {
            [cell.menuIcon sd_setImageWithURL:url];
        }
    } else if (self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:localIconStringForItemAtIndex:)]) {
        NSString *imageName = [self.dataSource horizontalMenuView:self localIconStringForItemAtIndex:indexPath.row];
        cell.menuIcon.image = [UIImage imageNamed:imageName];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(iconSizeForHorizontalMenuView:)]) {
        CGSize imageSize = [self.delegate iconSizeForHorizontalMenuView:self];
        [cell.menuIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageSize);
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleFontSizwForHorizontalMenuView:)]) {
        UIFont *titleFont = [self.delegate titleFontSizwForHorizontalMenuView:self];
        cell.menuTile.font = titleFont;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizontalMenuView:hotStringForItemAtIndex:)]) {
        NSString *hot = [self.dataSource horizontalMenuView:self hotStringForItemAtIndex:indexPath.row];
        if (hot) {
            cell.hotLabel.hidden = NO;
            cell.hotLabel.text = hot;
        } else {
            cell.hotLabel.hidden = YES;
        }
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(horizontalMenuView:didSelectItemAtIndex:)]) {
        [self.delegate horizontalMenuView:self didSelectItemAtIndex:indexPath.row];
    }
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setUpPageControl];
}
- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[ZSDPageControl class]]) {
        ZSDPageControl *pageControl = (ZSDPageControl *)_pageControl;
        pageControl.currentColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }else{
        ZSDPageControl *pageControl = (ZSDPageControl *)_pageControl;
        pageControl.otherColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    
    if (self.pageControlStyle != ZSDHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = ZSDHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage {
    _pageDotImage = pageDotImage;
    
    if (self.pageControlStyle != ZSDHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = ZSDHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot {
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[ZSDPageControl class]]) {
        ZSDPageControl *pageControl = (ZSDPageControl *)_pageControl;
        pageControl.currentBkImg = image;
    }
}

- (NSInteger)numOfPage {
    return [self.layout currentPageCount];
}

#pragma  mark ZSDPageControlDelegate。监听用户点击 (如果需要点击切换,如果将ZSDPageControl 中的userInteractionEnabled切换成YES或者注掉)
- (void)ellipsePageControlClick:(ZSDPageControl *)pageControl index:(NSInteger)clickIndex {
    CGPoint position = CGPointMake(self.frame.size.width * clickIndex, 0);
    [self.collectionView setContentOffset:position animated:YES];
}

@end
