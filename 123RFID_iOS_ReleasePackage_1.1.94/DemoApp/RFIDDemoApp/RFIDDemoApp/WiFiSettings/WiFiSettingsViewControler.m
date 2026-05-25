//
//  WiFiSettingsViewControler.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2023-06-30.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "WiFiSettingsViewControler.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "SavedNetworksCell.h"
#import "RFIDDemoApp-Swift.h"
#import <ZebraRfidSdkFramework/RfidWlanProfile.h>
#import <ZebraRfidSdkFramework/RfidWlanCertificates.h>
#import "ShareProfilePopup.h"
#import "ConnectedNetworkCell.h"
#import "AlertView.h"
#import "MBProgressHUD.h"

#define ZT_CELL_ID_SAVED_NETWORKS                   @"ID_SAVED_NETWORKS_CELL"
#define ZT_CELL_ID_CONNECTED_NETWORKS               @"ID_CONNECTED_NETWORKS_CELL"

#define ZT_CELL_SAVED_NETWORKS_HEIGHT             66
#define ZT_CELL_AVAILABLE_NETWORKS_HEIGHT         50
#define WIFI_ENABLE_TEXT                   @"ENABLE"
#define WIFI_DISABLE_TEXT                  @"DISABLE"
#define WIFI_DEFAULTS_KEY                  @"ScanAPIDefaults"
#define WIFI_DEFAULTS_VALUE                @"Manual"
#define WIFI_SCAN_ICON @"rotate_icon"
#define MSG_PLZ_ENTER_PASSWORD @"Please enter the password"
#define MSG_ACTION_ADD @"Connect"
#define MSG_ACTION_CANCEL @"Cancel"
#define MSG_PLACEHOLDER_PASSWORD @"Password";
#define MSG_INVALID_PASSWORD @"Invalid Password"
#define MSG_PASSWORD_VALIDATION @"Minimum length of a WLAN password is eight."
#define MSG_OK @"OK"
#define MSG_TITLE_DELETE_PROFILE @"Share WIFI Access with connected reader"
#define MSG_DETAIL_DELETE_PROFILE_PART_01 @"Would you like to share access to"
#define MSG_DETAIL_DELETE_PROFILE_PART_02 @"with your"
#define MSG_DETAIL_DELETE_PROFILE_PART_03 @"reader?"
#define MSG_ACTION_SHARE_ACCESS @"Share Access"
#define MSG_ACTION_DELETE_PROFILE @"Delete Profile"
#define MSG_OPERATION_FAILED @"Operation Failed"


@interface WiFiSettingsViewController () {
    IBOutlet UILabel * labelEnableWifi;
    IBOutlet UILabel * labelSavedNetworks;
    IBOutlet UILabel * labelAvailableNetworks;
    IBOutlet UIImageView * sampleRotate;
    NSString * wifiStatus;
    NSTimer * delayTimer;
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    BOOL activityLoader;
    BOOL isDisconnectCalled;
    NSMutableArray * sectionTitleArray;
    zt_AlertView *activityView;
}

@end

/// WiFi Settings view controller
@implementation WiFiSettingsViewController

#pragma mark - Life cycle
/// Called after the controller's view is loaded into memory.
-(void)viewDidLoad
{
    [self setTitle:WIFI_SETTINGS_TITLE];
    [self.available_networks_table setDelegate:self];
    [self.available_networks_table setDataSource:self];
    [self buttonDisable];
    isDisconnectCalled = NO;
    availableNetworks_listObject = [[srfidWlanScanList alloc] init];
    activityView = [[zt_AlertView alloc] init];
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != connected_networks_list)
    {
        [connected_networks_list release];
    }
    if (nil != saved_networks_list)
    {
        [saved_networks_list release];
    }
    if (nil != available_networks_list)
    {
        [available_networks_list release];
    }
    if (nil != self.available_networks_table)
    {
        [self.available_networks_table release];
    }
  
    [super dealloc];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    buttonScanWifi = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonScanWifi setUserInteractionEnabled:NO];
    sectionTitleArray =  [[NSMutableArray alloc]init];
    [sectionTitleArray addObject:@"Connected Network"];
    [sectionTitleArray addObject:@"Saved Networks"];
    [sectionTitleArray addObject:@"Available Networks"];
   
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
    activityLoader = NO;
    
    // Register for wlan scan event
    [[zt_RfidAppEngine sharedAppEngine] addWlanScanEventDelegate:self];
    [[zt_RfidAppEngine sharedAppEngine] addWlanDisConnectEventDelegate:self];
    //[[zt_RfidAppEngine sharedAppEngine] addWlanOperationFailedEventDelegate:self];
    
    [self scanWIFIApiCall];
    
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeWlanScanEventDelegate:self];
    [[zt_RfidAppEngine sharedAppEngine] removeWlanDisConnectEventDelegate:self];
    
    if (nil != delayTimer)
    {
        delayTimer = nil;
        [delayTimer invalidate];
    }
}

