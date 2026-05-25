//
//  SymbologiesViewController.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "SymbologiesViewController.h"
#import "Symbology.h"
#import <ZebraScannerFramework/RMDAttributes.h>
#import "SwitchTableViewCell.h"
#import "config.h"
#import "ui_config.h"
#import "SSCheckBoxView.h"
#import "ScannerEngine.h"
#import "RFIDDemoAppDelegate.h"

@interface SymbologiesViewController (){
    dispatch_queue_t queue;
    dispatch_group_t group;
    BOOL shouldSavePermanantly;
}

@end

/// Symbologoes table view controller
@implementation SymbologiesViewController

/// default cstr for storyboard
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil){
        symbologiesRetrieved = FALSE;
        
        scannerID = -1;
        
        symbologies = [[NSMutableArray alloc] init];
        
        Symbology *temporarySymbologyValue;
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UPC_A aRMDAttr:RMD_ATTR_SYM_UPC_A];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UPC_E aRMDAttr:RMD_ATTR_SYM_UPC_E];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UPC_E1 aRMDAttr:RMD_ATTR_SYM_UPC_E_1];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_EAN_8_OR_JAN8 aRMDAttr:RMD_ATTR_SYM_EAN_8_JAN_8];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_EAN_13_OR_JAN13 aRMDAttr:RMD_ATTR_SYM_EAN_13_JAN_13];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Bookland_EAN aRMDAttr:RMD_ATTR_SYM_BOOKLAND_EAN];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Code_128 aRMDAttr:RMD_ATTR_SYM_CODE_128];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_GS1_128 aRMDAttr:RMD_ATTR_SYM_UCC_EAN_128];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Code_39 aRMDAttr:RMD_ATTR_SYM_CODE_39];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Code_93 aRMDAttr:RMD_ATTR_SYM_CODE_93];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Code_11 aRMDAttr:RMD_ATTR_SYM_CODE_11];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Interleaved_2_of_5 aRMDAttr:RMD_ATTR_SYM_INTERLEAVED_2_OF_5];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Discrete_2_of_5 aRMDAttr:RMD_ATTR_SYM_DISCRETE_2_OF_5];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Chinese_2_of_5 aRMDAttr:RMD_ATTR_SYM_CHINESE_2_OF_5];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Codabar aRMDAttr:RMD_ATTR_SYM_CODABAR];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_MSI aRMDAttr:RMD_ATTR_SYM_MSI];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Data_Matrix aRMDAttr:RMD_ATTR_SYM_DATAMATRIXQR];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_PDF aRMDAttr:RMD_ATTR_SYM_PDF];
        [symbologies addObject:temporarySymbologyValue];
        
        //add new symbologies
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_ISBT_128 aRMDAttr:RMD_ATTR_SYM_ISBT_128];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UCCCouponExtendedCode aRMDAttr:RMD_ATTR_UCC_COUPEN_EXTENDED_CODE];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_US_Postnet aRMDAttr:RMD_ATTR_SYM_US_Postnet];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_US_Planet aRMDAttr:RMD_ATTR_SYM_US_Planet];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UK_Post aRMDAttr:RMD_ATTR_SYM_UK_POST];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_USPostal_Check_Digit aRMDAttr:RMD_ATTR_SYM_US_POSTAL_CHECK_DIGIT];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UKPostal_Check_Digit aRMDAttr:RMD_ATTR_SYM_UK_POSTAL_CHECK_DIGIT];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_JapanPost aRMDAttr:RMD_ATTR_SYM_JAPAN_POST];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_AusPost aRMDAttr:RMD_ATTR_SYM_AUS_POST];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_GS1DataBar14 aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_14];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_GS1DataBarLimited aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_LIMITED];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_GS1DataBarExpanded aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_EXPANDED];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_MicroPDF aRMDAttr:RMD_ATTR_SYM_MICRO_PDF];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_MaxiCode aRMDAttr:RMD_ATTR_SYM_MAXI_CODE];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_ISSN_EAN aRMDAttr:RMD_ATTR_ISSN_EAN];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Matrix_2_of_5 aRMDAttr:RMD_ATTR_MATRIX_2_OF_5];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Korean_3_of_5 aRMDAttr:RMD_ATTR_KOREAN_3_OF_5];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_QR_Code aRMDAttr:RMD_ATTR_QR_CODE];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Micro_QR_Code aRMDAttr:RMD_ATTR_MICRO_QR];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Aztec aRMDAttr:RMD_ATTR_AZTEC];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_HanXin aRMDAttr:RMD_ATTR_HANXIN];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Composite_CC_C aRMDAttr:RMD_ATTR_COMPOSITE_CC_C];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Composite_CC_A_OR_B aRMDAttr:RMD_ATTR_COMPOSITE_CC_A_B];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Composite_TLC_39 aRMDAttr:RMD_ATTR_COMPOSITE_TLC_39];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Netherlands_KIX aRMDAttr:RMD_ATTR_SYM_Netherlands_KIX];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_UPU_FICS aRMDAttr:RMD_ATTR_SYM_UPU_FICS];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_USPS_4CB_ONE_Code aRMDAttr:RMD_ATTR_SYM_USPS_4CB_ONECODE_INTELLIGENT_MAIL];
        [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_DOTCODE aRMDAttr:RMD_ATTR_SYM_DOT_CODE ];
                [symbologies addObject:temporarySymbologyValue];
        
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Code_32 aRMDAttr:RMT_ATTR_SYM_CODE_32];
                [symbologies addObject:temporarySymbologyValue];
                
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_ISBN aRMDAttr:RMT_ATTR_SYM_ISBN];
                [symbologies addObject:temporarySymbologyValue];
                
        temporarySymbologyValue = [[Symbology alloc] init:ZT_SYMBOLOGIES_CODE_Trioptic_Code_39 aRMDAttr:RMT_ATTR_SYM_TRIOPTIC_CODE_39];
                [symbologies addObject:temporarySymbologyValue];
        
    }
    didStartDataRetrieving = NO;
    return self;
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopProcessAndComplete];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCancelAndBackButton];
}

