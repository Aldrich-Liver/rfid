//
//  ScannerDetailsVC.m
//  RFIDDemoApp
//
//  Created by Kasun Adhikari on 2021-11-17.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.


#import "ScannerDetailsVC.h"
#import "config.h"
#import "RFIDDemoAppDelegate.h"
#import "ui_config.h"

/// Scanner Details view controller
@interface ScannerDetailsVC ()

@end

@implementation ScannerDetailsVC

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    activityView = [[zt_AlertView alloc]init];
    
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Hide the standard back button
    [self.navigationItem setHidesBackButton:YES];
    
    // Add the custom back button
    backBarButton = [[UIBarButtonItem alloc] initWithTitle:SCANNER_ASSET_INFORMATION_CANCEL_TEXT style:UIBarButtonItemStylePlain target:self action:@selector(confirmCancel)];
    self.navigationItem.leftBarButtonItem =backBarButton;
    
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void) viewWillDisappear:(BOOL)animated
{
    [self operationComplete];
}

/// Complete operation
- (void) operationComplete
{
    /**
    Restore the standard back button
    **/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationItem.hidesBackButton) {
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:NO];
        }
    });
    

}

/// Cancel operation confirmation
- (void)confirmCancel
{
    zt_RfidDemoAppDelegate *appDelegate = (zt_RfidDemoAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (alertViewController) {
        if (appDelegate.window.rootViewController.presentedViewController != nil)
        {
            [alertViewController dismissViewControllerAnimated:FALSE completion:nil];

        }
    }
    if (didStartDataRetrieving) {
        alertViewController = [UIAlertController
                        alertControllerWithTitle:ZT_RFID_APP_NAME
                                         message:ZT_RFID_SURE_WANT_GO_BACK
                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction
                            actionWithTitle:ACTIVE_SCANNER_DISCONNECT_ALERT_CANCEL
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle cancel action
                                    }];
        UIAlertAction* continueButton = [UIAlertAction
                            actionWithTitle:ACTIVE_SCANNER_DISCONNECT_ALERT_CONTINUE
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle continue action

            self->didStartDataRetrieving = NO;
            [self.navigationController popViewControllerAnimated:YES];
                                    }];
        [alertViewController addAction:cancelButton];
        [alertViewController addAction:continueButton];
        [self presentViewController:alertViewController animated:YES completion:nil];
    } else {
        didStartDataRetrieving = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SCANNER_ASSET_INFORMATION_TABLE_ZERO_ROW;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SCANNER_ASSET_INFORMATION_TABLE_ZERO_ROW;
}

@end
