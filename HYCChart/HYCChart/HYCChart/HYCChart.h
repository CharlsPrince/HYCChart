//
//  HYCChart.h
//  BezierPath学习
//
//  Created by charls on 2016/12/2.
//  Copyright © 2016年 Charls. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYCChart : UIView

/// 横向单位
@property (nonatomic, strong) NSArray <NSString *> *horizontalUnits;
/// 纵向单位
@property (nonatomic, strong) NSMutableArray <NSString *> *verticalUnits;
/// 横向单位文本颜色
@property (nullable, nonatomic, strong) UIColor *horizontalUnitColor;
/// 纵向单位文本颜色
@property (nullable, nonatomic, strong) UIColor *verizontalUnitColor;
/// 数据源
@property (nullable, nonatomic, strong) NSArray <NSNumber *> *chartData;
/// 根据数据源适应
@property (nonatomic, assign) BOOL adaptVByData;
/// 曲线
@property (nonatomic, assign) BOOL curveLine;
/// 单位分割线
@property (nonatomic, assign) BOOL sepLineAble;
/// 线颜色
@property (nullable, nonatomic, strong) UIColor *lineColor;
/// 线宽
@property (nonatomic, assign) CGFloat lineWidth;
/// 点色
@property (nullable, nonatomic, strong) UIColor *pointColor;
/// 点宽
@property (nonatomic, assign) CGFloat pointWidth;
/// 纵向单位名称
@property (nullable ,nonatomic, strong) NSString *verizontalUnitTitle;

@end

NS_ASSUME_NONNULL_END
