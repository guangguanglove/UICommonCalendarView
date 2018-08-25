//
//  ViewController.m
//  UICommonCalendar
//
//  Created by miqu on 2018/8/24.
//  Copyright © 2018年 zxg. All rights reserved.
//

#import "ViewController.h"
#import "UICommonCalendarView.h"


@interface ViewController ()<UICommonCalendarDelegate>

@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UICommonCalendarView *calendarView = [[UICommonCalendarView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 350)];
    [self.view addSubview:calendarView];
    calendarView.calendarDelagate = self;

    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 20)];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.infoLabel];
    [self selectCurrentDate:[NSDate date]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICommonCalendarDelegate
- (void)selectCurrentDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:dayInfoUnits fromDate:date];
    NSLog(@"####### delegate :%@", components);
    NSString *day;
    if (components.day < 10) {
        day = [NSString stringWithFormat:@"0%ld", components.day];
    } else {
        day = [NSString stringWithFormat:@"%ld", components.day];
    }
    NSString *month;
    if (components.month < 10) {
        month = [NSString stringWithFormat:@"0%ld", components.month];
    } else {
        month = [NSString stringWithFormat:@"%ld", components.month];
    }
    self.infoLabel.text = [NSString stringWithFormat:@"%ld-%@-%@", components.year, month, day];
}



@end
