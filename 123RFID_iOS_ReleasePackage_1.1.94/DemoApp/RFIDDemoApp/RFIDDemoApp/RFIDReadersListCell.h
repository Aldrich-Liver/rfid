//
//  RFIDReadersListCell.h
//  RFIDDemoApp
//
//  Created by Symbol on 30/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>

/// To list out the paired readers in the scan and pair view controller.
@interface zt_RFIDReadersListCell : UITableViewCell

- (void)setDeviceInformation : (NSString *)deviceName;

@end

