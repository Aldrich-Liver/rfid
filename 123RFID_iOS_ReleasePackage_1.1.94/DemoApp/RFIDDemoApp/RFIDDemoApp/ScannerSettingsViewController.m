//
//  ScannerSettingsViewController.m
//  RFIDDemoApp
//
//  Created by Symbol on 03/09/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "ScannerSettingsViewController.h"
#import "ui_config.h"
#import "config.h"
#import "ScannerEngine.h"
#import "SymbologiesViewController.h"
#import "LedActionVC.h"
#import "BeeperViewController.h"
#import "AlertView.h"
#import "RFIDDemoApp-Swift.h"

/// Responsible for scanner settings page with all the settings options.
@interface ScannerSettingsViewController ()

@end

@implementation ScannerSettingsViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ZT_SCANNER_SETTINGS_TITLE];
    [[ScannerEngine sharedScannerEngine] enableScanner];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: YES];
    //BOOL symbologiesChanged = [[NSUserDefaults standardUserDefaults] objectForKey:@"symbologychanged"];
    
    BOOL symbologiesChanged = [[ScannerEngine sharedScannerEngine] getConfigScannerSymbologySettings];
    
    BOOL beeperChanged = [[ScannerEngine sharedScannerEngine] getConfigScannerBeeperSettings];
    
    if (symbologiesChanged)
    {
        [self applyNewSetting:SYMBOLOGY_STRING_TEXT];
    }else if (beeperChanged)
    {
        [self applyNewSetting:BEEPER_STRING_TEXT];
    }
}

/// Notifies the view controller that its view was removed from a view hierarchy.
/// @param animated If YES, the disappearance of the view was animated.
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[ScannerEngine sharedScannerEngine] setConfigScannerSymbologySettings:NO];
    [[ScannerEngine sharedScannerEngine] setConfigScannerBeeperSettings:NO];
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SCANNER_SETTINGS_SECTION_COUNT;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SCANNER_SETTINGS_ROWS_COUNT;
}

/// Asks the delegate for the height to use for a row in a specified location.
/// @param tableView The table view requesting this information.
/// @param indexPath An index path that locates a row in tableView.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCANNER_SETTINGS_ROW_HEIGHT;
}

/// Tells the delegate a row is selected.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case SCANNER_SETTINGS_BEEPER_ROW:
            [self openBeeperView];
            break;
        case SCANNER_SETTINGS_SYMBOLOGIES_ROW:
            [self openSymbologiesView];
            break;
        case SCANNER_SETTINGS_AIM_ON_ROW:
            [self actionAim:YES];
            break;
        case SCANNER_SETTINGS_AIM_OFF_ROW:
            [self actionAim:NO];
            break;
        default :
           NSLog(@"Invalid row" );
       }
}

/// Open symbologies view
-(void)openSymbologiesView{
    SymbologiesViewController *symbologiesViewController = (SymbologiesViewController*)[[UIStoryboard storyboardWithName:SCANNER_SYMBOLOGIES_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    [[self navigationController] pushViewController:symbologiesViewController animated:YES];
}

/// Open beeper view
-(void)openBeeperView{
    BeeperViewController *beeperViewController = (BeeperViewController*)[[UIStoryboard storyboardWithName:@"Beeper" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    [[self navigationController] pushViewController:beeperViewController animated:YES];
}

/// Aim on and off
/// @param isOn if aim on
-(void)actionAim:(BOOL)isOn{
    @try {
        SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
        NSString *inputXml = [NSString stringWithFormat:SCANNER_SETTINGS_SCAN_XML, [scannerInfo getScannerID]];
        SBT_RESULT result = [[ScannerEngine sharedScannerEngine] executeCommand:isOn ? SBT_DEVICE_AIM_ON : SBT_DEVICE_AIM_OFF aInXML:inputXml];
        NSString *errorMessage = [[NSString alloc] initWithString:isOn ? ZT_AIM_CANNOT_PERFORM_ON : ZT_AIM_CANNOT_PERFORM_OFF];

        if (result != SBT_RESULT_SUCCESS){
            dispatch_async(dispatch_get_main_queue(),^{
                UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:ZT_RFID_APP_NAME
                                                 message:errorMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                [alert release];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"Aim On Exception: %@", exception);
    }
    
}

- (void)applyNewSetting:(NSString *)name
{
    [[ScannerEngine sharedScannerEngine] setConfigScannerSymbologySettings:NO];
    NSString *message = [NSString stringWithFormat:@"%@ %@", name,GENERAL_SUCCESS_SETTINGS];

    dispatch_async(dispatch_get_main_queue(), ^{
      //  zt_AlertView *alertView = [[zt_AlertView alloc]init];
       // [alertView showSuccessFailureWithText:self.view isSuccess:YES aSuccessMessage:message aFailureMessage:GENERAL_FAILED_SETTINGS];
        [self showLoadingBarWithDurationWithMessage:message time:ZT_SCANNER_SETTING_ALERT_DURATION];
    
    });
    
}

@end
