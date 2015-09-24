//
//  GameStatsViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameStatsViewController.h"

@interface GameStatsViewController () <GKLineGraphDataSource, GKBarGraphDataSource>
{
    GKLineGraph* lGraph;
    GKBarGraph* bGraph;
}
@property (strong, nonatomic) NSArray* labels;
@end

@implementation GameStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(47,139,193);
    // Line graph
    self.lineGraphData = @[
                  @[@20, @40, @20, @60, @40, @140, @80]
                  ];
    
    self.labels = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7"];
    
    
    lGraph = [[GKLineGraph alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.lineGraphContainer.height)];
    lGraph.backgroundColor = [UIColor whiteColor];
    lGraph.dataSource = self;
    lGraph.lineWidth = 8.0;
    lGraph.valueLabelCount = 3;
    lGraph.margin = 40;
    [self.lineGraphContainer addSubview:lGraph];
    self.lineGraphContainer.layer.cornerRadius = 10;
    
    // Bar graph
    
    self.barGraphData = @[@65, @10, @40, @90, @50, @75, @100];
    bGraph = [[GKBarGraph alloc] initWithFrame:CGRectMake(-60, 0, self.view.width, self.barGraphContainer.height)];
    bGraph.dataSource = self;
    bGraph.backgroundColor = [UIColor whiteColor];
    bGraph.barWidth = 80;
    bGraph.barHeight = 140;
    bGraph.marginBar = 40;
    bGraph.animationDuration = 2.0;
    
    [self.barGraphContainer addSubview:bGraph];
    self.barGraphContainer.layer.cornerRadius = 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [lGraph draw];
    [bGraph draw];
}

#pragma mark - GKLineGraphDataSource

- (NSInteger)numberOfLines {
    return [self.lineGraphData count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_alizarinColor],
                  [UIColor gk_sunflowerColor]
                  ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [self.lineGraphData objectAtIndex:index];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return  [self.labels objectAtIndex:index];
}


#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [self.barGraphData count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [self.barGraphData objectAtIndex:index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_alizarinColor],
                  [UIColor gk_amethystColor],
                  [UIColor gk_emerlandColor],
                  [UIColor gk_sunflowerColor],
                  [UIColor gk_belizeHoleColor]
                  ];
    return [colors objectAtIndex:index];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (bGraph.animationDuration * percentage);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return [self.labels objectAtIndex:index];
}

@end
