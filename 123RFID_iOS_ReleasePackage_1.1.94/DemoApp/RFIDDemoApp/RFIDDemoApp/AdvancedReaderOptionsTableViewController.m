//
//  AdvancedReaderOptionsTableViewController.m
//  RFIDDemoApp
//
//  Created by Adrian Danushka on 11/17/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "AdvancedReaderOptionsTableViewController.h"
#import "SingulationSettingsVC.h"
#import "ProfilesViewController.h"
#import "AntennaSettingsVC.h"
#import "TriggerSettingsVC.h"
#import "TagReportSettingsVC.h"
#import "SaveSettingsVC.h"
#import "PowerManagementVC.h"
#import "AlertView.h"
#import "UIViewController+ZT_ResponseHandler.h"
#import "config.h"
#import "RFIDDemoApp-Swift.h"

#define DEFAULT_RESPONSE_MESSAGE    @""

@interface AdvancedReaderOptionsTableViewController () {
    NSNumber *m_LoadedViewIndex;
}
@end


/// Responsible for show advanced reader options list (antenna, singulation control, start/stop triggers, tag reporting, save configuration, power management) .
@implementation AdvancedReaderOptionsTableViewController

/* Key to observe to detect change in dynamic power setting (KVO) */
static NSString *kKeyPathDynamicPowerEnable = DYNAMIC_POWER_ENABLE;

#pragma mark - Life cycle methods

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    
    [self setTitle:ZT_STR_SETTINGS_SECTION_ADVANCED_READER_OPTIONS];
    [super viewDidLoad];

}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] addObserver:self forKeyPath:kKeyPathDynamicPowerEnable options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
}


/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void) viewWillDisappear:(BOOL)animated
{
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] removeObserver:self forKeyPath:kKeyPathDynamicPowerEnable];
}


