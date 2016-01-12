//
//  GameStatsViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentStatsController.h"
#import "ActionSheetPicker.h"
#import "Games.h"
#import "Sounds.h"
#import "GameStatistics.h"
#import "PNChart.h"
#import "UIColor+Flat.h"


@interface ParentStatsController ()
{
    
    NSArray* _gameStatData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
    
    PNLineChart * _lineChart;
    PNBarChart  * _barChart;
    
    IBOutlet UIButton* _playedTimeButton;
    IBOutlet UIButton* _pointButton;
    
    IBOutlet UILabel* _chartNoDataLabel;
    IBOutlet UILabel* _barNoDataLabel;
}

@end

@implementation ParentStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    _gameStatData = [GameStatistics MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dateAdded >= %@ AND dateAdded <= %@", [NSDate beginningOfToday],[NSDate endOfToday]]];
    [self enableButton:_playedTimeButton];
    [self disableButton:_pointButton];
    
    
    if (_gameStatData.count > 0) {
        // First line data
        [self loadDataForLineChart:YES];
        // Bar data
        [self loadDataForWordsBarChart:_gameStatData];
        // setup chart
        [self drawLineChart];
        [self drawBarChart];
        _chartNoDataLabel.hidden = YES;
        _barNoDataLabel.hidden = YES;
    } else{
        _chartNoDataLabel.hidden = NO;
        _barNoDataLabel.hidden = NO;
    }
    
    _lineGraphContainer.layer.cornerRadius = 10;
    _barGraphContainer.layer.cornerRadius = 10;
}

- (void)drawLineChart {
    if (_lineBottomLabels.count > 0) {
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = PNLightBlue;
        data01.itemCount = _lineBottomLabels.count;
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [_lineGraphData[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        if (!_lineChart) {
            _lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 100 - 30, _lineGraphContainer.width, _lineGraphContainer.height - 100)];
            _lineChart.xLabelFont = [UIFont fontWithName:@"Helvetica" size:15];
            [_lineChart setXLabels:_lineBottomLabels];
            _lineChart.chartData = @[data01];
            [_lineChart strokeChart];
            [_lineGraphContainer addSubview:_lineChart];
        } else {
            [_lineChart setXLabels:_lineBottomLabels];
            [_lineChart updateChartData:@[data01]];
        }
    }
}

- (void)drawBarChart {
    if (_barBottomLabels.count > 0) {
        if (!_barChart) {
            _barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 90 - 30, _barGraphContainer.width - 100, _barGraphContainer.height - 90)];
            _barChart.yChartLabelWidth = 20;
            _barChart.barBackgroundColor = PNWhite;
            _barChart.labelTextColor = PNBlack;
            _barChart.isShowNumbers = NO;
            _barChart.xLabels = _barBottomLabels;
            _barChart.yValues = _barGraphData;
            
            [_barChart strokeChart];
            [_barGraphContainer addSubview:_barChart];
        } else {
            _barChart.xLabels = _barBottomLabels;
            [_barChart updateChartData:_barGraphData];
        }
    }
}

- (void) loadDataForLineChart:(BOOL) isCalculatingTotalPlayed {
    if (_gameStatData.count == 0) {
        return;
    }
    _chartNoDataLabel.hidden = YES;
    _barNoDataLabel.hidden = YES;
    
    _lineBottomLabels = nil;
    _lineGraphData = nil;
    
    _lineBottomLabels = [NSMutableArray array];
    _lineGraphData = [NSMutableArray array];
    
    // Get bottom labels
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE dd MMM"];
    for (GameStatistics* gs in _gameStatData) {
        NSString *dateString = [dateFormatter stringFromDate:gs.dateAdded];
        if (![_lineBottomLabels containsObject:dateString]) {
            [_lineBottomLabels addObject:dateString];
        }
    }
    
    for (NSString* dateString in _lineBottomLabels) {
        int totalPlayedCount = 0;
        for (GameStatistics* gs in _gameStatData) {
            NSString *gsDate = [dateFormatter stringFromDate:gs.dateAdded];
            if ([gsDate isEqualToString:dateString]) {
                totalPlayedCount += isCalculatingTotalPlayed ? gs.totalPlayedCount.integerValue : gs.correctCount.integerValue;
            }
        }
        [_lineGraphData addObject:@(totalPlayedCount)];
    }
}

