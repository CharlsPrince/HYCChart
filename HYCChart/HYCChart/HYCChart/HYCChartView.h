//
//  HYCChartView.h
//  BezierPath学习
//
//  Created by charls on 2016/12/2.
//  Copyright © 2016年 Charls. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TouchInstructionType) {
    TouchInstructionTypeNone = 0,
    TouchInstructionTypeLine = 1,
    TouchInstructionTypeScale
};

@interface HYCChartView : UIView

@property (nullable, nonatomic, strong) NSArray <NSNumber *> *chartData;

@property (nonatomic, assign) CGFloat maxValue;
/// 曲线
@property (nonatomic, assign, getter=isCurve) BOOL curve;
/// 
@property (nonatomic, assign, getter=isDrawing) BOOL drawing;

///
@property (nonatomic, assign) BOOL drawAnimation;

/// 触摸指示
@property (nonatomic, assign) BOOL touchInstructionAble;
/// 触摸指示类型
@property (nonatomic, assign) TouchInstructionType touchInsType;

@property (nullable, nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nullable, nonatomic, strong) UIColor *pointColor;

@property (nonatomic, assign) CGFloat pointWidth;

@property (nonatomic, strong) UILabel *instructionLabel;

@end

NS_ASSUME_NONNULL_END
