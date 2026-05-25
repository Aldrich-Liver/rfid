//
//  GetBatteryStatusViewController.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2022-11-03.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "GetBatteryStatusViewController.h"
#import "config.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidBatteryStatusInformation.h>
#import "RfidAppEngine.h"

@interface GetBatteryStatusViewController ()

@end

@implementation GetBatteryStatusViewController


/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ZT_STR_SETTINGS_SECTION_GET_BATTERY_STATUS ];
    [self getBatteryStatus];
    // Do any additional setup after loading the view.
}

// Get battery status
-(void)getBatteryStatus {
    
    
    int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    
    result = [[zt_RfidAppEngine sharedAppEngine] getBatteryStatus:readerId  aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        
        
       // NSString * stringDesignCapacity = [NSString stringWithFormat:@"%@ %@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:15] getBatterStatusValue], @" mAH"];
        NSString * stringStateOfHealth = [NSString stringWithFormat:@"%@%@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:4] getBatterStatusValue], @"%"];
       // NSString * stringVoltage = [NSString stringWithFormat:@"%@ %@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:1] getBatterStatusValue], @"mV"];
      //  NSString * stringCurrent = [NSString stringWithFormat:@"%@ %@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:2] getBatterStatusValue], @"mA"];
        NSString * stringFullyChargeCapacity = [NSString stringWithFormat:@"%@%@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:8] getBatterStatusValue], @"mAh"];
        NSString * stringChargePrecentage = [NSString stringWithFormat:@"%@%@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:3] getBatterStatusValue], @"%"];
       // NSString * stringRemainingCapacity = [NSString stringWithFormat:@"%@ %@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:13] getBatterStatusValue], @"mAh"];
      //  NSString * stringTimeToFullCharge = [NSString stringWithFormat:@"%@ %@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:11] getBatterStatusValue], @"ms"];
        NSString * stringTemperature = [NSString stringWithFormat:@"%@%@", [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:5] getBatterStatusValue], @"°C"];
        
        
        
        //Battery assert info
        self->labelManufactureDate.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:7] getBatterStatusValue];
        self->labelModelNumber.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:6] getBatterStatusValue];
        self->labelBatteryId.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:16] getBatterStatusValue];
        
      //  self->labelDesignCapacity.text = stringDesignCapacity;
      //  self->labelSerialNumber.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:10] getBatterStatusValue];
        
        
        //Battery life statistics
        self->labelStateOfHealth.text = stringStateOfHealth;
        self->labelChargeCycle.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:9] getBatterStatusValue];
        
        
        //Battery status

        self->labelFullyChargeCapacity.text = stringFullyChargeCapacity;
        self->labelChargePrecentage.text = stringChargePrecentage;
        
        //        self->labelVoltage.text = stringVoltage;
        //        self->labelCurrent.text = stringCurrent;
//        self->labelRemainingCapacity.text = stringRemainingCapacity;
        self->labelChargeStatus.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:14] getBatterStatusValue];
//        self->labelTimeToFullCharge.text =stringTimeToFullCharge;
//        self->labelChargingStatus.text = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:12] getBatterStatusValue];
//
        //Battery Temp
        self->labelTemperature.text = stringTemperature;
        
        
        
        
    }
    
    
    
    
}



@end