/// Setup cancel while processing and back button
-(void)setupCancelAndBackButton{
    // Hide the standard back button
    [self.navigationItem setHidesBackButton:YES];
    
    // Add the custom back button
    backBarButton = [[UIBarButtonItem alloc] initWithTitle:ZT_SYMBOLOGIES_CANCEL_BAR_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(confirmCancel)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

/// Stop process and complete
-(void)stopProcessAndComplete{
    if (group){
        dispatch_suspend(group);
    }
    [self operationComplete];
}


/// Set connected scanner id
- (void)setScannerID{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    scannerID = [scannerInfo getScannerID];
}

/// Check box view
static void (^extracted(SymbologiesViewController *object))(SSCheckBoxView *) {
    return [(^(SSCheckBoxView *v) {
        [object checkBoxViewChangedState:v];
    }) copy];
}

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ZT_SYMBOLOGIES_TITLE];
    activityView = [[zt_AlertView alloc] init];
    
    [self createPermanentCheckBox];
    [self setScannerID];
    
    if (NO == symbologiesRetrieved){
        
        
        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getSymbologiesConfiguration) withObject:nil withString:ZT_SYMBOLOGIES_RETRIEVING];
    }
    [[ScannerEngine sharedScannerEngine] setConfigScannerSymbologySettings:NO];
}

/// Create permanent check box view
-(void)createPermanentCheckBox{
    /// Add header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(ZT_SYMBOLOGIES_SECTION_RECT_ZERO, ZT_SYMBOLOGIES_SECTION_RECT_ZERO, self.tableView.frame.size.width, ZT_SYMBOLOGIES_SECTION_HEADER_HEIGHT)];

    self.tableView.tableHeaderView = headerView;
    
    /// Permanent check box
    SSCheckBoxView *check = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_X, ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_Y, ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_WIDTH, ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_HEIGHT) style:kSSCheckBoxViewStyleDark checked:NO];
    [headerView addSubview:check];
    [check setText:ZT_SYMBOLOGIES_PERMANENT];
    [check setStateChangedBlock:extracted(self)];
}


/// Check box value change
/// @param checkBoxView checkBoxView reference
- (void) checkBoxViewChangedState:(SSCheckBoxView *)checkBoxView{
    shouldSavePermanantly = checkBoxView.checked;
}

