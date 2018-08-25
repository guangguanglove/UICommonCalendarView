//
//  UICommonCalendarView.h
//  UICommonCalendar
//
//  Created by miqu on 2018/8/24.
//  Copyright © 2018年 zxg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICommonCalendarDelegate<NSObject>

- (void)selectCurrentDate:(NSDate *)date;

@end

@interface UICommonCalendarView : UIView

@property (nonatomic, strong) id<UICommonCalendarDelegate> calendarDelagate;

@end
