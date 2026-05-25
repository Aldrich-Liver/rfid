//
//  FactoryResetViewController.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2022-04-27.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "FactoryResetViewController.h"
#import "UIColor+DarkModeExtension.h"
#import "RfidAppEngine.h"
#import "config.h"
#import "ui_config.h"

#define RADIO_SELECT_BUTTON     @"radio_button_icon_90"
#define RADIO_UNSELECT_BUTTON     @"radiobuttonoff_68"
#define FACTORY_RESET  @"Factory Reset"
#define REBOOT  @"Device Reset"
#define IOS_VERSION 12.0
#define X_CORDINATE 0
#define Y_CORDINATE 0
#define BORDER_WIDTH 3.0f
#define REBOOTING  @"Reader reset is in progress"
#define RESETTING  @"Factory Reset done device rebooting.."

#define FACTORY_RESET_DESCRIPTION @"Performing factory reset will clear any saved settings and restart the reader. Region needs to be set again."
#define REBOOT_DESCRIPTION @"Device reset will reboot RFDXX device"
#define FACTORY_RESET_HEADING @"Reset to Factory Defaults"
#define REBOOT_HEADING @"Device Reset"
#define DEVICE_RESET @"Device Reset"


@interface FactoryResetViewController ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
}

@end

/// Responsible for Reset and reboot the device
@implementation FactoryResetViewController

#pragma mark - Life Cycle Methods

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];

}


/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If YES, the view is being added to the window using an animation.
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    self.title = FACTORY_RESET;
    labelDescription.text = REBOOT_DESCRIPTION;
    labelTitle.text = REBOOT_HEADING;
    [buttonResetReboot setTitle:DEVICE_RESET forState:UIControlStateNormal];
    activeReader = [[zt_ActiveReader alloc] init];
    viewRebootFactoryResetPopup.layer.borderColor = [UIColor getDarkModeLabelTextColorForRapidRead:self.view.traitCollection].CGColor;
    viewRebootFactoryResetPopup.layer.borderWidth = BORDER_WIDTH;
}

#pragma mark - Change radio button image methods

/// Set  image color
/// @param traitCollection The traits, such as the size class and scale factor.
/// @param radioImageView The radio image view.
/// @param selectedImage The slected image.
-(void)setImageColor:(UITraitCollection *)traitCollection radioImageView:(UIImageView*)radioImageView radioImage:(UIImage*)selectedImage {
    
    UIImage *currentRadioImage = [radioImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(selectedImage.size, NO, currentRadioImage.scale);
    if (@available(iOS IOS_VERSION, *)) {
        if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            [[UIColor whiteColor] set];
        }else{
            [[UIColor blackColor] set];
        }
    } else {
        [[UIColor blackColor] set];
    }
    [currentRadioImage drawInRect:CGRectMake(X_CORDINATE, Y_CORDINATE, selectedImage.size.width, currentRadioImage.size.height)];
    currentRadioImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    radioImageView.image = currentRadioImage;
    
}


/// Set radio image
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)setRadioImage:(UITraitCollection *)traitCollection{
    
    selectedImage = [UIImage imageNamed:RADIO_SELECT_BUTTON];
    unselectedImage = [UIImage imageNamed:RADIO_UNSELECT_BUTTON];
    [self setImageColor:traitCollection radioImageView:imageReset radioImage:selectedImage];
    [self setImageColor:traitCollection radioImageView:imgesetReboot radioImage:unselectedImage];
    
}

#pragma mark - IBAction Methods

/// Factory reset  button action
/// @param sender id The button reference
-(IBAction) toggleUIButtonActionForReset:(id)sender {
    
    [self setRadioButton:NO];

 }

/// Reboot  button  action
/// @param sender id The button reference
-(IBAction) toggleUIButtonActionForReboot:(id)sender {
    
    [self setRadioButton:YES];
       
 }


