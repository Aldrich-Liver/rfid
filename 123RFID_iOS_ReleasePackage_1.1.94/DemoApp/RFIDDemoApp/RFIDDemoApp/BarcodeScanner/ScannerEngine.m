//
//  ScannerEngine.m
//  SampleApp iOS SP
//
//  Created by Nilusha Wimalasena on 2021-09-07.
//

#import "ScannerEngine.h"
#import <ZebraScannerFramework/SbtSdkFactory.h>
#import <ZebraScannerFramework/RMDAttributes.h>
#import "ui_config.h"
#import "BarcodeDataTableViewController.h"
#import "config.h"
#import "BarcodeTypes.h"
#import "UpdateFirmwareViewController.h"

#define SCANNER_CONNECTION_FAILED @"Connection failed"
#define ZT_NOTIFICATION_KEY_SCANNER_ID         @"SbtNotificationKeyScannerId"
#define ZT_NOTIFICATION_KEY_BARCODE            @"SbtNotificationKeyBarcode"
#define DISCONNECT_FAILED_MESSAGE @"Failed to disconnect. Please try again later"
#define SPACE @" "
#define REPLACE_STRING @""
#define DEVICE_SEARCH_FAILED @"Search for available RFID devices has failed"



@implementation ScannerEngine


+(ScannerEngine *) sharedScannerEngine{
    static ScannerEngine *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[ScannerEngine alloc] init];
    });

    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self != nil){
        scannerList = [[NSMutableArray alloc] init];
        scannerInfoListGuard = [[NSLock alloc] init];
        scannerBarcodeList = [[NSMutableArray alloc] init];
        conectedScannerInfoObject = [ScannerObject sharedInstance];
        deviceConnectionsDelegates = [[NSMutableArray alloc] init];
        firmwareUpdateProgressDelegateList = [[NSMutableArray alloc] init];
        zebraScannerId = ZT_BATCHMODE_NEGATIVE_VALUE;
        [self initializationSDK];
    }
    return  self;
}

/*
This method will initialize the barcode scanner SDK
*/
-(void)initializationSDK{
    // Get instance to the Zebra Scanner SDK API
    sdkApi = [SbtSdkFactory createSbtSdkApiInstance];
    [sdkApi sbtSetDelegate:self];
    NSLog(@"Version %@",[    sdkApi sbtGetVersion]);
    [sdkApi sbtSetOperationalMode:SBT_OPMODE_ALL];
    
    [sdkApi sbtSubsribeForEvents:SBT_EVENT_SCANNER_APPEARANCE |
    SBT_EVENT_SCANNER_DISAPPEARANCE | SBT_EVENT_SESSION_ESTABLISHMENT |
    SBT_EVENT_SESSION_TERMINATION | SBT_EVENT_BARCODE | SBT_EVENT_IMAGE |
    SBT_EVENT_VIDEO];
    
    [sdkApi sbtEnableAvailableScannersDetection:YES];
    isBarcodePageAppear = false;
}

/*
This method will provide the scanner SDK version
- Returns : SDK version
*/
- (NSString *)getSDKVersion
{
    NSString *version = [sdkApi sbtGetVersion];
    return version;
}

/*
This method will provide available scanners list
- Returns : Available scanners list
*/
-(NSMutableArray *)getDeviceList{
    return scannerList;
}
/*
This method will initiate the connection with particuler scanner
Parameter scanner_id: Scanner id of the connecting scanner
*/
-(void)connectScanner:(NSString*)scannerName{
    
    NSMutableArray *deviceListFromBarcodeSDK = [[NSMutableArray alloc] init];
    if (sdkApi != nil)
        {
            [self getAvialbleScannersListFromBarcodeSDK:&(deviceListFromBarcodeSDK)];
            if([self getZebraConnectedScannerID] == -1 || ![self getZebraConnectedScannerID])
            {
                
                for (SbtScannerInfo *scannerInformation in deviceListFromBarcodeSDK)
                {
               
                    NSString *deviceName = [scannerInformation getScannerName];
         
                    NSString *deviceNameFromBarcodeSDK = [self removeSpacesFromString:deviceName];
                    NSString *readerNameFromRFIDSDK = [self removeSpacesFromString:scannerName];
                    
                    if ([deviceNameFromBarcodeSDK isEqualToString:readerNameFromRFIDSDK]) {
                        
                        SBT_RESULT conn_result = [sdkApi sbtEstablishCommunicationSession:[scannerInformation getScannerID]];
                        if (SBT_RESULT_SUCCESS != conn_result)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showMessageBox:SCANNER_CONNECTION_FAILED];
                            });
                        }else{
                            if ([scannerInformation getScannerID] == previousScanner) {
                                ///Display firmware update success on auto-reconnect
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self firmwareUpdateSuccessDisplay];
                                });
                            }
                        }
                    }
                    
                    
                }
               
            }
        }
}


