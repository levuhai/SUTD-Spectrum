//
//  ScheduleViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "ScheduleViewController.h"
#import "CalendarView.h"

@interface ScheduleViewController () <CalendarDataSource, CalendarDelegate>
{
    CalendarView* _scheduleCalendar;
    NSCalendar * _gregorian;
    NSInteger _currentYear;
}
@end

@implementation ScheduleViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCalendar];
}

- (void)setupCalendar {
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _scheduleCalendar                             = [[CalendarView alloc]initWithFrame:CGRectMake(0, 0, 640, 640)];
    _scheduleCalendar.delegate                    = self;
    _scheduleCalendar.datasource                  = self;
    _scheduleCalendar.calendarDate                = [NSDate date];
    _scheduleCalendar.monthAndDayTextColor        = RGBCOLOR(0, 174, 255);
    _scheduleCalendar.dayBgColorWithData          = RGBCOLOR(21, 124, 229);
    _scheduleCalendar.dayBgColorWithoutData       = RGBCOLOR(208, 208, 214);
    _scheduleCalendar.dayBgColorSelected          = RGBCOLOR(94, 94, 94);
    _scheduleCalendar.dayTxtColorWithoutData      = RGBCOLOR(57, 69, 84);
    _scheduleCalendar.dayTxtColorWithData         = [UIColor whiteColor];
    _scheduleCalendar.dayTxtColorSelected         = [UIColor whiteColor];
    _scheduleCalendar.borderColor                 = RGBCOLOR(159, 162, 172);
    _scheduleCalendar.borderWidth                 = 1;
    _scheduleCalendar.allowsChangeMonthByDayTap   = YES;
    _scheduleCalendar.allowsChangeMonthByButtons  = YES;
    _scheduleCalendar.keepSelDayWhenMonthChange   = YES;
    _scheduleCalendar.nextMonthAnimation          = UIViewAnimationOptionTransitionFlipFromRight;
    _scheduleCalendar.prevMonthAnimation          = UIViewAnimationOptionTransitionFlipFromLeft;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:_scheduleCalendar];
        _scheduleCalendar.center = CGPointMake(self.view.center.x, _scheduleCalendar.center.y);
    });
    
    NSDateComponents * yearComponent = [_gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    _currentYear = yearComponent.year;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action methods
-(IBAction) closeButton_pressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gesture recognizer

-(void)swipeleft:(id)sender
{
    [_scheduleCalendar showNextMonth];
}

-(void)swiperight:(id)sender
{
    [_scheduleCalendar showPreviousMonth];
}

#pragma mark - CalendarDelegate protocol conformance

-(void)dayChangedToDate:(NSDate *)selectedDate
{
    NSLog(@"dayChangedToDate %@(GMT)",selectedDate);
}

#pragma mark - CalendarDataSource protocol conformance

-(BOOL)isDataForDate:(NSDate *)date
{
    if ([date compare:[NSDate date]] == NSOrderedAscending)
        return YES;
    return NO;
}

-(BOOL)canSwipeToDate:(NSDate *)date
{
    NSDateComponents * yearComponent = [_gregorian components:NSYearCalendarUnit fromDate:date];
    return (yearComponent.year == _currentYear || yearComponent.year == _currentYear+1);
}

@end
