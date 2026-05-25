//
//  SwitchTableViewCell.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ISwitchTableViewCellProtocol <NSObject>
    - (void)switchValueChanged:(BOOL)on aIndex:(int)index;
@end

/// Symbol view cell
@interface SwitchTableViewCell : UITableViewCell{
    int m_Index;
    id <ISwitchTableViewCellProtocol> m_Delegate;
}

@property (retain, nonatomic) IBOutlet UILabel *cellTitle;
@property (retain, nonatomic) IBOutlet UISwitch *cellSwitch;

- (int)getIndex;
- (void)setIndex:(int)index;
- (void)setDelegate:(id <ISwitchTableViewCellProtocol>)delegate;
- (IBAction)switchSymbologyValueChanged:(id)sender;
- (void)setSwitchOn:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
