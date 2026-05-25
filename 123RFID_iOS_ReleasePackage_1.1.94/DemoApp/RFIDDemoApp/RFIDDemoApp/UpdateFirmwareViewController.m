//
//  UpdateFirmwareViewController.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-14.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UpdateFirmwareViewController.h"
#import "ui_config.h"
#import "config.h"
#import "PluginFirmwareModelContentReader.h"
#import "PluginFileContentReader.h"
#import "ScannerEngine.h"
#import "UpdateFirmwareViewController+Helper.h"
#import "SbtScannerInfo+AssetsTblRepresentation.h"
#import "RfidAppEngine.h"
#import "AlertView.h"
#import "RFIDDemoApp-Swift.h"

/// Firmware update
@interface UpdateFirmwareViewController ()

@end

@implementation UpdateFirmwareViewController

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ZT_STR_SETTINGS_SECTION_FIRMWARE_UPDATE];
    self->helpTextView.delegate = self;
    UIImage *image = [[UIImage imageNamed:ZT_FW_HELP_ICON_IMAGE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(firmwareHelpButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    authorisationRequired = NO;
    deviceAuthorised = [[NSUserDefaults standardUserDefaults] boolForKey:@"DeviceAuthorised"];

    [self adjustHelpViewVisibility:YES];
    [self setupIndicatorUI];
    [self updatePluginsMismatchUI];
    [self updateFirmwareUpdateHelpUI];
    [[ScannerEngine sharedScannerEngine] addFirmwareUpdateEventsDelegate:self];
    if (fromSuccess) {
        [closePopup setHidden:NO];
    }else{
        [closePopup setHidden:YES];
    }
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If YES, the view is being added to the window using an animation.
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    firmwareUpdateDidAbort = NO;
    [self getAvailableFirmwareFile];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If YES, the view was added to the window using an animation.
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getScannerInfo];
}

/// Setup close for popup view
/// @param isFromSuccess If success
-(void)setupCloseButton:(BOOL)isFromSuccess{
    fromSuccess = isFromSuccess;
}

/// Firmware update help button action.
/// @param sender Button reference.
- (void)firmwareHelpButtonAction:(id)sender
{
    [self adjustHelpViewVisibility:NO];
}

//MARK:- Firmware update

/// Setup indicator view
-(void)setupIndicatorUI{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setHidesWhenStopped:YES];
    [spinner setColor:UIColor.blackColor];
    spinner.frame = CGRectMake(round(([self view].frame.size.width - ZT_FW_UPDATE_SPINNER_SIZE) / ZT_FW_UPDATE_SPINNER_SIZE_DIVIDE), round(([self view].frame.size.height - ZT_FW_UPDATE_SPINNER_SIZE) / ZT_FW_UPDATE_SPINNER_SIZE_DIVIDE), ZT_FW_UPDATE_SPINNER_SIZE, ZT_FW_UPDATE_SPINNER_SIZE);
    [self.view addSubview:spinner];
    [self.view bringSubviewToFront:spinner];
}