/// Complete operation
- (void)operationComplete{
    /**Restore the standard back button**/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationItem.hidesBackButton) {
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:NO];
        }
    });
}


/// Cancel operation confirmation
- (void)confirmCancel{
    zt_RfidDemoAppDelegate *appDelegate = (zt_RfidDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (alert) {
        if (appDelegate.window.rootViewController.presentedViewController != nil){
            [alert dismissViewControllerAnimated:FALSE completion:nil];
        }
    }
    if (didStartDataRetrieving) {
        [self showCancelConfirmationAlert];
    } else {
        didStartDataRetrieving = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// Show only alert for confirmation
-(void)showCancelConfirmationAlert{
    alert = [UIAlertController
                    alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:ZT_SYMBOLOGIES_CANCEL_MESSAGE_ALERT
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction
                        actionWithTitle:ZT_SYMBOLOGIES_CANCEL_ALERT
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle cancel action
                                }];
    UIAlertAction* continueButton = [UIAlertAction
                        actionWithTitle:ZT_SYMBOLOGIES_CONTINUE_ALERT
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle continue action
         self->didStartDataRetrieving = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:cancelButton];
    [alert addAction:continueButton];
    [self presentViewController:alert animated:YES completion:nil];
}


//MARK:- Symbology Configure

/// Get supported symbologies configuration from device
- (void)getSymbologiesConfiguration{
    
    didStartDataRetrieving = YES;
    
    NSString* inputXML = [NSString stringWithFormat:ZT_SYMBOLOGIES_SCANNER_XML, scannerID];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    SBT_RESULT resultFirst = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:inputXML aOutXML:result forScanner:scannerID];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    if (resultFirst != SBT_RESULT_SUCCESS){
        [NSThread sleepForTimeInterval:ZT_SYMBOLOGIES_SLEEP_TIME_INTERVAL];
        SBT_RESULT resultSecond = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:inputXML aOutXML:result forScanner:scannerID];
        if (resultSecond != SBT_RESULT_SUCCESS){
            [NSThread sleepForTimeInterval:ZT_SYMBOLOGIES_SLEEP_TIME_INTERVAL];
            SBT_RESULT resultThird = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:inputXML aOutXML:result forScanner:scannerID];
            if (resultThird != SBT_RESULT_SUCCESS){
                [self operationComplete];
                if (!didStartDataRetrieving) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    if (self->alert) {
                        [self closeIfAnyAlertViewControllerPresented];
                    }
                    if (self->didStartDataRetrieving) {
                        [self showAlertMessageWithTitleLocal:ZT_RFID_APP_NAME withMessage:ZT_SYMBOLOGIES_CANNOT_SUPPORT];
                        self->didStartDataRetrieving = NO;
                    }
                });
                return;
            }
        }
    }
    
    [self processSymbologiesConfigurationsFromScanner:result];
}

/// Get ids of all supported attributes
/// @param result result from scanner
-(void)processSymbologiesConfigurationsFromScanner:(NSMutableString *)result{
    NSString *resultString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *temporary = ZT_SYMBOLOGIES_ATTRIBUTE_NAME_LIST_START;
    NSRange range = [resultString rangeOfString:temporary];
    
    if ((range.location == NSNotFound) || (range.length != [temporary length])){
        [self operationComplete];
        return;
    }
    
    resultString = [resultString substringFromIndex:(range.location + range.length)];
    
    temporary = ZT_SYMBOLOGIES_ATTRIBUTE_LIST;
    range = [resultString rangeOfString:temporary];
    
    if ((range.location == NSNotFound) || (range.length != [temporary length])){
        [self operationComplete];
        return;
    }
    range.length = [resultString length] - range.location;
    
    resultString = [resultString stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
    NSArray *attributeArray = [resultString componentsSeparatedByString:ZT_SYMBOLOGIES_ATTRIBUTE_NAME_LIST_END];
    
    if ([attributeArray count] == ZT_SYMBOLOGIES_ZERO){
        [self operationComplete];
        return;
    }
    
    BOOL oneSupported = NO;
    
    /* check which symbologies are supported */
    for (Symbology *symbologyOne in symbologies){
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        int symbologyAttributeId = [symbologyOne getRMDAttributeID];
        for (NSString *stringValue in attributeArray){
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            if (symbologyAttributeId == [stringValue intValue]){
                [symbologyOne setSupported:YES];
                oneSupported = YES;
                break;
            }
        }
    }
    
    if (NO == oneSupported){
        [self operationComplete];
        return;
    }
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    group = dispatch_group_create();
    
    NSString *inputXML = [NSString stringWithFormat:ZT_SYMBOLOGIES_ATTRIBUTE_SCANNER_ID, scannerID];
    
    Symbology *symbologyAtIndex = nil;
    for (int i = 0; i < [symbologies count]; i++){
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        symbologyAtIndex = [symbologies objectAtIndex:i];
        
        if ([symbologyAtIndex isSupported] == YES){
            inputXML = [inputXML stringByAppendingString:[NSString stringWithFormat:ZT_SYMBOLOGIES_SCANNER_ID_FORMAT, [symbologyAtIndex getRMDAttributeID]]];
        }
    }
    
    [self sendRequest:inputXML withOutXml:result withSymbology:symbologyAtIndex];
    
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            self->didStartDataRetrieving = NO;
            [self operationComplete];
        });
    });
}

