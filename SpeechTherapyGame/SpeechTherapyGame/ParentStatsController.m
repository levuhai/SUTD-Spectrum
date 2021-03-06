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
#import "MZFormSheetController.h"
#import "ParentSoundDetailsController.h"

#define CORRECT_VALUE 0.5f;

@interface ParentStatsController () <ChartViewDelegate>
{
    
    //NSArray* _gameStatData;
    NSMutableArray* _scoreData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
    NSDate* _from;
    NSDate* _to;
    NSInteger _currentIndex;
    NSMutableArray* _dates;
    NSMutableArray* _sounds;
}

@property (nonatomic, strong) IBOutlet CombinedChartView *chartView;
@property (nonatomic, weak) IBOutlet UIImageView *imgDateRange;
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;

@end

@implementation ParentStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _dates = [NSMutableArray new];
    
    self.lineGraphContainer.layer.cornerRadius = 30;
    self.lineGraphContainer.layer.borderWidth = 5;
    self.lineGraphContainer.layer.borderColor = [[UIColor flatSkyBlueColorDark] CGColor];
    
    self.barGraphContainer.layer.cornerRadius = 30;
    self.barGraphContainer.layer.borderWidth = 5;
    self.barGraphContainer.layer.borderColor = [[UIColor flatSkyBlueColorDark] CGColor];
    
    // Setup combined chart
    _chartView.delegate = self;
    _chartView.pinchZoomEnabled = YES;
    _chartView.doubleTapToZoomEnabled = NO;
    _chartView.scaleYEnabled = NO;
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
    _barChartView.scaleYEnabled = NO;
    _barChartView.descriptionText = @"";
    _barChartView.drawGridBackgroundEnabled = NO;
    _barChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    //[UIFont printAllFontName];
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
}