/// Setup firmware plugin view
-(void)firmwareUpdateUISetup{
        [self spinnerViewIsHide:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->updateButton.hidden =  YES;
        });
        
        id<PluginFirmwareModelContentReader> contentReader = [[PluginFileContentReader alloc] init];
       
        [contentReader readPluginFileData:^(FirmwareUpdateModel *model) {
            CFTimeInterval startTime = CACurrentMediaTime();
            CFTimeInterval elapsedTime = ZT_FW_UPDATE_CONTENT_READER_INIT_ELAPSED_TIME;
            while (modelNumber == nil && elapsedTime < ZT_FW_UPDATE_CONTENT_READER_ELAPSED_TIME) {
                [NSThread sleepForTimeInterval:ZT_FW_UPDATE_CONTENT_READER_THREAD_SLEEP];
                elapsedTime = CACurrentMediaTime() - startTime;
            }
            NSArray *supportedModelArray = model.supportedModels;
            BOOL isPluginMatcing = NO;
            for (NSString *scannerName in supportedModelArray) {
                if (modelNumber == NULL || scannerName == NULL){
                    continue;
                }
                if ([scannerName isEqualToString:modelNumber]) {
                    isPluginMatcing = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        updateButton.hidden =  NO;
                    });
                    if (isPluginMatcing == YES) {
                        break;
                    }
                }
            }
            if (isPluginMatcing == NO) {
                //check for dat files now
                NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:ZT_PLUGIN_DEFAULT_DOCUMENT];
                NSString *download = [documentDirectory stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
                //first look for plugins
                NSArray *datFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:download];
                
                NSArray *eDatSecureFirmwareFileArray = [self findFiles:@"edat" fromPath:download];
                NSArray *secureEDATFirmwareFileArray = [self findFiles:@"EDAT" fromPath:download];
                
                if ((datFileArray != nil && datFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT) || (eDatSecureFirmwareFileArray != nil && eDatSecureFirmwareFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT) || (secureEDATFirmwareFileArray != nil && secureEDATFirmwareFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT)) {
                    
                    [self setCommandType:ZT_INFO_UPDATE_FROM_DAT];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        updateButton.hidden =  NO;
                        NSString *fileName =@"";
                        if(datFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT){
                            fileName = datFileArray[ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
                        }
                        else  if(eDatSecureFirmwareFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT){
                            fileName = eDatSecureFirmwareFileArray[ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
                        }
                        else  if(secureEDATFirmwareFileArray.count > ZT_FW_UPDATE_NON_DAT_FILE_COUNT){
                            fileName = secureEDATFirmwareFileArray[ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
                        }
                    
                        
                        [releasedDateLabel setText:[NSString stringWithFormat:ZT_FW_UPDATE_TO_RELEASE_FORMAT_FOR_DAT,fileName]];
                        
                        [releaseNotesLabel setHidden:YES];
                        [releaseNotesTextView setHidden:YES];
                        [scannerImage setHidden:YES];
                    });
                } else {
                    [self adjustPluginVisibility:NO];
                    [self spinnerViewIsHide:YES];
                    return;
                }
            } else {
                [self setCommandType:ZT_INFO_UPDATE_FROM_PLUGIN];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //Your main thread code goes in here
                CFTimeInterval startTime = CACurrentMediaTime();
                CFTimeInterval elapsedTime = 0;
                while (model.releaseNotes == nil && firmwareVersion == nil && elapsedTime < 10) {
                    [NSThread sleepForTimeInterval:0.1];
                    elapsedTime = CACurrentMediaTime() - startTime;
                }
                [firmwareNameLabel setText:[NSString stringWithFormat:ZT_FW_NAME_STRING_FORMAT, ZT_FW_NAME_FROM_STRING, firmwareVersion]];
                updateButton.hidden =  NO;
                [releaseNotesTextView setText:model.releaseNotes];
                [headerLabel setText:model.plugFamily];
                NSString *toLabelText = [self processReleasedDateLableString:model.plugInRev withDate:model.releasedDate withFirmwareName:model.firmwareNameArray];
                if (![toLabelText  isEqual: EMPTY_STRING]){
                    [releasedDateLabel setText:toLabelText];
                }
                if (model.imgData != NULL){
                    scannerImage.image = [UIImage imageWithData:model.imgData];
                }else{
                    scannerImage.image = NULL;
                }
                [self spinnerViewIsHide:YES];
                [self adjustPluginVisibility:YES];
                [self setBackgroundColoursAndBtnColour];
            });
        }];
}


/// Set firmware update button ui updates
- (void)setBackgroundColoursAndBtnColour{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[ScannerEngine sharedScannerEngine] firmwareDidUpdate]) {
            [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                updateButton.hidden =  NO;
                updateButton.backgroundColor = [UIColor greenColor];
                [updateButton setTitle:ZT_UPDATE_FW_BTN_TITLE_UPDATED forState:UIControlStateNormal];
                updateButton.userInteractionEnabled = NO;
                [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:NO];
            });
            self->firmwareNameLabel.text = ZT_FW_UPDATE_EMPTY_STRING;
        } else {
            [updateButton setTitle:ZT_UPDATE_FW_BTN_TITLE forState:UIControlStateNormal];
            updateButton.backgroundColor = UIColorFromRGB(ZT_FW_UPDATE_UPDATE_BUTTON_COLOR);
            updateButton.userInteractionEnabled = YES;
        }
    });
}

/// Progress view
/// @param isHide Visibility status
-(void)progressViewIsHide:(BOOL)isHide {
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressView setHidden:isHide];
    });
}

/// Spinner vew
/// @param isHide Visibility status
-(void)spinnerViewIsHide:(BOOL)isHide{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHide){
            [spinner stopAnimating];
        }else{
            [spinner startAnimating];
        }
    });
}

/// Set plugins type
/// @param type Plugin type
- (void)setCommandType:(ZT_INFO_UPDATE_FIRMWARE)type{
    commandType = type;
}

/// Get scanner information
-(void)getScannerInfo{
    /**
     Model, MFD and serial no does not chage. So we need get the values for those variables only in the first time
     ***/
    [self getScannerFirmwareVersion];
}

/// Get scanner firmware version
-(void)getScannerFirmwareVersion{
    [self spinnerViewIsHide:NO];
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    [scannerInfo getAssetsTableRepresentation:^(NSMutableDictionary *dictionary) {
        [self spinnerViewIsHide:YES];
        if ([dictionary[SCANNER_ASSET_INFORMATION_TABLE_VALUES] count] > ZT_FIRMWARE_UPDATE_DETAIL_INDEX){
            NSString *firmwareValue = dictionary[SCANNER_ASSET_INFORMATION_TABLE_VALUES][ZT_FIRMWARE_UPDATE_DETAIL_INDEX];
            NSRange range = NSMakeRange(ZT_FIRMWARE_UPDATE_REPLACE_INDEX_START,ZT_FIRMWARE_UPDATE_REPLACE_INDEX_END);
            NSString *correctedFirmwareValue = [firmwareValue stringByReplacingCharactersInRange:range withString:ZT_FIRMWARE_UPDATE_NAME_REPLACE];
            firmwareVersion = [[NSString alloc] initWithString:correctedFirmwareValue];
            /// Completed firmware version get
            [self getScannerModelNumber];
        }
    }];
}

