//
//  WIFIStatusViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 31/05/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "WIFIStatusViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "RFIDDemoApp-Swift.h"
#import "WIFIStatusTableViewCell.h"
#import "AdminLoginVC.h"
#import "AlertView.h"
#import "MBProgressHUD.h"

#define WIFI_ENABLE_TEXT                   @"ENABLE"
#define WIFI_DISABLE_TEXT                  @"DISABLE"
#define ZT_CELL_ID_WIFI_STATUS             @"ID_WIFI_STATUS_CELL"

@interface WIFIStatusViewController ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    NSString * wifiStatus;
    NSMutableDictionary * statusDictionary;
    NSTimer * delayTimer;
    BOOL activityLoader;
    zt_AlertView *activityView;
}
@end

@implementation WIFIStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:WIFI_STATUS_TITLE];
    
    //[self.switchEnableWifi addTarget:self action:@selector(enableWifiApiCall:) forControlEvents:UIControlEventValueChanged];
    statusDictionary = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view.
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != _wifidetails_table)
    {
        [_wifidetails_table release];
    }
  
    [super dealloc];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    //activityLoader = NO;
    [self getWlanStatusApiCall];
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (nil != delayTimer)
    {
        delayTimer = nil;
        [delayTimer invalidate];
    }
}

/// Get Wlan Status
-(void)getWlanStatusApiCall
{
//    if (!activityLoader)
//    {
//        dispatch_async(dispatch_get_main_queue(),^{
//            [activityView showActivity:self.view];
//        });
//    }
    
    int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    srfidGetWifiStatusInfo *wifiStatusInfo = [[[srfidGetWifiStatusInfo alloc] init] autorelease];
    
    result = [[zt_RfidAppEngine sharedAppEngine] getWifiStatus:readerId wifiStatusInfo:&wifiStatusInfo status:&status];
    if (result == SRFID_RESULT_SUCCESS)
    {
        statusDictionary = [wifiStatusInfo getStatusDictionary];
        
        if ([[[statusDictionary objectForKey:@"wifi"]lowercaseString]  hasPrefix: @"enable"]){
            wifiStatus = [NSString stringWithFormat:@"%@",[statusDictionary objectForKey:@"wifi"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //[_switchEnableWifi setOn:YES];
               // [self hideLoadingView];
                [_wifidetails_table reloadData];
            });
            //activityLoader = NO;
            
        }else if ([[[statusDictionary objectForKey:@"wifi"]lowercaseString]  hasPrefix: @"disable"]){
            wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
            //activityLoader = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
               // [_switchEnableWifi setOn:NO];
                [_wifidetails_table reloadData];
                //[self hideLoadingView];
            });
        }

    }
    else if (result == SRFID_RESULT_RESPONSE_ERROR)
    {
        if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
        {
            [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
            wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^{
            //[self hideLoadingView];
            [self showFailurePopup:@"Wifi status failed"];
        });
        //activityLoader = NO;
        wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
    }
}
/*
/// Enable wifi
/// @param sender The sender, switch status
- (void) enableWifiApiCall:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO) {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        BOOL statusOfTheSwitch = NO;
        if ([sender isOn]){
            statusOfTheSwitch = YES;
        }else{
            statusOfTheSwitch = NO;
        }
        
        if (!activityLoader)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showLoadingBarWithMessage:ZT_LOADING_STRING];
            });
            activityLoader = YES;
        }
       
        result = [[zt_RfidAppEngine sharedAppEngine] setWifiEnable:readerId wifiEnable:statusOfTheSwitch status:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if (statusOfTheSwitch == YES)
            {
                wifiStatus = [NSString stringWithFormat:WIFI_ENABLE_TEXT];
                [self getWlanStatusApiCall];
            }else
            {
                wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    delayTimer = [NSTimer scheduledTimerWithTimeInterval:8.0
                                                              target:self
                                                            selector:@selector(getWlanStatusApiCall)
                                                            userInfo:nil
                                                             repeats:NO];
                });
            }
            
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self hideLoadingView];
                activityLoader = NO;
            });
            [self showPopupForWlanEnableAndDisableSuccess:statusOfTheSwitch successStatus:NO];
        }
    }else
    {
        [_switchEnableWifi setOn:NO];
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}
*/
#pragma mark - Method
///// Show alert view with given message
///// @param message The message
//- (void)showPopup:(NSString *)message
//{
//    [self showOnlyMessageWithDurationWithMessage:message time:ZT_MULTITAG_ALERTVIEW_WAITING_TIME];
//}

-(void)showFailurePopup:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

///// Show popup for wlan enable and disable success
///// @param switchStatus The status of the switch,if its true wifi is enable
///// @param statusOfSuccess The status of response
//-(void)showPopupForWlanEnableAndDisableSuccess:(BOOL)switchStatus successStatus:(BOOL)statusOfSuccess{
//
//    if (!statusOfSuccess){
//        if (switchStatus){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showPopup:@"WiFi Enable Fail"];
//            });
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showPopup:@"WiFi Disable Fail"];
//            });
//        }
//    }
//}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


/// Returns the number of rows (table cells) in a specified section.
/// @param tableView An object representing the table view requesting this information.
/// @param section An index number that identifies a section of the table. Table views in a plain style have a section index of zero.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return statusDictionary.count;
 
}

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
}
/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WIFIStatusTableViewCell *status_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_WIFI_STATUS forIndexPath:indexPath];
    
    if (status_cell == nil)
    {
        status_cell = [[WIFIStatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_WIFI_STATUS];
    }
    
    NSArray *keysArray =  [statusDictionary allKeys];
    NSArray *valuesArray = [statusDictionary allValues];
    
    [status_cell.labelKey setText:[[keysArray objectAtIndex:indexPath.row]capitalizedString]];
    [status_cell.labelValue setText:[valuesArray objectAtIndex:indexPath.row]];

    status_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //[status_cell darkModeCheck:self.view.traitCollection];
    return status_cell;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.wifidetails_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self.wifidetails_table reloadData];
}

@end
