//
//  ProfileTableViewCell.h
//  RFIDDemoApp
//
//  Created by Symbol on 05/01/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>

#define ZT_CELL_ID_PROFILE                   @"ID_PROFILE_CELL"
/// A UITableViewCell object is a specialized type of view that manages the content of a single table row.
@interface zt_ProfileTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel * lblTitle;
@property (retain, nonatomic) IBOutlet UISwitch * selectionSwitch;
@property (retain, nonatomic) IBOutlet UIButton * linkProfileBtn;
@property (retain, nonatomic) IBOutlet UIButton * sessionBtn;
@property (retain, nonatomic) IBOutlet UITextField *fieldPowerLevel;
@property (retain, nonatomic) IBOutlet UISwitch *switchDynamicPower;

- (void)setCellInformation : (NSString *)title withsubtitle: (NSString *)subTitle powerLevel:(NSString *)powerLevel linkProfile:(NSString *)linkProfile session:(NSString *)session dynamicPower:(BOOL)dynamicpower isActive:(BOOL)activeStatus isExpanded: (BOOL)expanded;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end