/// Get scanner firmware version
-(void)getScannerModelNumber{
    [self spinnerViewIsHide:NO];
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    NSString *inputXML = [NSString stringWithFormat:ZT_FW_UPDATE_SCANNER_INFO_GET_XML, [scannerInfo getScannerID], ZT_FW_UPDATE_SCANNER_INFO_GET_MODEL_NUMBER];
    [self getRFID8500Info:ZT_FW_UPDATE_SCANNER_INFO_GET_MODEL_NUMBER withXML:inputXML withAssignedVal:modelNumber scannerInfo:scannerInfo completed:^{
        /// Completed model number get
        [self spinnerViewIsHide:YES];
        [self firmwareUpdateUISetup];
    }];
}


/// Get information from scanner
/// @param attrID Attribute id
/// @param in_xml Input xml
/// @param value Assigned value
/// @param scannerinfo Scanner's info
/// @param completion Completion
- (void)getRFID8500Info:(int)attributeId withXML:(NSString*)in_xml withAssignedVal:(NSString*)value scannerInfo:(SbtScannerInfo*) scannerinfo completed:(void (^)(void))completion
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result setString:ZT_FW_UPDATE_EMPTY_STRING];
    
    SBT_RESULT sbtResult = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:result forScanner:[scannerinfo getScannerID]];
    
    if (SBT_RESULT_SUCCESS != sbtResult) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_CANNOT_RETRIEVE_ASSET_INFORMATION];
        });
        completion();
    }
    
    BOOL success = FALSE;
    
    do {
        NSString* resultString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* tmp = ZT_FW_UPDATE_ATTRIBUTE_START_XML;
        NSRange range = [resultString rangeOfString:tmp];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        resultString = [resultString substringFromIndex:(range.location + range.length)];
        
        tmp = ZT_FW_UPDATE_ATTRIBUTE_END_XML;
        range = [resultString rangeOfString:tmp];
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        range.length = [resultString length] - range.location;
        
        resultString = [resultString stringByReplacingCharactersInRange:range withString:ZT_FW_UPDATE_EMPTY_STRING];
        
        NSArray *attrs = [resultString componentsSeparatedByString:ZT_FW_UPDATE_ATTRIBUTE_START_END_XML];
        
        if ([attrs count] == 0)
        {
            break;
        }
        
        NSString *attr_str;
        
        int attr_id;
        int attr_val;
        
        for (NSString *pstr in attrs)
        {
            attr_str = pstr;
            
            tmp = ZT_FW_UPDATE_ID_START_XML;
            range = [attr_str rangeOfString:tmp];
            if ((range.location != 0) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:ZT_FW_UPDATE_EMPTY_STRING];
            
            tmp = ZT_FW_UPDATE_ID_END_XML;
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range2.length = [attr_str length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:ZT_FW_UPDATE_EMPTY_STRING];
            
            attr_id = [attr_id_str intValue];
            
            
            range2.location = 0;
            range2.length = range.location + range.length;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:ZT_FW_UPDATE_EMPTY_STRING];
            
            tmp = ZT_FW_UPDATE_VALUE_START_XML;
            range = [attr_str rangeOfString:tmp];
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str substringFromIndex:(range.location + range.length)];
            
            tmp = ZT_FW_UPDATE_VALUE_END_XML;
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [attr_str length] - range.location;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:ZT_FW_UPDATE_EMPTY_STRING];
            
            attr_str = [attr_str stringByReplacingOccurrencesOfString:ZT_FW_UPDATE_SPACE_STRING withString:ZT_FW_UPDATE_EMPTY_STRING];
            
            attr_val = [attr_str intValue];
            
            if (ZT_FW_UPDATE_SCANNER_INFO_GET_FIRMWARE_CODE == attr_id)
            {
                firmwareVersion = [[NSString alloc] initWithString:attr_str];
                NSLog(@"%@",firmwareVersion);
                completion();
                break;
            }
            else if (ZT_FW_UPDATE_SCANNER_INFO_GET_MODEL_NUMBER == attr_id)
            {
                modelNumber = [[NSString alloc] initWithString:attr_str];
                NSLog(@"%@",modelNumber);
                completion();
                break;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    if (FALSE == success)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_ERROR_MESSAGE];
        });
        completion();
    }
}

/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae{
    @try {
        dispatch_async(dispatch_get_main_queue(),^{
            
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
        });
        
    } @catch (NSException *exception) {
        NSLog(@"FW Update UI Exception: %@", exception);
    }
}

// Get the batery status for the firmware update
-(NSString*)getBatteryStatus {
    
    NSString * chargePrecentage = NULL;
    int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    
    result = [[zt_RfidAppEngine sharedAppEngine] getBatteryStatus:readerId  aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        
        chargePrecentage = [[[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getBatteryStatusArray] objectAtIndex:3] getBatterStatusValue];
        
    }
    return chargePrecentage;
}