/// Set radio button image and update button title
/// @param isReboot The status of reboot selection
-(void)setRadioButton:(BOOL)isRebootSelect {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        selectedImage = [UIImage imageNamed:RADIO_SELECT_BUTTON];
        unselectedImage = [UIImage imageNamed:RADIO_UNSELECT_BUTTON];

        if(isRebootSelect){
          imageReset.image = unselectedImage;
          imgesetReboot.image = selectedImage;
          [self setImageColor:self.view.traitCollection radioImageView:imageReset radioImage:unselectedImage];
          [self setImageColor:self.view.traitCollection radioImageView:imgesetReboot radioImage:selectedImage];
          [buttonResetReboot setTitle:DEVICE_RESET forState:UIControlStateNormal];
            labelDescription.text = REBOOT_DESCRIPTION;
            labelTitle.text = REBOOT_HEADING;
            
        }
        else {
            imageReset.image = selectedImage;
            imgesetReboot.image = unselectedImage;
            [self setImageColor:self.view.traitCollection radioImageView:imageReset radioImage:selectedImage];
            [self setImageColor:self.view.traitCollection radioImageView:imgesetReboot radioImage:unselectedImage];
            [buttonResetReboot setTitle:FACTORY_RESET forState:UIControlStateNormal];
            labelDescription.text = FACTORY_RESET_DESCRIPTION;
            labelTitle.text = FACTORY_RESET_HEADING;
        }
        
    });
    
}

/// Reboot and factory reset toggle button handle
/// @param sender The button reference
-(IBAction) toggleUIButtonActionForRebootAndFactoryReset:(id)sender {
    
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        if([buttonResetReboot.titleLabel.text isEqual:REBOOT]) {
            zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
            if ([[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS])
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZR_DEVICE_RESET_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBar.userInteractionEnabled = NO;
                    [labelRebootPopup setText:REBOOTING];
                    [viewRebootFactoryResetPopup setHidden:false];
                });
                // GCD
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    // Compute big gnarly thing that would block for really long time.
                    [self rebootDevice];
                });
            }
            
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationController.navigationBar.userInteractionEnabled = NO;
                [labelRebootPopup setText:RESETTING];
                [viewRebootFactoryResetPopup setHidden:false];
            });
            // GCD
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                // Compute big gnarly thing that would block for really long time.
                [self factoryResetDevice];
            });
        }
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
        });
    }
    
}

-(void) displayErrorAlert:(NSString *)alertMessage
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:alertMessage];
    });
}

/// Reboot the device
-(void)rebootDevice {
    
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        NSString *status = [[NSString alloc] init];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        result = [[zt_RfidAppEngine sharedAppEngine] setReaderReboot:[[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID] status:&status];
        
        if (result != SRFID_RESULT_FAILURE){
            [activeReader setIsActive:NO withID:nil];
            [activeReader setBatchModeStatus:NO];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_ACTIVE_READER_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewRebootFactoryResetPopup setHidden:true];
                self.navigationController.navigationBar.userInteractionEnabled = YES;
                [self.navigationController popViewControllerAnimated:YES];
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME  withMessage:ZT_SCANNER_CANNOT_REBOOT_THE_DEVICE];
                self.navigationController.navigationBar.userInteractionEnabled = YES;
            });
        }
        
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
        });
    }
}


/// Do factory reset the reader.
-(void)factoryResetDevice
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        NSString *status = [[NSString alloc] init];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        result = [[zt_RfidAppEngine sharedAppEngine] setReaderFactoryReset:[[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID] status:&status];
        
        if (result != SRFID_RESULT_FAILURE){
            [activeReader setIsActive:NO withID:nil];
            [activeReader setBatchModeStatus:NO];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_ACTIVE_READER_KEY];
            [[NSUserDefaults standardUserDefaults] setValue:0 forKey:DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
                        
            if ([[local readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8] || [[local readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR])
            {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REGULATORY_CHECKBOX_KEY];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:REGULATORY_CHECKBOX_KEY];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            
            [local SetTheDeviceIsFactoryReseted:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewRebootFactoryResetPopup setHidden:true];
                self.navigationController.navigationBar.userInteractionEnabled = YES;
                [self.navigationController popViewControllerAnimated:YES];
                
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME  withMessage:ZT_SCANNER_CANNOT_REBOOT_THE_DEVICE];
                self.navigationController.navigationBar.userInteractionEnabled = YES;
            });
        }
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
        });
        
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

-(void)showFailurePopup:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    [self setRadioImage:traitCollection];
    viewRebootFactoryResetPopup.layer.borderColor = [UIColor getDarkModeLabelTextColorForRapidRead:self.view.traitCollection].CGColor;
    

}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}


- (void)dealloc {
    [labelTitle release];
    [super dealloc];
}
@end