/// Close alert view
-(void)closeIfAnyAlertViewControllerPresented{
    zt_RfidDemoAppDelegate *appDelegate = (zt_RfidDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.window.rootViewController.presentedViewController == self->alert){
        [self->alert dismissViewControllerAnimated:FALSE completion:nil];
    }
}

/// Send request
/// @param in_xml input xml
/// @param result result
/// @param symbologyValue symbology value
- (void)sendRequest:(NSString*)in_xml withOutXml:(NSMutableString*)result withSymbology:(Symbology*)symbologyValue{
    in_xml = [in_xml stringByReplacingCharactersInRange:NSMakeRange(in_xml.length - ZT_SYMBOLOGIES_VALUE_ONE, ZT_SYMBOLOGIES_VALUE_ONE) withString:EMPTY_STRING];
    
    in_xml = [in_xml stringByAppendingString:ZT_SYMBOLOGIES_ATTRIBUTE_XML_ARG];
    result = [[NSMutableString alloc] init];
    [result setString:EMPTY_STRING];
    
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    SBT_RESULT resultCode = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:result forScanner:scannerID];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    
    if (SBT_RESULT_SUCCESS != resultCode){
        SBT_RESULT resultCodeTwo = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:result forScanner:scannerID];
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        if (SBT_RESULT_SUCCESS != resultCodeTwo){
            dispatch_async(dispatch_get_main_queue(),^{
                [self operationComplete];
                if (self->alert) {
                    [self closeIfAnyAlertViewControllerPresented];
                }
                if (self->didStartDataRetrieving) {
                    [self showAlertMessageWithTitleLocal:ZT_RFID_APP_NAME withMessage:ZT_SYMBOLOGIES_CANNOT_RETRIEVE_SUPPORTED];
                }
                self->didStartDataRetrieving = NO;
           });
            return;
        }
    }
    
    dispatch_group_async(group, queue, ^{
        [self updateUI:symbologyValue withInXML:in_xml withResult:result];
    });
}


