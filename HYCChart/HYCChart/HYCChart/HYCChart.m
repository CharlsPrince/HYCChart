//
//  HYCChart.m
//  BezierPath学习
//
//  Created by charls on 2016/12/2.
//  Copyright © 2016年 Charls. All rights reserved.
//

#import "HYCChart.h"
#import "HYCChartView.h"

static CGFloat const kHNormalHeight = 35.0f;  // 横向单位默认高度
static CGFloat const kVNormalWidth = 30.0f;  // 纵向单位默认宽度
static CGFloat const kChartStartPadding = 0.0f;
static CGFloat const kChartEndPadding = 0.0f;
static CGFloat const kChartTitleHeight = 25.0f;  // 标题高度

#define kDefaultHorizontalUnitColor  [UIColor redColor]   // 单位文字默认颜色
#define kDefaultVerzontalUnitColor  [UIColor blueColor]   // 单位文字默认颜色

@interface HYCChart ()
{
    NSMutableArray *_verizontalLabels;
    NSMutableArray *_sepLines;
    CGFloat _horizontalItemWith;
    CGFloat _verizontalImteHeight;
    CGFloat _firstVerizontalItemY;
    CGFloat _lastVerizontalItemCenterY;
}
@property (nonatomic, strong) HYCChartView *chartV;
@end

@implementation HYCChart
@synthesize horizontalUnitColor = _horizontalUnitColor;
@synthesize verizontalUnitColor = _verizontalUnitColor;

#pragma mark - initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _sepLines = [NSMutableArray arrayWithCapacity:0];
}

#pragma  mark - getter & setter

- (UIColor *)horizontalUnitColor {
    return _horizontalUnitColor ? _horizontalUnitColor : kDefaultHorizontalUnitColor;
}

- (void)setHorizontalUnitColor:(UIColor *)horizontalUnitColor {
    _horizontalUnitColor = horizontalUnitColor;
}

- (UIColor *)verizontalUnitColor {
    return _verizontalUnitColor ? _verizontalUnitColor : kDefaultVerzontalUnitColor;
}

- (void)setVerizontalUnitColor:(UIColor *)verizontalUnitColor {
    _verizontalUnitColor = verizontalUnitColor;
}

- (void)setSepLineAble:(BOOL)sepLineAble {
    _sepLineAble = sepLineAble;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (void)setCurveLine:(BOOL)curveLine {
    _curveLine = curveLine;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

#pragma mark - 重绘

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addVerticalUnitTitle];
    [self drawHorizontalUnits];
    [self drawVerticalUnits];
    [self drawSepLine];
    [self addLeftAndBottomLayer];
    [self drawChartData];
}

- (void)addVerticalUnitTitle {
    if (!self.verizontalUnitTitle) {
        return;
    }
    UILabel *verticalUnitTitleLabel = [[UILabel alloc] init];
    verticalUnitTitleLabel.text = self.verizontalUnitTitle;
    [verticalUnitTitleLabel sizeToFit];
    verticalUnitTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:verticalUnitTitleLabel];
    verticalUnitTitleLabel.frame = CGRectMake(0, (kChartTitleHeight - verticalUnitTitleLabel.bounds.size.height) / 2, verticalUnitTitleLabel.bounds.size.width, verticalUnitTitleLabel.bounds.size.height);
}

- (void)addLeftAndBottomLayer {
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    leftLayer.frame = CGRectMake(kVNormalWidth, kChartTitleHeight, 1, self.bounds.size.height - kChartTitleHeight - kHNormalHeight);
    leftLayer.backgroundColor = [UIColor colorWithRed:222/255.0 green:237/255.0 blue:239/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:leftLayer];
    
    CAShapeLayer *bottomLayer = [CAShapeLayer layer];
    bottomLayer.frame = CGRectMake(kVNormalWidth, self.bounds.size.height - 1 - kHNormalHeight, self.bounds.size.width - kVNormalWidth, 1);
    bottomLayer.backgroundColor = [UIColor colorWithRed:222/255.0 green:237/255.0 blue:239/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:bottomLayer];
}

- (void)drawVerticalUnits {
    _verizontalLabels = @[].mutableCopy;
    CGFloat verticalTotalHeight = self.bounds.size.height - kChartTitleHeight - kHNormalHeight;
    CGFloat verticalUnitHeight = verticalTotalHeight / self.verticalUnits.count;
    [[[self.verticalUnits reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kChartTitleHeight + verticalUnitHeight * idx + (verticalUnitHeight / 2), kVNormalWidth, verticalUnitHeight)];
//        unitLabel.backgroundColor = [UIColor yellowColor];
        unitLabel.text = obj;
        unitLabel.textColor = self.verizontalUnitColor;
        unitLabel.font = [UIFont systemFontOfSize:12.0f];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:unitLabel];
        if (idx == 0) {
            _firstVerizontalItemY = unitLabel.frame.origin.y;
        } else if (idx == self.verticalUnits.count - 1) {
            _lastVerizontalItemCenterY = unitLabel.center.y;
        }
        _verizontalImteHeight = unitLabel.frame.size.height;
        [_verizontalLabels addObject:unitLabel];
    }];
}

