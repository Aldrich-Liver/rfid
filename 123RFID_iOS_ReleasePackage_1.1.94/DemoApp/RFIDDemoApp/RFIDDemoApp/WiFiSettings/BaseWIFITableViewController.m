//
//  BaseWIFITableViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 01/06/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "BaseWIFITableViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "WIFIStatusViewController.h"
#import "WiFiSettingsViewControler.h"
#import "RFIDDemoApp-Swift.h"

@interface BaseWIFITableViewController ()

@end

@implementation BaseWIFITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:WIFI_SETTINGS_TITLE];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

/// Tells the delegate a row is selected.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *viewController = nil;
    WIFIStatusViewController *wifiStatusVC = nil;
    WiFiSettingsViewController *wifiSettingsVC = nil;
    
    switch (indexPath.row) {
           case 0:
            inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
            if (inventoryRequested == YES) {
                [self showWarning:@"WiFi Status is not allowed while inventory is running"];
                
            } else {
                wifiStatusVC = (WIFIStatusViewController*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:WIFI_STATUS_BOARD_ID];
                      viewController = wifiStatusVC;
            }
            break;
           case 1:
            wifiSettingsVC = (WiFiSettingsViewController*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:WIFI_SETTINGS_BOARD_ID];
                  viewController = wifiSettingsVC;
            break;
//            case 2:
//            wifiCertificatesVC = (WIFICertificatesViewController*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:CERTIFICATES_BOARD_ID];
//               viewController = wifiCertificatesVC;
//            break;
           default :
               NSLog(@"Invalid row" );
       }
    
        if (nil != viewController)
        {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    
   }

- (void)showWarning:(NSString *)message
{
    [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
    
}
  


@end