/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    BOOL locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    BOOL multitag_locate_Requested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    NSString * activeProfile = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY];
    
    if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO && [activeProfile intValue] == 0)
    {
        local.currentDpoEnable = 0;
        sled.currentDpoEnable = 0;
        [self saveDynamicPower];
    }
    
    [self refreshPowerManagementTableviewCellImage];
    isReportTagChanged = [[NSUserDefaults standardUserDefaults] boolForKey:TAGREPORT_DEFAULTS_KEY];
   
    
    if (m_LoadedViewIndex != nil) {
        
        switch ([m_LoadedViewIndex intValue])
        {
            case ANTENNA_ROW:
                
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    if (![sled isAntennaConfigEqual:local])
                    {
                        
                        NSString * antennaStr = [[NSUserDefaults standardUserDefaults] valueForKey:ANTENNA_CHANGE_DEFAULTS_KEY];
                        if (![antennaStr isEqualToString:ANTENNA_DEFAULTS_VALUE])
                        {
                            [self applyNewSetting:SAVE_ANTENNA_SETTINGS];
                            break;
                        }else
                        {
                            [self applyNewSetting:SAVE_ANTENNA_SETTINGS];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANTENNA_CHANGE_DEFAULTS_KEY];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                                            
                        break;
                    }
                        
                }else
                {
                    NSString * antennaStr = [[NSUserDefaults standardUserDefaults] valueForKey:ANTENNA_CHANGE_DEFAULTS_KEY];
                    if (![antennaStr isEqualToString:ANTENNA_DEFAULTS_VALUE])
                    {
                        if (![sled isAntennaConfigEqual:local])
                            [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                        break;
                    }
                    
                }
                break;
                
            case SINGULATION_ROW:
                
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    if (NO == [local isSingulationConfigValid]) {
                        
                        [self showInvalidParamsWarning];
                        
                        // set last actual config to local sled
                        [local setSingulationOptionsWithConfig:[sled getSingulationConfig]];
                        break;
                    }
                    
                    BOOL isSingulationChanged = [[NSUserDefaults standardUserDefaults] boolForKey:SINGULATION_DEFAULTS_KEY];
                                       
                    if (![sled isSingulationConfigEqual:local] && isSingulationChanged == YES)
                        [self applyNewSetting:SAVE_SINGULATION_SETTINGS];
                    break;
                }else
                {
                    BOOL isSingulationChanged = [[NSUserDefaults standardUserDefaults] boolForKey:SINGULATION_DEFAULTS_KEY];
                    if (isSingulationChanged == YES) {
                        if (![sled isSingulationConfigEqual:local])
                            [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                        break;
                    }
                    
                }
                break;
            case START_STOP_TRIGGER_ROW:
                
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    if (NO == [local isStartTriggerConfigValid] || NO == [local isStopTriggerConfigValid]) {
                        [self showInvalidParamsWarning];
                        [local setStartTriggerOptionWithConfig:[sled getStartTriggerConfig]];
                        [local setStopTriggerOptionWithConfig:[sled getStopTriggerConfig]];
                        break;
                    }
                
                    if (![sled isStartTriggerConfigEqual:local] || ![sled isStopTriggerConfigEqual:local])
                    {
                        [self applyNewSetting:SAVE_START_STOP_TRIGGER_SETTINGS];
                    }
                    break;
                }else
                {
                    if (![sled isStartTriggerConfigEqual:local] || ![sled isStopTriggerConfigEqual:local])
                        [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                    break;
                }
                break;
            case TAG_REPORTING_ROW:
                
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO)
                {
                    if (![sled isTagReporConfigEqual:local] || ![sled isBatchModeConfigEqual:local] ||![sled isUniqueTagsReportEqual:local])
                    {
                        if ([local currentBatchMode] == 2)
                        {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZT_BATCHMODE_ENABLED_KEY];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                        }else
                        {
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_BATCHMODE_ENABLED_KEY];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                        }
                        if (isReportTagChanged == YES) {
                            NSString * epcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];

                            if ([epcLength intValue] > EPC_LENGTH_MAX_VALUE) {
                                [self showFailure:NXP_BRANDID_FAILED_SETTINGS];
                            }else
                            {
                                [self applyNewSetting:SAVE_TAG_REPORT_SETTINGS];
                            }
                        }
                    }
                        
                    [self isBrandIDEnabled];
                    break;
                }else
                {
                    if (![sled isTagReporConfigEqual:local] || ![sled isBatchModeConfigEqual:local] ||![sled isUniqueTagsReportEqual:local] || isReportTagChanged == YES)
                        [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                    break;
                }
                break;
                
            case POWER_MANAGEMENT_ROW:
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    if (![sled isDpoConfigEqual:local])
                    {
                        [self applyNewSetting:SAVE_POWER_MANAGEMENT_SETTINGS];
                    }
                    break;
                }else
                {
                    BOOL isDPChanged = [[NSUserDefaults standardUserDefaults] boolForKey:DP_CHANGE_DEFAULTS_KEY];
                    if (isDPChanged == YES) {
                        if (![sled isDpoConfigEqual:local])
                            [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                        break;
                    }
                }
                break;
                
            default:
                break;
      }
        
    }
}

/// Save dynamic power settings
-(void)saveDynamicPower {
    
    @try {
    
        SRFID_RESULT resultForDynamicPowerSettings = SRFID_RESULT_FAILURE;
        NSString *responseForDynamicPowerSettings = DEFAULT_RESPONSE_MESSAGE;
        resultForDynamicPowerSettings = [[zt_RfidAppEngine sharedAppEngine] setDpoConfigurationFromLocal:&responseForDynamicPowerSettings];
        [self handleCommandResult:resultForDynamicPowerSettings withStatusMessage:responseForDynamicPowerSettings];
 
     }
     @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    
}

/// Handle the command result
/// @param result result  The result
/// @param message The message
- (void)handleCommandResult:(SRFID_RESULT)result withStatusMessage:(NSString *)message
{
    switch (result) {
        case SRFID_RESULT_SUCCESS:
            NSLog(@"Sucess");
            break;
            
        case SRFID_RESULT_FAILURE:
            NSLog(@"Failed");
            [self showResponsePopup:GENERAL_FAILED_SETTINGS];
            break;
            
        case SRFID_RESULT_RESPONSE_ERROR:
            NSLog(@"Response error");
            //[self showResponsePopup:[NSString stringWithFormat:@"%@ %@",GENERAL_FAILED_SETTINGS,INVALID_ERROR_IN_ANTENNA_SETTINGS]];
            break;
            
        case SRFID_RESULT_RESPONSE_TIMEOUT:
            NSLog(@" Time out");
            break;
            
        default:
            break;
    }
}
/// Show alert view with given message
/// @param message The message
- (void)showResponsePopup:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOnlyMessageWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
    });
    
}

