//
//  BeeperViewController.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-11-22.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "BeeperViewController.h"
#import "ScannerEngine.h"
#import "ui_config.h"
#import "config.h"
#import "RFIDDemoAppDelegate.h"


//Beeper view controller
@interface BeeperViewController ()

@end

@implementation BeeperViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:BEEPER_SETTINGS_TITLE];
    activityView = [[zt_AlertView alloc] init];
    settingsRetrieved = NO;
    [[ScannerEngine sharedScannerEngine] setConfigScannerBeeperSettings:NO];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (NO == settingsRetrieved){
        UITableViewCell *cell;
        for (int i = ZT_BEEPER_LOOP_ZERO; i < ZT_BEEPER_LOOP_TOTAL_THREE; i++){
            for (int j = ZT_BEEPER_LOOP_ZERO; j < ZT_BEEPER_LOOP_TOTAL_TWO; j++){
                cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if (cell != nil){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getBeeperSettings) withObject:nil withString:nil];
    }
}

/// Set connected scanner id
- (void)setScannerID{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    scannerID = [scannerInfo getScannerID];
}

/// Complete operation
- (void) operationComplete{
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

/// Get beeper settings
- (void)getBeeperSettings{
    [self setScannerID];
    didStartDataRetrieving = YES;
    NSString *in_xml = [NSString stringWithFormat:ZT_SCANNER_BEEPER_SETTINGS_XML, scannerID,RMD_ATTR_BEEPER_VOLUME, RMD_ATTR_BEEPER_FREQUENCY];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result setString:EMPTY_STRING];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    
    SBT_RESULT resultForGet = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:result forScanner:scannerID];
    
    if (SBT_RESULT_SUCCESS != resultForGet){
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        
        [NSThread sleepForTimeInterval:ZT_BEEPER_SLEEP_THREAD];
        SBT_RESULT resultForAttributeGet = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:result forScanner:scannerID];
        if (SBT_RESULT_SUCCESS != resultForAttributeGet){
            [self operationComplete];
            if (!didStartDataRetrieving) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(),^{
                zt_RfidDemoAppDelegate *appDelegate = (zt_RfidDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
                if (self->alertController) {
                    if (self->alertController) {
                        if (appDelegate.window.rootViewController.presentedViewController == self->alertController){
                            [self->alertController dismissViewControllerAnimated:FALSE completion:nil];
                        }
                    }
                }
                [self operationComplete];
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_MESSAGE];
            });
            return;
        }
    }
    
    BOOL success = FALSE;
    
    /* success */
    do {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        NSString* resultString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *temporaryValue = ZT_SCANNER_RETRIEVE_ATTRIBUTE;
        NSRange range = [resultString rangeOfString:temporaryValue];
        NSRange rangeSeparate;
        
        if ((range.location == NSNotFound) || (range.length != [temporaryValue length])){
            [self operationComplete];
            break;
        }
        
        resultString = [resultString substringFromIndex:(range.location + range.length)];
        
        temporaryValue = ZT_SCANNER_RETRIEVE_CLOSE_ATTRIBUTE;
        range = [resultString rangeOfString:temporaryValue];
        
        if ((range.location == NSNotFound) || (range.length != [temporaryValue length])){
            [self operationComplete];
            break;
        }
        
        range.length = [resultString length] - range.location;
        
        resultString = [resultString stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
        
        NSArray *attributesList = [resultString componentsSeparatedByString:ZT_SCANNER_RETRIEVE_CLOSE_OPEN_ATTRIBUTE];
        
        if ([attributesList count] == ZT_BEEPER_ZERO){
            [self operationComplete];
            break;
        }
        
        NSString *attributeStringSeparate;
        
        int attributeId;
        int attributeValue;
        int rowId;
        int sectionId;
        
        for (NSString *oneAttributeString in attributesList){
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            attributeStringSeparate = oneAttributeString;
            
            temporaryValue = ZT_SCANNER_ID_XML;
            range = [attributeStringSeparate rangeOfString:temporaryValue];
            if ((range.location != ZT_BEEPER_ZERO) || (range.length != [temporaryValue length])){
                [self operationComplete];
                break;
            }
            attributeStringSeparate = [attributeStringSeparate stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
            
            temporaryValue = ZT_SCANNER_ID_CLOSE_XML;
            
            range = [attributeStringSeparate rangeOfString:temporaryValue];
            
            if ((range.location == NSNotFound) || (range.length != [temporaryValue length])){
                [self operationComplete];
                break;
            }
            
            rangeSeparate.length = [attributeStringSeparate length] - range.location;
            rangeSeparate.location = range.location;
            
            NSString *attr_id_str = [attributeStringSeparate stringByReplacingCharactersInRange:rangeSeparate withString:EMPTY_STRING];
            
            attributeId = [attr_id_str intValue];
            
            rangeSeparate.location = ZT_BEEPER_ZERO;
            rangeSeparate.length = range.location + range.length;
            
            attributeStringSeparate = [attributeStringSeparate stringByReplacingCharactersInRange:rangeSeparate withString:EMPTY_STRING];
            
            temporaryValue = ZT_SCANNER_VALUE_XML;
            range = [attributeStringSeparate rangeOfString:temporaryValue];
            if ((range.location == NSNotFound) || (range.length != [temporaryValue length])){
                break;
            }
            attributeStringSeparate = [attributeStringSeparate substringFromIndex:(range.location + range.length)];
            
            temporaryValue = ZT_SCANNER_VALUE_CLOSE_XML;
            
            range = [attributeStringSeparate rangeOfString:temporaryValue];
            
            if ((range.location == NSNotFound) || (range.length != [temporaryValue length])){
                break;
            }
            
            range.length = [attributeStringSeparate length] - range.location;
            
            attributeStringSeparate = [attributeStringSeparate stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
        
            attributeValue = [attributeStringSeparate intValue];
            
            if (RMD_ATTR_BEEPER_VOLUME == attributeId){
                sectionId = ZT_BEEPER_SECTION_ZERO;
                if (RMD_ATTR_VALUE_BEEPER_VOLUME_LOW == attributeValue){
                    rowId = ZT_BEEPER_SECTION_ZERO;
                }
                else if (RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM == attributeValue){
                    rowId = ZT_BEEPER_SECTION_ONE;
                }
                else if (RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH == attributeValue){
                    rowId = ZT_BEEPER_SECTION_TWO;
                }
                else{
                    break;
                }
            }
//
//            else if (RMD_ATTR_BEEPER_FREQUENCY == attributeId){
//                sectionId = ZT_BEEPER_SECTION_ONE;
//                if (RMD_ATTR_VALUE_BEEPER_FREQ_LOW == attributeValue){
//                    rowId = ZT_BEEPER_SECTION_ZERO;
//                }
//                else if (RMD_ATTR_VALUE_BEEPER_FREQ_MEDIUM == attributeValue){
//                    rowId = ZT_BEEPER_SECTION_ONE;
//                }
//                else if (RMD_ATTR_VALUE_BEEPER_FREQ_HIGH == attributeValue){
//                    rowId = ZT_BEEPER_SECTION_TWO;
//                }
//                else{
//                    break;
//                }
//            }

            else{
                break;
            }
            dispatch_async(dispatch_get_main_queue(),^{
                UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowId inSection:sectionId]];
                if (cell != nil){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            });
        }
        success = TRUE;
    } while (ZT_BEEPER_ZERO);
    
    if (FALSE == success){
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [self operationComplete];
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_CANNOT_RETRIEVE_BEEPER_SETTINGS];
        });
        return;
    }else{
        settingsRetrieved = TRUE;
    }
    didStartDataRetrieving = NO;
    [self operationComplete];
}