/// Remove Space from string
/// @param deviceName The device name
-(NSString*)removeSpacesFromString:(NSString*) deviceName {
  
    return  [deviceName stringByReplacingOccurrencesOfString:SPACE withString:REPLACE_STRING];
    
}


/// Get avialble scanners list from barcode sdk
/// @param list The scanner list
- (void)getAvialbleScannersListFromBarcodeSDK:(NSMutableArray**)readerListFromBarcodeSDK
{
    NSMutableArray *availableReaderList = [[NSMutableArray alloc] init];
    NSMutableArray *activeReaderList = [[NSMutableArray alloc] init];
    
   
    
    if (sdkApi != nil)
    {
        if ([sdkApi sbtGetAvailableScannersList:&availableReaderList] == SBT_RESULT_FAILURE)
        {
            dispatch_async(dispatch_get_main_queue(),
                ^{
                    [self showMessageBox:DEVICE_SEARCH_FAILED];
                }
            );
        }
        [sdkApi sbtGetActiveScannersList:&activeReaderList];
        
        /* nrv364: due to auto-reconnect option some available scanners may have
         changed to active and thus the same scanner has appeared in two lists */
        for (SbtScannerInfo *act in activeReaderList)
        {
            for (SbtScannerInfo *scannerInformation in availableReaderList)
            {
                if ([scannerInformation getScannerID] == [act getScannerID])
                {
                    [availableReaderList removeObject:scannerInformation];
                    break;
                }
            }
        }
        if ((readerListFromBarcodeSDK != nil) && (*readerListFromBarcodeSDK != nil))
        {
            [*readerListFromBarcodeSDK removeAllObjects];
            [*readerListFromBarcodeSDK addObjectsFromArray:availableReaderList];
            [*readerListFromBarcodeSDK addObjectsFromArray:activeReaderList];
        }
    }
    
    [availableReaderList release];
    [activeReaderList release];
}


/// This method will initiate the disconnection with particuler scanner
/// @param scannerId Scanner id of the disconnecting the scanner
- (void)disconnect:(int)scannerId
{
  
    if (sdkApi != nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_ACTIVE_READER_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SBT_RESULT res = [sdkApi sbtTerminateCommunicationSession:zebraScannerId];
        if (res == SBT_RESULT_FAILURE) {
            [self showMessageBox:DISCONNECT_FAILED_MESSAGE];
        }
    }
}

/// Pull trigger command
/// @Return SBT Result
-(SBT_RESULT)pullTiggerStart{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    if (scannerInfo != NULL){
        NSString *inXML = [NSString stringWithFormat:SCANNER_PULL_RELEASE_TRIGGER_SCAN_XML,[scannerInfo getScannerID]];
        return [[ScannerEngine sharedScannerEngine] executeCommand:SBT_DEVICE_PULL_TRIGGER aInXML:inXML];
    }
    return SBT_RESULT_FAILURE;
}

/// Release trigger command
/// @Return SBT Result
-(SBT_RESULT)releaseTiggerStart{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    if (scannerInfo != NULL){
        NSString *inXML = [NSString stringWithFormat:SCANNER_PULL_RELEASE_TRIGGER_SCAN_XML,[scannerInfo getScannerID]];
        return [[ScannerEngine sharedScannerEngine] executeCommand:SBT_DEVICE_RELEASE_TRIGGER aInXML:inXML];
    }
    return SBT_RESULT_FAILURE;
}

/// Batch request
/// @Return SBT Result
-(SBT_RESULT)scanBatchRequest{
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    if (scannerInfo != NULL){
        NSString *inXML = [NSString stringWithFormat:SCANNER_PULL_RELEASE_TRIGGER_SCAN_XML,[scannerInfo getScannerID]];
        
        return [[ScannerEngine sharedScannerEngine] executeCommand:SBT_DEVICE_BATCH_REQUEST aInXML:inXML];
    }
    return SBT_RESULT_FAILURE;
}