/// Firmware update action
/// @param id Button reference
- (IBAction)updateFirmwareButtonAction:(id)sender{
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if (!deviceAuthorised && ([[local readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8] || [[local readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR]))
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:@"Device Authorization Required"];
        });
    }else
    {
        @try {
            inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
            bool tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
            bool multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];

            NSString * stringChargePrecentage = [self getBatteryStatus];
            NSInteger bat_val = [stringChargePrecentage integerValue];

            zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
            if (inventoryRequested == YES)
                {
                    [self showWarning:FIRMWARE_UPDATE_WARNING_MESSAGE];
                    
                } else if (tagLocated || multiTagLocated){
                    [self showWarning:FIRMWARE_UPDATE_TAG_LOCATE_WARNING];
                }
                else {
                    if (bat_val <= 20 && (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS])) {

                        [self showWarning:FIRMWARE_UPDATE_BATTERY_LOW_MESSAGE];
                        
                    } else {
                        if (inventoryRequested == NO)
                        {
                            [firmwareProgressLabel setText:[NSString stringWithFormat:ZT_FIRMWARE_UPDATING]];
                            [progressValueLabel setHidden:NO];
                            [progressBarView setHidden:NO];
                            [cancelFirmwareUpdateButton setHidden:NO];
                            
                            if([self checkFirmwareFileIsAlreadyExtract] || [self checkEDATFirmwareFileIsAlreadyExtract]){
                            
                                [self updateFirmwareEDATStart];
                                
                            }else{
                                if([[ScannerEngine sharedScannerEngine]
                                    checkIsThisSecureFirmwareFile:selectedFirmwareFilePath]){
                                    [self showPasswordAlertViewForTheSecureFirmwareFile];
                                }
                                else {
                                    [self updateFirmwareStart];
                                }
                            }
                        }else
                        {
                            [self showWarning:FIRMWARE_UPDATE_WARNING_MESSAGE];
                        }
                    }
                }
        } @catch (NSException *exception) {
            NSString *exceptionString = [NSString stringWithFormat:@"Exception Name: %@\nReason: %@\nUser Info: %@",
                                             exception.name,
                                             exception.reason,
                                             exception.userInfo ? exception.userInfo.description : @"No user info"];
            [self showWarning:exceptionString];
        }
    }

}

/// Show alert view with given message
/// @param message The message
- (void)showWarning:(NSString *)message
{
   // [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:ZT_ALERTVIEW_WAITING_TIME];
    [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
    
}

/// Cancel update action
/// @param sender Button reference
- (IBAction)cancelFirmwareUpdate:(UIButton *)sender {
    @try {
        [self showCancelConfirmationForFirmwareUpdate];
    } @catch (NSException *exception) {
        NSLog(@"FW Update UI Exception: %@", exception);
    }
    
}

/// Display cancel confiramtion alert message
-(void)showCancelConfirmationForFirmwareUpdate{
    dispatch_async(dispatch_get_main_queue(),^{
        cancelAlert = [UIAlertController
                        alertControllerWithTitle:ZT_RFID_APP_NAME
                                         message:FIRMWARE_UPDATE_CANCEL_CONFIRMATION
                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesButton = [UIAlertAction
                            actionWithTitle:YES_BUTTON
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
            [self abortFirmwareUpdate];
        }];
        UIAlertAction *noButton = [UIAlertAction
                            actionWithTitle:NO_BUTTON
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
            cancelAlert = NULL;
        }];
        [cancelAlert addAction:yesButton];
        [cancelAlert addAction:noButton];
        [self presentViewController:cancelAlert animated:YES completion:nil];
        
    });
    
}

