# UICommonCalendarView
## Custom calendar view
### Init, Height is greater than 350, advice is initialized,beacause no adaptation~
```Objective-C
    UICommonCalendarView *calendarView = [[UICommonCalendarView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen      mainScreen].bounds.size.width, 350)];
    [self.view addSubview:calendarView];
```
### Delegate
```Objective-C
- (void)selectCurrentDate:(NSDate *)date;
```
![show me~](https://github.com/guangguanglove/UICommonCalendarView/blob/master/UICommonCalendar/WechatIMG12.jpeg,https://github.com/guangguanglove/UICommonCalendarView/blob/master/UICommonCalendar/WechatIMG9.png)
