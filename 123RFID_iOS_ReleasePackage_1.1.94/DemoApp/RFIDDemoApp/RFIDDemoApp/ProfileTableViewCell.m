//
//  ProfileTableViewCell.m
//  RFIDDemoApp
//
//  Created by Symbol on 05/01/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "ProfileTableViewCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"

@interface zt_ProfileTableViewCell()
{
    IBOutlet UILabel *lblSubTitle;
    IBOutlet UILabel *lblPowerLevel;
    IBOutlet UILabel *lblLinkProfile;
    IBOutlet UILabel *lblSession;
    IBOutlet UILabel *lblDynamicPower;
    IBOutlet UIView *bottomView;
}

@end

/// A UITableViewCell object is a specialized type of view that manages the content of a single table row.
@implementation zt_ProfileTableViewCell

/// To Initializes a table cell with a style and a reuse identifier and returns it to the caller.
/// @param style An enumeration for the various styles of cells.
/// @param reuseIdentifier A string used to identify a cell that is reusable.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_fieldPowerLevel setKeyboardType:UIKeyboardTypeNumberPad];
    }
    [self darkModeCheck:self.traitCollection];
    return self;
}

- (void)dealloc
{
    if (nil != bottomView) {
        [bottomView release];
    }
    if (nil != lblSubTitle) {
        [lblSubTitle release];
    }
    if (nil != lblPowerLevel) {
        [lblPowerLevel release];
    }
    if (nil != lblLinkProfile) {
        [lblLinkProfile release];
    }
    if (nil != lblSession) {
        [lblSession release];
    }
    if (nil != lblDynamicPower) {
        [lblDynamicPower release];
    }
    
    [super dealloc];
}

/// This is method is used to send the cell information from the view controller.
/// @param title Sending the profile title to show on the lbltitle.
/// @param subTitle Sending the profile subtitle to show on the lblsubtitle.
/// @param powerLevel Sending the profile powerlevel data to show on the lblpowerlevel.
/// @param linkProfile Sending the linkprofile data to show on the lbllinkprofile
/// @param session Sending the session data to show on the lblpowerlevel.
/// @param dynamicpower Sending the dynamic power data to show on the lbldynamicpower.
/// @param activeStatus Sending the status of the cell switch which is visible on top of the cell.
/// @param expanded Sending the cell status is expanded or not.
- (void)setCellInformation : (NSString *)title withsubtitle: (NSString *)subTitle powerLevel:(NSString *)powerLevel linkProfile:(NSString *)linkProfile session:(NSString *)session dynamicPower:(BOOL)dynamicpower isActive:(BOOL)activeStatus isExpanded: (BOOL)expanded;
{
    [_lblTitle setText:[NSString stringWithFormat:@"%@",title]];
    [lblSubTitle setText:[NSString stringWithFormat:@"%@",subTitle]];
    [lblPowerLevel setText:PROFILE_POWER_LEVEL];
    [lblLinkProfile setText:PROFILE_LINK_PROFILE];
    [lblSession setText:PROFILE_SESSION];
    [lblDynamicPower setText:PROFILE_DYNAMIC_POWER];
    _fieldPowerLevel.text = powerLevel;
    [_linkProfileBtn setTitle:linkProfile forState:UIControlStateNormal];
    [_sessionBtn setTitle:session forState:UIControlStateNormal];
    [_switchDynamicPower setOn:dynamicpower];
    
    if ([title  isEqual: PROFILE_USER_DEFINED] || [title  isEqual: PROFILE_READER_DEFINED]) {
        bottomView.userInteractionEnabled = true;
        _fieldPowerLevel.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
        [_linkProfileBtn setTitleColor:[UIColor getDarkModeLabelTextColor:self.traitCollection] forState:UIControlStateNormal];
        [_sessionBtn setTitleColor:[UIColor getDarkModeLabelTextColor:self.traitCollection] forState:UIControlStateNormal];
    }else
    {
        bottomView.userInteractionEnabled = false;
        _fieldPowerLevel.textColor = UIColor.systemGrayColor;
        [_linkProfileBtn setTitleColor:UIColor.systemGrayColor forState:UIControlStateNormal];
        [_sessionBtn setTitleColor:UIColor.systemGrayColor forState:UIControlStateNormal];
    }
    
    if (activeStatus) {
        _lblTitle.textColor = UIColor.systemBlueColor;
        [_selectionSwitch setOn:true];
    }else
    {
        _lblTitle.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
        [_selectionSwitch setOn:false];
    }
    
    if (expanded) {
        [bottomView setHidden:false];
    }else
    {
        [bottomView setHidden:true];
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end

