//
//  ScheduleViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "ScheduleViewController.h"
#import "CalendarView.h"

#define CloseIconTag 1

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:[self.view viewWithTag:CloseIconTag]];
}

- (void)setupCalendar {
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _scheduleCalendar                             = [[CalendarView alloc]initWithFrame:CGRectMake(0, 50, 898, 898)];
    _scheduleCalendar.delegate                    = self;
    _scheduleCalendar.datasource                  = self;
    _scheduleCalendar.calendarDate                = [NSDate date];
    _scheduleCalendar.monthAndDayTextColor        = RGBCOLOR(52, 73, 94);
    _scheduleCalendar.dayBgColorWithData          = [UIColor clearColor];
    _scheduleCalendar.dayBgColorWithoutData       = [UIColor clearColor];
    _scheduleCalendar.dayBgColorSelected          = [UIColor clearColor];
    _scheduleCalendar.dayTxtColorWithoutData      = [UIColor whiteColor];
    _scheduleCalendar.dayTxtColorWithData         = [UIColor whiteColor];
    _scheduleCalendar.dayTxtColorSelected         = [UIColor whiteColor];
    _scheduleCalendar.borderColor                 = RGBCOLOR(159, 162, 172);
    _scheduleCalendar.borderWidth                 = 0;
    _scheduleCalendar.allowsChangeMonthByDayTap   = YES;
    _scheduleCalendar.allowsChangeMonthByButtons  = YES;
    _scheduleCalendar.keepSelDayWhenMonthChange   = YES;
    _scheduleCalendar.nextMonthAnimation          = UIViewAnimationOptionTransitionFlipFromRight;
    _scheduleCalendar.prevMonthAnimation          = UIViewAnimationOptionTransitionFlipFromLeft;
    _scheduleCalendar.titleFont                   = [UIFont fontWithName:@"Chalkboard SE" size:25.0];
    _scheduleCalendar.defaultFont                   = [UIFont fontWithName:@"MarkerFelt-Wide" size:27];
//    _scheduleCalendar.backgroundColor = [UIColor lightGrayColor];
    
    
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
