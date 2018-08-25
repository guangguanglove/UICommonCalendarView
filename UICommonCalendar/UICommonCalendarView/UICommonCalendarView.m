//
//  UICommonCalendarView.m
//  UICommonCalendar
//
//  Created by miqu on 2018/8/24.
//  Copyright © 2018年 zxg. All rights reserved.
//

#import "UICommonCalendarView.h"
#import "UICommonCollectionViewCell.h"

//屏幕宽&&高
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

static NSString *kCollectionViewCell = @"UICommonCollectionViewCell";
static CGFloat kItemWidth = 30;
static NSUInteger kLineHorizontal = 7;
static NSUInteger kLineVertical = 7;
static NSUInteger kOnePageHasTotalItem = 49;

@interface UICommonCalendarView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, assign) NSUInteger todayIndex;
@property (nonatomic, assign) NSUInteger otherDayIndex;
@property (nonatomic, assign) NSUInteger todayIsWhichDay;
@property (nonatomic, assign) NSUInteger todayIsWhichMonth;
@property (nonatomic, assign) NSUInteger todayIsWhichYear;
@property (nonatomic, assign) NSUInteger slideToSelectWhichDay;
@property (nonatomic, assign) NSUInteger slideToSelectWhichMonth;
@property (nonatomic, assign) NSUInteger slideToSelectWhichYear;
@property (nonatomic, strong) NSDate *currentShowDate;

@end


@implementation UICommonCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // get today
        [self getTodayTotalInfo];
        //set data
        self.currentShowDate = [NSDate date];
        [self configDate];
        // set UI
        [self setUpCollectionView];
        [self setUpselectLabel];
    }
    return self;
}

- (void)configDate {
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < kOnePageHasTotalItem; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    NSArray *titleArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    for (int i = 0; i < titleArray.count; i++) {
        [self.dataArray replaceObjectAtIndex:i * kLineVertical withObject:titleArray[i]];
    }
    NSInteger thisMonthTotalDays = [self getCurrentMonthForDays:self.currentShowDate];
    NSInteger thisMonthFirstDayIsWhichWeek = [self getFirstDayWeekForMonth:[self getAMonthFromDate:self.currentShowDate]];
    for (int i = 0; i < thisMonthTotalDays; i++) {
        NSInteger everyDayIndex = ((i + thisMonthFirstDayIsWhichWeek) % kLineHorizontal * kLineVertical + 1) + (i + thisMonthFirstDayIsWhichWeek) / kLineHorizontal;
        [self.dataArray replaceObjectAtIndex:everyDayIndex withObject:[NSString stringWithFormat:@"%d", i + 1]];
        if ([self getTodayDay] == i + 1) {
            self.todayIndex = everyDayIndex;
        } else if (i == 0 && ![self isTodayMainView]) {
            self.otherDayIndex = everyDayIndex;
        }
    }
    for (int i = 0; i < thisMonthFirstDayIsWhichWeek; i++) {
        [self.dataArray replaceObjectAtIndex:kLineVertical * i + 1 withObject:@""];
    }
    NSInteger nextDayAtCurrentPageCount = kOnePageHasTotalItem - thisMonthFirstDayIsWhichWeek - thisMonthTotalDays - kLineHorizontal;
    for (int i = 0; i < nextDayAtCurrentPageCount; i++) {
        NSUInteger index = (kLineHorizontal - 1)  * (kLineHorizontal - i % kLineHorizontal) + (kLineVertical - i / kLineVertical) - i % kLineHorizontal - 1;
        [self.dataArray replaceObjectAtIndex:index  withObject:@""];
    }
}

- (void)setUpCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewCell bundle:nil] forCellWithReuseIdentifier:kCollectionViewCell];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;

    //add swipe gesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(switchingCalendar:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.collectionView addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(switchingCalendar:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.collectionView addGestureRecognizer:swipeRight];
}

- (void)switchingCalendar:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self getLastMonthDate:self.currentShowDate];
        [self resetUI];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self getNextMonthDate:self.currentShowDate];
        [self resetUI];
    }
}

- (void)resetUI {
    [self.collectionView removeFromSuperview];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self configDate];
    [self setUpCollectionView];
    [self setUpselectLabel];

}

- (void)setUpselectLabel {
    self.selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.selectLabel.clipsToBounds = YES;
    self.selectLabel.layer.cornerRadius = 20;
    [self.collectionView addSubview:self.selectLabel];
    self.selectLabel.backgroundColor = [UIColor redColor];
    self.selectLabel.textColor = [UIColor whiteColor];
    self.selectLabel.font = [UIFont systemFontOfSize:18];
    self.selectLabel.textAlignment = NSTextAlignmentCenter;
}