- (void) loadDataForWordsBarChart:(NSArray*) gameStatData {
    
    if (gameStatData.count == 0) {
        return;
    }
    _chartNoDataLabel.hidden = YES;
    _barNoDataLabel.hidden = YES;
    
    _barBottomLabels = nil;
    _barGraphData = nil;
    _barBottomLabels = [NSMutableArray array];
    _barGraphData = [NSMutableArray array];
    
    for (GameStatistics* gs in gameStatData) {
        
        if (![_barBottomLabels containsObject:gs.word]) {
            [_barBottomLabels addObject:gs.word];
        }
    }
    
    for (NSString* letter in _barBottomLabels) {
        for (GameStatistics* gs in gameStatData) {
            if ([gs.word isEqualToString:letter]) {
                [_barGraphData addObject:@((gs.correctCount.integerValue / (float)gs.totalPlayedCount.integerValue) * 100)];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

-(IBAction) playedTimeButton_action {
    [self enableButton:_playedTimeButton];
    [self disableButton:_pointButton];
    // Reload data
    [self loadDataForLineChart:YES];
    // Update line chart
    [self drawLineChart];
}

-(IBAction) pointButton_action {
    [self enableButton:_pointButton];
    [self disableButton:_playedTimeButton];
    // Reload data
    [self loadDataForLineChart:NO];
    // Update line chart
    [self drawLineChart];

}

- (void) enableButton:(UIButton*) button {
    button.backgroundColor = RGB(47,139,193);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor clearColor]];
    button.selected = YES;
}

- (void) disableButton:(UIButton*) button {
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:RGB(47,139,193) forState:UIControlStateNormal];
    [button setTintColor:[UIColor clearColor]];
    button.selected = NO;
}


#pragma mark - Action methods
- (IBAction) timeRange_pressed:(id)sender {
    __block NSArray *rangeData = [NSArray arrayWithObjects:@"Today",@"Yesterday",@"Last 7 days", @"Last 2 weeks",@"This month", @"Last month", @"All time", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Date ranges"
                                            rows:rangeData
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [(UIButton*)sender setTitle:selectedValue forState:UIControlStateNormal];
                                           
                                           [self fetchDataByDateRange:selectedIndex];
                                           
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:sender];
}

- (void) fetchDataByDateRange:(NSInteger) index {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    
    components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components weekday] - 1))];
    NSDate *thisWeek  = [cal dateFromComponents:components];
    
    [components setDay:([components day] - 7)];
    NSDate *lastWeek  = [cal dateFromComponents:components];
    
    [components setDay:([components day] - ([components day] -1))];
    NSDate *thisMonth = [cal dateFromComponents:components];
    
    [components setMonth:([components month] - 1)];
    NSDate *lastMonth = [cal dateFromComponents:components];
    
    NSLog(@"today=%@",today);
    NSLog(@"yesterday=%@",yesterday);
    NSLog(@"thisWeek=%@",thisWeek);
    NSLog(@"lastWeek=%@",lastWeek);
    NSLog(@"thisMonth=%@",thisMonth);
    NSLog(@"lastMonth=%@",lastMonth);
    
    
    NSPredicate *predicate = nil;
    switch (index) {
        case 0: // Today
            predicate = [NSPredicate predicateWithFormat:@"dateAdded >= %@ AND dateAdded <= %@", [NSDate beginningOfToday],[NSDate endOfToday]];
            break;
        case 1: // Yesterday
            predicate = [NSPredicate predicateWithFormat:@"dateAdded >= %@ AND dateAdded <= %@", yesterday,[NSDate beginningOfToday]];
            break;
        case 2: // Last 7 days
            predicate = [NSPredicate predicateWithFormat:@"(dateAdded >= %@) AND (dateAdded <= %@)", thisWeek, [NSDate beginningOfToday]];
            break;
        case 3: // Last 2 weeks
            predicate = [NSPredicate predicateWithFormat:@"(dateAdded >= %@) AND (dateAdded <= %@)", lastWeek, [NSDate beginningOfToday]];
            break;
        case 4: // This month
            predicate = [NSPredicate predicateWithFormat:@"dateAdded >= %@",thisMonth];
            break;
        case 5: // Last month
            predicate = [NSPredicate predicateWithFormat:@"(dateAdded >= %@) AND (dateAdded <= %@)", lastMonth, thisMonth];
            break;
        case 6: // All time
            break;
        default:
            break;
    }
    
    if (predicate) {
        _gameStatData = [GameStatistics MR_findAllWithPredicate:predicate];
    } else {
        _gameStatData = [GameStatistics MR_findAll];
    }
    
    for (GameStatistics* gs in _gameStatData) {
        NSLog(@"- %@",gs);
    }
    
    //_gameStatData = [GameStatistics MR_findAll];
    
    // Reload data
    [self loadDataForLineChart:_playedTimeButton.selected];
    [self loadDataForWordsBarChart:_gameStatData];
    
    // setup chart
    if (_gameStatData.count > 0) {
        _lineChart.hidden = NO;
        _barChart.hidden = NO;
        [self drawLineChart];
        [self drawBarChart];
    } else {
        _lineChart.hidden = YES;
        _barChart.hidden = YES;
        _chartNoDataLabel.hidden = NO;
        _barNoDataLabel.hidden = NO;
    }
}

- (NSDate*) getYesterday{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    return yesterday;
}

@end
