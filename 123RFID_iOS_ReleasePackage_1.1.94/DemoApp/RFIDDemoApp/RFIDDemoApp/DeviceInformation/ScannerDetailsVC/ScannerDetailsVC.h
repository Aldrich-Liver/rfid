//
//  ScannerDetailsVC.h
//  RFIDDemoApp
//
//  Created by Kasun Adhikari on 2021-11-17.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.


#import <UIKit/UIKit.h>
#import "AlertView.h"

@interface ScannerDetailsVC : UITableViewController {
    BOOL didStartDataRetrieving;
    UIAlertController *alertViewController;
    zt_AlertView *activityView;
    UIBarButtonItem *backBarButton;
}

// remove cancel button and restore back button
- (void) operationComplete;

@end
