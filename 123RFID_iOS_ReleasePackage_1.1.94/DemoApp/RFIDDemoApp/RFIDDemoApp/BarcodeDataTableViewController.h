//
//  BarcodeDataTableViewController.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-08-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"
#import "ScannerEngine.h"
#import "RfidAppEngine.h"
#import "BaseDpoVC.h"

NS_ASSUME_NONNULL_BEGIN

/// Barcode data table view controller
@interface BarcodeDataTableViewController : BaseDpoVC<ScannerEngineDelegate,zt_IRfidAppEngineTriggerEventDelegate,zt_IRadioOperationEngineListener,UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *barcodeList;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
    IBOutlet UITableView *tableViewBarcode;
    BOOL isScannerSupport;
    IBOutlet UIButton *btnScan;
    UIActivityIndicatorView *spinner;
    IBOutlet UIButton *btnTrigPull;
    int timeout;
    IBOutlet UIButton *btnBatchRequest;
    
}

@end

NS_ASSUME_NONNULL_END