#pragma mark - Event AddprofilePopupDelegate

-(void)reloadTableData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getWlanProfileListApiCall];
    });
}

#pragma mark - Event ShareProfilePopupDelegate

-(void)reloadTableDataAfterDelete
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getWlanProfileListApiCall];
    });
}
#pragma mark - Event zt_IRfidAppEngineWlanScanEventDelegate

- (BOOL)onNewWlanScanEvent:(NSString*)scanEvent
{
    NSString * event = [[NSUserDefaults standardUserDefaults] objectForKey:WIFI_DEFAULTS_KEY];
    
    if ([event isEqualToString:WIFI_DEFAULTS_VALUE])
    {
        if ([scanEvent isEqualToString:ZT_WIFI_STOP_EVENT])
        {
            [available_networks_list removeAllObjects];
            available_networks_list = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getWIFIListArray];
            
            if (available_networks_list != nil || available_networks_list.count != 0)
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activityLoader = NO;
                    [activityView hideActivity];
                    [self.available_networks_table reloadData];
                });
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:WIFI_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:WIFI_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getWlanProfileListApiCall];
            });
            
            delayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(buttonEnable)
                                                    userInfo:nil
                                                     repeats:NO];
        }
    }
    return TRUE;
    
}

#pragma mark - Button Action

/// Button action for the scan wifi.
/// - Parameter sender: The sender.
- (IBAction)scanWifiAction:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO) {
        activityLoader = NO;
        [self buttonDisable];
        [available_networks_list removeAllObjects];
        [self scanWIFIApiCall];
    }else{
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}


/// Scan wifi button press in table view section
-(void)scanWIFIButtonPress {
    
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO) {
        activityLoader = NO;
        [self buttonDisable];
        [available_networks_list removeAllObjects];
        [self scanWIFIApiCall];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self.available_networks_table reloadData];
        });
    }else{
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}