/// Execute command inXML and output xml
/// @param opCode Command code
/// @param inXML Input XML
/// @param outXML Output XML
/// @param scannerID scanner's id
- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString*)outXML forScanner:(int)scannerID
{
    if (sdkApi != nil)
    {
        return [sdkApi sbtExecuteCommand:opCode aInXML:inXML aOutXML:&outXML forScanner:scannerID];
    }
    return SBT_RESULT_FAILURE;
}

/// Execute command inXML only
/// @param opCode Command code
/// @param inXML Input XML
/// @Return SBT Result
- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML{
    if (sdkApi != nil){
        int scannerId = [[conectedScannerInfoObject scannerInfo] getScannerID];
        SBT_RESULT resultExecuteCommand = [sdkApi sbtExecuteCommand:opCode aInXML:inXML aOutXML:NULL forScanner:scannerId];
        return resultExecuteCommand;
    }
    return SBT_RESULT_FAILURE;
}

/// Get connect scanner's info
/// @Return - Scanner's info
-(SbtScannerInfo *)getConnectedScannerInfo{
    return [conectedScannerInfoObject scannerInfo];
}

/*
This method will disable the scanner
*/
-(void)disableScanner {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        int scannerId = [[conectedScannerInfoObject scannerInfo] getScannerID];
        NSString *in_xml = [NSString stringWithFormat:SCANNER_SETTINGS_SCAN_XML, scannerId];
        [sdkApi sbtExecuteCommand:SBT_DEVICE_SCAN_DISABLE aInXML:in_xml aOutXML:nil forScanner:scannerId];
        
    });
    

}

/*
This method will enable the scanner
*/
- (void)enableScanner {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int scannerId = [[conectedScannerInfoObject scannerInfo] getScannerID];
            NSString *in_xml = [NSString stringWithFormat:SCANNER_SETTINGS_SCAN_XML, scannerId];
            [sdkApi sbtExecuteCommand:SBT_DEVICE_SCAN_ENABLE aInXML:in_xml aOutXML:nil forScanner:scannerId];
            
     
        });

              
}

/* ###################################################################### */
/* ########## API calls for UI View Controllers ######################### */
/* ###################################################################### */

/*
Add new view controller to the device event notification list
@param delegate Delegate that need to register with scanner events
*/
- (void)addDeviceEventsDelegate:(id<ScannerEngineConnectionsDelegate>)delegate
{
    [deviceConnectionsDelegates addObject:delegate];
}

/*
Remove view controller to the device event notification list
@param delegate Delegate that need to unregister with scanner events
*/
- (void)removeDeviceEventsDelegate:(id<ScannerEngineConnectionsDelegate>)delegate
{
    [deviceConnectionsDelegates removeObject:delegate];
}


/* ###################################################################### */
/* ########## IDcsSdkApiDelegate Protocol implementation ################ */
/* ###################################################################### */

