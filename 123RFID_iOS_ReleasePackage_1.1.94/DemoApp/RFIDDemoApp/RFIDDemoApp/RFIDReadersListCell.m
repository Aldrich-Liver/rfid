//
//  RFIDReadersListCell.m
//  RFIDDemoApp
//
//  Created by Symbol on 30/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "RFIDReadersListCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>

@interface zt_RFIDReadersListCell()
{
    IBOutlet UILabel *m_lblDeviceName;
    IBOutlet UIImageView *m_ImageSelection;
}
@end

/// To listout the paired readers in the scan and pair view controller.
@implementation zt_RFIDReadersListCell

/// To initialise the cell with the style and the identifier to reuse the cell wherever we need.
/// @param style To pass the cell style to show in the tableview.
/// @param reuseIdentifier To reuse the cell wherever we need.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_lblDeviceName) {
        [m_lblDeviceName release];
    }
    [super dealloc];
}

/// This is method is used to send the device information from the view controller.
/// @param deviceName Passing the device name from the view controller to show on the device name label.
- (void)setDeviceInformation : (NSString *)deviceName
{
    [m_lblDeviceName setText:[NSString stringWithFormat:@"%@",deviceName]];
}

@end