#pragma mark - API Call
/// Scan wifi method to get the list of wifi networks.
- (void)scanWIFIApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO) {
        [[NSUserDefaults standardUserDefaults] setObject:WIFI_DEFAULTS_VALUE forKey:WIFI_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        [self buttonEnable];
        if (!activityLoader)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView showActivity:self.view];
            });
        }
        result = [[zt_RfidAppEngine sharedAppEngine] getWlanScanList:readerId status:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            NSLog(@"Success");
        }
        else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activityLoader = NO;
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }
        else
        {
            NSLog(@"Failure");
            dispatch_async(dispatch_get_main_queue(),^{
                activityLoader = NO;
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
        
        [buttonScanWifi setUserInteractionEnabled:YES];
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

/*
/// Get Wlan Status
-(void)getWlanStatusApiCall
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self showLoadingBarWithMessage:ZT_LOADING_STRING];
    });
    
    int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    srfidGetWifiStatusInfo *wifiStatusInfo = [[[srfidGetWifiStatusInfo alloc] init] autorelease];
    NSMutableDictionary * statusDictionary = [[NSMutableDictionary alloc] init];
    
    result = [[zt_RfidAppEngine sharedAppEngine] getWifiStatus:readerId wifiStatusInfo:&wifiStatusInfo status:&status];
    if (result == SRFID_RESULT_SUCCESS)
    {
        statusDictionary = [wifiStatusInfo getStatusDictionary];
        
        if ([[[statusDictionary objectForKey:@"wifi"]lowercaseString]  hasPrefix: @"enable"]){
            wifiStatus = [NSString stringWithFormat:@"%@",[statusDictionary objectForKey:@"wifi"]];
            activityLoader = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                delayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(scanWIFIApiCall)
                                                        userInfo:nil
                                                         repeats:NO];
            });
            
        }else if ([[[statusDictionary objectForKey:@"wifi"]lowercaseString]  hasPrefix: @"disable"]){
            wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                activityLoader = NO;
                [self hideLoadingView];
                
            });
        }

    }else
    {
        dispatch_async(dispatch_get_main_queue(),^{
            activityLoader = NO;
            [self hideLoadingView];
            [self showFailurePopup:@"Wifi status failed"];
        });
        wifiStatus = [NSString stringWithFormat:WIFI_DISABLE_TEXT];
    }
}
*/

/// Get wlan profile list api call
-(void)getWlanProfileListApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        saved_networks_list= [[NSMutableArray alloc]init];
        NSMutableArray* wlanProfileList= [[NSMutableArray alloc]init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] getWlanProfileList:readerId wlanProfileList:&wlanProfileList status:&status];
        
        saved_networks_list = [[NSMutableArray alloc]init];
        connected_networks_list = [[NSMutableArray alloc]init];

        if (result == SRFID_RESULT_SUCCESS)
        {
            if(wlanProfileList.count > 0){
                [saved_networks_list removeAllObjects];
                [connected_networks_list removeAllObjects];
                for (srfidWlanProfile* key in wlanProfileList) {
                    
                    if ([[key getWlanState] isEqualToString:@"connect"]) {
                        if (![[key getWlanSSID] isEqual:EMPTY_STRING]) {
                            [connected_networks_list addObject:[key getWlanSSID]];
                        }
                    }else
                    {
                        if (![[key getWlanSSID] isEqual:EMPTY_STRING]) {
                            [saved_networks_list addObject:[key getWlanSSID]];
                        }
                    }
                }
            }else{
                [saved_networks_list removeAllObjects];
                [connected_networks_list removeAllObjects];
            }
            [self.available_networks_table reloadData];
            
        }else if(result == SRFID_RESULT_RESPONSE_TIMEOUT)
        {
            if(wlanProfileList.count == 0)
            {
                [saved_networks_list removeAllObjects];
                [self.available_networks_table reloadData];
            }
        }
        else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activityLoader = NO;
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                activityLoader = NO;
                [self showFailurePopup:@"Get profiles list failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

/// Get wlan profile list for add profile api call
-(void)getWlanProfileListForAddDeleteProfileApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        saved_networks_list= [[NSMutableArray alloc]init];
        NSMutableArray* wlanProfileList= [[NSMutableArray alloc]init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] getWlanProfileList:readerId wlanProfileList:&wlanProfileList status:&status];
        
        saved_networks_list= [[NSMutableArray alloc]init];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if(wlanProfileList.count > 0){
                [saved_networks_list removeAllObjects];
                [connected_networks_list removeAllObjects];
                for (srfidWlanProfile* key in wlanProfileList) {
                    
                    if ([[key getWlanState] isEqualToString:@"connect"]) {
                        if (![[key getWlanSSID] isEqual:EMPTY_STRING]) {
                            [connected_networks_list addObject:[key getWlanSSID]];
                        }
                    }else
                    {
                        if (![[key getWlanSSID] isEqual:EMPTY_STRING]) {
                            [saved_networks_list addObject:[key getWlanSSID]];
                        }
                    }
                }
            }else{
                [saved_networks_list removeAllObjects];
                [connected_networks_list removeAllObjects];
            }
            [self.available_networks_table reloadData];
            
        }
        else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                    [self.available_networks_table reloadData];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Add/Delete wifi failed"];
                [self.available_networks_table reloadData];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

-(void)removeProfileAction
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Do you want to Disconnect?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disconnectAPICall];
                }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:cancel];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

-(void)disconnectAPICall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        isDisconnectCalled = YES;
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] disconnectWlanProfile:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView showActivity:self.view];
            });
        }
        else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activityLoader = NO;
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                activityLoader = NO;
                [self showFailurePopup:@"Disconnect wifi failed"];
            });
        }
    }
    else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

#pragma mark - Method
/// Show alert view with given message
/// @param message The message
- (void)showPopup:(NSString *)message
{
    [self showOnlyMessageWithDurationWithMessage:message time:ZT_MULTITAG_ALERTVIEW_WAITING_TIME];
}

-(void)showFailurePopup:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

/// Enable the buttons
- (void)buttonEnable
{
    buttonScanWifi.enabled = true;
    buttonScanWifi.userInteractionEnabled = true;
}

