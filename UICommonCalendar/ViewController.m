//
//  ViewController.m
//  UICommonCalendar
//
//  Created by miqu on 2018/8/24.
//  Copyright © 2018年 zxg. All rights reserved.
//

#import "ViewController.h"
#import "UICommonCalendarView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UICommonCalendarView *calendarView = [[UICommonCalendarView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 350)];
    [self.view addSubview:calendarView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickAction:(id)sender {
    
}

@end
