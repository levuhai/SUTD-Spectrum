//
//  ScheduleViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "ScheduleViewController.h"
#import "CalendarView.h"
#import "Games.h"
#import <Masonry/Masonry.h>
#import "MZFormSheetController.h"
#import "HomeSceneViewController.h"

#define CloseIconTag 1

@interface ScheduleViewController () <CalendarDataSource, CalendarDelegate>
{
    NSCalendar * _gregorian;
    NSInteger _currentYear;
}

@property (nonatomic, weak) IBOutlet CalendarView* scheduleCalendar;

@end

@implementation ScheduleViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCalendar];
    
    //NSArray* allGames = [Games MR_findAll];
    //NSLog(@"%@",allGames);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.view bringSubviewToFront:[self.view viewWithTag:CloseIconTag]];
}

- (void)setupCalendar {
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
//    _scheduleCalendar                             = [[CalendarView alloc]initWithFrame:CGRectMake(0, 0, 898, 858)];
    _scheduleCalendar.frame = self.view.bounds;
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
    //_scheduleCalendar.backgroundColor = [UIColor whiteColor];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view insertSubview:_scheduleCalendar belowSubview:[self.view viewWithTag:CloseIconTag]];
//        _scheduleCalendar.x = (self.view.width - _scheduleCalendar.width)/2.0;
//         _scheduleCalendar.y = (self.view.height - _scheduleCalendar.height)/2.0;
//    });
    
    NSDateComponents * yearComponent = [_gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    _currentYear = yearComponent.year;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action methods
-(IBAction) closeButton_pressed {
    [_container dismissAnimated:YES completionHandler:nil];
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
    NSDateComponents * yearComponent = [_gregorian components:NSCalendarUnitYear fromDate:date];
    return (yearComponent.year == _currentYear || yearComponent.year == _currentYear+1);
}

@end