- (void)drawHorizontalUnits {
    CGFloat horizontalTotalWidth = self.bounds.size.width - kChartStartPadding - kChartEndPadding - kVNormalWidth;
    CGFloat horizontalUnitWith = horizontalTotalWidth / self.horizontalUnits.count;
    CGFloat horizontalUnitY = self.bounds.size.height - kHNormalHeight;
    [self.horizontalUnits enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalUnitWith * idx + kVNormalWidth + kChartStartPadding , horizontalUnitY, horizontalUnitWith, kHNormalHeight)];
//        unitLabel.backgroundColor = [UIColor yellowColor];
        unitLabel.text = obj;
        unitLabel.textColor = self.horizontalUnitColor;
        unitLabel.font = [UIFont systemFontOfSize:12.0f];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        _horizontalItemWith = unitLabel.frame.size.width;
        [self addSubview:unitLabel];
    }];
    
//    [self.horizontalUnits enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSMutableDictionary *attr = @{}.mutableCopy;
//        attr[NSFontAttributeName] = [UIFont systemFontOfSize:12.0f];
//        attr[NSForegroundColorAttributeName] = self.horizontalUnitColor;
//        CGSize unitSize = [obj sizeWithAttributes:attr];
//        CGFloat unitCenterY = self.bounds.size.height - kHNormalHeight + (kHNormalHeight - unitSize.height) / 2;
//        CGFloat space = ((horizontalUnitWith - unitSize.width) / 2) > 0 ? ((horizontalUnitWith - unitSize.width) / 2)  : 0.0f;
//        CGPoint unitPoint = CGPointMake(kChartStartPadding + kVNormalWidth   +  space* idx  +  space, unitCenterY);
//        [obj drawAtPoint:unitPoint withAttributes:attr];
//    }];
}

/// 添加横向分割线
- (void)drawSepLine {
    if (!self.sepLineAble) {
        [_sepLines enumerateObjectsUsingBlock:^(CAShapeLayer  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
        return;
    }
    if (!_verizontalLabels || _verizontalLabels.count <= 0) {
        return;
    }
    [_verizontalLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != _verizontalLabels.count - 1) {
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.frame = self.bounds;
            layer.strokeColor = [UIColor colorWithRed:222/255.0 green:237/255.0 blue:239/255.0 alpha:1.0].CGColor;
            layer.fillColor = [UIColor colorWithRed:222/255.0 green:237/255.0 blue:239/255.0 alpha:1.0].CGColor;
            layer.lineWidth = 1.0f;
            UIBezierPath *layerPath = [UIBezierPath bezierPath];
            CGPoint labelCenter = obj.center;
            CGPoint startPoint = CGPointMake(labelCenter.x + obj.frame.size.width / 2 + 1, labelCenter.y);
            [layerPath moveToPoint:startPoint];
            [layerPath addLineToPoint:CGPointMake(self.frame.size.width, startPoint.y)];
            layer.path = layerPath.CGPath;
            [self.layer addSublayer:layer];
            [_sepLines addObject:layer];
            
            CABasicAnimation *layerAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            layerAnimation.duration = 2.0f;
            layerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            layerAnimation.fromValue = @(0.0);
            layerAnimation.toValue = @(1.0);
            layerAnimation.removedOnCompletion = NO;
            layerAnimation.fillMode = kCAFillModeForwards;
            [layer addAnimation:layerAnimation forKey:@"strokeEnd"];
            
        }
    }];
}

- (void)drawChartData {
    CGFloat chartStartX = kVNormalWidth + kChartStartPadding + _horizontalItemWith / 2;
    CGFloat chartStartY = _firstVerizontalItemY;
    CGFloat chartWith = self.bounds.size.width - kVNormalWidth - kChartStartPadding - kChartEndPadding - _horizontalItemWith;
    CGFloat chartHeight = _lastVerizontalItemCenterY - chartStartY;
    _chartV = [[HYCChartView alloc] initWithFrame:CGRectMake(chartStartX, chartStartY, chartWith, chartHeight - 1)];
    _chartV.lineColor = self.lineColor;
    _chartV.pointColor = self.pointColor;
    _chartV.chartData = self.chartData;
    _chartV.pointWidth = self.pointWidth;
    _chartV.lineWidth = self.lineWidth;
    _chartV.curve = self.curveLine;
    _chartV.maxValue = 0.0f;
    if (self.adaptVByData) {
        NSNumber *maxNum = [self.chartData valueForKeyPath:@"@max.intValue"];
        int maxNumInt = maxNum.intValue;
        if (maxNumInt%10==0) {  
        } else {
            for (int i = 0; i < 10; i ++) {
                maxNumInt ++;
                if (maxNumInt%10==0) {
                    break;
                }
            }
        }
        [_verizontalLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        int num = maxNumInt / 5;
        _chartV.maxValue = maxNumInt + num / 2;
        [_verizontalLabels removeAllObjects];
        [self.verticalUnits removeAllObjects];
        [self.verticalUnits addObject:@"0"];
        for (int i = 1; i < 6; i ++) {
            int pro = i * num;
            [self.verticalUnits addObject:[NSString stringWithFormat:@"%d",pro]];
        }
        [self drawVerticalUnits];
        [self drawSepLine];
    } else {
        _chartV.maxValue = self.verticalUnits.lastObject.floatValue +  self.verticalUnits.lastObject.floatValue / self.verticalUnits.count / 2.0;
    }
    [self addSubview:_chartV];
}


@end
