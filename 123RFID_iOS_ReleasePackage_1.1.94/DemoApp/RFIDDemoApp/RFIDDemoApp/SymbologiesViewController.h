//
//  SymbologiesViewController.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchTableViewCell.h"
#import "AlertView.h"

NS_ASSUME_NONNULL_BEGIN

/// Symbologoes table view controller
@interface SymbologiesViewController : UITableViewController <ISwitchTableViewCellProtocol>{
    NSMutableArray *symbologies;
    int scannerID;
    BOOL symbologiesRetrieved;
    zt_AlertView *activityView;
    BOOL didStartDataRetrieving;
    UIAlertController *alert;
    UIBarButtonItem *backBarButton;
}

@end

NS_ASSUME_NONNULL_END
