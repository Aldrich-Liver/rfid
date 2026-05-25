//
//  BeeperViewController.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-11-22.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BeeperViewController : UITableViewController{
    int scannerID;
    BOOL settingsRetrieved;
    BOOL didStartDataRetrieving;
    UIAlertController *alertController;
    zt_AlertView *activityView;
}

@end

NS_ASSUME_NONNULL_END
