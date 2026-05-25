//
//  MultiTagTableViewCell.h
//  RFIDDemoApp
//
//  Created by Symbol on 23/09/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ZT_CELL_ID_MULTITAG_DATA                 @"ID_CELL_MULTITAG_DATA"

@interface MultiTagTableViewCell : UITableViewCell
{
    IBOutlet UILabel *tagIdLabel;
    IBOutlet UILabel *tagCountLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UIView *progressBackgroundView;
    IBOutlet UIView *progressView;
    IBOutlet UIProgressView *progressBar;
}

- (void)setTagId:(NSString*)tagId;
- (NSString*)getTagId;
- (void)setPrecentage:(NSString*)precentage;
- (void)setTagSeenCount:(NSString*)tagSeenCount;
- (void)setTagIdForASCIIMode:(NSString*)tagId;
- (void) setTagDataTextColorForASCIIMode;

@end
