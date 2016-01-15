//
//  GameStatsViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentStatsController.h"
#import "ActionSheetPicker.h"
#import "UIColor+Chameleon.h"
#import "DataManager.h"
#import "Score.h"
#import "UIFont+ES.h"
#import "UIColor+Expanded.h"
#import "Chameleon.h"
#import <Charts/Charts.h>

#define CORRECT_VALUE 0.5f;

@interface ParentStatsController () <ChartViewDelegate>
{
    
    //NSArray* _gameStatData;
    NSMutableArray* _scoreData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
}

@property (nonatomic, strong) IBOutlet CombinedChartView *chartView;
@property (nonatomic, weak) IBOutlet UIImageView *imgDateRange;
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;

@end

@implementation ParentStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Setup combined chart
    _chartView.delegate = self;
    _chartView.pinchZoomEnabled = YES;
    _chartView.doubleTapToZoomEnabled = NO;
    _chartView.descriptionText = @"";
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _chartView.infoFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:25];
    _chartView.infoTextColor = [UIColor colorWithHexString:@"FCB726"];
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawHighlightArrowEnabled = NO;
    _chartView.drawOrder = @[
                             @(CombinedChartDrawOrderBar),
                             @(CombinedChartDrawOrderLine)
                             ];
    _chartView.rightAxis.enabled = NO;
    
    _chartView.leftAxis.drawAxisLineEnabled = NO;
    _chartView.leftAxis.drawGridLinesEnabled = YES;
    _chartView.leftAxis.gridLineWidth = .5;
    //_chartView.leftAxis.gridColor = [UIColor colorWithHexString:@"E0E0E0"];
    _chartView.leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _chartView.leftAxis.labelTextColor = [UIColor flatGrayColorDark];
    _chartView.leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    _chartView.leftAxis.valueFormatter.maximumFractionDigits = 0;
    _chartView.leftAxis.valueFormatter.allowsFloats = NO;


    _chartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _chartView.xAxis.drawAxisLineEnabled = YES;
    _chartView.xAxis.drawGridLinesEnabled = NO;
    _chartView.xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    // Setup bar chart
    _barChartView.delegate = self;
    _barChartView.pinchZoomEnabled = YES;
    _barChartView.doubleTapToZoomEnabled = NO;
    _barChartView.descriptionText = @"";
    _barChartView.drawGridBackgroundEnabled = NO;
    _barChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    [UIFont printAllFontName];
    _barChartView.infoFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
    _barChartView.infoTextColor = [UIColor colorWithHexString:@"FCB726"];
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawHighlightArrowEnabled = NO;
    _barChartView.drawMarkers = NO;
    
    //_barChartView.leftAxis.axisMaximum = 100;
    _barChartView.leftAxis.customAxisMax = 100.0f;
    _barChartView.leftAxis.drawAxisLineEnabled = NO;
    _barChartView.leftAxis.drawGridLinesEnabled = YES;
    _barChartView.leftAxis.gridLineWidth = .5;
    
    //_barChartView.leftAxis.gridColor = [UIColor colorWithHexString:@"E0E0E0"];
    _barChartView.leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _barChartView.leftAxis.labelTextColor = [UIColor flatGrayColorDark];
    _barChartView.leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    _barChartView.leftAxis.valueFormatter.maximumFractionDigits = 0;
    _barChartView.leftAxis.valueFormatter.positiveSuffix = @"%";
    _barChartView.leftAxis.valueFormatter.allowsFloats = NO;
    
    _barChartView.rightAxis.enabled = NO;
    
    _barChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _barChartView.xAxis.drawAxisLineEnabled = YES;
    _barChartView.xAxis.drawGridLinesEnabled = NO;
    _barChartView.xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    // Data
    [self fetchDataByDateRange:0];
    
    _lineGraphContainer.layer.cornerRadius = 30;
    _barGraphContainer.layer.cornerRadius = 30;
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
    [set setColor:[UIColor flatRedColor]];
    set.lineWidth = 4;
    set.circleRadius = 6;
    [set setCircleColor:[UIColor flatRedColor]];
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
    [set1 setColor:[UIColor flatSkyBlueColor]];
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
    [set1 setColor:FlatMint];
    set1.drawValuesEnabled = NO;
    
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
                                  @"Last 30 days",
                                  @"This month",
                                  @"Last month",
                                  @"All time",
                                  nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Date ranges"
                                            rows:rangeData
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSString* v = [selectedValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                                           NSString* name = [NSString stringWithFormat:@"lb%@",v];
                                           self.imgDateRange.image = [UIImage imageNamed:name];
                                           
                                           [self fetchDataByDateRange:selectedIndex];
                                           
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:sender];
}

- (void)fetchDataByDateRange:(NSInteger)index {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    
    NSDate *f, *t;
    if (index == 0) {
        f = [NSDate beginningOfToday];
        t = [NSDate endOfToday];
    } else if (index == 1) {
        NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate beginningOfToday] options:0];
        f = yesterday;
        t = [NSDate beginningOfToday];
    } else if (index == 2) {
        [components setDay:([components day] - ([components weekday] - 1))];
        NSDate *thisWeek  = [cal dateFromComponents:components];
        f = thisWeek;
        t = [NSDate beginningOfToday];
    } else if (index == 3) { // Last 30 days
        [components setDay:([components day] - 30)];
        NSDate *last30Days  = [cal dateFromComponents:components];
        f = last30Days;
        t = [NSDate beginningOfToday];
    } else if (index == 4) {
        
        [components setDay:([components day] - ([components day] -1))];
        NSDate *thisMonth = [cal dateFromComponents:components];
        f = thisMonth;
        t = [NSDate endOfToday];
    } else if (index == 5) {
        components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
        [components setDay:([components day] - ([components day] -1))];
        NSDate *thisMonth = [cal dateFromComponents:components];
        [components setMonth:([components month] - 1)];
        NSDate *lastMonth = [cal dateFromComponents:components];
        
        f = lastMonth;
        t = thisMonth;
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