/// Firmware update start
-(void)updateFirmwareStart{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self setUpTemporaryView];
    
    [[ScannerEngine sharedScannerEngine] blinkLEDFastON];

    firmwareUpdateDidAbort = NO;
    progressCurrent = START_PROGRESS_RESET_VALUE;
    [self progressViewIsHide:NO];
    NSLog(@"FIRMWARE:-  update progress: %f",progressCurrent);
    [updateButton setUserInteractionEnabled:NO];
    
    firmwareUpdateDidStop = NO;
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    
        NSString *inputXML = [NSString stringWithFormat:ZT_FW_UPDATE_START_XML, [scannerInfo getScannerID], selectedFirmwareFilePath];
        int firmwareFileTypeCommand = 0;
        if (commandType == ZT_INFO_UPDATE_FROM_DAT) {
            firmwareFileTypeCommand = SBT_UPDATE_FIRMWARE;
        } else {
            firmwareFileTypeCommand = SBT_UPDATE_FIRMWARE_FROM_PLUGIN;
        }
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self disableScanner];
            
            SBT_RESULT result = [[ScannerEngine sharedScannerEngine] executeCommand:firmwareFileTypeCommand aInXML:inputXML];
            [[ScannerEngine sharedScannerEngine] blinkLEDFastOFF];
            
            if (firmwareUpdateDidAbort == YES) {
                [self enableScanner];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"FIRMWARE:-  update abort: %f",progressCurrent);
                    [self progressViewIsHide:YES];
                    [self spinnerViewIsHide:YES];
                    [self removeTemporaryView];
                    [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:FIRMWARE_UPDATE_STOPPED];
                });
                return;
            }else if (result != SBT_RESULT_SUCCESS){
                
                    [self enableScanner];
               
                    [self progressViewIsHide:YES];
                    firmwareUpdateDidStop = YES;
                    progressCurrent = START_PROGRESS_RESET_VALUE;
                    NSLog(@"FIRMWARE:- update stoped: %f",progressCurrent);
                
                //dispatch_async(dispatch_get_main_queue(),^{
                    [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:FIRMWARE_UPDATE_FAILED];
                    [self resetProgressBar];
                    [self removeTemporaryView];
                   
               // });
                if([[ScannerEngine sharedScannerEngine] firmwareDidUpdate]) {
                    [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:NO];
                }
            } else {
                NSLog(@"FIRMWARE:- update rebooting: %f",progressCurrent);
                [self performSelectorOnMainThread:@selector(rebootingScannerMessage) withObject:NULL waitUntilDone:YES];
                NSString *in_xml = [NSString stringWithFormat:ZT_FW_ATTRIBUTE_SCANNER_XML_FORMAT, [scannerInfo getScannerID]];
                [self performStartNewFirmware:in_xml];
                [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:YES];
                [[ScannerEngine sharedScannerEngine] setPreviousScanner:[scannerInfo getScannerID]];
                [self resetProgressBar];
            }
        });
        [updateButton setUserInteractionEnabled:YES];
}

/// Display rebooting text view
-(void)rebootingScannerMessage{
    dispatch_async(dispatch_get_main_queue(),^{
        if (cancelAlert != NULL){
            [cancelAlert dismissViewControllerAnimated:NO completion:NULL];
        }
        [firmwareProgressLabel setText:[NSString stringWithFormat:ZT_FW_UPDATE_REBOOTING]];
        [progressValueLabel setHidden:YES];
        [progressBarView setHidden:YES];
        [cancelFirmwareUpdateButton setHidden:YES];
        [[self view] layoutIfNeeded];
    });
   
}

/// Perfrom reboot and new firmware start
/// @param param input parameter.
- (void)performStartNewFirmware:(NSString*)param{
    [self spinnerViewIsHide:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpTemporaryView];
    });
    
    SBT_RESULT res = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_START_NEW_FIRMWARE aInXML:param];
    [self removeTemporaryView];
    [self spinnerViewIsHide:YES];
    if (res != SBT_RESULT_SUCCESS){
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SCANNER_CANNOT_PERFORM_NEW_FIRMWARE_ACTION];
            [self enableScanner];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(),^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        [self performSelectorOnMainThread:@selector(removeTemporaryView) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(enableScanner) withObject:nil waitUntilDone:YES];
    }
}

/// Reset progress bar
- (void)resetProgressBar{
    firmwareUpdateDidStop = YES;
    progressCurrent = START_PROGRESS_RESET_VALUE;
}

/// Update progress view
/// @param event Firmware update event object
- (void)updateUI:(FirmwareUpdateEvent*)event{
    
    if (event.status == SBT_FW_UPDATE_RESULT_LOGIN_REQUIRED){
        authorisationRequired = YES;
        dispatch_async(dispatch_get_main_queue(),^{
            [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:@"Device Authorization Required"];
        });
      
    }else
    {
        //authorisationRequired = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (firmwareUpdateDidStop == NO) {
                progressCurrent = (float)event.currentRecord/event.maxRecords;
                if ((int)(float)event.currentRecord/event.maxRecords*ZT_FW_UPDATE_PROGRESS_100_PERCENT < ZT_FW_UPDATE_PROGRESS_10_PERCENT) {
                    int currentProgress = (int)((float)event.currentRecord/event.maxRecords*ZT_FW_UPDATE_PROGRESS_100_PERCENT);
                    NSLog(@"FIRMWARE:-  update progress: %d",currentProgress);
                    [progressValueLabel setText:[NSString stringWithFormat:ZT_FW_UPDATE_PROGRESS_FORMAT_WITH_VALUE, currentProgress]];
                    [progressBarView setProgress:(currentProgress / ZT_FW_UPDATE_PROGRESS_UI_100_PERCENT)];
                } else {
                    int currentProgress = (float)event.currentRecord/event.maxRecords;
                    NSLog(@"FIRMWARE:-  update progress: %d",currentProgress);
                    [progressValueLabel setText:[NSString stringWithFormat:ZT_FW_UPDATE_PROGRESS_FORMAT_WITH_VALUE, currentProgress]];
                    [progressBarView setProgress:(currentProgress / ZT_FW_UPDATE_PROGRESS_UI_100_PERCENT)];
                }
            }
        });
    }
}

///Disable the scanner
-(void)disableScanner{
    [[ScannerEngine sharedScannerEngine] disableScanner];
}