/// Update UI
/// @param symbologyValue Symbology value
/// @param in_xml Input xml
/// @param result result
- (void)updateUI:(Symbology*)symbologyValue withInXML:(NSString*)inputXml withResult:(NSMutableString*)result{
    BOOL success = FALSE;
    
    /* success */
    do {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        NSString* resultString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* temporary = ZT_SYMBOLOGIES_ATTRIB_LIST_START_XML;
        NSRange range = [resultString rangeOfString:temporary];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [temporary length])){
            break;
        }
        
        resultString = [resultString substringFromIndex:(range.location + range.length)];
        
        temporary = ZT_SYMBOLOGIES_ATTRIB_LIST_END_XML;
        range = [resultString rangeOfString:temporary];
        
        if ((range.location == NSNotFound) || (range.length != [temporary length])){
            break;
        }
        
        range.length = [resultString length] - range.location;
        
        resultString = [resultString stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
        
        NSArray *attributeArray = [resultString componentsSeparatedByString:ZT_SYMBOLOGIES_ATTRIBUTE_START_XML];
        
        if ([attributeArray count] == ZT_SYMBOLOGIES_ZERO){
            break;
        }
        
        NSString *attributeString;
        
        int attributeId;
        BOOL attributeValue;
        
        for (NSString *attributeOne in attributeArray){
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            attributeString = attributeOne;
            
            temporary = ZT_SYMBOLOGIES_ID_START;
            range = [attributeString rangeOfString:temporary];
            if ((range.location != ZT_SYMBOLOGIES_ZERO) || (range.length != [temporary length])){
                break;
            }
            attributeString = [attributeString stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
            
            temporary = ZT_SYMBOLOGIES_ID_END;
            
            range = [attributeString rangeOfString:temporary];
            
            if ((range.location == NSNotFound) || (range.length != [temporary length])){
                break;
            }
            
            range2.length = [attributeString length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attributeString stringByReplacingCharactersInRange:range2 withString:EMPTY_STRING];
            
            attributeId = [attr_id_str intValue];
            
            
            range2.location = ZT_SYMBOLOGIES_ZERO;
            range2.length = range.location + range.length;
            
            attributeString = [attributeString stringByReplacingCharactersInRange:range2 withString:EMPTY_STRING];
            
            temporary = ZT_SYMBOLOGIES_VALUE_START;
            range = [attributeString rangeOfString:temporary];
            if ((range.location == NSNotFound) || (range.length != [temporary length]))
            {
                break;
            }
            attributeString = [attributeString substringFromIndex:(range.location + range.length)];
            
            temporary = ZT_SYMBOLOGIES_VALUE_END;
            
            range = [attributeString rangeOfString:temporary];
            
            if ((range.location == NSNotFound) || (range.length != [temporary length])){
                break;
            }
            
            range.length = [attributeString length] - range.location;
            
            attributeString = [attributeString stringByReplacingCharactersInRange:range withString:EMPTY_STRING];
            
            attributeString = [attributeString lowercaseString];
            
            if ([attributeString isEqualToString:ZT_SYMBOLOGIES_VALUE_FALSE] == YES){
                attributeValue = NO;
            }else if ([attributeString isEqualToString:ZT_SYMBOLOGIES_VALUE_TRUE] == YES){
                attributeValue = YES;
            }else{
                break;
            }
            
            BOOL found = NO;
            for (int j = 0; j < [symbologies count]; j++){
                if (!didStartDataRetrieving) {
                    [self operationComplete];
                    return;
                }
                symbologyValue = (Symbology*)[symbologies objectAtIndex:j];
                if ([symbologyValue getRMDAttributeID] == attributeId){
                    found = YES;
                    [symbologyValue setEnabled:attributeValue];
                }
            }
            
            if (NO == found){
                break;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    
    if (FALSE == success){
        for (Symbology *symbologyOne in symbologies){
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            [symbologyOne setEnabled:NO];
        }
    }
    [self updateTableViewCells];
    symbologiesRetrieved = TRUE;
}


/// Update table view cells
-(void)updateTableViewCells{
    dispatch_async(dispatch_get_main_queue(),^{
        for (int i = 0; i < [self->symbologies count]; i++){
            if (!self->didStartDataRetrieving){
                [self operationComplete];
                return;
            }
            Symbology *symbologyAtIndex = (Symbology*)[self->symbologies objectAtIndex:i];
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:ZT_SYMBOLOGIES_ZERO]];
            if (cell != nil){
               [cell setSwitchOn:[symbologyAtIndex isEnabled]];
               [cell.cellSwitch setEnabled:[symbologyAtIndex isSupported]];
            }
        }
    });
}


/// Set symbology configuration
/// @param param parameter
/// @param index selected index
/// @param isON is Enable
- (void)setSymbologyConfiguration:(NSString*)param withIndex:(int)index withStatuc:(BOOL)isON{
    SBT_RESULT result;
    
    activityView = [[zt_AlertView alloc] init];
    dispatch_async(dispatch_get_main_queue(),^{
        [activityView showActivity:self.view];
    });
    
    if (shouldSavePermanantly) {
        result = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_STORE aInXML:param];
    } else {
        result = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_RSM_ATTR_SET aInXML:param];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [activityView hideActivity];
        [self operationComplete];
    });
    
    
    if (SBT_RESULT_SUCCESS !=  result ){
        dispatch_async(dispatch_get_main_queue(),^{
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SYMBOLOGIES_FAILD_TO_CONFIGURE_MESSAGE];
        });
        
        /* failed, return to previous value */
        
        NSString *pattern = ZT_SYMBOLOGIES_PATTERN_XML;
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:pattern
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
        
        NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:param options:ZT_SYMBOLOGIES_ZERO range:NSMakeRange(ZT_SYMBOLOGIES_ZERO, param.length)];
        
        if ([textCheckingResult numberOfRanges] == ZT_SYMBOLOGIES_NUMBER_OF_RANGE_FOUR){
            int symbolAttributeId = [[param substringWithRange:[textCheckingResult rangeAtIndex:ZT_SYMBOLOGIES_2_INDEX]] intValue];
            NSString *symbolAttributeValue = [param substringWithRange:[textCheckingResult rangeAtIndex:ZT_SYMBOLOGIES_3_INDEX]];
            BOOL enabled = [symbolAttributeValue isEqualToString:ZT_SYMBOLOGIES_VALUE_CAPS_TRUE];
            
            Symbology *symbol;
            
            for (int i = ZT_SYMBOLOGIES_ZERO; i < [symbologies count]; i++){
                symbol = [symbologies objectAtIndex:i];
                if ([symbol getRMDAttributeID] == symbolAttributeId){
                    SwitchTableViewCell *cell = (SwitchTableViewCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:ZT_SYMBOLOGIES_ZERO]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (cell != nil){
                            [cell setSwitchOn:(enabled == YES) ? NO : YES];
                        }
                    });
                    break;
                }
            }
        }
    } else {
        Symbology *symbologyIndex = [symbologies objectAtIndex:index];
        [symbologyIndex setEnabled:isON];
        [[ScannerEngine sharedScannerEngine] setConfigScannerSymbologySettings:YES];
    }
}


