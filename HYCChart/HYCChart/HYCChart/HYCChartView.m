//
//  HYCChartView.m
//  BezierPath学习
//
//  Created by charls on 2016/12/2.
//  Copyright © 2016年 Charls. All rights reserved.
//

#import "HYCChartView.h"

@implementation HYCChartView {
    NSMutableArray *_pointValues;  // 坐标
    CAShapeLayer *_instructionLayer;
    NSMutableArray *_pointLayers;  // 坐标层
    CGFloat _pw;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _curve = YES;
        _drawAnimation = YES;
        _touchInstructionAble = YES;
        _touchInsType = TouchInstructionTypeNone;
        _pointLayers = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (BOOL)isCurve {
    return _curve;
}

- (BOOL)drawAnimation {
    return _drawAnimation;
}

- (BOOL)touchInstructionAble {
    return _touchInstructionAble;
}

- (UIColor *)lineColor {
    return _lineColor ? _lineColor : [UIColor blackColor];
}

- (UIColor *)pointColor {
    return _pointColor ? _pointColor : [UIColor blackColor];
}

- (CGFloat)pointWidth {
    return _pointWidth ? _pointWidth : 5.0f;
}

- (CGFloat)lineWidth {
    return _lineWidth ? _lineWidth : 2.5f;
}

- (void)drawRect:(CGRect)rect {
    NSNumber *startNum = self.chartData.firstObject;
    CGFloat startY = self.bounds.size.height - startNum.floatValue * self.bounds.size.height / self.maxValue;
    CGPoint startPoint = CGPointMake(0, startY);
    
    // 坐标数组
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:0];
    _pw = self.bounds.size.width / (self.chartData.count - 1);
    [self.chartData enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat y = self.bounds.size.height - obj.floatValue * self.bounds.size.height / self.maxValue;
        CGPoint point = CGPointMake(_pw * idx, y);
        NSValue *pointValue = [NSValue valueWithCGPoint:point];
        [points addObject:pointValue];
    }];
    
    // 坐标数组
    _pointValues = points.mutableCopy;
    
    // 曲线层
    CAShapeLayer *curveLayer = [CAShapeLayer layer];
    curveLayer.frame = self.bounds;
    curveLayer.strokeColor = self.lineColor.CGColor;
    curveLayer.fillColor = [UIColor clearColor].CGColor;
    curveLayer.lineWidth = self.lineWidth;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    
    __block CGPoint subStartPoint = startPoint;  // 分段开始点
    [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != 0) {
            CGPoint subEndPoint = obj.CGPointValue;
            
            CGFloat centerX = (subStartPoint.x + subEndPoint.x) / 2;
            CGPoint ctrolP1 = CGPointMake(centerX, subStartPoint.y);
            CGPoint ctrolP2 = CGPointMake(centerX, subEndPoint.y);
            
            if (self.isCurve) {
                [path addCurveToPoint:subEndPoint controlPoint1:ctrolP1 controlPoint2:ctrolP2];
                subStartPoint = subEndPoint;
            } else {
                [path addLineToPoint:obj.CGPointValue];
            }
        }
    }];
    curveLayer.lineCap = kCALineCapRound;
    curveLayer.lineJoin=kCALineJoinRound;
    curveLayer.path = path.CGPath;
//    [self.layer addSublayer:curveLayer];
    
    // 遮罩层
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.CGPath = curveLayer.path;
    [maskPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [maskPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [maskPath addLineToPoint:startPoint];
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.path = maskPath.CGPath;
    
    // 渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.colors = [NSMutableArray arrayWithArray:@[
        (__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor]];

    
    // 渐变背景层
    CALayer *bLayer = [CALayer layer];
    bLayer.frame = self.bounds;
    [bLayer addSublayer:gradientLayer];
    [bLayer setMask:maskLayer];
    [self.layer addSublayer:bLayer];

    // 渐变层
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    gradientLayer2.startPoint = CGPointMake(0, 0);
    gradientLayer2.endPoint = CGPointMake(1, 0);
    gradientLayer2.colors = [NSMutableArray arrayWithArray:@[
                                                            (__bridge id)[UIColor colorWithRed:205 / 255.0 green:234 / 160.0 blue:8 / 155.0 alpha:1.0].CGColor,
                                                            (__bridge id)[UIColor colorWithRed:90 / 255.0 green:211 / 255.0 blue:221 / 255.0 alpha:1.0].CGColor]];
    CALayer *bLayer2 = [CALayer layer];
    bLayer2.frame = self.bounds;
    [bLayer2 addSublayer:gradientLayer2];
    [bLayer2 setMask:curveLayer];
    [self.layer addSublayer:bLayer2];
    
    [self addCirclePoints:points];
    
    if (self.drawAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 2.0f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.fromValue = @(0.0);
        animation.toValue = @(1.0);
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [curveLayer addAnimation:animation forKey:@"strokeEnd"];
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.duration = 2.0f;
        animation2.keyPath = @"bounds";
        animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.bounds.size.width * 2, self.bounds.size.height)];
        animation2.removedOnCompletion = NO;
        animation2.autoreverses =NO;//动画结束是否执行逆动画
        animation2.fillMode = kCAFillModeForwards;
        [gradientLayer addAnimation:animation2 forKey:@"maskBounds"];
    }
 
}

