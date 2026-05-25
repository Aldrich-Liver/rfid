//
//  AdvancedReaderOptionsTableViewController.h
//  RFIDDemoApp
//
//  Created by Adrian Danushka on 11/17/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/// Responsible for show advanced reader options list (antenna, singulation control, start/stop triggers, tag reporting, save configuration, power management) .
@interface AdvancedReaderOptionsTableViewController : UITableViewController { 
    IBOutlet UIImageView *imgViewPowerManagement;
    BOOL inventoryRequested;
    BOOL isReportTagChanged;
}


@end

NS_ASSUME_NONNULL_END
