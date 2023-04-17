//
//  ZSDHorizontalMenuCollectionLayout.h
//  ZSD_Business
//
//  Created by Kevin_han Pro on 2022/01/05.
//

#import <UIKit/UIKit.h>

@interface ZSDHorizontalMenuCollectionLayout : UICollectionViewLayout

@property (nonatomic,assign) NSInteger rowCount;

@property (nonatomic,assign) NSInteger columCount;


/**
 获取当前页数

 @return 页数
 */
-(NSInteger)currentPageCount;
@end
