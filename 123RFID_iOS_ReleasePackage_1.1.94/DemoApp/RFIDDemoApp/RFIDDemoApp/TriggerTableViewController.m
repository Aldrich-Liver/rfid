//
//  TriggerTableViewController.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-12-13.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "TriggerTableViewController.h"
#import "ui_config.h"
#import "config.h"
#import "UIViewController+ZT_ResponseHandler.h"
#import "RfidAppEngine.h"
#import "RFIDDemoApp-Swift.h"

@interface TriggerTableViewController ()
{
    NSString * triggerUpperText;
    NSString * triggerLowerText;
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE upperTrigger;
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE lowerTrigger;
}
@end

/// Trigger Settings Table View Controller
@implementation TriggerTableViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:TRIGGER_MAPPING_TITLE];
    [[self lowerPickerView] setDelegate:self];
    [[self upperPickerView] setDelegate:self];
    triggersConfig = [[NSMutableArray alloc] initWithObjects:ZT_TRIGGER_MAPPING_RFID, ZT_TRIGGER_MAPPING_DEVICE_SCAN, ZT_TRIGGER_MAPPING_TERMINAL, ZT_TRIGGER_MAPPING_SCAN_NOTIFICATION, ZT_TRIGGER_MAPPING_NO_ACTION, nil];
    [_lowerPickerView reloadAllComponents];
    [_upperPickerView reloadAllComponents];
    
    triggerUpperText = ZT_TRIGGER_MAPPING_EMPTY_STRING;
    triggerLowerText = ZT_TRIGGER_MAPPING_EMPTY_STRING;
    
    ///Apply button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:ZT_TRIGGER_MAPPING_BUTTON_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(applyKeyMapConfiguration:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self displayLoadingView];
}

/// Spinner vew
/// @param isHide Visibility status
-(void)displayLoadingView {
    dispatch_async(dispatch_get_main_queue(),^{
       // [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:ZT_TRIGGER_MAPPING_LOADING withDuration:ZT_TRIGGER_MAPPING_DURATION];
        
       [self showLoadingBarWithDurationWithMessage:ZT_TRIGGER_MAPPING_LOADING time:ZT_TRIGGER_MAPPING_DURATION];
     
    });
}

/// Dealloc
- (void)dealloc{
    if (nil != triggerUpperText)
    {
        [triggerUpperText release];
    }
    if (nil != triggerLowerText)
    {
        [triggerLowerText release];
    }
    [_upperPickerView release];
    [_lowerPickerView release];
    [super dealloc];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupInitialConfiguration];
}

/// Apply button actions
/// @param sender Button reference.
- (void)applyKeyMapConfiguration:(id)sender{
    //[self displayLoadingView];
    [self callTrigger];
}

/// Get the trigger configuration from sled.
- (void) setupInitialConfiguration{
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    result = [[zt_RfidAppEngine sharedAppEngine] getTriggerConfigurationUpperTrigger];
    lowerTrigger = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getSelectedLowerTriggerConfiguration];
    upperTrigger = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getSelectedUpperTriggerConfiguration];
    [self getTriggerIndexby];
}

//MARK:- Picker view delegate

/// Called by the picker view when it needs the number of components.
/// @param thePickerView The picker view requesting the data.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView{
     return ZT_TRIGGER_PICKER_COMPONENTS;
}

/// Called by the picker view when it needs the number of rows for a specified component.
/// @param thePickerView The picker view requesting the data.
/// @param component A zero-indexed number identifying a component of pickerView. Components are numbered left-to-right.
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
     return [triggersConfig count];
}

/// Called by the picker view when it needs the title to use for a given row in a given component.
/// @param pickerView An object representing the picker view requesting the data.
/// @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
/// @param component A zero-indexed number identifying a component of pickerView. Components are numbered left-to-right.
/// @Return The string to use as the title of the indicated component row.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [triggersConfig objectAtIndex:row];
}

/// Called by the picker view when the user selects a row in a component.
/// @param pickerView An object representing the picker view requesting the data.
/// @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
/// @param component A zero-indexed number identifying a component of pickerView. Components are numbered left-to-right.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    long upper = [_upperPickerView selectedRowInComponent:ZT_TRIGGER_PICKER_COMPONENT_INDEX];
    long lower = [_lowerPickerView selectedRowInComponent:ZT_TRIGGER_PICKER_COMPONENT_INDEX];
    triggerLowerText = [self getTextValueForSelection:(int)lower];
    triggerUpperText = [self getTextValueForSelection:(int)upper];
    [self setTriggerValueBy:(int)upper lowerTrigger:(int)lower];
}