#pragma mark - SwitchTableViewCell Protocol implementation

/// Switch value change
/// @param on status of value
/// @param index index of symbology
- (void)switchValueChanged:(BOOL)on aIndex:(int)index{
    if (index < [symbologies count]){
        if (YES == symbologiesRetrieved){
            Symbology *symbologyOne = (Symbology *)[symbologies objectAtIndex:index];
            NSString *inputXml = [NSString stringWithFormat:ZT_SYMBOLOGIES_INPUT_XML_FORMAT, scannerID, [symbologyOne getRMDAttributeID], (on == YES) ? ZT_SYMBOLOGIES_VALUE_CAPS_TRUE :ZT_SYMBOLOGIES_VALUE_CAPS_FALSE];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
                [self setSymbologyConfiguration:inputXml withIndex:index withStatuc:on];
            });
        }else{
            [self operationComplete];
            [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:ZT_SYMBOLOGIES_RETRIEVED_ERROR_MESSAGE];
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


/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitleLocal:(NSString*)title withMessage:(NSString*)messgae{
    self->alert = [UIAlertController
                    alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:ZT_SYMBOLOGIES_CANNOT_SUPPORT
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                        actionWithTitle:OK
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle ok action
                                }];
    [self->alert addAction:okButton];
    [self presentViewController:self->alert animated:YES completion:nil];
}


#pragma mark - Table View Data Source Delegate Protocol implementation

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return ZT_SYMBOLOGIES_SECTION_COUNT;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [symbologies count];
}


/// Asks the data source for a cell to insert in a particular location of the table view.
/// @param tableView A table-view object requesting the cell.
/// @param indexPath An index path locating a row in tableView.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = ZT_SYMBOLOGIES_CELL_INDENTIFIER;
    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setIndex:(int)[indexPath row]];
    [cell setDelegate:self];
    Symbology *symbology = [symbologies objectAtIndex:[indexPath row]];
    cell.cellTitle.text = [symbology getSymbologyName];
    [cell.cellSwitch setEnabled:[symbology isSupported]];
    [cell setSwitchOn:[symbology isEnabled]];
    
    return cell;
}


@end