/// Set beeper settings
/// @param param beeper settings
- (void)setBeeperSettings:(NSString*)param{
    SBT_RESULT results = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_SET aInXML:param];
    
    if (results != SBT_RESULT_SUCCESS){
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_CANNOT_APPLY_BEEPER_CONFIG];
        });
    }else {
        [[ScannerEngine sharedScannerEngine] setConfigScannerBeeperSettings:YES];
    }
    [self getBeeperSettings];
}

/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae{
    alertController = [UIAlertController
                    alertControllerWithTitle:title
                                     message:messgae
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                        actionWithTitle:OK
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle ok action
                                }];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */


/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return ZT_BEEPER_NUMBER_OF_SECTION;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    switch (section){
        case ZT_BEEPER_SECTION_CASE_ZERO:
            return ZT_BEEPER_ROW_TOTAL_THREE;
//
//        case ZT_BEEPER_SECTION_CASE_ONE:
//            return ZT_BEEPER_ROW_TOTAL_THREE;
//
        default:
            return ZT_BEEPER_ZERO;
    }
}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */


/// Tells the delegate a row is selected.
/// @param tableView A table view informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    char beeperValue = -ZT_BEEPER_VALUE_INIT;
    int attributeId = -ZT_BEEPER_VALUE_INIT;
    
    UITableViewCell *cellInit;
    for (int i = ZT_BEEPER_DID_SELECT_ZERO; i < ZT_BEEPER_SELECT_LOOP_THREE; i++){
        cellInit = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:[indexPath section]]];
        if (cellInit != nil){
            cellInit.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if ([indexPath section] == ZT_BEEPER_VOLUME_SECTION) /* Volume */
    {
        attributeId = RMD_ATTR_BEEPER_VOLUME;
        if ([indexPath row] == ZT_BEEPER_VOLUME_LOW) /* Low */
        {
            beeperValue = RMD_ATTR_VALUE_BEEPER_VOLUME_LOW;
        }
        else if ([indexPath row] == ZT_BEEPER_VOLUME_MEDIUM) /* Medium */
        {
            beeperValue = RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM;
        }
        else if ([indexPath row] == ZT_BEEPER_VOLUME_HIGH) /* High */
        {
            beeperValue = RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH;
        }
    }
//
//    else if ([indexPath section] == ZT_BEEPER_FREQUENCY_SECTION) /* Frequency */
//    {
//        attributeId = RMD_ATTR_BEEPER_FREQUENCY;
//        if ([indexPath row] == ZT_BEEPER_FREQUENCY_LOW) /* Low */
//        {
//            beeperValue = RMD_ATTR_VALUE_BEEPER_FREQ_LOW;
//        }
//        else if ([indexPath row] == ZT_BEEPER_FREQUENCY_MEDIUM) /* Medium */
//        {
//            beeperValue = RMD_ATTR_VALUE_BEEPER_FREQ_MEDIUM;
//        }
//        else if ([indexPath row] == ZT_BEEPER_FREQUENCY_HIGH) /* High */
//        {
//            beeperValue = RMD_ATTR_VALUE_BEEPER_FREQ_HIGH;
//        }
//    }
  
    
    if ((attributeId != -ZT_BEEPER_VALUE_INIT) && (beeperValue != -ZT_BEEPER_VALUE_INIT)){
        if (YES == settingsRetrieved){
            NSString *inputXml = [NSString stringWithFormat:ZT_BEEPER_SETTING_SET_XML, scannerID, attributeId, beeperValue];
            activityView = [[zt_AlertView alloc]init];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(setBeeperSettings:) withObject:inputXml withString:nil];
        }else{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_BEEPER_SETTINGS_NOT_RETRIEVED];
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}



@end