///Enable the scanner
- (void)enableScanner{
    [[ScannerEngine sharedScannerEngine] enableScanner];
}

/// Temporary view
- (void)setUpTemporaryView{
    temporaryView = [[UIView alloc] initWithFrame:CGRectMake(ZT_FW_UPDATE_TEMPORARY_FRAME_X_Y, ZT_FW_UPDATE_TEMPORARY_FRAME_X_Y, self.view.frame.size.width, self.view.frame.size.height)];
    UIView *superViewToTemporaryView = nil;
    superViewToTemporaryView = superScrollView;
    [superViewToTemporaryView addSubview:temporaryView];
    temporaryView.backgroundColor = [UIColorFromRGB(ZT_FW_UPDATE_TEMPORARY_COLOR) colorWithAlphaComponent:ZT_FW_UPDATE_TEMPORARY_ALPHA];
    [superViewToTemporaryView bringSubviewToFront:temporaryView];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    temporaryView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:temporaryView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superViewToTemporaryView attribute:NSLayoutAttributeTop multiplier:ZT_FW_UPDATE_TEMPORARY_CONSTANT_MULTIPLIER constant:0];
    [superViewToTemporaryView addConstraint:constraint1];
    
    NSLayoutConstraint *contraint2 = [NSLayoutConstraint constraintWithItem:temporaryView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superViewToTemporaryView attribute:NSLayoutAttributeBottom multiplier:ZT_FW_UPDATE_TEMPORARY_CONSTANT_MULTIPLIER constant:ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
    [superViewToTemporaryView addConstraint:contraint2];
    
    NSLayoutConstraint *contraint3 = [NSLayoutConstraint constraintWithItem:temporaryView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superViewToTemporaryView attribute:NSLayoutAttributeLeft multiplier:ZT_FW_UPDATE_TEMPORARY_CONSTANT_MULTIPLIER constant:ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
    [superViewToTemporaryView addConstraint:contraint3];
    
    NSLayoutConstraint *contraint4 = [NSLayoutConstraint constraintWithItem:temporaryView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superViewToTemporaryView attribute:NSLayoutAttributeRight multiplier:ZT_FW_UPDATE_TEMPORARY_CONSTANT_MULTIPLIER constant:ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO];
    [superViewToTemporaryView addConstraint:contraint4];
}

/// Remove temporary view
- (void)removeTemporaryView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (temporaryView != nil) {
            [temporaryView removeFromSuperview];
            temporaryView = nil;
        }
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    });
}

/// To abort the firmware update.
- (void)abortFirmwareUpdate{
    [[ScannerEngine sharedScannerEngine] blinkLEDFastOFF];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [updateButton setUserInteractionEnabled:YES];
    [self progressViewIsHide:YES];
    firmwareUpdateDidStop = YES;
    [self spinnerViewIsHide:NO];
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    NSString *in_xml = [NSString stringWithFormat:ZT_FW_ATTRIBUTE_SCANNER_XML_FORMAT, [scannerInfo getScannerID]];
    
    SBT_RESULT res = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_DEVICE_ABORT_UPDATE_FIRMWARE aInXML:in_xml];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (res != SBT_RESULT_SUCCESS){
            dispatch_async(dispatch_get_main_queue(),^{
                [self spinnerViewIsHide:YES];
                [self removeTemporaryView];
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_RFID_APP_NAME
                                                 message:FIRMWARE_UPDATE_STOPPED
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                                
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                [self enableScanner];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                firmwareUpdateDidAbort = YES;
                [progressBarView setProgress:START_PROGRESS_RESET_VALUE];
                [progressBarView setNeedsDisplay];
                progressCurrent = START_PROGRESS_RESET_VALUE;
                [progressValueLabel setText:[NSString stringWithFormat:ZT_FW_PROGRESS_FORMAT_WITH_VALUE_FLOAT,START_PROGRESS_RESET_VALUE]];
                [self enableScanner];
            });
           
        }
        [NSThread sleepForTimeInterval:ZT_FIRMWARE_CANCEL_THREAD_SLEEP];
    });
}

//MARK:- Plugins mismatch

/// Update mismatch plugin view
-(void)updatePluginsMismatchUI{
    [self darkModeCheck:self.view.traitCollection];
    pluginMismatchView.layer.borderWidth = 2.0;
    updateButton.layer.borderWidth = 2.0;
    
    ///Change in image, update button, firmware details view size only in iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _deviceImageViewHeightConstraint.constant = FW_PAGE_DEVICE_IMG_HEIGHT_IPAD;
        _updateButtonHeightConstraint.constant = FW_PAGE_BUTTON_HEIGHT_IPAD;
        _firmwareDetailsViewHeightConstraint.constant = FW_PAGE_DETAIL_VIEW_HEIGHT_IPAD;
    }
    [pluginMismatchView setHidden:YES];
    [superScrollView setHidden:YES];
}

