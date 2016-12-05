//
//  ChartViewController.m
//  BezierPath学习
//
//  Created by charls on 2016/12/2.
//  Copyright © 2016年 Charls. All rights reserved.
//

#import "ChartViewController.h"

#import "HYCChart.h"

@interface ChartViewController ()

@property (nonatomic, strong) HYCChart *chart;

@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _chart = [[HYCChart alloc] initWithFrame:CGRectZero];
    _chart.horizontalUnits = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    _chart.verticalUnits = @[@"0",@"50",@"100",@"150",@"550",@"250"].mutableCopy;
    _chart.chartData = @[@22,@8,@13,@10,@20,@12,@31];
    _chart.adaptVByData = YES;
    _chart.sepLineAble = NO;
    _chart.pointColor = [UIColor orangeColor];
    _chart.lineColor = [UIColor purpleColor];
    _chart.lineWidth = 4.0f;
    _chart.verizontalUnitTitle = @"里程 : 公里";
    _chart.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_chart];
    
    NSDictionary *_bingViews = @{@"chat":_chart};
    NSArray *h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[chat]-10-|" options:kNilOptions metrics:nil views:_bingViews];
    NSArray *v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[chat(==200)]" options:kNilOptions metrics:nil views:_bingViews];
    
    [self.view addConstraints:h];
    [self.view addConstraints:v];
    [_chart setNeedsLayout];
    
    
    UISwitch *lineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 320, 10, 10)];
    [lineSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:lineSwitch];
    
}

- (void)switchValueChange:(UISwitch *)aSwitch {
    _chart.sepLineAble = aSwitch.isOn;
    _chart.curveLine = aSwitch.isOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
