//
//  RFIDDeviceCellViewTableViewCell.m
//  RFIDDemoApp
//
//  Created by SST on 11/03/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "RFIDDeviceCellView.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>

@interface zt_RFIDDeviceCellView()
{
    IBOutlet UILabel *m_lblDeviceName;
    //IBOutlet UILabel *m_lblBluetoothAddress;
    IBOutlet UILabel *m_lblSerialNotice;
    IBOutlet UILabel *m_lblSerialData;
    IBOutlet UILabel *m_lblModelNotice;
    IBOutlet UILabel *m_lblModelData;
    
    IBOutlet UILabel *m_lblBatchModeInfo;
    BOOL m_ShowActive;
}
@end

@implementation zt_RFIDDeviceCellView

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
    
//    if (nil != m_lblBluetoothAddress)
//    {
//        [m_lblBluetoothAddress release];
//    }
    
    if (nil != m_lblSerialData)
    {
        [m_lblSerialData release];
    }
    
    if (nil != m_lblSerialNotice)
    {
        [m_lblSerialNotice release];
    }
    
    if (nil != m_lblModelNotice)
    {
        [m_lblModelNotice release];
    }
    
    if (nil != m_lblModelData)
    {
        [m_lblModelData release];
    }
    
    if (nil != m_lblBatchModeInfo)
    {
        [m_lblBatchModeInfo release];
    }
    
    [super dealloc];
}

- (void)setDeviceInformation : (NSString *)deviceName withModel: (NSString *)model withSerial:(NSString *)serial withBTAddress:(NSString*)bt_address isActive:(BOOL)active isBatch :(BOOL)batchMode
{
    [m_lblDeviceName setText:[NSString stringWithFormat:@"%@",deviceName]];

    if (active == TRUE && batchMode == FALSE)
    {
        // Reader active - Populate with all information
        
        // Set device information text
        [m_lblModelData setText:model];
        [m_lblSerialData setText:serial];
        
        // Set Bluetooth address
//        if (6*2 == [bt_address length])
//        {
//            NSString *_bt_address = @"";
//            for (int i = 0; i < 6; i++)
//            {
//                _bt_address = [_bt_address stringByAppendingString:[NSString stringWithString:[bt_address substringWithRange:NSMakeRange(i*2, 2)]]];
//                if (i < 5)
//                {
//                    _bt_address = [_bt_address stringByAppendingString:@":"];
//                }
//            }
//            //[m_lblBluetoothAddress setText:_bt_address];
//        }
//        else
//        {
//            //[m_lblBluetoothAddress setText:bt_address];
//        }
        
    }
    
}

@end