/// Adujst plugins visibile
/// @param isVisible Check visible condition
- (void)adjustPluginVisibility:(BOOL)isVisible{
    dispatch_async(dispatch_get_main_queue(),^{
        self->pluginMismatchView.hidden = isVisible;
        if (isVisible == NO) {
            [self->pluginsMismatchTextView setAttributedText:[self getPluginMismatchString]];
            //make other views disappear
            [self adjustViewVisibilityForFirmwarePage:YES];
        }else{
            [self adjustViewVisibilityForFirmwarePage:NO];
        }
    });
}

/// Plugins mismatch ok button
/// @param sender Button reference
- (IBAction)pluginMisMatchOkClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// Adujst plugin view visibility
/// @param visibilityStatus Visibility status
- (void)adjustViewVisibilityForFirmwarePage:(BOOL)isHidden{
    superScrollView.hidden = isHidden;
}

/// close succes firmware
/// @param sender button
- (IBAction)closePopupAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//MARK:- Firmware help

/// Update firmware update help ui.
- (void)updateFirmwareUpdateHelpUI
{
    [self darkModeCheck:self.view.traitCollection];
    [helpView setHidden:YES];
    helpView.layer.borderWidth = 2.0;
}

/// Adujst firmware update help view visibility
/// @param isVisible Visibility status
- (void)adjustHelpViewVisibility:(BOOL)isVisible
{
    dispatch_async(dispatch_get_main_queue(),^{
        self->helpView.hidden = isVisible;
        if (isVisible == NO) {
            [self->helpTextView setAttributedText:[self getFirmwareUpdateHelpString]];
            //make other views disappear
            [helpView.superview bringSubviewToFront:helpView];
        }
    });
}

/// To close the firmware update help view.
/// @param sender Button reference.
- (IBAction)closeHelpView:(id)sender {
    [self adjustHelpViewVisibility:YES];
}

///MARK:- Textview delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    // Do whatever you want here
    NSLog(@"%@", URL); // URL is an instance of NSURL of the tapped link
    return YES; // Return NO if you don't want iOS to open the link
}

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection{
    if (@available(iOS 13.0, *)) {
        pluginMismatchView.layer.borderColor = [UIColor labelColor].CGColor;
        helpView.layer.borderColor = [UIColor labelColor].CGColor;
        updateButton.layer.borderColor = [UIColor labelColor].CGColor;
    } else {
        pluginMismatchView.layer.borderColor = [UIColor blackColor].CGColor;
        helpView.layer.borderColor = [UIColor blackColor].CGColor;
        updateButton.layer.borderColor = [UIColor blackColor].CGColor;
    }
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc {
    [headerLabel release];
    [releasedDateLabel release];
    [releaseNotesTextView release];
    [updateButton release];
    [releaseNotesLabel release];
    [releaseNotesSuperView release];
    [scannerImage release];
    [superScrollView release];
    [pluginMismatchButton release];
    [pluginMismatchView release];
    [pluginMismatchLabel release];
    [pluginsMismatchTextView release];
    [contentView release];
    [selectedFirmwareFilePath release];
    [spinner release];
    [firmwareNameLabel release];
    [modelNumber release];
    [firmwareVersion release];
    [helpView release];
    [helpTextView release];
    [helpViewCloseButton release];
    [[ScannerEngine sharedScannerEngine] removeFirmwareUpdateEventsDelegate:self];
    [progressView release];
    [firmwareProgressLabel release];
    [progressValueLabel release];
    [progressBarView release];
    [cancelFirmwareUpdateButton release];
    [closePopup release];
    [super dealloc];
}


// This method can be placed in your view controller
- (void)showPasswordAlertViewForTheSecureFirmwareFile {
    // Step 1: Create the alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Password"
                                                                             message:@"Please enter your password."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // Step 2: Add the secure text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES; // Ensures the text is hidden
        
    }];
    
        // Step 3: Add the "OK" action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        // Retrieve the password entered by the user
        UITextField *passwordField = alertController.textFields.firstObject;
        NSString *password = passwordField.text;
        
        // Handle the password (e.g., validation or authentication)
        NSLog(@"Entered Password: %@", password);
            
        BOOL unzipedSuccess = [[ScannerEngine sharedScannerEngine] unzippedTheSecureFirmwareFile:password firmwarePath:selectedFirmwareFilePath];
            
            
        if (unzipedSuccess) {
            
            if ([self checkFirmwareFileIsAlreadyExtract] || [self checkEDATFirmwareFileIsAlreadyExtract]) {
                [self updateFirmwareEDATStart];
            }else{
                [self retryMessage];
            }
           
        }else{
            NSLog(@"Wrong Password");
            [self wrongPasswordMessage];
        }
            
    }];
    
    // Step 4: Add the "Cancel" action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    // Add the actions to the alert controller
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    // Present the alert controller
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)wrongPasswordMessage{
    // Create an alert controller
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message"
                                                                              message:@"The password you entered is wrong. Please retry."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
     
     // Add an OK action
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
         NSLog(@"OK button clicked");
     }];
     [alertController addAction:okAction];
     // Present the alert controller
     [self presentViewController:alertController animated:YES completion:nil];
}
-(void)retryMessage{
    // Create an alert controller
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message"
                                                                              message:@"Please retry."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
     
     // Add an OK action
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
         NSLog(@"OK button clicked");
     }];
     [alertController addAction:okAction];
     // Present the alert controller
     [self presentViewController:alertController animated:YES completion:nil];
}