/*
Barcode event
*/
- (void)sbtEventBarcode:(NSString *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID {
    NSLog(@"sbtEventBarcode");
}

/*
Barcode data event
*/
- (void)sbtEventBarcodeData:(NSData *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID {
    NSLog(@"sbtEventBarcodeData");
    [self addBarcodeDataToList:barcodeData barcodeType:barcodeType scannerId:scannerID];
    
    if ([self delegate] != nil && barcodeData != nil && barcodeType != ST_NOT_APP && [self getBarcodePageIsAppear]){
        
        [_delegate barcodeDataList:barcodeData barcodeType:barcodeType];
    }
   
}

/*
Scanner connected event
*/
- (void)sbtEventCommunicationSessionEstablished:(SbtScannerInfo *)activeScanner {
    NSLog(@"sbtEventCommunicationSessionEstablished");
    conectedScannerInfoObject.scannerInfo = activeScanner;
    BarcodeList* barcodeList = [[BarcodeList alloc] initWithMotoID:[conectedScannerInfoObject.scannerInfo getScannerID] andName:[ conectedScannerInfoObject.scannerInfo getScannerName]];
    [scannerBarcodeList addObject:barcodeList];
    [self setZebraScannerID:[conectedScannerInfoObject.scannerInfo getScannerID]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZT_ACTIVE_READER_KEY];
    [[NSUserDefaults standardUserDefaults]synchronize];
    /* notify connections delegates */
    for (id<ScannerEngineConnectionsDelegate> delegate in [[deviceConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            [delegate scannerHasConnected:[activeScanner getScannerID]];
        }
    }
}

/*
Scanner disconnected event
*/
- (void)sbtEventCommunicationSessionTerminated:(int)scannerID {
    NSLog(@"sbtEventCommunicationSessionTerminated");
    [self setZebraScannerID:ZT_BATCHMODE_NEGATIVE_VALUE];
    /* notify connections delegates */
    for (id<ScannerEngineConnectionsDelegate> delegate in [[deviceConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            [delegate scannerHasDisconnected:scannerID];
        }
    }
    [self removeBarcodeData];
   
}

/// Firmware update event
/// @param fwUpdateEventObj SDK's firmware update event object
- (void)sbtEventFirmwareUpdate:(FirmwareUpdateEvent *)fwUpdateEventObj {
    
    
    if (fwUpdateEventObj.status == SBT_FW_UPDATE_RESULT_LOGIN_REQUIRED){
        
       // [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:@"EU LOGIN"];
    }
    
    
    
    NSLog(@"sbtEventFirmwareUpdate");
    for (id<ScannerAppEngineFirmwareUpdateEventsDelegate> delegate in [[firmwareUpdateProgressDelegateList copy] autorelease]){
        if (delegate != nil) {
            if (delegate != nil && fwUpdateEventObj != nil && [delegate conformsToProtocol:@protocol(ScannerAppEngineFirmwareUpdateEventsDelegate)]){
                [delegate updateUI:fwUpdateEventObj];
            }
        }
    }
}

/// Turn on fast blink LED
- (void)blinkLEDFastON{
    //red LED on
    NSString *inputXMLforLED = [NSString stringWithFormat:ZT_FW_UPDATE_FAST_LED_XML_FORMAT,[[conectedScannerInfoObject scannerInfo] getScannerID], RMD_ATTR_VALUE_ACTION_FAST_BLINK];
    [[ScannerEngine sharedScannerEngine] executeCommand:SBT_SET_ACTION aInXML:inputXMLforLED];
}

/// Turn off fast blink LED
- (void)blinkLEDFastOFF{
    //red LED off
    NSString *inputXMLforLED = [NSString stringWithFormat:ZT_FW_UPDATE_FAST_LED_XML_FORMAT, [[conectedScannerInfoObject scannerInfo] getScannerID], RMD_ATTR_VALUE_ACTION_FAST_BLINK_OFF];
    [[ScannerEngine sharedScannerEngine] executeCommand:SBT_SET_ACTION aInXML:inputXMLforLED];
}

/// Get previous scanner id
- (int)getPreviousScannerId{
    return previousScanner;
}

/// Set previous scanner id
/// @param scannerIdStatus Scanner Id
- (void)setPreviousScanner:(int)scannerIdStatus{
    previousScanner = scannerIdStatus;
}

/// Add firmware update event delegate
/// @param delegate delegate referance
-(void)addFirmwareUpdateEventsDelegate:(id<ScannerAppEngineFirmwareUpdateEventsDelegate>)delegate{
    [firmwareUpdateProgressDelegateList addObject:delegate];
}

/// Remove firmware update event delegate
/// @param delegate delegate referance
-(void)removeFirmwareUpdateEventsDelegate:(id<ScannerAppEngineFirmwareUpdateEventsDelegate>)delegate{
    [firmwareUpdateProgressDelegateList removeObject:delegate];
}


/*
Image data event
*/
- (void)sbtEventImage:(NSData *)imageData fromScanner:(int)scannerID {
    NSLog(@"sbtEventImage");
}

/*
Scanner appired event
*/
- (void)sbtEventScannerAppeared:(SbtScannerInfo *)availableScanner {
    
    /* update dev list */
    BOOL found = NO;
    
    if (YES == [scannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *scannerInfo in [[scannerList copy] autorelease])
        {
            if ([scannerInfo getScannerID] == [availableScanner getScannerID])
            {
                /* find scanner with ID in dev list */
                [scannerInfo setActive:NO];
                [scannerInfo setAvailable:YES];
                [scannerInfo setAutoCommunicationSessionReestablishment:[availableScanner getAutoCommunicationSessionReestablishment]];
                [scannerInfo setConnectionType:[availableScanner getConnectionType]];
                found = YES;
                break;
            }
        }
        
        if (found == NO)
        {
            SbtScannerInfo *scanner_info = [[SbtScannerInfo alloc] init];
            [scanner_info setActive:NO];
            [scanner_info setAvailable:YES];
            [scanner_info setScannerID:[availableScanner getScannerID]];
            [scanner_info setAutoCommunicationSessionReestablishment:[availableScanner getAutoCommunicationSessionReestablishment]];
            [scanner_info setConnectionType:[availableScanner getConnectionType]];
            [scanner_info setScannerName:[availableScanner getScannerName]];
            [scanner_info setScannerModel:[availableScanner getScannerModel]];
            [scannerList addObject:scanner_info];
            [scanner_info release];
        }
        
        [scannerInfoListGuard unlock];
        
    }
    
    /* notify connections delegates */
    for (id<ScannerEngineConnectionsDelegate> delegate in [[deviceConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            [delegate scannerHasAppeared:[availableScanner getScannerID]];
        }
    }
    
}

/*
Scanner disappeared event
*/
- (void)sbtEventScannerDisappeared:(int)scannerID {

    NSString *scannerName = [[[NSString alloc] initWithString:@""] retain];
    
    /* update dev list */
    BOOL found = NO;
    BOOL was_active = NO;
    
    if (YES == [scannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *scannerInfo in [[scannerList copy] autorelease])
        {
            if ([scannerInfo getScannerID] == scannerID)
            {
                /* find scanner with ID in dev list */
                was_active = [scannerInfo isActive];
                scannerName = [[scannerInfo getScannerName] copy];
                
                [scannerInfo setAvailable:NO];

                found = YES;
                break;
            }
        }
        
        
        [scannerInfoListGuard unlock];
    }
    
    /* notify connections delegates */
    for (id<ScannerEngineConnectionsDelegate> delegate in [[deviceConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            [delegate scannerHasDisappeared:scannerID];
        }
    }
    
    [scannerName release];
    
    [self removeBarcodeData];
}

/*
Video event
*/
- (void)sbtEventVideo:(NSData *)videoFrame fromScanner:(int)scannerID {
    NSLog(@"sbtEventVideo");
}

/// To set delegate for the scanner object event.
/// @param viewController The viewcontroller of where we are using the delegate.
-(void)setDelegateForScannerObject:(id)viewController{

    if(viewController != nil){
        _delegate = viewController;
    }
   

}


/// Show message
/// @param message The message description
- (void)showMessageBox:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     
                       UIAlertController * alert = [UIAlertController
                                                    alertControllerWithTitle:ZT_RFID_APP_NAME
                                                    message:message
                                                    preferredStyle:UIAlertControllerStyleAlert];
                       
                       
                       
                       UIAlertAction* cancelButton = [UIAlertAction
                                                      actionWithTitle:OK
                                                      style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action) {
                                                          //Handle cancel button here
                                                      }];
                       
                       [alert addAction:cancelButton];
                       
                       UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                       [topVC presentViewController:alert animated:YES completion:nil];

                   });
}


/// Add barcode data to list
/// @param barcodeData The barcode data
/// @param barcodeType The barcode type
/// @param scannerId The scanner id
- (void)addBarcodeDataToList:(NSData *)barcodeData barcodeType:(int)barcodeType scannerId:(int)scannerId {
    
    
    NSString *scannerName = [[[NSString alloc] initWithString:@""] retain];
    /* add new barcode to barcode list of specified scanner */
  
     /* add new barcode to barcode list of specified scanner */
    for (BarcodeList *barcodeList in [[scannerBarcodeList copy] autorelease])
    {
        if (scannerId == [barcodeList getScannerID])
        {
            BarcodeData *decodeData = [[BarcodeData alloc] initWithData:barcodeData ofType:barcodeType];
            [barcodeList addBarcodeData:decodeData];
            scannerName = [[barcodeList getScannerName] copy];
            [decodeData release];
        }
    }
    
}


/// Get scanner barcodes
- (NSArray*)getScannerBarcodes
{
    /* find barcode list for specified scanner */
    
    for (BarcodeList *barcode_lst in [[scannerBarcodeList copy] autorelease])
    {
        if ([conectedScannerInfoObject.scannerInfo getScannerID]  == [barcode_lst getScannerID])
        {
            return [barcode_lst getBarcodeList];
        }
    }
    
    return nil;
}


/// Clear barcode data when scanner dissapear
-(void)clearBarcodeDataWhenScannerDissapear {
    
    for (int i = 0; i < [scannerBarcodeList count]; i++)
    {
        if ([conectedScannerInfoObject.scannerInfo getScannerID] == [(BarcodeList*)[scannerBarcodeList objectAtIndex:i] getScannerID])
        {
            [scannerBarcodeList removeObjectAtIndex:i];
            break;
        }
    }
}


/// Remove barcode data when scanner disapear or disconnect
-(void)removeBarcodeData {
    
    for (int i = 0; i < [scannerBarcodeList count]; i++)
    {
        if ([conectedScannerInfoObject.scannerInfo getScannerID] == [(BarcodeList*)[scannerBarcodeList objectAtIndex:i] getScannerID])
        {
            [scannerBarcodeList removeObjectAtIndex:i];
            break;
        }
    }
}


/// Clear barcode data from "BarcodeList"  module class
-(void)clearBarcodeData {
    
    for (BarcodeList *barcodeList in [[scannerBarcodeList copy] autorelease])
    {
        if ([conectedScannerInfoObject.scannerInfo getScannerID] == [barcodeList getScannerID])
        {
            [barcodeList clearBarcodeList];
        }
    }
    
}


/// Set barcode page appear status
/// @param appeared The status of barcode page appear
-(void)setBarcodePageAppear:(BOOL)appeared {

    isBarcodePageAppear = appeared;

}


/// Get barcode page appear status
-(BOOL)getBarcodePageIsAppear {

    return isBarcodePageAppear;

}

/// Set selected barcode
/// @param barcodeData Selected barcode's data
-(void)setSelectedBarcodeValue:(BarcodeData *) barcodeData{
    selectedBarcodeData = barcodeData;
}

/// Get selected barcode data
-(BarcodeData *)getSelectedBarcodeValue{
    if (selectedBarcodeData != nil){
        return selectedBarcodeData;
    }else{
        return NULL;
    }
}

/// Removel selected barcode
-(void)removeSelectedBarcodeValue{
    selectedBarcodeData = NULL;
}


/// Get firmware update status
- (BOOL)firmwareDidUpdate{
    return didFirmwareUpdate;
}

/// Set firmware update status
/// @param updateStatus  Status
- (void)setFirmwareDidUpdate:(BOOL)updateStatus
{
    didFirmwareUpdate = updateStatus;
}

/// Create success firmware popup
-(void)firmwareUpdateSuccessDisplay{
    if (didFirmwareUpdate){
        UpdateFirmwareViewController *firmware_vc = (UpdateFirmwareViewController*)[[UIStoryboard storyboardWithName:SCANNER_FIRMWARE_UPDATE_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        UIViewController *topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [firmware_vc setupCloseButton:YES];
        [topVC presentViewController:firmware_vc animated:YES completion:nil];
    }
}

/// Set the scanner id from source class.
/// @param scannerId Scanner id to be save.
- (void)setZebraScannerID:(int)scannerId
{
    zebraScannerId = scannerId;
}


/// Get the saved scanner id.
- (int)getZebraConnectedScannerID
{
    return zebraScannerId;
}


/// Set scanner symbology settings configuraion.
/// - Parameter symbology: Configuration value.
-(void)setConfigScannerSymbologySettings:(BOOL)symbology
{
    isScanSymbologyChanged = symbology;
}

/// Get scanner symbology settings.
-(BOOL)getConfigScannerSymbologySettings
{
    return isScanSymbologyChanged;
}

/// Set scanner beeper settings configuraion.
/// - Parameter beeper: Configuration value.
-(void)setConfigScannerBeeperSettings:(BOOL)beeper
{
    isScanBeeperChanged = beeper;
}

/// Get scanner beeper settings.
-(BOOL)getConfigScannerBeeperSettings
{
    return isScanBeeperChanged;
}

- (BOOL)checkIsThisSecureFirmwareFile:(NSString*)firmwarePath
{
    return [sdkApi isThisSecureFirmwareFile:firmwarePath];
}

- (BOOL)unzippedTheSecureFirmwareFile:(NSString*)password firmwarePath:(NSString*)firmwarePath {
    
    return [sdkApi extractTheSecureFirmwareFile:password firmwarePath:firmwarePath];
    
}

@end
