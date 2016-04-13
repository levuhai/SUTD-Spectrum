//
//  SelectionTable.h
//  MFCCDemo
//
//  Created by Hai Le on 4/13/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Word;

@interface SelectionTable : UITableViewController

@property (nonatomic,assign) BOOL showRecordedSounds;
@property (nonatomic,strong) Word* selectedWord;
@property (nonatomic,strong) NSString* selectedRecordPath;

@end