/// Show alert view with given message
/// @param message The message
- (void)showWarning:(NSString *)message
{
   // [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:ZT_ALERTVIEW_WAITING_TIME];
    [self showOnlyMessageWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
}


/// Handled the brandid changes.
- (void)isBrandIDEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_BRAND_ID_VALUE_IS_CHANGED_KEY] && isReportTagChanged == YES)
    {
        NSString * previousEpcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_OLD_KEY_DEFAULTS];
        NSString * epcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];

        if ([epcLength intValue] > EPC_LENGTH_MAX_VALUE) {
            [[NSUserDefaults standardUserDefaults] setObject:previousEpcLength forKey:EPCLENGTH_KEY_DEFAULTS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showFailure:NXP_BRANDID_FAILED_SETTINGS];
        }else
        {
            [self applyBrandIDSetting:NXP_BRANDID_SUCCESS_SETTINGS];
        }
    }
}
    
#pragma mark - KVO observer methods

/// Informs the observing object when the value at the specified key path relative to the observed object has changed.
/// @param keyPath The key path, relative to object, to the value that has changed.
/// @param object The source object of the key path keyPath.
/// @param change A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in change dictionary keys.
/// @param context The value that was provided when the observer was registered to receive key-value observation notifications.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // detect if the current dynamic power enable value has changed
    if ([keyPath isEqual:kKeyPathDynamicPowerEnable])
    {
        [self refreshPowerManagementTableviewCellImage];
    }
}


/// Refresh power management tableview cell image icon
- (void) refreshPowerManagementTableviewCellImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        imgViewPowerManagement.image = [UIImage imageNamed:[self getImageNameForPowerManagementIcon]];
    });
}

#pragma mark - Methods

/// Save antenna, singulation, start/stop, tag report and power management settings .
-(void)updateSled
{
    int index = [m_LoadedViewIndex intValue];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *response = @"";
    
    switch (index) {
        case ANTENNA_ROW:
            result = [[zt_RfidAppEngine sharedAppEngine] setAntennaConfigurationFromLocal:&response];
            break;
        case SINGULATION_ROW:
            result = [[zt_RfidAppEngine sharedAppEngine] setSingulationConfigurationFromLocal:&response];
            break;
        case START_STOP_TRIGGER_ROW:
            result = [[zt_RfidAppEngine sharedAppEngine] setStartTriggerConfiguration:&response];
            if (result != SRFID_RESULT_SUCCESS) {
                zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
                [local setStopTriggerOptionWithConfig:[sled getStopTriggerConfig]];
                break;
            }
            else
            {
                result = [[zt_RfidAppEngine sharedAppEngine] setStopTriggerConfiguration:&response];
            }
            break;
        case TAG_REPORTING_ROW:
            {
                zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
                if(![sled isTagReporConfigEqual:local])
                    result = [[zt_RfidAppEngine sharedAppEngine] setTagReportConfigurationFromLocal:&response];
                if ( ![sled isBatchModeConfigEqual:local])
                    result = [[zt_RfidAppEngine sharedAppEngine] setBatchModeConfig:&response];
                if (![sled isUSBBatchModeConfigEqual:local])
                    result = [[zt_RfidAppEngine sharedAppEngine] setUSBBatchModeConfig:&response];
                if ( ![sled isUniqueTagsReportEqual:local])
                    result = [[zt_RfidAppEngine sharedAppEngine] setUniqueTagsReportConfigurationFromLocal:&response];
                }
            break;
        case POWER_MANAGEMENT_ROW:
            result = [[zt_RfidAppEngine sharedAppEngine] setDpoConfigurationFromLocal:&response];
        break;
    }
    [self handleCommandResult:result withStatusMessage:response];
    m_LoadedViewIndex = [NSNumber numberWithInt:DEFAULT_INDEX];
}


