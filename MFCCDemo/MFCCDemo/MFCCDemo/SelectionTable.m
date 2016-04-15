//
//  SelectionTable.m
//  MFCCDemo
//
//  Created by Hai Le on 4/13/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import "SelectionTable.h"
#import "DataManager.h"
#import "Word.h"
#import <MZFormSheetController/MZFormSheetController.h>

@implementation SelectionTable {
    NSMutableArray* words;
    NSMutableArray* records;
}

- (NSArray *)ls {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingString:@"/recordings"];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    NSLog(@"%@", documentsDirectory);
    return directoryContent;
}

- (void)viewDidLoad {
    words = [[DataManager shared] getWords];
    
    if (self.showRecordedSounds) {
        records = [NSMutableArray arrayWithArray:[self ls]];
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.showRecordedSounds) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showRecordedSounds) {
        if (section == 0) {
            return records.count;
        } else {
            return words.count;
        }
    }
    return words.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Word *w;
    NSString *fileName;
    if (_showRecordedSounds) {
        if (indexPath.section == 1) {
            w = words[indexPath.row];
            fileName = [[w.croppedPath lastPathComponent] stringByDeletingPathExtension];
        } else {
            fileName = [records[indexPath.row] stringByDeletingPathExtension];
        }
    } else {
        w = words[indexPath.row];
        fileName = [[w.croppedPath lastPathComponent] stringByDeletingPathExtension];
    }
    cell.textLabel.text = fileName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_showRecordedSounds)
        if (indexPath.section == 1) {
            Word *w= words[indexPath.row];
            _selectedRecordPath = [NSString stringWithFormat:@"%@/sounds/%@",
                                   [self applicationDocumentsDirectory],
                                   w.fullPath];
        }
        else
            _selectedRecordPath = [NSString stringWithFormat:@"%@/recordings/%@",
                                   [self applicationDocumentsDirectory],
                                   records[indexPath.row]];
    
    else _selectedWord = words[indexPath.row];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController * _Nonnull formSheetController) {
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_showRecordedSounds)
        if (section == 0) {
            return @"Records";
        }
    return @"Samples";
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
