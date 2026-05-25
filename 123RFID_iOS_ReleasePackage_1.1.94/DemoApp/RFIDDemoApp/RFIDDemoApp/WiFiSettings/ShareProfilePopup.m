//
//  ShareProfilePopup.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 13/03/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "ShareProfilePopup.h"
#import "UIColor+DarkModeExtension.h"
#import "RFIDDemoApp-Swift.h"
#import "ScannerEngine.h"
#import "ui_config.h"
#import <ZebraScannerFramework/SbtScannerInfo.h>
#import "AlertView.h"
#define MSG_PROFILE_SHARING @"Would you like to share access to SSID with your RFID reader?"

@interface ShareProfilePopup ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
    int enterEvent;
    UIAlertView *alert;
}
@end

@implementation ShareProfilePopup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    shareProfileView.layer.cornerRadius = 20;
    shareProfileView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    m_LastReaderInfo = [[srfidReaderInfo alloc] init];
    activityView = [[zt_AlertView alloc] init];
    enterEvent = 0;
    [self initialConfiguration];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Register for wlan scan event
    [[zt_RfidAppEngine sharedAppEngine] addWlanConnectEventDelegate:self];
    [[zt_RfidAppEngine sharedAppEngine] addWlanOperationFailedEventDelegate:self];
}

- (void)initialConfiguration
{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    NSString * descriptionStr = [MSG_PROFILE_SHARING stringByReplacingOccurrencesOfString:@"SSID" withString:self.profileName];
    descriptionStr = [descriptionStr stringByReplacingOccurrencesOfString:@"RFID" withString:[scannerInfo getScannerName]];
    [descriptionLabel setText:descriptionStr];
}
-(IBAction)shareProfileAction:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        NSString * profile = [NSString stringWithFormat:@"\"%@\"", self.profileName];
        result = [[zt_RfidAppEngine sharedAppEngine] connectWlanProfile:readerId ssidWlan:profile aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            enterEvent = 1;
            [activityView showActivity:self.view];
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Share WLAN Profile Failed"];
            });
        }
    }
    else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}
-(IBAction)deleteProfileAction:(id)sender
{
    [self deleteWlanProfileApiCall:self.profileName];
}

/// Delete wlan profile
/// - Parameters:
///   - wlanSsid: The wlan profile
///   - wlanPassword: The password
-(void)deleteWlanProfileApiCall:(NSString*)wlanSsid {
    
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        NSString * profile = [NSString stringWithFormat:@"\"%@\"", wlanSsid];
        
        result = [[zt_RfidAppEngine sharedAppEngine] removeWlanProfile:readerId ssidWlan:profile aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            [self saveProfile];
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Delete WLAN Profile Failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)saveProfile
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveWlanProfile:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            [self dismissViewControllerAnimated:YES completion:^{
                [self.sharePopupDelegate reloadTableDataAfterDelete];
            }];
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Delete WLAN Profile Failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)closeShareProfileView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)showFailurePopup:(NSString *)message
{
    if ([self doesAlertViewExist] == NO) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:message
                                                            delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL) doesAlertViewExist {
    if ([[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]])
    {
        return NO;//AlertView does not exist on current window
    }
    return YES;//AlertView exist on current window
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeWlanConnectEventDelegate:self];
    [[zt_RfidAppEngine sharedAppEngine] removeWlanOperationFailedEventDelegate:self];
}

#pragma mark - Event zt_IRfidAppEngineWlanConnectEventDelegate
- (BOOL)onNewWlanConnectEvent:(NSString*)connectEvent
{
    if ([connectEvent isEqualToString:ZT_WIFI_CONNECT_EVENT])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView hideActivity];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.sharePopupDelegate reloadTableDataAfterDelete];
            }];
        });
    }
    return TRUE;
}

#pragma mark - Event zt_IRfidAppEngineWlanOperationFailedEventDelegate
- (BOOL)onNewWlanOperationFailedEvent:(NSString*)operationFailedEvent
{
    if ([operationFailedEvent isEqualToString:ZT_WIFI_OPERATION_FAILED_EVENT])
    {
        if (enterEvent == 1) {
            enterEvent = enterEvent + 1;
            [self showFailurePopup:@"Connect WLAN Profile Failed"];
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self dismissViewControllerAnimated:YES completion:nil];
//                [self dismissViewControllerAnimated:YES completion:^{
//                    [self.sharePopupDelegate reloadTableDataAfterDelete];
//                }];
            });
        }
    }
    return TRUE;
}
@end