/// Show alert view with given message
/// @param message The message
-(void)applyNewSetting:(NSString *)message {
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(updateSled) withObject:nil withString:[NSString stringWithFormat:@"%@", message]];
}


/// Show alert view with given message
/// @param message The message
-(void)applyBrandIDSetting:(NSString *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:YES aSuccessMessage:message aFailureMessage:nil];
        //[self showOnlyMessageWithDurationWithMessage:message time:2];
    });
}


/// Show alert view with given message
/// @param message The message
- (void)showFailure:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //zt_AlertView *alertView = [[zt_AlertView alloc]init];
        //[alertView showSuccessFailureWithText:self.view isSuccess:NO aSuccessMessage:NXP_BRANDID_SUCCESS_SETTINGS aFailureMessage:message];
        [self showOnlySuccessFailureMessageWithDurationWithSuccessMessage:NXP_BRANDID_SUCCESS_SETTINGS failureMessage:message time:2 isSucess:false];
    });
}

/// Get  image name for the power management icon .
- (NSString *) getImageNameForPowerManagementIcon
{
    // Use grey image by default (dynamic power off)
    NSString *imageName = CELL_IMAGE_PWR_MANAGEMENT_OFF;
    
    // Check if there is a connected reader
    if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        // Check if dynamic power is active
        if([[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentDpoEnable] boolValue] )
        {
            // Dynamic power is active, turn power management button green
            imageName = CELL_IMAGE_PWR_MANAGEMENT_ON;
        }
        else
        {
            // Dynamic power is not active, turn power management button grey
            imageName = CELL_IMAGE_PWR_MANAGEMENT_OFF;
        }
    }

    return imageName;
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return NO_OF_SECTION_IN_ADVANCED_READER_OPTION;
    
}

/// Returns the number of rows (table cells) in a specified section.
/// @param tableView An object representing the table view requesting this information.
/// @param section An index number that identifies a section of the table. Table views in a plain style have a section index of zero.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return NO_OF_ROW_IN_ADVANCED_READER_OPTION;
    
}

/// Tells the delegate a row is selected.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int idx = (int)[indexPath row];
    UIViewController *viewController = nil;
    zt_SingulationSettingsVC *singulationSettingViewController = nil;
    zt_AntennaSettingsVC *antennaViewController = nil;
    zt_TriggerSettingsVC *triggerViewController = nil;
    zt_TagReportSettingsVC *tagReportViewController = nil;
    zt_PowerManagementVC *powerManagementViewController = nil;
    zt_SaveSettingsVC *saveSettingsViewController = nil;
    
    switch (indexPath.row) {
           case ANTENNA_ROW:
                  antennaViewController = (zt_AntennaSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ANTENNA_STORY_BOARD_ID];
                  viewController = antennaViewController;
            break;
           case SINGULATION_ROW:
                  singulationSettingViewController = (zt_SingulationSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:SINGULATION_STORY_BOARD_ID];
                  viewController = singulationSettingViewController;
            break;
           case START_STOP_TRIGGER_ROW:
                  triggerViewController = (zt_TriggerSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:TRIGGER_STORY_BOARD_ID];
                  viewController = triggerViewController;
            break;
           case TAG_REPORTING_ROW:
                  tagReportViewController = (zt_TagReportSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:TAG_REPORT_STORY_BOARD_ID];
                  viewController = tagReportViewController;
            break;
           case SAVE_CONFIGURATION_ROW:
                 saveSettingsViewController = (zt_SaveSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:SAVE_SETTINGS_STORY_BOARD_ID];
                  viewController = saveSettingsViewController;
            break;
           case POWER_MANAGEMENT_ROW:
                  powerManagementViewController = (zt_PowerManagementVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:POWER_MANAGEMENT_STORY_BOARD_ID];
                  viewController = powerManagementViewController;
            break;
           default :
               NSLog(@"Invalid row" );
       }
    
        if (nil != viewController)
        {
            m_LoadedViewIndex = [NSNumber numberWithInt:idx];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    
   }
  

@end