- (void)loadDataForLineChart:(NSMutableArray*)rawData {
//    if (rawData.count == 0) {
//        [_chartView clearValues];
//        [_chartView clear];
//        [_chartView setNeedsDisplay];
//        return;
//    }
    
    // Get bottom labels
    [_dates removeAllObjects];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay: 1];
    if (_currentIndex == 6) {
        Score* s = rawData[0];
        _from = s.date;
        _to = [NSDate endOfToday];
    }
    for (id date = [_from copy];
         [date compare: _to] <= 0;
         date = [calendar dateByAddingComponents: oneDay
                                          toDate: date
                                         options: 0] )
        {
            [_dates addObject:[dateFormatter stringFromDate:date]];
        }
    
    // Line Data
    LineChartData *lData = [[LineChartData alloc] init];
    NSMutableArray *lineEntries = [[NSMutableArray alloc] init];
    
    BarChartData *bData = [[BarChartData alloc] init];
    NSMutableArray *barEntries = [[NSMutableArray alloc] init];
    
    int index = 0;
    int max = 0;
    float minScore = [[DataManager shared] difficultyValue];
    for (NSString* dateString in _dates) {
        
        int totalPlayedCount = 0;
        int totalCorrectCount = 0;
        for (Score* gs in rawData) {
            NSString *gsDate = [dateFormatter stringFromDate:gs.date];
            if ([gsDate isEqualToString:dateString]) {
                totalPlayedCount += 1;
                totalCorrectCount += gs.score>=minScore;
            }
            
        }
        if (max < totalPlayedCount) {
            max = totalPlayedCount;
        }
        [lineEntries addObject:[[ChartDataEntry alloc] initWithValue:totalCorrectCount
                                                          xIndex:index]];
        [barEntries addObject:[[BarChartDataEntry alloc] initWithValue:totalPlayedCount
                                                                xIndex:index]];
        index++;
    }
    
    // validate yAxis data
    if (rawData.count == 0 || max < 6) {
        _chartView.leftAxis.customAxisMax = 6;
    } else {
        [_chartView.leftAxis resetCustomAxisMax];
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
    CombinedChartData *combinedData = [[CombinedChartData alloc] initWithXVals:_dates];
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
    if (!_sounds) {
        _sounds = [[NSMutableArray alloc] init];
    }
    [_sounds removeAllObjects];
    
    for (Score* gs in gameStatData) {
        if (![_sounds containsObject:gs.sound]) {
            [_sounds addObject:gs.sound];
        }
    }
    
    // Y Values
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    int index = 0;
    float minScore = [[DataManager shared] difficultyValue];
    for (NSString* letter in _sounds) {
        float totalScore = 0.0f;
        float totalPlay = 0.0f;
        for (Score* gs in gameStatData) {
            if ([gs.sound isEqualToString:letter]) {
                if (gs.score >= minScore) {
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
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:_sounds dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _barChartView.data = data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods
- (IBAction) savePressed:(id)sender {
    [_barChartView saveToCameraRoll];
    [_chartView saveToCameraRoll];
    [[AudioPlayer shared] playSfx];
}
- (IBAction) timeRange_pressed:(id)sender {
    [[AudioPlayer shared] playSfx];
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
                                initialSelection:_currentIndex
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
    _currentIndex = index;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDate *f, *t;
    if (index == 0) {
        f = [NSDate beginningOfToday];
        t = [NSDate endOfToday];
    } else if (index == 1) {
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        [components setDay:([components day] - 1)];
        f = [cal dateFromComponents:components];
        
        [components setHour:23];
        [components setMinute:59];
        [components setSecond:59];
        t = [cal dateFromComponents:components];
    } else if (index == 2) { // Lasy 7 days
        [components setDay:([components day] - 6)];
        NSDate *thisWeek  = [cal dateFromComponents:components];
        f = thisWeek;
        t = [NSDate endOfToday];
    } else if (index == 3) { // Last 30 days
        [components setDay:([components day] - 29)];
        NSDate *last30Days  = [cal dateFromComponents:components];
        f = last30Days;
        t = [NSDate endOfToday];
    } else if (index == 4) {
        
        [components setDay:([components day] - ([components day] -1))];
        NSDate *thisMonth = [cal dateFromComponents:components];
        f = thisMonth;
        t = [NSDate endOfToday];
    } else if (index == 5) {
        [components setDay:([components day] - ([components day] -1))];
        NSDate *thisMonth = [cal dateFromComponents:components];
        [components setMonth:([components month] - 1)];
        NSDate *lastMonth = [cal dateFromComponents:components];
        
        f = lastMonth;
        t = thisMonth;
    }
    _from = f;
    _to = t;
    _scoreData = [[DataManager shared] getScoresFrom:_from to:_to];
    
    // Reload data
    [self loadDataForLineChart:_scoreData];
    [self loadDataForWordsBarChart:_scoreData];
    
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
    if ([chartView isKindOfClass:[CombinedChartView class]]) {
        NSLog(@"date %@",_dates[entry.xIndex]);
        ParentSoundDetailsController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SoundDetails"];
        [vc reloadTableWithDateString:_dates[entry.xIndex]];
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromRight;
        formSheet.presentedFormSheetSize = CGSizeMake(550, self.view.height-80);
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.shouldCenterVertically = YES;
        formSheet.cornerRadius = 20.0;
//        vc.container = formSheet;
//        vc.homeSceneVC = self;
        formSheet.didDismissCompletionHandler = ^(UIViewController *vc){
            [_chartView highlightValues:nil];
            [_barChartView highlightValues:nil];
        };
        
        [self mz_presentFormSheetController:formSheet
                                   animated:YES
                          completionHandler:nil];
    } else {
        
        ParentSoundDetailsController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SoundDetails"];
        [vc reloadTableWithSound:_sounds[entry.xIndex]];
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromRight;
        formSheet.presentedFormSheetSize = CGSizeMake(550, self.view.height-80);
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.shouldCenterVertically = YES;
        formSheet.cornerRadius = 20.0;
        //        vc.container = formSheet;
        //        vc.homeSceneVC = self;
        formSheet.didDismissCompletionHandler = ^(UIViewController *vc){
            [_chartView highlightValues:nil];
            [_barChartView highlightValues:nil];
        };
        
        [self mz_presentFormSheetController:formSheet
                                   animated:YES
                          completionHandler:nil];
    }
    
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
