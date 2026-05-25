//
//  ProClipSettingViewController.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2022-10-20.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "ProClipSettingViewController.h"

#import "ProClipSettingViewController.h"
#import "FactoryResetViewController.h"
#import "UIColor+DarkModeExtension.h"
#import "RfidAppEngine.h"
#import "config.h"
#import "ui_config.h"
#import "RFIDDemoApp-Swift.h"

#define  MFI_USB_MODE         2356
#define  CHARGE_TERMINAL      234

#define SUCCESS_MESAGE_USB_MFI @"Successfully enable the USB MFI mode"
#define SUCCESS_MESAGE_TERMINAL_CHARGING @"Successfully enable the Terminal Charging"

#define CHECK_IMAGE_NAME @"check_box_48dp"
#define UN_CHECK_IMAGE_NAME @"un_check_box_48dp"



@interface ProClipSettingViewController ()

@end

@implementation ProClipSettingViewController


/// /// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ZT_STR_SETTINGS_SECTION_PRO_CLIP ];

}


/// Vew did appear
/// @param animated animated
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self displayLoadingView:@"Status Loading .."];
    [self buttonStatusUiUpdateForTerminalStatus];
}


/// Button status ui update for terminal status
-(void)buttonStatusUiUpdateForTerminalStatus
{
    [[zt_RfidAppEngine sharedAppEngine]requestChargeTerminalStatus];
    BOOL statusTerminal =  [zt_RfidAppEngine sharedAppEngine].statusOfChargeTerminal;
  

    if(statusTerminal) {
        NSLog(@"statusTerminal :Enabled.");
        dispatch_async(dispatch_get_main_queue(), ^{
       
            self.lbStatus.text = @"Status: Enabled";
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:CHECK_IMAGE_NAME] forState:UIControlStateNormal];
                [self.btnCheckBox layoutIfNeeded];
            }];
            [self.btnCheckBox setSelected:NO];
         
        });
    }
    else {
        NSLog(@"statusTerminal : Disabled.");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.lbStatus.text = @"Status: Disabled";
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:UN_CHECK_IMAGE_NAME] forState:UIControlStateNormal];
                    [self.btnCheckBox layoutIfNeeded];
                }];
            [self.btnCheckBox setSelected:YES];
        });
    }
}



/// Check box tapped
/// @param sender sender
- (IBAction)checkboxTapped:(UIButton *)sender {
    
    if (sender.selected) {
        NSLog(@"Checkbox is checked");
        [self displayLoadingView:@"Status Applying .."];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        result = [[zt_RfidAppEngine sharedAppEngine]requestChargeTerminalStatusEnable:YES];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:CHECK_IMAGE_NAME] forState:UIControlStateNormal];
                [self.btnCheckBox layoutIfNeeded];
            }];
            [self.btnCheckBox setSelected:NO];
            self.lbStatus.text = @"Status: Enable";
        }else{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed enable charge terminal"];
        }

     
    } else {
        NSLog(@"Checkbox is unchecked");
        [self displayLoadingView:@"Status Applying .."];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        result = [[zt_RfidAppEngine sharedAppEngine]requestChargeTerminalStatusEnable:NO];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:UN_CHECK_IMAGE_NAME] forState:UIControlStateNormal];
                    [self.btnCheckBox layoutIfNeeded];
                }];
            [self.btnCheckBox setSelected:YES];
            self.lbStatus.text = @"Status: Disable";
        }else{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed disable charge terminal"];
        }
    }
    
}


/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae{
    UIAlertController * alert = [UIAlertController
                    alertControllerWithTitle:title
                                     message:messgae
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                        actionWithTitle:OK
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle ok action
                                }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


/// Spinner vew
/// @param isHide Visibility status
-(void)displayLoadingView:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(),^{

       [self showLoadingBarWithDurationWithMessage:message time:1];
     
    });
}

@end