#pragma mark  设置CollectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark  设置CollectionView每组所包含的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kOnePageHasTotalItem;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICommonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:kCollectionViewCell owner:nil options:nil] firstObject];
    }
    if (indexPath.row < self.dataArray.count) {
        cell.textLabel.text = self.dataArray[indexPath.row];
    }

    if ([self isTodayMainView]) {
        if (self.todayIndex == indexPath.row) {
            cell.textLabel.textColor = [UIColor redColor];
            self.selectLabel.center = cell.center;
            self.selectLabel.text = cell.textLabel.text;
        }
    } else {
        if (self.self.otherDayIndex == indexPath.row) {
            self.selectLabel.center = cell.center;
            self.selectLabel.text = cell.textLabel.text;
        }
    }

    return cell;

}

#pragma mark 判断是否是当前的年月view
- (BOOL)isTodayMainView {
    if ((self.todayIsWhichMonth == self.slideToSelectWhichMonth && self.todayIsWhichYear == self.slideToSelectWhichYear) || self.slideToSelectWhichDay == 0) {
        return YES;
    } else {
        return NO;
    }

}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kItemWidth, kItemWidth);
}

#pragma mark  定义整个CollectionViewCell与整个View的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, (SCREEN_WIDTH - kItemWidth * 7) / 8, 15, (SCREEN_WIDTH - kItemWidth * 7) / 8);//（上、左、下、右）
}

#pragma mark  定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.bounds.size.height - 7 * kItemWidth) / 8;
}

#pragma mark  定义每个UICollectionView的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return (SCREEN_WIDTH - kItemWidth * 7) / 8;
}

#pragma mark  UICollectionView Click Item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % kLineHorizontal == 0) {
        return;
    }
    UICommonCollectionViewCell *cell = (UICommonCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectLabel.center = cell.center;
    self.selectLabel.text = cell.textLabel.text;
}

#pragma mark - 获取日期数据
#pragma mark  获取当前月份日期的天数
- (NSInteger)getCurrentMonthForDays:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSInteger numberOfDays = range.length;
    return numberOfDays;
}

#pragma mark  获取目标月份的天数
- (NSInteger)getNextNMonthForDays:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSUInteger numbersOfDays = range.length;
    return numbersOfDays;
}

#pragma mark  获取某月一号是星期几
- (NSInteger)getFirstDayWeekForMonth:(NSDate *)date {
    if (date == nil) {
        return 0;
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = [components weekday];
    weekday--;
    if (weekday == 7) {
        return 0;
    } else {
        return weekday;
    }
}

#pragma mark  获取今天是多少号
- (NSUInteger)getTodayDay {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    NSInteger day = [components day];
    return day;
}

#pragma mark  获取今天数据
- (void)getTodayTotalInfo {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    self.todayIsWhichDay = [components day];
    self.todayIsWhichMonth = [components month];
    self.todayIsWhichYear = [components year];
    NSLog(@"######## today is: %ld-%ld-%ld", self.todayIsWhichYear, self.todayIsWhichMonth, self.todayIsWhichDay);
}

#pragma mark  获取目标date（包含某个月 1 号的数据）
- (NSDate *)getAMonthFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:dayInfoUnits fromDate:date];
    components.day = 1;
    NSDate *nextMonthDate = [calendar dateFromComponents:components];
    return nextMonthDate;
}

#pragma mark  获取下个月 date
- (NSDate *)getNextMonthDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:dayInfoUnits fromDate:date];
    components.day = 1;
    if ([components month] == 12) {
        components.month = 1;
        components.year++;
    } else {
        components.month++;
    }

    self.slideToSelectWhichYear = [components year];
    self.slideToSelectWhichMonth = [components month];
    self.slideToSelectWhichDay = [components day];
    NSLog(@"######## slide date: %ld-%ld-%ld", self.slideToSelectWhichYear, self.slideToSelectWhichMonth, self.slideToSelectWhichDay);

    NSDate *nextMonthDate = [calendar dateFromComponents:components];
    self.currentShowDate = nextMonthDate;
    return nextMonthDate;
}

#pragma mark  获取上个月 date
- (NSDate *)getLastMonthDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:dayInfoUnits fromDate:date];
    components.day = 1;
    if ([components month] == 1) {
        components.month = 12;
        components.year--;
    } else {
        components.month--;
    }

    self.slideToSelectWhichYear = [components year];
    self.slideToSelectWhichMonth = [components month];
    self.slideToSelectWhichDay = [components day];
    NSLog(@"######## slide date: %ld-%ld-%ld #####%@", self.slideToSelectWhichYear, self.slideToSelectWhichMonth, self.slideToSelectWhichDay, components);
    NSDate *lastMonthDate = [calendar dateFromComponents:components];
    self.currentShowDate = lastMonthDate;
    return lastMonthDate;
}



#pragma mark - date对象转成字符串
- (NSString *)theTargetDateConversionStr:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormat stringFromDate:date];
    return [currentDateStr substringFromIndex:7];
}

#pragma mark - NSString戳转NSDate
- (NSDate *)theTragetStringConversionDate:(NSString *)str {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:str];
    return date;
}

#pragma mark - remove collection
- (void)removeCollectionView {


}

#pragma mark - 判断是否是闰年 闰月


@end