/// Disable the buttons
- (void)buttonDisable
{
    buttonScanWifi.enabled = false;
    buttonScanWifi.userInteractionEnabled = false;
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


/// Asks the data source for the title of the header of the specified section of the table view.
/// @param tableView The table-view object asking for the title.
/// @param section An index number identifying a section of tableView.
-(NSString * )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return sectionTitleArray[section];
}


/// Returns the number of rows (table cells) in a specified section.
/// @param tableView An object representing the table view requesting this information.
/// @param section An index number that identifies a section of the table. Table views in a plain style have a section index of zero.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return connected_networks_list.count;
            break;
        case 1:
            return saved_networks_list.count;
            break;
        case 2:
            return available_networks_list.count;
            break;
        default:
            return 0;
            break;
    }
 
}

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return ZT_CELL_SAVED_NETWORKS_HEIGHT;
            break;
        case 1:
            return ZT_CELL_SAVED_NETWORKS_HEIGHT;
            break;
        case 2:
            return ZT_CELL_AVAILABLE_NETWORKS_HEIGHT;
            break;
        default:
            return 0;
            break;
    }
}

/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * tableCell = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            ConnectedNetworkCell *connected_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_CONNECTED_NETWORKS forIndexPath:indexPath];
            
            if (connected_cell == nil)
            {
                connected_cell = [[ConnectedNetworkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_CONNECTED_NETWORKS];
            }
        
            if (connected_networks_list.count > 0)
            {
                NSString *ssid =  [NSString stringWithFormat:@"%@", [connected_networks_list objectAtIndex:indexPath.row] ];
                [connected_cell.labelTitle setText:ssid];
            }
            connected_cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [connected_cell.moreOption addTarget:self
                                                         action:@selector(removeProfileAction)
                                               forControlEvents:UIControlEventTouchUpInside];
            tableCell = connected_cell;

        }
            break;
        case 1:
        {
            SavedNetworksCell *saved_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SAVED_NETWORKS forIndexPath:indexPath];
            
            if (saved_cell == nil)
            {
                saved_cell = [[SavedNetworksCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SAVED_NETWORKS];
            }
        
            if (saved_networks_list.count > 0)
            {
                NSString *ssid =  [NSString stringWithFormat:@"%@", [saved_networks_list objectAtIndex:indexPath.row] ];
                [saved_cell.labelTitle setText:ssid];
            }
            saved_cell.lockIcon.hidden = NO;
            saved_cell.cellType = @"saved";
            saved_cell.labelDetail.hidden = NO;
            [saved_cell.bgView setBackgroundColor:[UIColor systemGray6Color]];
            saved_cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [saved_cell darkModeCheck:self.view.traitCollection];
            tableCell = saved_cell;
        }
            break;
        case 2:
        {
            SavedNetworksCell *available_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SAVED_NETWORKS forIndexPath:indexPath];
            
            if (available_cell == nil)
            {
                available_cell = [[SavedNetworksCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SAVED_NETWORKS];
            }
            
            if (available_networks_list.count > 0)
            {
                availableNetworks_listObject = [available_networks_list objectAtIndex:indexPath.row];
                NSString * wifiName = [NSString stringWithFormat:@"%@",[availableNetworks_listObject getWlanSSID]];
                
                NSString * protocol = [NSString stringWithFormat:@"%@",[availableNetworks_listObject getWlanProtocol]];
                [available_cell.labelTitle setText:wifiName];
                
                if ([protocol containsString:@"WPA"]) {
                    available_cell.lockIcon.hidden = NO;
                }else
                {
                    available_cell.lockIcon.hidden = YES;
                }
                
            }
            available_cell.cellType = @"available";
            available_cell.labelDetail.hidden = YES;
            [available_cell.bgView setBackgroundColor:[UIColor whiteColor]];
            available_cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [available_cell darkModeCheck:self.view.traitCollection];
            tableCell = available_cell;
        }
            break;
        default:
            break;
    }
    return tableCell;
}


