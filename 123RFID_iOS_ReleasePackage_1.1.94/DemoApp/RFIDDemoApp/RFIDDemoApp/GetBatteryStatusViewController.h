//
//  GetBatteryStatusViewController.h
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2022-11-03.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetBatteryStatusViewController : UITableViewController
{
    IBOutlet UILabel *labelManufactureDate;
    IBOutlet UILabel *labelSerialNumber;
    IBOutlet UILabel *labelModelNumber;
    IBOutlet UILabel *labelBatteryId;
    IBOutlet UILabel *labelDesignCapacity;
    
    IBOutlet UILabel *labelStateOfHealth;
    IBOutlet UILabel *labelChargeCycle;
    
    IBOutlet UILabel *labelVoltage;
    IBOutlet UILabel *labelCurrent;
    IBOutlet UILabel *labelFullyChargeCapacity;
    IBOutlet UILabel *labelChargePrecentage;
    IBOutlet UILabel *labelRemainingCapacity;
    IBOutlet UILabel *labelChargeStatus;
    IBOutlet UILabel *labelTimeToFullCharge;
    IBOutlet UILabel *labelChargingStatus;
    
    IBOutlet UILabel *labelTemperature;
}
@end

NS_ASSUME_NONNULL_END