/// Get index for selection
/// @param index index of trigger
-(NSString *)getTextValueForSelection:(int)index{
    switch (index) {
        case RFID_Index:
            return ZT_TRIGGER_MAPPING_RFID;
            break;
        case SledScan_Index:
            return ZT_TRIGGER_MAPPING_DEVICE_SCAN;
            break;
        case TerminalScan_Index:
            return ZT_TRIGGER_MAPPING_TERMINAL;
            break;
        case ScanNotification_Index:
            return ZT_TRIGGER_MAPPING_SCAN_NOTIFICATION;
            break;
        case NoAction_Index:
            return ZT_TRIGGER_MAPPING_NO_ACTION;
            break;
        default:
            return ZT_TRIGGER_MAPPING_EMPTY_STRING;
    }
}


/// Set Trigger value by upper and lower for index UI
/// @param upper index of upper value
/// @param lower index of lower value
-(SRFID_ENUM_KEYLAYOUT_TYPE)setTriggerValueBy:(int)upper lowerTrigger:(int)lower{
    
    upperTrigger = [self getEnumFrom:upper];
    lowerTrigger = [self getEnumFrom:lower];
    
    return SRFID_UPPER_TRIGGER_FOR_RFID;
}

/// Get Key layout enum from integer value
/// @param value integer value
-(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)getEnumFrom:(int)value{
    switch (value) {
        case 0:
            return RFID_SCAN;
            break;
        case 1:
            return SLED_SCAN;
            break;
        case 2:
            return TERMINAL_SCAN;
            break;
        case 3:
            return SCAN_NOTIFICATION;
            break;
        case 4:
            return NO_ACTION;
            break;
        default:
            return RFID_SCAN;
            break;
    }
}

/// Get picker index for Key mapping layout
/// @param KeyLayout Key mapping value
-(void)getTriggerIndexby{
    int selectedUpper = RFID_Index;
    int selectedLower = RFID_Index;
    
    selectedUpper = (int)upperTrigger;
    selectedLower = (int)lowerTrigger;
    
    triggerLowerText = [self getTextValueForSelection:(int)selectedLower];
    triggerUpperText = [self getTextValueForSelection:(int)selectedUpper];
    
    [self setPickerBySelectedTriggerValue:selectedUpper lower:selectedLower];

}


/// Set picker value
/// @param upperTrigger Index of upper trigger
/// @param lowerTrigger Index of lower trigger
-(void)setPickerBySelectedTriggerValue:(int)upperTrigger lower:(int)lowerTrigger{
    [_upperPickerView selectRow:upperTrigger inComponent:ZT_TRIGGER_PICKER_COMPONENT_INDEX animated:YES];
    [_lowerPickerView selectRow:lowerTrigger inComponent:ZT_TRIGGER_PICKER_COMPONENT_INDEX animated:YES];
}


/// To call the trigger configuration for setup.
/// @param configuration Configuration value from tableview.
- (void)callTrigger{
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    result = [[zt_RfidAppEngine sharedAppEngine] setTriggerConfigurationUpperTrigger:upperTrigger andLowerTrigger:lowerTrigger];
    
    if (result == SRFID_RESULT_SUCCESS) {
        
        NSString *updatedSetting = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_CONFIG_UPPER_LOWER,triggerUpperText,triggerLowerText];
        
        NSString * successMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_TRIGGER_MAPPING_SELECTED,updatedSetting];
        dispatch_async(dispatch_get_main_queue(),^{
            //[zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:successMessage withDuration:ZT_TRIGGER_MAPPING_ALERT_DURATION];
            
            [self showLoadingBarWithDurationWithMessage:successMessage time:ZT_TRIGGER_MAPPING_ALERT_DURATION];
        });
    }else{
        NSString *updatedSetting = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_CONFIG_UPPER_LOWER_NOT_ALLOWED,triggerUpperText,triggerLowerText];
        
        NSString * failureMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_TRIGGER_MAPPING_SELECTED,updatedSetting];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:failureMessage];
            [self setupInitialConfiguration];
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

@end