/// 添加圆点
- (void)addCirclePoints:(NSArray *)pointValues {
    [pointValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CAShapeLayer *circlePointLayer = [CAShapeLayer layer];
        UIBezierPath *circlePointPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.pointWidth * 2, self.pointWidth * 2) cornerRadius:self.pointWidth];
        circlePointLayer.fillColor = self.pointColor.CGColor;
        circlePointLayer.lineWidth = 0;
        circlePointLayer.position = CGPointMake(obj.CGPointValue.x - self.pointWidth, obj.CGPointValue.y - self.pointWidth);
        circlePointLayer.path = circlePointPath.CGPath;
        [self.layer addSublayer:circlePointLayer];
        [_pointLayers addObject:circlePointLayer];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.instructionLabel.frame = CGRectZero;
    [self touchWithTouches:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchWithTouches:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endTouch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"取消Touch");
    [self endTouch];
}

- (void)showTouchInstructionWithTouch:(UITouch *)touch {
    if (_touchInsType == TouchInstructionTypeLine) {
         [self instructionLayer].position = CGPointMake([touch locationInView:self].x, [self instructionLayer].position.y);
    }
}

- (void)touchWithTouches:(NSSet<UITouch *> *)touches {
    if (!self.touchInstructionAble) {
        return;
    }
    UITouch *touch = touches.allObjects.lastObject;
    if (touch.tapCount > 1) {
        return;
    } else {
        if (!_pointValues || _pointValues.count <= 0) {
            return;
        } else {
            [self showTouchInstructionWithTouch:touch];
            [_pointValues enumerateObjectsUsingBlock:^(NSValue  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGPoint currentPoint = obj.CGPointValue;
                CGPoint touchPoint = [touch locationInView:self];
                if (fabs(currentPoint.x-touchPoint.x) < _pw / 2) {
                    NSLog(@"在%@范围内",self.chartData[idx]);
                    NSString *insText = [NSString stringWithFormat:@"%@",self.chartData[idx]];
                    self.instructionLabel.text = insText;
                    [self.instructionLabel sizeToFit];
                    currentPoint.y -= (self.pointWidth + 5 + self.instructionLabel.bounds.size.height / 2);
                    self.instructionLabel.center = currentPoint;
                    self.instructionLabel.backgroundColor = [UIColor lightGrayColor];
                    
                    
                    if (_touchInsType == TouchInstructionTypeScale) {
                        if (_pointLayers.count < _pointValues.count) {
                            return;
                        } else {
                            CAShapeLayer *pointLayer = _pointLayers[idx];
                            /// 弹簧动画
                            CASpringAnimation *springAni = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
                            springAni.damping = 5;
                            springAni.stiffness = 100;
                            springAni.mass = 1;
                            springAni.initialVelocity = 0;
                            springAni.fromValue = @(1);
                            springAni.toValue = @(2);
                            springAni.duration = springAni.settlingDuration;
                            [pointLayer addAnimation:springAni forKey:@"SpringAni"];
                        }
                    } else if (_touchInsType == TouchInstructionTypeLine) {
                        NSLog(@"point->>>>>>>%@",NSStringFromCGPoint([touch locationInView:self]));
                    }
                }
            }];
        }
    }
}

- (void)endTouch {
    [self instructionLayer].position = CGPointMake(-15, _instructionLayer.position.y);
}

/// 触摸指示层
- (CAShapeLayer *)instructionLayer {
    if (!_instructionLayer) {
        
        UIView *_instructionBackView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, self.bounds.size.width + 20, self.bounds.size.height)];
        _instructionBackView.layer.masksToBounds = YES;
        [self addSubview:_instructionBackView];
        
        _instructionLayer = [CAShapeLayer layer];
        _instructionLayer.frame = CGRectMake(-10, 0, 2, self.bounds.size.height);
        _instructionLayer.fillColor = [UIColor blackColor].CGColor;
        _instructionLayer.backgroundColor = [UIColor blackColor].CGColor;
        _instructionLayer.position = CGPointMake(-15, _instructionLayer.position.y);
        [_instructionBackView.layer addSublayer:_instructionLayer];
    }
    return _instructionLayer;
}
/// 指示标签
- (UILabel *)instructionLabel {
    if (!_instructionLabel) {
        _instructionLabel = [[UILabel alloc] init];
        _instructionLabel.layer.cornerRadius = 5.0f;
        _instructionLabel.textColor = [UIColor whiteColor];
        _instructionLabel.layer.masksToBounds = YES;
        [self addSubview:_instructionLabel];
    }
    return _instructionLabel;
}

@end
