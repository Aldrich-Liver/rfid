//
//  RFIDDeviceCellViewTableViewCell.h
//  RFIDDemoApp
//
//  Created by SST on 11/03/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>

@interface zt_RFIDDeviceCellView : UITableViewCell

- (void)setDeviceInformation : (NSString *)deviceName withModel: (NSString *)model withSerial:(NSString *)serial withBTAddress:(NSString*)bt_address isActive:(BOOL)active isBatch :(BOOL)batchMode;

@end
