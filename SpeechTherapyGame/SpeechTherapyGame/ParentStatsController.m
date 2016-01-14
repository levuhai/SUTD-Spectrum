//
//  GameStatsViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentStatsController.h"
#import "ActionSheetPicker.h"
#import "PNChart.h"
#import "UIColor+Chameleon.h"
#import "DataManager.h"
#import "Score.h"
#import <Charts/Charts.h>

#define CORRECT_VALUE 0.5f;

@interface ParentStatsController () <ChartViewDelegate>
{
    
    //NSArray* _gameStatData;
    NSMutableArray* _scoreData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
    
    PNLineChart * _lineChart;
    PNBarChart  * _barChart;
}

@property (nonatomic, strong) IBOutlet CombinedChartView *chartView;
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;

@end

@implementation ParentStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Setup combined chart
    _chartView.delegate = self;
    _chartView.descriptionText = @"";
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawHighlightArrowEnabled = YES;
    _chartView.drawOrder = @[
                             @(CombinedChartDrawOrderBar),
                             @(CombinedChartDrawOrderLine)
                             ];
    _chartView.rightAxis.enabled = NO;
    
    _chartView.leftAxis.drawGridLinesEnabled = NO;
    _chartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _chartView.xAxis.drawAxisLineEnabled = YES;
    _chartView.xAxis.drawGridLinesEnabled = NO;
    
    // Setup bar chart
    _barChartView.delegate = self;
    _barChartView.descriptionText = @"";
    _barChartView.drawGridBackgroundEnabled = NO;
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawHighlightArrowEnabled = YES;
    
    _barChartView.leftAxis.axisMaximum = 100;
    _barChartView.leftAxis.customAxisMax = 100.0f;
    _barChartView.leftAxis.drawGridLinesEnabled = NO;
    
    _barChartView.rightAxis.enabled = NO;
    
    _barChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _barChartView.xAxis.drawAxisLineEnabled = YES;
    _barChartView.xAxis.drawGridLinesEnabled = NO;
    
    // Data
    [self fetchDataByDateRange:0];
    
    _lineGraphContainer.layer.cornerRadius = 10;
    _barGraphContainer.layer.cornerRadius = 10;
}


- (void)loadDataForLineChart:(NSMutableArray*)rawData {
    if (rawData.count == 0) {
        [_chartView clearValues];
        [_chartView clear];
        [_chartView setNeedsDisplay];
        return;
    }
    
    // Get bottom labels
    NSMutableArray* dates = [NSMutableArray new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM, yyyy"];
    for (Score* score in rawData) {
        NSString *dateString = [dateFormatter stringFromDate:score.date];
        if (![dates containsObject:dateString]) {
            [dates addObject:dateString];
        }
    }
    
    // Line Data
    LineChartData *lData = [[LineChartData alloc] init];
    NSMutableArray *lineEntries = [[NSMutableArray alloc] init];
    
    BarChartData *bData = [[BarChartData alloc] init];
    NSMutableArray *barEntries = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString* dateString in dates) {
        
        int totalPlayedCount = 0;
        int totalCorrectCount = 0;
        for (Score* gs in rawData) {
            NSString *gsDate = [dateFormatter stringFromDate:gs.date];
            if ([gsDate isEqualToString:dateString]) {
                totalPlayedCount += 1;
                totalCorrectCount += gs.score>=CORRECT_VALUE;
            }
        }
        [lineEntries addObject:[[ChartDataEntry alloc] initWithValue:totalCorrectCount
                                                          xIndex:index]];
        [barEntries addObject:[[BarChartDataEntry alloc] initWithValue:totalPlayedCount
                                                                xIndex:index]];
        index++;
    }
    
    // Line Dataset
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:lineEntries
                                                              label:@"Correct Attempts"];
    [set setColor:[UIColor flatSkyBlueColor]];
    set.lineWidth = 4;
    [set setCircleColor:[UIColor flatSkyBlueColor]];
    set.fillColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.drawCubicEnabled = NO;
    set.drawCircleHoleEnabled = YES;
    set.drawCirclesEnabled = YES;
    set.drawValuesEnabled = NO;
    set.drawVerticalHighlightIndicatorEnabled = NO;
    set.axisDependency = AxisDependencyLeft;
    
    [lData addDataSet:set];
    
    // Bar Dataset
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:barEntries
                                                             label:@"Attempts"];
    [set1 setColor:[UIColor flatRedColor]];
    set1.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;
    set1.drawValuesEnabled = NO;
    
    [bData addDataSet:set1];
    
    // Line chart
    CombinedChartData *combinedData = [[CombinedChartData alloc] initWithXVals:dates];
    combinedData.lineData = lData;
    combinedData.barData = bData;

    _chartView.data = combinedData;
}

- (void)loadDataForWordsBarChart:(NSArray*)gameStatData {
    if (gameStatData.count == 0) {
        [_barChartView clearValues];
        [_barChartView clear];
        [_barChartView setNeedsDisplay];
        return;
    }
    
    // X values
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (Score* gs in gameStatData) {
        if (![xVals containsObject:gs.sound]) {
            [xVals addObject:gs.sound];
        }
    }
    
    // Y Values
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString* letter in xVals) {
        float totalScore = 0.0f;
        float totalPlay = 0.0f;
        for (Score* gs in gameStatData) {
            if ([gs.sound isEqualToString:letter]) {
                if (gs.score >= 0.5) {
                    totalScore += 1;
                }
                totalPlay += 1;
                
            }
        }
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:totalScore/totalPlay*100.0f
                                                           xIndex:index]];
        index++;
    }
    
    // Dataset
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"Sounds"];
    set1.barSpace = 0.35;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _barChartView.data = data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods
- (IBAction) timeRange_pressed:(id)sender {
    __block NSArray *rangeData = [NSArray arrayWithObjects:
                                  @"Today",
                                  @"Yesterday",
                                  @"Last 7 days",
                                  @"Last 2 weeks",
                                  @"This month",
                                  @"Last month",
                                  @"All time",
                                  nil];
    
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

- (void)fetchDataByDateRange:(NSInteger)index {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[NSDate date]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
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
    
    NSDate *f, *t;
    switch (index) {
        case 0: // Today
            f = [NSDate beginningOfToday];
            t = [NSDate endOfToday];
            break;
        case 1: // Yesterday
            f = yesterday;
            t = [NSDate beginningOfToday];
            break;
        case 2: // Last 7 days
            f = thisWeek;
            t = [NSDate beginningOfToday];
            break;
        case 3: // Last 2 weeks
            f = lastWeek;
            t = [NSDate beginningOfToday];
            break;
        case 4: // This month
            f = thisMonth;
            break;
        case 5: // Last month
            f = lastMonth;
            t = thisMonth;
            break;
        case 6: // All time
            break;
        default:
            break;
    }
    
    _scoreData = [[DataManager shared] getScoresFrom:f to:t];
    
    // Reload data
    [self loadDataForLineChart:_scoreData];
    [self loadDataForWordsBarChart:_scoreData];
    
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
