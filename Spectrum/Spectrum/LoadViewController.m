//
//  LoadViewController.m
//  Spectrum
//
//  Created by Mr.J on 5/30/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import "LoadViewController.h"
#import "RecordViewCell.h"
#import "Configs.h"

@interface LoadViewController ()

@end

@implementation LoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // get list record
    if (!listRecord) {
        listRecord = [[NSMutableArray alloc]initWithCapacity:1];
    }
    [self getData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getData{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    listRecord = [userDefaults objectForKey:@"data"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // return number of list record
    return [listRecord count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"RecordViewCell";
    
    RecordViewCell *cell = (RecordViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecordViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary * data = [listRecord objectAtIndex:indexPath.row];
    if (data) {
        // add name
        cell.lbName.text = [data objectForKey:@"name"];
        // add score
        cell.lbScore.text = @"Score";
    }
    
    // add target
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IS_iPAD) {
        return 50;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (IS_iPAD) {
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        header.backgroundColor = [UIColor whiteColor];
        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(38, 5, 50, 40)];
        lblName.text = @"Name";
        lblName.font = [UIFont boldSystemFontOfSize:17];
        [header addSubview:lblName];
        
        UILabel *lblScore = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width - 90, 5, 50, 40)];
        lblScore.text = @"Score";
        lblScore.font = [UIFont boldSystemFontOfSize:17];
        lblScore.textColor = [UIColor redColor];
        [header addSubview:lblScore];
        return header;
    }
    return nil;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    // load data
//    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//    NSArray * arrayData = [userDefaults objectForKey:@"data"];
//    
//    for (int i=0; i<[arrayData count]; i++) {
//        <#statements#>
//    }
    
    
}
@end