/// Asks the delegate for a view to display in the header of the specified section of the table view.
/// @param tableView The table view asking for the view.
/// @param section The index number of the section containing the header view.
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
  // [sectionView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    [sectionView setBackgroundColor:[UIColor systemBackgroundColor]];
   UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, tableView.frame.size.width, 25)];
   [sectionLabel setFont:[UIFont boldSystemFontOfSize:15]];
 
   NSString *sectionTitleString =[sectionTitleArray objectAtIndex:section];
   [sectionLabel setText:sectionTitleString];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:17]];
    if (section == 2)
    {
        [buttonScanWifi addTarget:self
                   action:@selector(scanWIFIButtonPress)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *img = [UIImage imageNamed:WIFI_SCAN_ICON];
        [buttonScanWifi setImage:img forState:UIControlStateNormal];
        buttonScanWifi.frame = CGRectMake((tableView.frame.size.width - 50),8, 25, 25.0);
        [sectionView addSubview:buttonScanWifi];
        
        UIView *manualView = [[UIView alloc] initWithFrame:CGRectMake(0,50,tableView.frame.size.width,40)];
        UIImageView *arrow =[[UIImageView alloc] initWithFrame:CGRectMake((tableView.frame.size.width - 50),5,30,30)];
        arrow.image=[UIImage imageNamed:@"right_arrow_gray.png"];
        [manualView addSubview:arrow];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self
                   action:@selector(AddProfileManually:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Add Profile Manually" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.frame = CGRectMake(20, 0, tableView.frame.size.width - 20, 40);
        [manualView addSubview:button];
        [sectionView addSubview:manualView];
    }

   [sectionView addSubview:sectionLabel];
   return sectionView;
}

-(void) AddProfileManually:(UIButton*)sender
{
    AddprofilePopup * addprofile_popup_vc = (AddprofilePopup*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADDPROFILE_POPUP_BOARD_ID];
    [addprofile_popup_vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    addprofile_popup_vc.popupDelegate = self;
    addprofile_popup_vc.popup_type = @"Manual";
    [self presentViewController:addprofile_popup_vc
                       animated:YES
                     completion:nil];
}


/// Asks the delegate for the height to use for the header of a particular section.
/// @param tableView The table view requesting this information.
/// @param section An index number identifying a section of tableView .
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2)
    {
        return 90;
    }else
    {
        return 40;
    }
   
}

/// Tells the delegate a row is selected.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            {
            ShareProfilePopup * shareprofile_popup_vc = (ShareProfilePopup*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:SHAREPROFILE_POPUP_BOARD_ID];
            [shareprofile_popup_vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                shareprofile_popup_vc.profileName = [saved_networks_list objectAtIndex:indexPath.row];
            shareprofile_popup_vc.sharePopupDelegate = self;
            [self presentViewController:shareprofile_popup_vc
                               animated:YES
                             completion:nil];
            }
            break;
        case 2:
            {
            availableNetworks_listObject = [available_networks_list objectAtIndex:indexPath.row];
            if (![[availableNetworks_listObject getWlanProtocol] isEqualToString:@"UNSUPPORTED"])
            {
                AddprofilePopup * addprofile_popup_vc = (AddprofilePopup*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADDPROFILE_POPUP_BOARD_ID];
                addprofile_popup_vc.profile_listObject = availableNetworks_listObject;
                [addprofile_popup_vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                addprofile_popup_vc.popup_type = @"Default";
                addprofile_popup_vc.popupDelegate = self;
                [self presentViewController:addprofile_popup_vc
                                   animated:YES
                                 completion:nil];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showPopup:@"Unsupported Profile"];
                });
            }
            }
            break;
        default:
            break;
    }
}

#pragma mark - Event zt_IRfidAppEngineWlanDisConnectEventDelegate
- (BOOL)onNewWlanDisConnectEvent:(NSString*)disconnectEvent
{
    if ([disconnectEvent isEqualToString:ZT_WIFI_DISCONNECT_EVENT])
    {
        if (isDisconnectCalled) {
            [activityView hideActivity];
            isDisconnectCalled = NO;
            [self getWlanProfileListApiCall];
        }
    }
    return TRUE;
}

//#pragma mark - Event zt_IRfidAppEngineWlanOperationFailedEventDelegate
//- (BOOL)onNewWlanOperationFailedEvent:(NSString*)operationFailedEvent
//{
//    if ([operationFailedEvent isEqualToString:ZT_WIFI_OPERATION_FAILED_EVENT])
//    {
//        [activityView hideActivity];
//        dispatch_async(dispatch_get_main_queue(),^{
//            [self showFailurePopup:@"Disconnect WLAN Profile Failed"];
//        });
//
//    }
//    return TRUE;
//}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.available_networks_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self.available_networks_table reloadData];
}

@end