-(BOOL)checkFirmwareFileIsAlreadyExtract{
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *downLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    NSString *edateFileName = [self findFilesEdatName:@"edat" fromPath:downLoad];
    NSString *mergedEdatPathString = [NSString stringWithFormat:@"%@/%@", downLoad, edateFileName];
      
  
    NSArray *datFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:mergedEdatPathString];
    
    if (datFileArray != nil && datFileArray.count>0) {
        
        [self setCommandType:ZT_INFO_UPDATE_FROM_DAT];
        NSString *edatFilePathForFirmwareUpdate = [NSString stringWithFormat:@"%@/%@", mergedEdatPathString, datFileArray[ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO]];
        selectedFirmwareFilePath = edatFilePathForFirmwareUpdate;
        return YES;
        
    }
    else
    {
        return NO;
    }
}

-(BOOL)checkEDATFirmwareFileIsAlreadyExtract{
    
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *downLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    NSString *edateFileName = [self findFilesEDATtName:@"EDAT" fromPath:downLoad];
    NSString *mergedEdatPathString = [NSString stringWithFormat:@"%@/%@", downLoad, edateFileName];
      
  
    NSArray *datFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:mergedEdatPathString];
    
    if (datFileArray != nil && datFileArray.count>0) {
        
        [self setCommandType:ZT_INFO_UPDATE_FROM_DAT];
        NSString *edatFilePathForFirmwareUpdate = [NSString stringWithFormat:@"%@/%@", mergedEdatPathString, datFileArray[ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO]];
        selectedFirmwareFilePath = edatFilePathForFirmwareUpdate;
        return YES;
        
    }
    else
    {
        return NO;
    }
}
/// Firmware update start
-(void)updateFirmwareEDATStart{
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self setUpTemporaryView];
    
    [[ScannerEngine sharedScannerEngine] blinkLEDFastON];

    firmwareUpdateDidAbort = NO;
    progressCurrent = START_PROGRESS_RESET_VALUE;
    [self progressViewIsHide:NO];
    NSLog(@"FIRMWARE:-  update progress: %f",progressCurrent);
    [updateButton setUserInteractionEnabled:NO];
    
    firmwareUpdateDidStop = NO;
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    
 
     NSString *inputXML = [NSString stringWithFormat:ZT_FW_UPDATE_START_XML, [scannerInfo getScannerID], selectedFirmwareFilePath];
        int firmwareFileTypeCommand = 0;
        if (commandType == ZT_INFO_UPDATE_FROM_DAT) {
            firmwareFileTypeCommand = SBT_UPDATE_FIRMWARE;
        } else {
            firmwareFileTypeCommand = SBT_UPDATE_FIRMWARE_FROM_PLUGIN;
        }
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self disableScanner];
            
            SBT_RESULT result = [[ScannerEngine sharedScannerEngine] executeCommand:firmwareFileTypeCommand aInXML:inputXML];
            [[ScannerEngine sharedScannerEngine] blinkLEDFastOFF];
            
            if (firmwareUpdateDidAbort == YES) {
                [self enableScanner];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"FIRMWARE:-  update abort: %f",progressCurrent);
                    [self progressViewIsHide:YES];
                    [self spinnerViewIsHide:YES];
                    [self removeTemporaryView];
                    
                    if (!authorisationRequired) {
                        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:FIRMWARE_UPDATE_STOPPED];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                });
                return;
            }else if (result != SBT_RESULT_SUCCESS){
                [self enableScanner];
              
                    [self progressViewIsHide:YES];
                    firmwareUpdateDidStop = YES;
                    progressCurrent = START_PROGRESS_RESET_VALUE;
                    NSLog(@"FIRMWARE:- update stoped: %f",progressCurrent);
               // dispatch_async(dispatch_get_main_queue(),^{
                if (!authorisationRequired) {
                    [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:FIRMWARE_UPDATE_STOPPED];
                }
                    [self resetProgressBar];
                    [self removeTemporaryView];
                   
               // });
                if([[ScannerEngine sharedScannerEngine] firmwareDidUpdate]) {
                    [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:NO];
                }
            } else {
                NSLog(@"FIRMWARE:- update rebooting: %f",progressCurrent);
                [self performSelectorOnMainThread:@selector(rebootingScannerMessage) withObject:NULL waitUntilDone:YES];
                NSString *in_xml = [NSString stringWithFormat:ZT_FW_ATTRIBUTE_SCANNER_XML_FORMAT, [scannerInfo getScannerID]];
                [self performStartNewFirmware:in_xml];
                [[ScannerEngine sharedScannerEngine] setFirmwareDidUpdate:YES];
                [[ScannerEngine sharedScannerEngine] setPreviousScanner:[scannerInfo getScannerID]];
                [self resetProgressBar];
            }
        });
        [updateButton setUserInteractionEnabled:YES];
        
    
}
@end
