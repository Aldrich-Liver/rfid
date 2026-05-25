/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  RfidAppEngine.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RfidAppEngine.h"
#import "config.h"
#import "RfidAppKeys.h"
#import <ZebraRfidSdkFramework/RfidSdkFactory.h>
#import <ZebraRfidSdkFramework/RfidLinkProfile.h>
#import <ZebraRfidSdkFramework/RfidAntennaConfiguration.h>
#import <ZebraRfidSdkFramework/RfidSingulationConfig.h>
#import <ZebraRfidSdkFramework/RfidReportConfig.h>
#import "AlertView.h"
#import "RegulatorySettingsVC.h"
#import "BatteryStatusVC.h"
#import "FileExportManager.h"
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>
#import <ZebraRfidSdkFramework/RfidOperEndSummaryEvent.h>
#import <ZebraRfidSdkFramework/RfidDatabaseEvent.h>
#import <ZebraRfidSdkFramework/RfidTemperatureEvent.h>
#import <ZebraRfidSdkFramework/RfidPowerEvent.h>
#import "ui_config.h"
#import "ScannerEngine.h"
#import "SbtScannerInfo+AssetsTblRepresentation.h"
#import <ZebraRfidSdkFramework/RfidWlanProfile.h>
#import <ZebraRfidSdkFramework/RfidWlanScanList.h>
#import <ZebraRfidSdkFramework/RfidWlanCertificates.h>
#import <ZebraRfidSdkFramework/RfidCertificatesList.h>
#import "ProfilesViewController.h"
#import "AdminLoginVC.h"
#import "SettingsVC.h"

#define ZT_MAX_RETRY                          2
#define ZT_NOTIFICATION_KEY_READER_ID         @"ZtSymbolRfidNotificationKeyDeviceId"
#define INVENTORY_IN_BATCH_MODE               @"Inventory Started in Batch Mode"

#define ZT_TAG_EXPORT_INVENTORY_TIME_SESSION

zt_RfidAppEngine *_g_sharedAppEngine;

@interface zt_RfidAppEngine()
{
    zt_SledConfiguration *m_SledConfiguration;
    zt_AppConfiguration *m_AppConfiguration;
    zt_ActiveReader *m_ActiveReader;
    zt_SledConfiguration *m_TemporarySledConfigurationCopy;
    zt_InventoryData *m_InventoryData;
    
    id <srfidISdkApi> m_RfidSdkApi;
    NSMutableArray *m_DeviceInfoList;
    NSLock *m_DeviceInfoListGuard;
    
    NSMutableArray *m_DevListDelegates;
    NSMutableArray *m_ReadEventListDelegates;
    NSMutableArray *m_TriggerEventDelegates;
    NSMutableArray *m_BatteryEventDelegates;
    
    NSMutableArray *multiTagEventDelegates;
    NSMutableArray *m_WlanScanEventDelegates;
    NSMutableArray *m_WlanConnectEventDelegates;
    NSMutableArray *m_WlanDisConnectEventDelegates;
    NSMutableArray *m_WlanOperationFailedEventDelegates;
    NSMutableArray *m_IOTStatusEventDelegates;
    
    NSMutableArray *impingTagDataEventDelegates;
    
    /* nrv364: stores last battery event info */
    srfidBatteryEvent *m_BatteryInfo;
    NSMutableString *m_BatteryStatusStr;
    NSLock *m_BatteryInfoGuard;
    
    zt_RadioOperationEngine *m_RadioOperationEngine;
    NSMutableArray *wifiScanListArray;
    NSLock *wlanProfileListGuard;
    
    srfidIOTStatusEvent *m_IOTStatusInfo;
    NSMutableString *m_IOTStatusStr;
    NSLock *m_IOTStatusInfoGuard;
}
@property (nonatomic, retain) NSMutableDictionary *resultDictioanry;
@property (nonatomic, retain) NSString *readerName;
- (void)fillDeviceList:(NSMutableArray**)list;
- (void)updateInitialSledConfiguration;
- (void)initializeRfidSdkWithAppSettings;
- (int)showBackgroundNotification:(NSString *)text aDictionary:(NSDictionary*)param_dict;
- (void)showMessageBox:(NSString*)message;
- (BOOL)isInBackgroundMode;
- (NSString*)stringOfRfidStatusEvent:(SRFID_EVENT_STATUS)event;
- (NSString*)stringOfRfidMemoryBank:(SRFID_MEMORYBANK)mem_bank;
- (NSString*)stringOfRfidSlFlag:(SRFID_SLFLAG)sl_flag;
- (NSString*)stringOfRfidSession:(SRFID_SESSION)session;
- (NSString*)stringOfRfidInventoryState:(SRFID_INVENTORYSTATE)state;

/* test/debug */
- (void)printInventoryItems;


@end

@implementation zt_RfidAppEngine

+ (zt_RfidAppEngine *) sharedAppEngine
{
    @synchronized([zt_RfidAppEngine class])
    {
        if (_g_sharedAppEngine == nil)
        {
            [[self alloc] init];
        }
        
        return _g_sharedAppEngine;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([zt_RfidAppEngine class])
    {
        NSAssert(_g_sharedAppEngine == nil, @"Attempted to allocate a second instance of a singleton.");
        _g_sharedAppEngine = [super alloc];
        return _g_sharedAppEngine;
    }
    return nil;
}

+(void)destroy
{
    @synchronized([zt_RfidAppEngine class])
    {
        if (_g_sharedAppEngine != nil)
        {
            [_g_sharedAppEngine dealloc];
        }
    }
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        m_SledConfiguration = [[zt_SledConfiguration alloc] init];
        /*
         TBD: sled configuration shall be downloaded from active
         sled on connection establishment
         */
        [m_SledConfiguration setupInitialConfiguration];
        
        m_TemporarySledConfigurationCopy = [[zt_SledConfiguration alloc] init];
        [m_TemporarySledConfigurationCopy setupInitialConfiguration];
        
        m_AppConfiguration = [[zt_AppConfiguration alloc] init];
        [m_AppConfiguration loadAppConfiguration];
        
        m_DeviceInfoList = [[NSMutableArray alloc] init];
        m_DeviceInfoListGuard = [[NSLock alloc] init];
        m_DevListDelegates = [[NSMutableArray alloc] init];
        
        m_ReadEventListDelegates = [[NSMutableArray alloc] init];
        
        m_ActiveReader = [[zt_ActiveReader alloc] init];
        [m_ActiveReader setIsActive:NO withID:nil];
        [m_ActiveReader setBatchModeStatus:NO];
        
        m_InventoryData = [[zt_InventoryData alloc] init];
        
        m_TriggerEventDelegates = [[NSMutableArray alloc] init];
        m_BatteryEventDelegates = [[NSMutableArray alloc] init];
        multiTagEventDelegates = [[NSMutableArray alloc] init];
        m_IOTStatusEventDelegates = [[NSMutableArray alloc] init];
        
        m_BatteryInfo = [[srfidBatteryEvent alloc] init];
        m_BatteryStatusStr = [[NSMutableString alloc] initWithString:@""];
        m_BatteryInfoGuard = [[NSLock alloc] init];
        
        m_IOTStatusInfo = [[srfidIOTStatusEvent alloc] init];
        m_IOTStatusStr = [[NSMutableString alloc] initWithString:@""];
        m_IOTStatusInfoGuard = [[NSLock alloc] init];
        
        m_RadioOperationEngine = [[zt_RadioOperationEngine alloc] init];
        m_WlanScanEventDelegates = [[NSMutableArray alloc] init];
        m_WlanConnectEventDelegates = [[NSMutableArray alloc] init];
        m_WlanOperationFailedEventDelegates = [[NSMutableArray alloc] init];
        m_WlanDisConnectEventDelegates = [[NSMutableArray alloc] init];
        wifiScanListArray = [[NSMutableArray alloc] init];
        
        wlanProfileListGuard = [[NSLock alloc] init];
        
        impingTagDataEventDelegates = [[NSMutableArray alloc] init];
        
        _readerName = @"";
        [self initializeRfidSdkWithAppSettings];
    }
    
    return self;
}

- (void)dealloc
{
    /* release all allocated for singleton objects */
    if (nil != m_SledConfiguration)
    {
        [m_SledConfiguration release];
    }
    if (nil != m_AppConfiguration)
    {
        [m_AppConfiguration release];
    }
    
    if (nil != m_DeviceInfoList)
    {
        [m_DeviceInfoList removeAllObjects];
        [m_DeviceInfoList release];
    }
    if (nil != m_DeviceInfoListGuard)
    {
        [m_DeviceInfoListGuard release];
    }
    
    if (nil != m_DevListDelegates)
    {
        [m_DevListDelegates removeAllObjects];
        [m_DevListDelegates release];
    }
    
    if (nil != m_ReadEventListDelegates)
    {
        [m_ReadEventListDelegates removeAllObjects];
        [m_ReadEventListDelegates release];
    }
    
    if (nil != m_InventoryData)
    {
        [m_InventoryData release];
    }
    
    if (nil != m_ActiveReader)
    {
        [m_ActiveReader release];
    }
    
    if (nil != m_TriggerEventDelegates)
    {
        [m_TriggerEventDelegates removeAllObjects];
        [m_TriggerEventDelegates release];
    }
    
    if (nil != m_BatteryEventDelegates)
    {
        [m_BatteryEventDelegates removeAllObjects];
        [m_BatteryEventDelegates release];
    }
    if (nil != m_WlanScanEventDelegates)
    {
        [m_WlanScanEventDelegates removeAllObjects];
        [m_WlanScanEventDelegates release];
    }
    if (nil != m_WlanConnectEventDelegates)
    {
        [m_WlanConnectEventDelegates removeAllObjects];
        [m_WlanConnectEventDelegates release];
    }
    if (nil != m_WlanDisConnectEventDelegates)
    {
        [m_WlanDisConnectEventDelegates removeAllObjects];
        [m_WlanDisConnectEventDelegates release];
    }
    if (nil != m_WlanOperationFailedEventDelegates)
    {
        [m_WlanOperationFailedEventDelegates removeAllObjects];
        [m_WlanOperationFailedEventDelegates release];
    }
    if (nil != multiTagEventDelegates)
    {
        [multiTagEventDelegates removeAllObjects];
        [multiTagEventDelegates release];
    }
    if (nil != m_IOTStatusEventDelegates)
    {
        [m_IOTStatusEventDelegates removeAllObjects];
        [m_IOTStatusEventDelegates release];
    }
    if (nil != m_BatteryInfo)
    {
        [m_BatteryInfo release];
    }
    
    if (nil != m_BatteryStatusStr)
    {
        [m_BatteryStatusStr release];
    }
    
    if (nil != m_BatteryInfoGuard)
    {
        [m_BatteryInfoGuard release];
    }
    
    if (nil != m_RadioOperationEngine)
    {
        [m_RadioOperationEngine release];
    }
    
    if (nil != wlanProfileListGuard)
    {
        [wlanProfileListGuard release];
    }
    
    if (nil != m_IOTStatusInfo)
    {
        [m_IOTStatusInfo release];
    }
    
    if (nil != m_IOTStatusStr)
    {
        [m_IOTStatusStr release];
    }
    
    if (nil != m_IOTStatusInfoGuard)
    {
        [m_IOTStatusInfoGuard release];
    }
    
    if (nil != _readerName) {
        [_readerName release];
    }
    if (nil != impingTagDataEventDelegates)
    {
        [impingTagDataEventDelegates removeAllObjects];
        [impingTagDataEventDelegates release];
    }
    [super dealloc];
}

- (void)initializeRfidSdkWithAppSettings
{
    m_RfidSdkApi = [srfidSdkFactory createRfidSdkApiInstance];
    [m_RfidSdkApi srfidSetDelegate:self];
    
    NSLog(@"Symbol RFID SDK version: %@", [m_RfidSdkApi srfidGetSdkVersion]);
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    /*
     NSUserDefaults returns 0 for number if the key doesn't exist
     Check that 0 is not a valid value for the parameter
     
     */
    
    /* TBD: nrv364: load/save actual app settings */
    
    int op_mode = (int)[settings integerForKey:ZT_SETTING_OPMODE];
    if (op_mode == 0)
    {
        /* no value => setup default values */
        op_mode = SRFID_OPMODE_MFI;
        [settings setInteger:op_mode forKey:ZT_SETTING_OPMODE];
    }
    
    
    BOOL device_detection = [[self appConfiguration] getConfigConnectionAutoDetection];
    
    int notifications_mask = SRFID_EVENT_READER_APPEARANCE |
    SRFID_EVENT_READER_DISAPPEARANCE |
    SRFID_EVENT_SESSION_ESTABLISHMENT |
    SRFID_EVENT_SESSION_TERMINATION;
    
    BOOL reconnection = [[self appConfiguration] getConfigConnectionAutoReconnection];
    
    /*
     TBD:
     it doesn't matter in which order enable scanner detection and set op mode:
     - when scanner detection becomes enabled, corresponding discover
     procedure is performed;
     - when opmode becomes enabled, if scanner detection is already enabled,
     corresponding discover procedure is performed (moreover, when some
     opmode becomes disabled, all incompatible scanners are removed from
     available/active lists independently on detection option status)
     Update SRS?
     Because enabling of op mode as well as enabling of detection options
     immidiately results in discover procedure, the app SHALL be already suscribed for
     corresponding notifications.
     */
    [m_RfidSdkApi srfidSetOperationalMode:op_mode];
    [m_RfidSdkApi srfidSubsribeForEvents:notifications_mask];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_READ | SRFID_EVENT_MASK_STATUS | SRFID_EVENT_MASK_STATUS_OPERENDSUMMARY)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_TEMPERATURE | SRFID_EVENT_MASK_POWER | SRFID_EVENT_MASK_DATABASE)];
    //[m_RfidSdkApi srfidUnsubsribeForEvents:(SRFID_EVENT_MASK_RADIOERROR | SRFID_EVENT_MASK_POWER | SRFID_EVENT_MASK_TEMPERATURE)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_PROXIMITY)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_TRIGGER)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_BATTERY)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_MULTI_PROXIMITY)];
    [m_RfidSdkApi srfidEnableAvailableReadersDetection:device_detection];
    [m_RfidSdkApi srfidEnableAutomaticSessionReestablishment:reconnection];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_WLAN_SCAN)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_IOT_STATUS)];
    [m_RfidSdkApi srfidSubsribeForEvents:(SRFID_EVENT_MASK_CONNECTED_INTERFACE)];
}

- (zt_SledConfiguration *)sledConfiguration
{
    return m_SledConfiguration;
}

- (zt_AppConfiguration *)appConfiguration
{
    return m_AppConfiguration;
}

- (zt_ActiveReader *)activeReader
{
    return m_ActiveReader;
}

- (zt_SledConfiguration *)temporarySledConfigurationCopy
{
    return m_TemporarySledConfigurationCopy;
}

- (zt_InventoryData *)inventoryData
{
    return m_InventoryData;
}

- (zt_RadioOperationEngine *)operationEngine
{
    return m_RadioOperationEngine;
}

- (void)setConnectedReaderName:(NSString *)readerName
{
    _readerName = [NSString stringWithString:readerName];
}
- (NSString*)getConnectedReaderName
{
    return _readerName;
}

- (int)showBackgroundNotification:(NSString *)text aDictionary:(NSDictionary*)param_dict
{
    /* there is no need for notification when we are in foreground */
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        UILocalNotification * notification = [[UILocalNotification alloc] init];
        if (notification)
        {
            notification.repeatInterval = 0;
            notification.alertBody = text;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.alertAction = ZT_RFID_APP_NAME;
            notification.userInfo = param_dict;
            //[m_UINotificationList addObject:notif];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            [notification release];
        }
    }
    return 0;
}

- (void)showMessageBox:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
        }];
        
        [alert addAction:cancelButton];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];
        
    });
}
-(void)showAuthorizationPopup:(UIViewController*)viewcontroller andaMessage:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        [self loginCall:viewcontroller];
                                                          }];
    [confirmAlert addAction:ok];
    [viewcontroller presentViewController:confirmAlert animated:YES completion:nil];
}

-(void)loginCall:(UIViewController*)viewController
{
    AdminLoginVC * adminlogin_vc = (AdminLoginVC*)[[UIStoryboard storyboardWithName:LOGIN_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:LOGIN_BOARD_ID];
    adminlogin_vc.fromRootView = false;
    [viewController.navigationController pushViewController:adminlogin_vc animated:YES];
}

- (BOOL)isInBackgroundMode
{
    /* TBD: decide if background mode is:
     - !(UIApplicationStateActive) = UIApplicationStateInactive OR UIApplicationStateBackground
     - UIApplicationstateBackground
     */
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
    {
        return YES;
    }
    return NO;
}

- (NSString*)stringOfRfidStatusEvent:(SRFID_EVENT_STATUS)event
{
    if (SRFID_EVENT_STATUS_OPERATION_START == event)
    {
        return @"EVENT_OPERATION_START";
    }
    else if (SRFID_EVENT_STATUS_OPERATION_STOP == event)
    {
        return @"EVENT_OPERATION_STOP";
    }
    else if (SRFID_EVENT_STATUS_OPERATION_BATCHMODE == event)
    {
        return @"EVENT_BATCH_MODE";
    }
    else if (SRFID_EVENT_STATUS_OPERATION_END_SUMMARY == event)
    {
        return @"EVENT_OPERATION_END_SUMMARY";
    }
    else if (SRFID_EVENT_STATUS_TEMPERATURE == event)
    {
        return @"EVENT_TEMPERATURE";
    }
    else if (SRFID_EVENT_STATUS_POWER == event)
    {
        return @"EVENT_POWER";
    }
    else if (SRFID_EVENT_STATUS_DATABASE == event)
    {
        return @"EVENT_DATABASE";
    }
    else if (SRFID_EVENT_STATUS_WLAN_START == event)
    {
        return @"WPN_SCAN_START";
    }
    else if (SRFID_EVENT_STATUS_WLAN_STOP == event)
    {
        return @"WPN_SCAN_STOP";
    }
    else if (SRFID_EVENT_STATUS_WLAN_CONNECT == event)
    {
        return @"WPA_PROFILE_CONNECT";
    }
    else if (SRFID_EVENT_STATUS_WLAN_DISCONNECT == event)
    {
        return @"WPA_PROFILE_DISCONNECT";
    }
    return @"EVENT_UNKNOWN";
}

- (NSString*)stringOfRfidMemoryBank:(SRFID_MEMORYBANK)mem_bank
{
    if (SRFID_MEMORYBANK_EPC == mem_bank)
    {
        return @"EPC";
    }
    else if (SRFID_MEMORYBANK_RESV == mem_bank)
    {
        return @"RESV";
    }
    else if (SRFID_MEMORYBANK_TID == mem_bank)
    {
        return @"TID";
    }
    else if (SRFID_MEMORYBANK_USER == mem_bank)
    {
        return @"USER";
    }
    
    return @"None";
}

- (NSString*)stringOfRfidSlFlag:(SRFID_SLFLAG)sl_flag
{
    switch (sl_flag)
    {
        case SRFID_SLFLAG_ASSERTED:
            return @"ASSERTED";
        case SRFID_SLFLAG_DEASSERTED:
            return @"DEASSERTED";
        case SRFID_SLFLAG_ALL:
            return @"ALL";
    }
    
    return @"Unknown";
}

- (NSString*)stringOfRfidSession:(SRFID_SESSION)session
{
    switch (session)
    {
        case SRFID_SESSION_S1:
            return @"S1";
        case SRFID_SESSION_S2:
            return @"S2";
        case SRFID_SESSION_S3:
            return @"S3";
        case SRFID_SESSION_S0:
            return @"S0";
    }
    
    return @"Unknown";
}

- (NSString*)stringOfRfidInventoryState:(SRFID_INVENTORYSTATE)state
{
    switch (state)
    {
        case SRFID_INVENTORYSTATE_A:
            return @"STATE A";
        case SRFID_INVENTORYSTATE_B:
            return @"STATE B";
        case SRFID_INVENTORYSTATE_AB_FLIP:
            return @"STATE AB FLIP";
    }
    
    return @"Unknown";
}

- (srfidBatteryEvent*)getBatteryInfo
{
    srfidBatteryEvent *_info = [[srfidBatteryEvent alloc] init];
    if (YES == [m_BatteryInfoGuard lockBeforeDate:[NSDate distantFuture]])
    {
        [_info setEventCause:[m_BatteryInfo getEventCause]];
        [_info setIsCharging:[m_BatteryInfo getIsCharging]];
        [_info setPowerLevel:[m_BatteryInfo getPowerLevel]];
        [m_BatteryInfoGuard unlock];
    }
    
    [_info autorelease];
    return _info;
}

- (NSString*)getBatteryStatusString
{
    NSString *res = @"";
    if (YES == [m_BatteryInfoGuard lockBeforeDate:[NSDate distantFuture]])
    {
        res = [NSString stringWithString:m_BatteryStatusStr];
        [m_BatteryInfoGuard unlock];
    }
    return res;
}

- (void)resetBatteryStatusString
{
    if (YES == [m_BatteryInfoGuard lockBeforeDate:[NSDate distantFuture]])
    {
        [m_BatteryStatusStr setString:@""];
        [m_BatteryInfoGuard unlock];
    }
}

- (NSString *)getSDKVersion
{
    NSString *version = [m_RfidSdkApi srfidGetSdkVersion];
    return version;
}

- (void)readerProblem
{
    NSLog(@"%@", @"Problem with reader connection");
    [self showMessageBox:@"Unknown error occured while communicating with RFID reader. Please reconnect it."];
}


- (void)updateInitialSledConfiguration
{
    /* TBD: clean all sled related configuration */
    [m_SledConfiguration setRegionOptions:nil];
    [m_SledConfiguration setSupportedRegions:nil];
    [m_TemporarySledConfigurationCopy setRegionOptions:nil];
    [m_TemporarySledConfigurationCopy setSupportedRegions:nil];
    
    SRFID_RESULT res = [self getRegulatoryConfig:nil];
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        if (NSOrderedSame == [[[m_SledConfiguration getRegulatoryConfig] getRegionCode] caseInsensitiveCompare:@"NA"] || [[m_SledConfiguration getRegulatoryConfig] getRegionCode] == nil)
        {
            NSLog(@"Reader is not configured with a region - 'Command Not Allowed- Region Not Set' error");
            
            
            /*
             nrv364: "Command Not Allowed- Region Not Set" error:
             - user shall select one of supported regions:
             - get supported regions
             - going to UI thread:
             - present regulatory VC in modal mode (save button + disabled back button)
             - on save buttong of regulatory VC perform set regulatory config action
             - disconnect on success with reconnection option
             
             */
            
            res = [self getSupportedRegions:nil];
            
            if (SRFID_RESULT_SUCCESS == res)
            {
                res = SRFID_RESULT_FAILURE;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    zt_RegulatorySettingsVC *vc = (zt_RegulatorySettingsVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_REGULATORY_SETTINGS_VC"];
                    [vc setModalMode:YES];
                    vc.regulatoryDelegate = self;
                    UINavigationController *nav_vc = [[UINavigationController alloc] initWithRootViewController:vc];
                    [nav_vc setModalPresentationStyle:UIModalPresentationFormSheet];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:nav_vc animated:YES completion:nil];
                    [nav_vc release];
                });
                return;
            }
            else
            {
                /* if we have failed to get supported regions -> error message has been presented
                 and reader has been disconnected (refer ::onConfigRequestError) */
            }
        }
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getReaderCapabilitiesInfo:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res) {
        res = [self getSupportedLinkProfiles:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getAntennaConfiguration:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getReaderVersionInfo:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getSingulationConfiguration:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getTagReportConfiguration:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getStartTriggerConfiguration:nil];
        
        /* to be sure, that device has valid settings, we rewrite them */
        
        if (SRFID_RESULT_SUCCESS == res)
        {
            res = [self setStartTriggerConfiguration:nil];
        }
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getStopTriggerConfiguration:nil];
        
        /* to be sure, that device has valid settings, we rewrite them */
        
        if (SRFID_RESULT_SUCCESS == res)
        {
            res = [self setStopTriggerConfiguration:nil];
        }
        
    }
    
    //    if (SRFID_RESULT_SUCCESS == res) {
    //        res = [self getSupportedRegions:nil];
    //    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getBeeperConfig:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getPrefilters:nil];
    }
    
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getDpoConfiguration:nil];
    }
    
    /* fetch all supported regions and detailed info regarding current region only */
    /* detailed info regarding all other regions is requested in RegulatoryVC */
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getSupportedRegions:nil];
        res = [self getBatchModeConfig:nil];
        res = [self getUSBBatchModeConfig:nil];
    }
    if (SRFID_RESULT_SUCCESS == res)
    {
        res = [self getUniqueTagsReportConfiguration:nil];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
        {
            if (delegate != nil)
            {
                [delegate deviceListHasBeenUpdated];
            }
        }
    });
}

- (void)updateProfileSettings;
{
    zt_ProfilesViewController *profile_vc = (zt_ProfilesViewController*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:PROFILE_STORY_BOARD_ID];
    [profile_vc setModalMode:YES];
    UINavigationController *nav_vc = [[UINavigationController alloc] initWithRootViewController:profile_vc];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:nav_vc animated:YES completion:nil];
}

#pragma mark - delegate protocol implementation
/* ###################################################################### */
/* ########## IRfidSdkApiDelegate Protocol implementation ############### */
/* ###################################################################### */

- (void)srfidEventReaderAppeared:(srfidReaderInfo*)availableReader
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    
    /* update dev list */
    BOOL found = NO;
    
    if (YES == [m_DeviceInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (srfidReaderInfo *ex_info in m_DeviceInfoList)
        {
            if ([ex_info getReaderID] == [availableReader getReaderID])
            {
                /* find scanner with ID in dev list */
                [ex_info setActive:NO];
                [ex_info setConnectionType:[availableReader getConnectionType]];
                found = YES;
                break;
            }
        }
        
        if (found == NO)
        {
            srfidReaderInfo *reader_info = [[srfidReaderInfo alloc] init];
            [reader_info setActive:NO];
            [reader_info setReaderID:[availableReader getReaderID]];
            [reader_info setConnectionType:[availableReader getConnectionType]];
            [reader_info setReaderName:[availableReader getReaderName]];
            //[reader_info setReaderModel:[availableReader getReaderModel]];
            [reader_info setReaderModel:[availableReader getReaderName]];
            [reader_info setReaderSerialNumber:[availableReader getReaderSerialNumber]];
            [m_DeviceInfoList addObject:reader_info];
            [reader_info release];
                        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
                [self startAutoReconnect:reader_info];
            });
        }
        
        [m_DeviceInfoListGuard unlock];
    }
    
    //NSString *notif_str = [NSString stringWithFormat:@"New RFID reader (ID [%d]) has appeared", [availableReader getReaderID]];
    NSString *notif_str = [NSString stringWithFormat:@"%@ is available", [availableReader getReaderName]];
    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether available notifications are enabled */
        if (YES == [[self appConfiguration] getConfigNotificationAvailable])
        {
            
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[availableReader getReaderID]] forKey:ZT_NOTIFICATION_KEY_READER_ID];
            [self showBackgroundNotification:notif_str aDictionary:notif_dict];
        }
    }
    
    /* notify dev list delegates */
    for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
    {
        if (delegate != nil)
        {
            result = [delegate deviceListHasBeenUpdated];
        }
    }
    
    if ([self isInBackgroundMode] == NO)
    {
        if (NO == notificaton_processed)
        {
            if (YES == [[self appConfiguration] getConfigNotificationAvailable])
            {
                [zt_AlertView showInfoMessage:[[UIApplication sharedApplication] keyWindow].rootViewController.view withHeader:ZT_RFID_APP_NAME withDetails:notif_str withDuration:1];
            }
            
            /*dispatch_async(dispatch_get_main_queue(), ^{
             [self showMessageBox:[NSString stringWithFormat:@"New RFID reader (ID [%d]) has appeared", [availableReader getReaderID]]];
             });
             */
        }
    }
    
    if([self isPairByScanReaderIsFound:availableReader]){
          
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
            [self pairByScanConnectByReader:availableReader];
        });
    }
    
}

- (void)srfidEventReaderDisappeared:(int)readerID
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    
    /* update dev list */
    BOOL found = NO;
    BOOL was_active = NO;
    
    NSString *notification = nil;
    /*
     if (NO == was_active)
     {
     notification = [NSString stringWithFormat:@"Available RFID reader (ID [%d]) has disappeared", readerID];
     }
     else
     {
     notification = [NSString stringWithFormat:@"Active RFID reader (ID [%d]) has disappeared", readerID];
     }
     */
    
    if (YES == [m_DeviceInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (srfidReaderInfo *ex_info in m_DeviceInfoList)
        {
            if ([ex_info getReaderID] == readerID)
            {
                /* find scanner with ID in dev list */
                notification = [NSString stringWithFormat:@"%@ is unavailable", [ex_info getReaderName]];
                was_active = [ex_info isActive];
                [m_DeviceInfoList removeObject:ex_info];
                found = YES;
                break;
            }
        }
        
        if (found == NO)
        {
            /* TBD */
            NSLog(@"RfidAppEngine:srfidEventReaderDisappeared: device is not in list");
        }
        
        [m_DeviceInfoListGuard unlock];
    }
    
    if (NO == found)
    {
        notification = [NSString stringWithFormat:@"RFID reader (ID [%d]) has disappeared", readerID];
    }
    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether available notifications are enabled */
        if (YES == [[self appConfiguration] getConfigNotificationAvailable])
        {
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:readerID] forKey:ZT_NOTIFICATION_KEY_READER_ID];
            [self showBackgroundNotification:notification aDictionary:notif_dict];
        }
    }
    
    /* notify dev list delegates */
    for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
    {
        if (delegate != nil)
        {
            result = [delegate deviceListHasBeenUpdated];
        }
    }
    
    if ([self isInBackgroundMode] == NO)
    {
        if (notificaton_processed == NO)
        {
            if (YES == [[self appConfiguration] getConfigNotificationAvailable])
            {
                [zt_AlertView showInfoMessage:[[UIApplication sharedApplication] keyWindow].rootViewController.view withHeader:ZT_RFID_APP_NAME withDetails:notification withDuration:1];
            }
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self showMessageBox:notification];
            //            });
        }
    }
}

/// Auto connect store
/// @param connectedReader reader informations
-(void)setAutoConnectDeviceDetails:(srfidReaderInfo*)connectedReader{
    [[NSUserDefaults standardUserDefaults] setInteger:[connectedReader getReaderID] forKey:ZT_AUTO_CONNECT_READER_ID];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_AUTO_CONNECT_TERMINATE_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Get auto connect scanner details
-(BOOL)isShouldAutoConnect:(srfidReaderInfo*)readerInfo{
    int readerId = [[[NSUserDefaults standardUserDefaults] objectForKey:ZT_AUTO_CONNECT_READER_ID] intValue];
    BOOL isTerminate = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_AUTO_CONNECT_TERMINATE_STATE];
    if (readerId == [readerInfo getReaderID] && isTerminate){
        return YES;
    }else{
        return NO;
    }
}

/// Start auto reconnect
/// @param ex_info reader information
-(void)startAutoReconnect:(srfidReaderInfo *)ex_info{
    BOOL isAutoReconnectSessionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_AUTO_CONNECT_CONFIG_IS_ENABLED];
    if (!isAutoReconnectSessionEnabled) {
        return;
    }
    if (![ex_info isActive] == YES) {
        if ([self isShouldAutoConnect:ex_info] ){
            [self connect:[ex_info getReaderID]];
        }
    }
}

/// Reset auto reconnect
-(void)resetAutoReconnect{
    [[NSUserDefaults standardUserDefaults] setInteger:ZT_AUTO_CONNECT_CONFIG_RESET_ID forKey:ZT_AUTO_CONNECT_READER_ID];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_AUTO_CONNECT_TERMINATE_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)srfidEventCommunicationSessionEstablished:(srfidReaderInfo*)activeReader
{
    BOOL notificaton_processed = NO;
    
    /* update dev list */
    BOOL found = NO;
    
    
    NSString *notification = nil;
    notification = [NSString stringWithFormat:@"%@ has connected", [activeReader getReaderName]];
    /*
     if (NO == found)
     {
     notification = [NSString stringWithFormat:@"Communication session with appeared RFID reader (ID [%d]) has been established", [activeReader getReaderID]];
     }
     else
     {
     notification = [NSString stringWithFormat:@"Communication session with RFID reader (ID [%d]) has been established", [activeReader getReaderID]];
     }
     */
    
    if (YES == [m_DeviceInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (srfidReaderInfo *ex_info in m_DeviceInfoList)
        {
            if ([ex_info getReaderID] == [activeReader getReaderID])
            {
                /* find scanner with ID in the device list */
                [ex_info setActive:[activeReader isActive]];
                [ex_info setConnectionType:[activeReader getConnectionType]];
                [[ScannerEngine sharedScannerEngine] connectScanner:[activeReader getReaderName]];
                [self setAutoConnectDeviceDetails:ex_info];
                found = YES;
                
                break;
            }
        }
        
        if (found == NO)
        {
            /* TBD */
            NSLog(@"RfidAppEngine:srfidEventSessionEstablished: device is not in list");
            
            if (found == NO)
            {
                [m_DeviceInfoList addObject:activeReader];
            }
        }
        
        [m_DeviceInfoListGuard unlock];
    }
    
    // set as the primary reader
    [m_ActiveReader setIsActive:YES withID:[NSNumber numberWithInt:[activeReader getReaderID]]];
    
    // check transition from background mode to front
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether active notifications are enabled */
        if (YES == [[self appConfiguration] getConfigNotificationConnection])
        {
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[activeReader getReaderID]] forKey:ZT_NOTIFICATION_KEY_READER_ID];
            [self showBackgroundNotification:notification aDictionary:notif_dict];
        }
    }
    
    
    if ([self isInBackgroundMode] == NO)
    {
        if (NO == notificaton_processed)
        {
            /* nrv364: show "connected" notifification together with "getting config" alert */
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             [self showMessageBox:notification];
             });
             */
        }
    }
    
    /* nrv364: reset stored critical/low battery status */
    [self resetBatteryStatusString];
    
    /* nrv364:
     ASCII connection is required for complete work */
        
    if([[ScannerEngine sharedScannerEngine] firmwareDidUpdate])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self establishAsciiConnection];
        });
    }
    else
    {
        [self establishAsciiConnection];
    }
}

- (void)srfidEventCommunicationSessionTerminated:(int)readerID
{
    [m_RadioOperationEngine eventSessionTerminated];
    
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    
    /* update dev list */
    BOOL found = NO;
    
    NSString *notification = nil;
    if (YES == [m_DeviceInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (srfidReaderInfo *ex_info in m_DeviceInfoList)
        {
            if ([ex_info getReaderID] == readerID)
            {
                /* find scanner with ID in dev list */
                [ex_info setActive:NO];
                found = YES;
                notification = [NSString stringWithFormat:@"%@ has disconnected", [ex_info getReaderName]];
                break;
            }
        }
        
        if (found == NO)
        {
            /* TBD */
            NSLog(@"RfidAppEngine:srfidEventSessionTerminated: device is not in list");
        }
        
        [m_DeviceInfoListGuard unlock];
    }
    
    if(YES == found)
    {
        if ([m_ActiveReader isActive] && [m_ActiveReader getReaderID] == readerID) {
            [m_ActiveReader setIsActive:NO withID:nil];
        }
    }
    
    if (NO == found)
    {
        notification = [NSString stringWithFormat:@"RFID reader (ID [%d]) has disconnected", readerID];
    }
    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether active notifications are enabled */
        if (YES == [[self appConfiguration] getConfigNotificationConnection])
        {
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:readerID] forKey:ZT_NOTIFICATION_KEY_READER_ID];
            [self showBackgroundNotification:notification aDictionary:notif_dict];
        }
    }
    
    /* notify dev list delegates */
    for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
    {
        if (delegate != nil)
        {
            result = [delegate deviceListHasBeenUpdated];
        }
    }
    
    if ([self isInBackgroundMode] == NO)
    {
        if (notificaton_processed == NO)
        {
            if (YES == [[self appConfiguration] getConfigNotificationConnection])
            {
                [zt_AlertView showInfoMessage:[[UIApplication sharedApplication] keyWindow].rootViewController.view withHeader:ZT_RFID_APP_NAME withDetails:notification withDuration:3];
            }
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self showMessageBox:[NSString stringWithFormat:@"Communication session with RFID reader (ID [%d]) has been terminated", readerID]];
            //            });
        }
    }
}


/// Wifi scan event.
/// - Parameters:
///   - readerID: The reader id.
///   - wlanScanObject: Wlan object data.
- (void)srfidEventWifiScan:(int)readerID wlanSCanObject:(srfidWlanScanList *)wlanScanObject{
    
    if (![[wlanScanObject getWlanSSID] isEqualToString:EMPTY_STRING]) {
        [wifiScanListArray addObject:wlanScanObject];
    }
}

- (void)srfidEventIOTSatusNotity:(int)readerID aIOTStatusEvent:(srfidIOTStatusEvent*)iotStatusEvent
{
    NSLog(@"\nIOTStatusEvent: cause = (%@) eptype = (%@) epname = (%@) status = (%@) reason = (%@)\n", [iotStatusEvent getCause], [iotStatusEvent getEpType], [iotStatusEvent getEpName], [iotStatusEvent getStatus], [iotStatusEvent getReason]);
    
    for (id<zt_IRfidAppEngineIOTStatusEventDelegate> delegate in m_IOTStatusEventDelegates)
    {
        if (delegate != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate onNewIOTStatusEvent:iotStatusEvent];
            });
        }
    }
}

- (void)srfidEventReadNotify:(int)readerID aTagData:(srfidTagData*)tagData
{
    /* nrv364: thread is unknown */
    //NSLog(@"eventReadNotify: tagId = %@, memory_bank = %@\n", [tagData getTagId], ([tagData getMemoryBankData] == nil ? @"null" : [tagData getMemoryBankData]));
    for (id<zt_IRfidAppEngineTagDataEventForImpingTag> delegate in impingTagDataEventDelegates )
    {
        if (delegate != nil && ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeRepeat] == NO))
        {
            dispatch_async([m_RadioOperationEngine getQueue], ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [delegate impingTagDataEventDelegate:tagData];
                    [delegate impingTagDataEvent:tagData];
                });
            });
        }
    }
    
    
    
    if ([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank] == SRFID_MEMORYBANK_TAMPER) {
        if ([tagData getOperationSucceed]) {
            [m_RadioOperationEngine eventTagData:tagData];
        }
    }else
    {
        [m_RadioOperationEngine eventTagData:tagData];
    }
}

- (void)srfidEventStatusNotify:(int)readerID aEvent:(SRFID_EVENT_STATUS)event aNotification:(id)notificationData
{
    /* nrv364: thread is unknown */
    NSLog(@"eventStatusNotify: %@\n", [self stringOfRfidStatusEvent:event]);
    
    if (event == SRFID_EVENT_STATUS_OPERATION_BATCHMODE) {
        [m_ActiveReader setBatchModeStatus:YES];
        [m_ActiveReader setBatchModeRepeat:[notificationData boolValue]];
    }
    
    if (event == SRFID_EVENT_STATUS_OPERATION_BATCHMODE || event == SRFID_EVENT_STATUS_OPERATION_START)
        [m_RadioOperationEngine eventRadioOperation:YES];
    else if(event == SRFID_EVENT_STATUS_OPERATION_STOP)
        [m_RadioOperationEngine eventRadioOperation:NO];
    else if (event == SRFID_EVENT_STATUS_OPERATION_END_SUMMARY)
    {
        NSLog(@"notification:::%@,,totalrounds:::%d,totaltags:%d,,,totalTimeUS::%ld",notificationData,[(srfidOperEndSummaryEvent *)notificationData getTotalRounds],[(srfidOperEndSummaryEvent *)notificationData getTotalTags],[(srfidOperEndSummaryEvent *)notificationData getTotalTimeUs]);
    }
    else if (event == SRFID_EVENT_STATUS_DATABASE)
    {
        NSLog(@"notification:%@ Cause:%@ EntriesUsed:%d EntriesRemaining::%d",notificationData,[(srfidDatabaseEvent *)notificationData getCause],[(srfidDatabaseEvent *)notificationData getEntriesUsed],[(srfidDatabaseEvent *)notificationData getEntriesRemaining]);
    }
    else if (event == SRFID_EVENT_STATUS_TEMPERATURE)
    {
        NSLog(@"notification:%@ Cause:%@ Ambient Temperature:%d Radio Temperature::%d",notificationData,[(srfidTemperatureEvent *)notificationData getEventCause],[(srfidTemperatureEvent *)notificationData getSTM32Temp],[(srfidTemperatureEvent *)notificationData getRadioPATemp]);
    }
    else if (event == SRFID_EVENT_STATUS_POWER)
    {
        NSLog(@"notification:%@ Cause:%@ Voltage:%f Current:%f",notificationData,[(srfidPowerEvent *)notificationData getCause],[(srfidPowerEvent *)notificationData getVoltage],[(srfidPowerEvent *)notificationData getCurrent]);
    }
    else if (event == SRFID_EVENT_STATUS_WLAN_START) {
        NSLog(@"Demo App notification: Wlan scan Start");
        [wifiScanListArray removeAllObjects];
        for (id<zt_IRfidAppEngineWlanScanEventDelegate> delegate in m_WlanScanEventDelegates )
        {
            if (delegate != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewWlanScanEvent:ZT_WIFI_START_EVENT];
                });
            }
        }
    }
    else if (event == SRFID_EVENT_STATUS_WLAN_STOP) {
        NSLog(@"Demo App notification: Wlan scan stop");
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setWIFIListArray:wifiScanListArray];
        for (id<zt_IRfidAppEngineWlanScanEventDelegate> delegate in m_WlanScanEventDelegates)
        {
            if (delegate != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewWlanScanEvent:ZT_WIFI_STOP_EVENT];
                });
            }
        }
    }
    else if (event == SRFID_EVENT_STATUS_WLAN_CONNECT)
    {
        NSLog(@"Demo App notification: Wlan connect");
        
        for (id<zt_IRfidAppEngineWlanConnectEventDelegate> delegate in m_WlanConnectEventDelegates )
        {
            if (delegate != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewWlanConnectEvent:ZT_WIFI_CONNECT_EVENT];
                });
            }
        }
    }
    else if (event == SRFID_EVENT_STATUS_WLAN_DISCONNECT)
    {
        NSLog(@"Demo App notification: Wlan disconnect");
        
        for (id<zt_IRfidAppEngineWlanDisConnectEventDelegate> delegate in m_WlanDisConnectEventDelegates )
        {
            if (delegate != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewWlanDisConnectEvent:ZT_WIFI_DISCONNECT_EVENT];
                });
            }
        }
    }
    else
    {
        NSLog(@"Demo App notification: operation failed");
        for (id<zt_IRfidAppEngineWlanOperationFailedEventDelegate> delegate in m_WlanOperationFailedEventDelegates )
        {
            if (delegate != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewWlanOperationFailedEvent:ZT_WIFI_OPERATION_FAILED_EVENT];
                });
            }
        }
    }
    [m_RadioOperationEngine setCurrentBatchModeStatus:event];
}

- (void)srfidEventProximityNotify:(int)readerID aProximityPercent:(int)proximityPercent
{
    /* nrv364: thread is unknown */
    //    NSLog(@"eventProximityNotify: %d\n", proximityPercsent);
    
    [m_RadioOperationEngine eventProximityData:proximityPercent];
}

- (void)srfidEventTriggerNotify:(int)readerID aTriggerEvent:(SRFID_TRIGGEREVENT)triggerEvent
{
    /* nrv364: thread is unknown */
    NSLog(@"\nTriggerEvent: %d (%@)\n", triggerEvent, (triggerEvent == SRFID_TRIGGEREVENT_PRESSED ? @"PRESS" : @"RELEASE"));
    
    for (id<zt_IRfidAppEngineTriggerEventDelegate> delegate in m_TriggerEventDelegates )
    {
        if (delegate != nil && ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeRepeat] == NO))
        {
            dispatch_async([m_RadioOperationEngine getQueue], ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (SRFID_TRIGGEREVENT_SCAN_RELEASED == triggerEvent || SRFID_TRIGGEREVENT_SCAN_PRESSED == triggerEvent){
                        NSLog(@"Scan_Notification_Event: (%@)\n", (triggerEvent == SRFID_TRIGGEREVENT_SCAN_PRESSED ? @"PRESS" : @"RELEASE"));
                        [delegate onNewTriggerEvent:SRFID_TRIGGEREVENT_PRESSED == triggerEvent typeRFID:NO];
                    }else{
                        [delegate onNewTriggerEvent:SRFID_TRIGGEREVENT_PRESSED == triggerEvent typeRFID:YES];
                    }
                });
            });
        }
    }
}

- (void)srfidEventBatteryNotity:(int)readerID aBatteryEvent:(srfidBatteryEvent*)batteryEvent
{
    /* nrv364: thread is unknown */
    NSLog(@"\nbatteryEvent: level = [%d] charging = [%d] cause = (%@)\n", [batteryEvent getPowerLevel], [batteryEvent getIsCharging], [batteryEvent getEventCause]);
    
    BOOL _is_low = NO;
    BOOL _is_critical = NO;
    
    _is_low = (NSOrderedSame == [[batteryEvent getEventCause] caseInsensitiveCompare:ZT_BATTERY_EVENT_CAUSE_LOW]);
    _is_critical = (NSOrderedSame == [[batteryEvent getEventCause] caseInsensitiveCompare:ZT_BATTERY_EVENT_CAUSE_CRITICAL]);
    
    
    if (YES == [m_BatteryInfoGuard lockBeforeDate:[NSDate distantFuture]])
    {
        [m_BatteryInfo setPowerLevel:[batteryEvent getPowerLevel]];
        [m_BatteryInfo setIsCharging:[batteryEvent getIsCharging]];
        [m_BatteryInfo setEventCause:[batteryEvent getEventCause]];
        
        /* nrv364:
         - store low/critical battery status if reported
         - reset low/critical battery status if charging is on
         */
        if ((YES == _is_low) || (YES == _is_critical))
        {
            if (YES == [m_AppConfiguration getConfigNotificationBattery])
            {
                [m_BatteryStatusStr setString:[batteryEvent getEventCause]];
            }
        }
        if (YES == [batteryEvent getIsCharging])
        {
            [m_BatteryStatusStr setString:@""];
        }
        
        [m_BatteryInfoGuard unlock];
    }
    
    /* inform battery status screen */
    for (id<zt_IRfidAppEngineBatteryEventDelegate> delegate in m_BatteryEventDelegates )
    {
        if (delegate != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate onNewBatteryEvent];
            });
        }
    }
    
    /* proceed with notifications for low/critical causes */
    if (YES == [m_AppConfiguration getConfigNotificationBattery])
    {
        /* proceed with notifications for low/critical causes */
        NSString *battery_notification = @"";
        if (YES == _is_critical)
        {
            battery_notification = @"Battery is critical! Please charge the Sled";
        }
        else if (YES == _is_low)
        {
            battery_notification = @"Battery is low! Please charge the Sled";
            
            
        }
        
        if (0 < [battery_notification length])
        {
            if (YES == [self isInBackgroundMode])
            {
                [self showBackgroundNotification:battery_notification aDictionary:nil];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [zt_AlertView showInfoMessage:[[UIApplication sharedApplication] keyWindow].rootViewController.view withHeader:ZT_RFID_APP_NAME withDetails:battery_notification withDuration:3];
                });
            }
        }
    }
}

/// The event of multi proximity notify
/// @param readerID The reader id
/// @param tagData The tag data
- (void)srfidEventMultiProximityNotify:(int)readerID aTagData:(srfidTagData *)tagData {
    
    for (id<zt_IRfidAppEngineMultiTagEventDelegate> delegate in multiTagEventDelegates )
    {
        if (delegate != nil && ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeRepeat] == NO))
        {
            dispatch_async([m_RadioOperationEngine getQueue], ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onNewMultiTagEvent:tagData];
                });
            });
        }
    }
    
}



/* ###################################################################### */
/* ########## interface for UI implementation ########################### */
/* ###################################################################### */

- (void)addDeviceListDelegate:(id<zt_IRfidAppEngineDevListDelegate>)delegate
{
    [m_DevListDelegates addObject:delegate];
}

- (void)removeDeviceListDelegate:(id<zt_IRfidAppEngineDevListDelegate>)delegate
{
    [m_DevListDelegates removeObject:delegate];
}

- (void)addTriggerEventDelegate:(id<zt_IRfidAppEngineTriggerEventDelegate>)delegate
{
    [m_TriggerEventDelegates addObject:delegate];
}

- (void)removeTriggerEventDelegate:(id<zt_IRfidAppEngineTriggerEventDelegate>)delegate
{
    [m_TriggerEventDelegates removeObject:delegate];
}

- (void)addBatteryEventDelegate:(id<zt_IRfidAppEngineBatteryEventDelegate>)delegate
{
    [m_BatteryEventDelegates addObject:delegate];
}
- (void)multiTagEventDelegate:(id<zt_IRfidAppEngineMultiTagEventDelegate>)delegate
{
    [multiTagEventDelegates addObject:delegate];
}

- (void)removeBatteryEventDelegate:(id<zt_IRfidAppEngineBatteryEventDelegate>)delegate
{
    [m_BatteryEventDelegates removeObject:delegate];
}
- (void)impingTagDataEventDelegate:(id<zt_IRfidAppEngineTagDataEventForImpingTag>)delegate{
    [impingTagDataEventDelegates addObject:delegate];
}
- (void)addWlanScanEventDelegate:(id<zt_IRfidAppEngineWlanScanEventDelegate>)delegate
{
    [m_WlanScanEventDelegates addObject:delegate];
}

- (void)removeWlanScanEventDelegate:(id<zt_IRfidAppEngineWlanScanEventDelegate>)delegate
{
    [m_WlanScanEventDelegates removeObject:delegate];
}
- (void)addWlanConnectEventDelegate:(id<zt_IRfidAppEngineWlanConnectEventDelegate>)delegate
{
    [m_WlanConnectEventDelegates addObject:delegate];
}

- (void)removeWlanConnectEventDelegate:(id<zt_IRfidAppEngineWlanConnectEventDelegate>)delegate
{
    [m_WlanConnectEventDelegates removeObject:delegate];
}

- (void)addWlanDisConnectEventDelegate:(id<zt_IRfidAppEngineWlanDisConnectEventDelegate>)delegate
{
    [m_WlanDisConnectEventDelegates addObject:delegate];
}

- (void)removeWlanDisConnectEventDelegate:(id<zt_IRfidAppEngineWlanDisConnectEventDelegate>)delegate
{
    [m_WlanDisConnectEventDelegates removeObject:delegate];
}

- (void)addWlanOperationFailedEventDelegate:(id<zt_IRfidAppEngineWlanOperationFailedEventDelegate>)delegate
{
    [m_WlanOperationFailedEventDelegates addObject:delegate];
}

- (void)removeWlanOperationFailedEventDelegate:(id<zt_IRfidAppEngineWlanOperationFailedEventDelegate>)delegate
{
    [m_WlanOperationFailedEventDelegates removeObject:delegate];
}

- (void)addIOTStatusEventDelegate:(id<zt_IRfidAppEngineIOTStatusEventDelegate>)delegate
{
    [m_IOTStatusEventDelegates addObject:delegate];
}

- (void)removeIOTStatusEventDelegate:(id<zt_IRfidAppEngineIOTStatusEventDelegate>)delegate
{
    [m_IOTStatusEventDelegates removeObject:delegate];
}

#pragma mark - base commands

- (NSArray*)getActualDeviceList
{
    return m_DeviceInfoList;
}

- (void)connect:(int)reader_id
{
    if (m_RfidSdkApi != nil)
    {
        SRFID_RESULT conn_result = [m_RfidSdkApi srfidEstablishCommunicationSession:reader_id];
        /*Setting batch mode to default after connect and will be set back if and when event is received*/
        [m_ActiveReader setBatchModeStatus:NO];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:ZT_DEVICEINFO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZT_DEVICEINFO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:ZT_DEVICEINFO_API_CALL];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:SELECTED_LP_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_LP_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PROFILE_OPENED_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PROFILE_OPENED_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PROFILE_UPDATED_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PROFILE_UPDATED_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FACTORY_RESET_MODE_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DPO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:DPO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (SRFID_RESULT_SUCCESS != conn_result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageBox:@"Connection failed"];
            });
        }
    }
}

- (SRFID_RESULT)locateReader:(BOOL)doEnabled message:(NSString **)statusMessage
{
    SRFID_RESULT conn_result = SRFID_RESULT_FAILURE;
    if (m_RfidSdkApi != nil)
    {
        conn_result = [m_RfidSdkApi srfidLocateReader:[m_ActiveReader getReaderID] doEnabled:doEnabled aStatusMessage:statusMessage];
        
        if (SRFID_RESULT_SUCCESS != conn_result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageBox:@"Couldn't locate reader"];
            });
        }
    }
    return conn_result;
}


- (void)disconnect:(int)reader_id
{
    if (m_RfidSdkApi != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:ZT_DEVICEINFO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZT_DEVICEINFO_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:ZT_DEVICEINFO_API_CALL];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_ACTIVE_READER_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [m_RfidSdkApi srfidTerminateCommunicationSession:reader_id];
        [self resetAutoReconnect];
    }
}

- (void)updateDeviceList
{
    if (YES == [m_DeviceInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        [m_DeviceInfoList removeAllObjects];
        [self fillDeviceList:&(m_DeviceInfoList)];
        
        
        [m_DeviceInfoListGuard unlock];
    }
    
    /* notify delegates */
    for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
    {
        if (delegate != nil)
        {
            /* TBD: appear/disappear, connect/disconnect logic ? */
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate deviceListHasBeenUpdated];
            });
        }
    }
}

- (void)fillDeviceList:(NSMutableArray**)list
{
    NSMutableArray *available = [[NSMutableArray alloc] init];
    NSMutableArray *active = [[NSMutableArray alloc] init];
    
    if (m_RfidSdkApi != nil)
    {
        if ([m_RfidSdkApi srfidGetAvailableReadersList:&available] == SRFID_RESULT_FAILURE)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                [self showMessageBox:@"Searhing for available readers has failed"];
            }
                           );
        }
        [m_RfidSdkApi srfidGetActiveReadersList:&active];
        
        /* nrv364: due to auto-reconnect option some available scanners may have
         changed to active and thus the same scanner has appeared in two lists */
        for (srfidReaderInfo *act in active)
        {
            for (srfidReaderInfo *av in available)
            {
                if ([av getReaderID] == [act getReaderID])
                {
                    [available removeObject:av];
                    break;
                }
            }
        }
        if ((list != nil) && (*list != nil))
        {
            [*list removeAllObjects];
            [*list addObjectsFromArray:available];
            [*list addObjectsFromArray:active];
        }
    }
    
    [available release];
    [active release];
}

- (void)sendCommand:(NSString*)cmd forReader:(int)reader_id
{
    if (nil != m_RfidSdkApi)
    {
        //[m_RfidSdkApi srfidSendCommand:cmd bytesWritten:nil forReader:reader_id];
    }
}

#pragma mark - Brand id reading command
/// Perform inventory when  brand id is enable in tag report viewcontroller
/// @param readerID  The reader id
/// @param memoryBankId  The memory ban
/// @param reportConfig  The report configuration object
/// @param accessConfig  The access configuration object
/// @param statusMessage  The status message
/// @param brandId  The brand id
/// @param epcLenth  The epc length
- (SRFID_RESULT) sdkPerformBrandCheckInventory:(int)readerID aMemoryBank:(SRFID_MEMORYBANK)memoryBankId aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage  brandId:(NSString*)brandId epcLenth:(int)epcLenth
{
    
    
    if (nil != m_RfidSdkApi)
    {
        SRFID_RESULT result = [m_RfidSdkApi srfidPerformBrandCheckInventory:readerID aMemoryBank:memoryBankId aReportConfig:reportConfig aAccessConfig:accessConfig aStatusMessage:statusMessage brandId:brandId epcLenth:epcLenth];
        
        if ([*statusMessage isEqualToString:INVENTORY_IN_BATCH_MODE]) {
            [m_ActiveReader setBatchModeStatus:YES];
        }
        return result;
        
    }
    return SRFID_RESULT_FAILURE;
}
#pragma mark - reading command
- (SRFID_RESULT) sdkStartInventory:(int)readerID aMemoryBank:(SRFID_MEMORYBANK)memoryBankId aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage
{
    /*
     nrv364:
     temporary workaround for following issue:
     - for some reason region related information retrieval was moved from reader connection
     event to appearance of particular UI screens (regulatory & save settings) - Pragnesh
     - if radio operation is started without region data a crash will occur when
     user opens regulatory or save settings screen as region related information retrieval will
     fail with "radio operation in progress" error
     */
    //[self loadRegionsInfoIfRequired];
    
    if (nil != m_RfidSdkApi)
    {
        SRFID_RESULT result = [m_RfidSdkApi srfidStartInventory:readerID aMemoryBank:memoryBankId aReportConfig:reportConfig aAccessConfig:accessConfig aStatusMessage:statusMessage];
        
        if ([*statusMessage isEqualToString:@"Inventory Started in Batch Mode"]) {
            [m_ActiveReader setBatchModeStatus:YES];
        }
        return result;
        /*
         if (SRFID_MEMORYBANK_NONE == memoryBankId)
         {
         return [m_RfidSdkApi srfidStartRapidRead:readerID aReportConfig:reportConfig aAccessConfig:accessConfig aStatusMessage:statusMessage];
         }
         else
         {
         return [m_RfidSdkApi srfidStartInventory:readerID aMemoryBank:memoryBankId aReportConfig:reportConfig aAccessConfig:accessConfig aStatusMessage:statusMessage];
         }
         */
    }
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT) sdkStopInventory:(int)readerID aStatusMessage:(NSString**)statusMessage
{
    if (nil != m_RfidSdkApi)
    {
        return [m_RfidSdkApi srfidStopInventory:readerID aStatusMessage:statusMessage];
    }
    return SRFID_RESULT_FAILURE;
}


#pragma mark - tag locationing commands

- (SRFID_RESULT)sdkStartTagLocationing:(int)readerID aEpcId:(NSString*)tagEpcID aStatusMessage:(NSString **)statusMessage;
{
    /*
     nrv364:
     temporary workaround for following issue:
     - for some reason region related information retrieval was moved from reader connection
     event to appearance of particular UI screens (regulatory & save settings) - Pragnesh
     - if radio operation is started without region data a crash will occur when
     user opens regulatory or save settings screen as region related information retrieval will
     fail with "radio operation in progress" error
     */
    //[self loadRegionsInfoIfRequired];
    
    if(m_RfidSdkApi != nil)
    {
        SRFID_RESULT srfid_result = [m_RfidSdkApi srfidStartTagLocationing:[m_ActiveReader getReaderID] aTagEpcId:tagEpcID aStatusMessage:statusMessage];
        return srfid_result;
    }
    return SRFID_RESULT_FAILURE;
}



/// Start multi tag locationing
/// @param readerID The reader id
/// @param reportConfig The report config object
/// @param accessConfig the access config object
/// @param statusMessage The message
- (SRFID_RESULT)sdkStartMultiTagLocationing:(int)readerID aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage;
{
    
    if(m_RfidSdkApi != nil)
    {
        SRFID_RESULT srfid_result = [m_RfidSdkApi srfidStartMultiTagsLocationing:readerID aReportConfig:reportConfig aAccessConfig:accessConfig aStatusMessage:statusMessage];
        return srfid_result;
    }
    return SRFID_RESULT_FAILURE;
}

/// Stop multi tag locationing
/// @param readerID Thereader id
/// @param statusMessage The message
- (SRFID_RESULT)sdkStopMultiTagLocationing:(int)readerID aStatusMessage:(NSString **)statusMessage
{
    if(m_RfidSdkApi != nil)
    {
        SRFID_RESULT srfid_result = [m_RfidSdkApi srfidStopMultiTagsLocationing:[m_ActiveReader getReaderID] aStatusMessage:statusMessage];
        return srfid_result;
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)sdkStopTagLocationing:(int)readerID aStatusMessage:(NSString **)statusMessage;
{
    if(m_RfidSdkApi != nil)
    {
        SRFID_RESULT srfid_result = [m_RfidSdkApi srfidStopTagLocationing:[m_ActiveReader getReaderID] aStatusMessage:statusMessage];
        return srfid_result;
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - access command
- (SRFID_RESULT)readTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidReadTag:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aLength:length aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)writeTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidWriteTag:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aData:data aPassword:password aDoBlockWrite:blockWrite aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)killTag:(NSString *)tagID withTagData:(srfidTagData **)tagData withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidKillTag:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)lockTag:(NSString *)tagID withTagData:(srfidTagData **)tagData memoryBank:(SRFID_MEMORYBANK)memoryBank accessPermissions:(SRFID_ACCESSPERMISSION)accessPermissions withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidLockTag:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBank aAccessPermissions:accessPermissions aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - Async access operations
/// Read tag asyncronous.
/// - Parameters:
///   - tagID: Selected tag id.
///   - tagData: Tagdata object.
///   - memoryBankID: Selected memory bank.
///   - offset: Offset for the write operation.
///   - data: Selected tag data.
///   - password: Password for the write operation.
///   - statusMessage: Status message to return.
- (SRFID_RESULT)readTagAsync:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidReadTagAsync:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aLength:length aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}
/// Write tag asyncronous.
/// - Parameters:
///   - tagID: Selected tag id.
///   - tagData: Tagdata object.
///   - memoryBankID: Selected memory bank.
///   - offset: Offset for the write operation.
///   - data: Selected tag data.
///   - password: Password for the write operation.
///   - blockWrite: Block write access for write operation.
///   - statusMessage: Status message to return.
- (SRFID_RESULT)writeTagAsync:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidWriteTagAsync:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aData:data aPassword:password aDoBlockWrite:blockWrite aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}
/// Lock tag asyncronous.
/// - Parameters:
///   - tagID: Selected tag id.
///   - tagData: Tagdata object.
///   - memoryBank: Selected memory bank.
///   - accessPermissions: Access permission for lock the tag.
///   - password: Password for kill operation.
///   - statusMessage: Status message to return.
- (SRFID_RESULT)lockTagAsync:(NSString *)tagID withTagData:(srfidTagData **)tagData memoryBank:(SRFID_MEMORYBANK)memoryBank accessPermissions:(SRFID_ACCESSPERMISSION)accessPermissions withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidLockTagAsync:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBank aAccessPermissions:accessPermissions aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

/// Kill tag asyncronous.
/// - Parameters:
///   - tagID: Selected tag id.
///   - tagData: Tagdata object.
///   - password: Password for kill operation.
///   - statusMessage: Status message to return.
- (SRFID_RESULT)killTagAsync:(NSString *)tagID withTagData:(srfidTagData **)tagData withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (m_RfidSdkApi != nil)
    {
        return [m_RfidSdkApi srfidKillTagAsync:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - setting requests

- (SRFID_RESULT)getSupportedLinkProfiles:(NSString **)statusMessage
{
    NSMutableArray *linkProfiles = [[[NSMutableArray alloc] init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetSupportedLinkProfiles:[m_ActiveReader getReaderID] aLinkProfilesList:&linkProfiles aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setLinkProfileOptions:linkProfiles];
        [m_TemporarySledConfigurationCopy setLinkProfileOptions:linkProfiles];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setLinkProfileOptions:m_SledConfiguration.backUpLinkProfile];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getAntennaConfiguration:(NSString **)statusMessage
{
    srfidAntennaConfiguration *antenaCofiguration = [[[srfidAntennaConfiguration alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetAntennaConfiguration:[m_ActiveReader getReaderID] aAntennaConfiguration:&antenaCofiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    // we check if the power level from a device match the app power level
    // if not we set the nearest value to the device
    
    BOOL isMatch = NO;
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        isMatch = [m_SledConfiguration setAntennaOptionsWithConfig:antenaCofiguration];
        [m_TemporarySledConfigurationCopy setAntennaOptionsWithConfig:antenaCofiguration];
        
        if (NO == isMatch) {
            [self setAntennaConfigurationFromLocal:statusMessage];
        }
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setAntennaOptionsWithConfig:[m_SledConfiguration getAntennaConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setAntennaConfigurationFromLocal:(NSString **)statusMessage
{
    srfidAntennaConfiguration *antenaCofiguration = [m_TemporarySledConfigurationCopy getAntennaConfig];
    
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    NSMutableDictionary * linkDictionary = configuration.antennaOptionsLinkProfile;
    NSArray *keysArray =  [linkDictionary allKeys];
    NSArray *valuesArray = [linkDictionary allValues];
    int linkProfileIndex = 0;
    
    for (int i = 0; i < valuesArray.count; i++) {
        
        int index = 0;
        
        if ([antenaCofiguration getLinkProfileIdx] > [[configuration getLinkProfileArray] count]) {
            index =  (int)[[configuration getLinkProfileArray] count];
            index = index - 1;
        }else
        {
            index = [antenaCofiguration getLinkProfileIdx];
        }
        
        NSString * profileName = [[configuration getLinkProfileArray] objectAtIndex:index];
        
        //NSString * profileName = @"M4 256K";
        
        if ([valuesArray objectAtIndex:i] == profileName) {
            linkProfileIndex = [[keysArray objectAtIndex:i] intValue];
        }
    }
    
    [antenaCofiguration setLinkProfileIdx:linkProfileIndex];
        
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetAntennaConfiguration:[m_ActiveReader getReaderID] aAntennaConfiguration:antenaCofiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getAntennaConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getAntennaConfiguration:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getDpoConfiguration:(NSString **)responseMessage
{
    srfidDynamicPowerConfig *dpoConfig = [[[srfidDynamicPowerConfig alloc]init]autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetDpoConfiguration:[m_ActiveReader getReaderID] aDpoConfiguration:&dpoConfig aStatusMessage:responseMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setDpoOptionsWithConfig:dpoConfig];
        [m_TemporarySledConfigurationCopy setDpoOptionsWithConfig:dpoConfig];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setDpoOptionsWithConfig:[m_SledConfiguration getDpoConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setDpoConfigurationFromLocal:(NSString **)responseMessage
{
    srfidDynamicPowerConfig *dpoConfiguration = [m_TemporarySledConfigurationCopy getDpoConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetDpoConfiguration:[m_ActiveReader getReaderID] aDpoConfiguration:dpoConfiguration aStatusMessage:responseMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getDpoConfiguration:responseMessage];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getDpoConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return srfid_result;
}

- (SRFID_RESULT)getSingulationConfiguration:(NSString **)statusMessage
{
    srfidSingulationConfig *singulationCofiguration = [[[srfidSingulationConfig alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetSingulationConfiguration:[m_ActiveReader getReaderID] aSingulationConfig:&singulationCofiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        BOOL is_match = [m_SledConfiguration setSingulationOptionsWithConfig:singulationCofiguration];
        [m_TemporarySledConfigurationCopy setSingulationOptionsWithConfig:singulationCofiguration];
        if (NO == is_match)
        {
            [self setSingulationConfigurationFromLocal:statusMessage];
        }
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setSingulationOptionsWithConfig:[m_SledConfiguration getSingulationConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setSingulationConfigurationFromLocal:(NSString **)statusMessage
{
    srfidSingulationConfig *singulationConfiguration = [m_TemporarySledConfigurationCopy getSingulationConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetSingulationConfiguration:[m_ActiveReader getReaderID]aSingulationConfig:singulationConfiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getSingulationConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getSingulationConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getTagReportConfiguration:(NSString **)statusMessage
{
    srfidTagReportConfig *reportCofiguration = [[[srfidTagReportConfig alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetTagReportConfiguration:[m_ActiveReader getReaderID] aTagReportConfig:&reportCofiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setTagReportOptionsWithConfig:reportCofiguration];
        [m_TemporarySledConfigurationCopy setTagReportOptionsWithConfig:reportCofiguration];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setTagReportOptionsWithConfig:[m_SledConfiguration getTagReportConfig]];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setTagReportConfigurationFromLocal:(NSString **)statusMessage
{
    srfidTagReportConfig *config = [m_TemporarySledConfigurationCopy getTagReportConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetTagReportConfiguration:[m_ActiveReader getReaderID]  aTagReportConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getTagReportConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getTagReportConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    SRFID_BATCHMODECONFIG config1 = [m_TemporarySledConfigurationCopy getBatchModeConfig];
    
    SRFID_RESULT srfid_result1 = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result1 = [m_RfidSdkApi srfidSetBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:config1 aStatusMessage:statusMessage];
        
        if ((srfid_result1 != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result1 != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result1 == SRFID_RESULT_SUCCESS)
    {
        srfid_result1 = [self getBatchModeConfig:statusMessage];
    }
    else if(srfid_result1 == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getBatchModeConfig:nil];
    }
    
    else if(srfid_result1 == SRFID_RESULT_FAILURE || srfid_result1 == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    
    SRFID_BATCHMODECONFIG config2 = [m_TemporarySledConfigurationCopy getUSBBatchModeConfig];
    
    SRFID_RESULT srfid_result2 = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result2 = [m_RfidSdkApi srfidSetUSBBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:config2 aStatusMessage:statusMessage];
        
        if ((srfid_result2 != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result2 != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result2 == SRFID_RESULT_SUCCESS)
    {
        srfid_result2 = [self getUSBBatchModeConfig:statusMessage];
    }
    else if(srfid_result2 == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getUSBBatchModeConfig:nil];
    }
    
    else if(srfid_result2 == SRFID_RESULT_FAILURE || srfid_result2 == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return (srfid_result || srfid_result1 || srfid_result2);
}

- (SRFID_RESULT)getStartTriggerConfiguration:(NSString **)statusMessage
{
    srfidStartTriggerConfig *config = [[[srfidStartTriggerConfig alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetStartTriggerConfiguration:[m_ActiveReader getReaderID] aStartTriggeConfig:&config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setStartTriggerOptionWithConfig:config];
        [m_TemporarySledConfigurationCopy setStartTriggerOptionWithConfig:config];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setStartTriggerOptionWithConfig:[m_SledConfiguration getStartTriggerConfig]];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setStartTriggerConfiguration:(NSString **)statusMessage
{
    srfidStartTriggerConfig *config = [m_TemporarySledConfigurationCopy getStartTriggerConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetStartTriggerConfiguration:[m_ActiveReader getReaderID] aStartTriggeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getStartTriggerConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getStartTriggerConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getStopTriggerConfiguration:(NSString **)statusMessage
{
    srfidStopTriggerConfig *config = [[[srfidStopTriggerConfig alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetStopTriggerConfiguration:[m_ActiveReader getReaderID] aStopTriggeConfig:&config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setStopTriggerOptionWithConfig:config];
        [m_TemporarySledConfigurationCopy setStopTriggerOptionWithConfig:config];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setStopTriggerOptionWithConfig:[m_SledConfiguration getStopTriggerConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setStopTriggerConfiguration:(NSString **)statusMessage
{
    srfidStopTriggerConfig *config = [m_TemporarySledConfigurationCopy getStopTriggerConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetStopTriggerConfiguration:[m_ActiveReader getReaderID] aStopTriggeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getStopTriggerConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getStopTriggerConfiguration:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getSupportedRegions:(NSString **)statusMessage
{
    NSMutableArray *supportedRegions = [[[NSMutableArray alloc] init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetSupportedRegions:[m_ActiveReader getReaderID] aSupportedRegions:&supportedRegions aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_TemporarySledConfigurationCopy setSupportedRegions:supportedRegions];
        [m_SledConfiguration setSupportedRegions:supportedRegions];
        NSMutableArray *regionDatas = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i<[supportedRegions count]; i++) {
            if([[[supportedRegions objectAtIndex:i] getRegionCode] isEqualToString:[m_TemporarySledConfigurationCopy currentRegionCode]])
            {
                zt_RegionData *regionData = [[[zt_RegionData alloc] init] autorelease];
                [regionData setRegionFromRegionInfo:[supportedRegions objectAtIndex:i]];
                [self getRegionInfo:&regionData message:statusMessage];
                [regionDatas addObject:regionData];
            }
        }
        [m_TemporarySledConfigurationCopy setRegionOptions:regionDatas];
        [m_SledConfiguration setRegionOptions:regionDatas];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)fetchAllRegionData:(NSString**)statusMessage
{
    NSMutableArray *regionDatas = [[[NSMutableArray alloc] init] autorelease];
    SRFID_RESULT res = SRFID_RESULT_FAILURE;
    for (int i = 0; i<[[m_TemporarySledConfigurationCopy supportedRegions] count]; i++) {
        zt_RegionData *regionData = [[[zt_RegionData alloc] init] autorelease];
        [regionData setRegionFromRegionInfo:[[m_TemporarySledConfigurationCopy supportedRegions] objectAtIndex:i]];
        res = [self getRegionInfo:&regionData message:statusMessage];
        if (res == SRFID_RESULT_SUCCESS)
        {
            [regionDatas addObject:regionData];
        }
        else
        {
            break;
        }
    }
    if (res == SRFID_RESULT_SUCCESS)
    {
        [m_TemporarySledConfigurationCopy setRegionOptions:regionDatas];
        [m_SledConfiguration setRegionOptions:regionDatas];
    }
    return res;
}

- (void)loadRegionsInfoIfRequired
{
    if ([[m_TemporarySledConfigurationCopy regionOptions] count] == 0)
    {
        [[zt_RfidAppEngine sharedAppEngine] getSupportedRegions:nil];
    }
    
    if([[m_TemporarySledConfigurationCopy supportedRegions] count]>[[m_TemporarySledConfigurationCopy regionOptions] count])
    {
        [self fetchAllRegionData:nil];
    }
}

- (SRFID_RESULT)getRegionInfo:(zt_RegionData**)region_data message:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    if (m_RfidSdkApi != nil)
    {
        NSMutableArray *channels = [[NSMutableArray alloc] init];
        BOOL hopping = NO;
        
        for (int k = 0; k < ZT_MAX_RETRY; k++)
        {
            [channels removeAllObjects];
            hopping = NO;
            
            srfid_result = [m_RfidSdkApi srfidGetRegionInfo:[m_ActiveReader getReaderID] aRegionCode:(*region_data).regionCode aSupportedChannels:&channels aHoppingConfigurable:&hopping aStatusMessage:statusMessage];
            
            if (SRFID_RESULT_SUCCESS != srfid_result)
            {
                /* continue */
            }
            else
            {
                (*region_data).hoppingConfigurable = hopping;
                [(*region_data) setSupportedChannels:channels];
                break;
            }
        }
        [channels release];
    }
    return srfid_result;
}

- (SRFID_RESULT)getRegulatoryConfig:(NSString **)statusMessage
{
    srfidRegulatoryConfig *config = [[[srfidRegulatoryConfig alloc]init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetRegulatoryConfig:[m_ActiveReader getReaderID] aRegulatoryConfig:&config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setRegulatoryOptionsWithConfig:config];
        [m_TemporarySledConfigurationCopy setRegulatoryOptionsWithConfig:config];
        SRFID_RESULT linkProfile_result = SRFID_RESULT_FAILURE;
        linkProfile_result = [self getSupportedLinkProfiles:nil];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setRegulatoryOptionsWithConfig:[m_SledConfiguration getRegulatoryConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setRegulatoryConfig:(NSString **)statusMessage
{
    srfidRegulatoryConfig *config = [m_TemporarySledConfigurationCopy getRegulatoryConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetRegulatoryConfig:[m_ActiveReader getReaderID] aRegulatoryConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
//        srfid_result = [self getRegulatoryConfig:statusMessage];
//        [self updateInitialSledConfiguration];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSString *status = [[NSString alloc] init];
        status = [NSString stringWithString:*statusMessage];
        
        if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
        {
            [self getRegulatoryConfig:nil];
            dispatch_async(dispatch_get_main_queue(),^{
                [self.popupAuthDelegate showAuthorisation:status];
                });
        }else
        {
            [self getRegulatoryConfig:nil];
        }
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getBeeperConfig:(NSString **)statusMessage
{
    SRFID_BEEPERCONFIG config = SRFID_BEEPERCONFIG_HIGH;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetBeeperConfig:[m_ActiveReader getReaderID] aBeeperConfig:&config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setBeeperOptionsWithConfig:config];
        [m_TemporarySledConfigurationCopy setBeeperOptionsWithConfig:config];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_SledConfiguration setBeeperOptionsWithConfig:config];
        [m_TemporarySledConfigurationCopy setBeeperOptionsWithConfig:[m_SledConfiguration getBeeperConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setBeeperConfig:(NSString **)statusMessage
{
    SRFID_BEEPERCONFIG config = [m_TemporarySledConfigurationCopy getBeeperConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetBeeperConfig:[m_ActiveReader getReaderID] aBeeperConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getBeeperConfig:statusMessage];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getBeeperConfig:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getReaderCapabilitiesInfo:(NSString **)statusMessage
{
    srfidReaderCapabilitiesInfo *info = [[[srfidReaderCapabilitiesInfo alloc] init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetReaderCapabilitiesInfo:[m_ActiveReader getReaderID] aReaderCapabilitiesInfo:&info aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setCapabilityOptionWithInfo:info];
        [m_TemporarySledConfigurationCopy setCapabilityOptionWithInfo:info];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing, because we only get the config from the device
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getReaderVersionInfo:(NSString **)statusMessage
{
    srfidReaderVersionInfo *info = [[[srfidReaderVersionInfo alloc] init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetReaderVersionInfo:[m_ActiveReader getReaderID] aReaderVersionInfo:&info aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setReaderVersionWithInfo:info];
        [m_TemporarySledConfigurationCopy setReaderVersionWithInfo:info];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing, because we only get the config from the device
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getPrefilters:(NSString **)statusMessage
{
    NSMutableArray *prefilters = [[[NSMutableArray alloc] init] autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetPreFilters:[m_ActiveReader getReaderID] aPreFilters:&prefilters aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        if ([prefilters count] > 2)
        {
            for (int i = 2; i < [prefilters count] ; i++)
            {
                [prefilters removeObjectAtIndex:i];
            }
            srfid_result = [self setPrefilters:statusMessage];
        }
        // keep new state
        [m_SledConfiguration setPrefiltersFromConfig:prefilters];
        [m_TemporarySledConfigurationCopy setPrefiltersFromConfig:prefilters];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self restorePrefilters];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setPrefilters:(NSString **)statusMessage
{
    NSMutableArray *prefilters = [[[NSMutableArray alloc] init] autorelease];
    
    if (m_TemporarySledConfigurationCopy.applyFirstFilter)
    {
        [prefilters addObject:[[m_TemporarySledConfigurationCopy currentPrefilters] objectAtIndex:0]];
    }
    if (m_TemporarySledConfigurationCopy.applySecondFilter)
    {
        [prefilters addObject:[[m_TemporarySledConfigurationCopy currentPrefilters] objectAtIndex:1]];
    }
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetPreFilters:[m_ActiveReader getReaderID] aPreFilters:prefilters aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getPrefilters:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self restorePrefilters];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (void)restorePrefilters
{
    if (YES == m_SledConfiguration.applyFirstFilter)
    {
        [m_TemporarySledConfigurationCopy copyFirstFilerConfig:m_SledConfiguration.currentPrefilters[0]];
        [m_TemporarySledConfigurationCopy setApplyFirstFilter:YES];
    }
    else
    {
        [m_TemporarySledConfigurationCopy setApplyFirstFilter:NO];
    }
    
    if (YES == m_SledConfiguration.applySecondFilter)
    {
        [m_TemporarySledConfigurationCopy copySecondFilterConfig:m_SledConfiguration.currentPrefilters[1]];
        [m_TemporarySledConfigurationCopy setApplySecondFilter:YES];
    }
    else
    {
        [m_TemporarySledConfigurationCopy setApplySecondFilter:NO];
    }
}


- (void)restorePrefiltersForTagQuet
{
    if (YES == m_SledConfiguration.applyFirstFilter)
    {
        [m_TemporarySledConfigurationCopy copyFirstFilerConfig:m_SledConfiguration.currentPrefilters[0]];
        [m_TemporarySledConfigurationCopy setApplyFirstFilter:NO];
    }
    else
    {
        [m_TemporarySledConfigurationCopy setApplyFirstFilter:NO];
    }
    
    if (YES == m_SledConfiguration.applySecondFilter)
    {
        [m_TemporarySledConfigurationCopy copySecondFilterConfig:m_SledConfiguration.currentPrefilters[1]];
        [m_TemporarySledConfigurationCopy setApplySecondFilter:NO];
    }
    else
    {
        [m_TemporarySledConfigurationCopy setApplySecondFilter:NO];
    }
    
    NSMutableArray *prefilters = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *statusMessage = @"";
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetPreFilters:[m_ActiveReader getReaderID] aPreFilters:prefilters aStatusMessage:&statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        //srfid_result = [self getPrefilters:&statusMessage];
        NSLog(@"Tagquet reset SUCCESS");
    }
   else
    {
        NSLog(@"Tagquet reset Failed");
       // srfid_result = [self getPrefilters:&statusMessage];
    }
}


- (SRFID_RESULT)saveReaderConfig:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSaveReaderConfiguration:[m_ActiveReader getReaderID] aSaveCustomDefaults:NO aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)requestBatteryStatus:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        //        srfid_result = [m_RfidSdkApi srfidRequestBatteryStatus:[m_ActiveReader getReaderID]];
        //        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
        //            break;
        //        }
        
        srfid_result = [m_RfidSdkApi srfidRequestDeviceStatus:[m_ActiveReader getReaderID] aBattery:YES aTemperature:NO aPower:NO];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        //[self readerProblem];
        // do nothing
    }
    return srfid_result;
}

- (SRFID_RESULT)requestIOTStatus:(NSString **)responsMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidRequestIOTStatus:[m_ActiveReader getReaderID]];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        //[self readerProblem];
        // do nothing
    }
    return srfid_result;
}

#pragma mark - sdk config

- (void)setAutoDetect:(BOOL)option
{
    [m_RfidSdkApi srfidEnableAvailableReadersDetection:option];
}
- (void)setAutoReconect:(BOOL)option
{
    [m_RfidSdkApi srfidEnableAutomaticSessionReestablishment:option];
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:ZT_AUTO_CONNECT_CONFIG_IS_ENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - debug
- (void)printInventoryItems
{
    // [m_InventoryData printInventoryItems];
}

/* Batch Mode Config */

-(SRFID_RESULT)getBatchModeConfig:(NSString **)responsMessage
{
    SRFID_BATCHMODECONFIG config = SRFID_BATCHMODECONFIG_AUTO;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:&config aStatusMessage:responsMessage ];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setBatchModeOptionsWithConfig:config];
        [m_TemporarySledConfigurationCopy setBatchModeOptionsWithConfig:config];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setBatchModeOptionsWithConfig:[m_SledConfiguration getBatchModeConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setBatchModeConfig:(NSString **)statusMessage
{
    SRFID_BATCHMODECONFIG config = [m_TemporarySledConfigurationCopy getBatchModeConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getBatchModeConfig:statusMessage];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getBatchModeConfig:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

// USB Batchmode

/// Get usb batchmode configuration.
/// - Parameter responsMessage: The response message.
-(SRFID_RESULT)getUSBBatchModeConfig:(NSString **)responsMessage
{
    SRFID_BATCHMODECONFIG config = SRFID_BATCHMODECONFIG_ENABLE;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetUSBBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:&config aStatusMessage:responsMessage ];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Selected batchmode : %u",config);
        [m_SledConfiguration setUSBBatchModeOptionsWithConfig:config];
        [m_TemporarySledConfigurationCopy setUSBBatchModeOptionsWithConfig:config];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setUSBBatchModeOptionsWithConfig:[m_SledConfiguration getUSBBatchModeConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}


/// Set batchmode configuration.
/// - Parameter statusMessage: The status message.
- (SRFID_RESULT)setUSBBatchModeConfig:(NSString **)statusMessage
{
    SRFID_BATCHMODECONFIG config = [m_TemporarySledConfigurationCopy getUSBBatchModeConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetUSBBatchModeConfig:[m_ActiveReader getReaderID] aBatchModeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getUSBBatchModeConfig:statusMessage];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getUSBBatchModeConfig:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}


#pragma mark - GetTags in Batch mode

- (SRFID_RESULT)getTags:(NSString **)statusMessage
{
    
    // [self loadRegionsInfoIfRequired];
    NSString *status_msg = nil;
    
    if (nil != m_RfidSdkApi)
    {
        SRFID_RESULT result;
        result = [m_RfidSdkApi srfidgetTags:[m_ActiveReader getReaderID] aStatusMessage:&status_msg];
        [m_ActiveReader setBatchModeStatus:NO];
        return result;
    }
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)purgeTags:(NSString **)statusMessage
{
    NSString *status_msg = nil;
    
    if (nil != m_RfidSdkApi)
    {
        SRFID_RESULT result;
        result = [m_RfidSdkApi srfidPurgeTags:[m_ActiveReader getReaderID] aStatusMessage:&status_msg];
        [m_ActiveReader setBatchModeStatus:NO];
        return result;
    }
    return SRFID_RESULT_FAILURE;
}


- (void) reconnectAfterBatchMode
{
    [m_RfidSdkApi srfidGetConfigurations];
}

- (void)establishAsciiConnection
{
    int reader_id = [m_ActiveReader getReaderID];
    //NSString *ascii_pwd = [m_AppConfiguration getConfigAsciiPassword:reader_id];
    
    SRFID_RESULT _conn_res = [m_RfidSdkApi srfidEstablishAsciiConnection:reader_id];
    
    if (_conn_res == SRFID_RESULT_SUCCESS)
    {
        /* success -> we may continue */
        [self postAsciiConnectionActions];
    }
    else if (_conn_res == SRFID_RESULT_WRONG_ASCII_PASSWORD)
    {
        /* wrong password -> display password dialog */
       /* UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"Connection password required!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* connectButton = [UIAlertAction
                                        actionWithTitle:@"Connect"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
            //Handle connect button here
            // save entered ascii connection password
            NSString * password = alert.textFields[0].text;
            [m_AppConfiguration setConfigAsciiPassword:password forReader:[m_ActiveReader getReaderID]];
            [self establishAsciiConnection];
        }];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
            [self disconnect:[m_ActiveReader getReaderID]];
        }];
        
        [alert addAction:cancelButton];
        [alert addAction:connectButton];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            textField.placeholder = @"Enter password";
        }];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];*/
        
        /* unknown error -> show message box */
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"Failed to establish connection with RFID reader"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
        }];
        
        [alert addAction:cancelButton];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        /* unknown error -> show message box */
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"Failed to establish connection with RFID reader"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
        }];
        
        [alert addAction:cancelButton];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}
- (void) postAsciiConnectionActions
{
    if([m_ActiveReader getBatchModeStatus])
    {
        [m_ActiveReader setIsActive:NO withID:[NSNumber numberWithInt:[m_ActiveReader getReaderID]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<zt_IRfidAppEngineDevListDelegate> delegate in m_DevListDelegates)
            {
                if (delegate != nil)
                {
                    [delegate deviceListHasBeenUpdated];
                }
            }
        });
    }
    else    // get latest config
    {
        NSString *notification = nil;
        
        for (srfidReaderInfo *info in m_DeviceInfoList)
        {
            if ([info getReaderID] == [m_ActiveReader getReaderID])
            {
                notification = [NSString stringWithFormat:@"%@ has connected", [info getReaderName]];
                break;
            }
        }
        
        if (nil == notification)
        {
            notification = [NSString stringWithFormat:@"RFID reader (ID %d) has connected", [m_ActiveReader getReaderID]];
            [[NSUserDefaults standardUserDefaults] setValue:ZT_DEVICEINFO_API_CALL_VALUE forKey:ZT_DEVICEINFO_API_CALL];
            [[NSUserDefaults standardUserDefaults] synchronize];
            SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
            self.resultDictioanry = [scannerInfo getAssetsTableRepresentation:^(NSMutableDictionary *dictionary) {
                
                self.resultDictioanry = dictionary;
                
                [[NSUserDefaults standardUserDefaults] setValue:self.resultDictioanry forKey:ZT_DEVICEINFO_DEFAULTS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            
            NSString *response = @"";
            [self setAntennaConfigurationFromLocal:&response];
        }
        
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showDetailedAlertWithView:[[UIApplication sharedApplication] keyWindow].rootViewController.view  withTarget:self withMethod:@selector(updateInitialSledConfiguration) withObject:nil withHeader:ZT_RFID_APP_NAME withDetails:[NSString stringWithFormat:@"%@\n\nRetrieving configuration", notification]];
    }
    
}

#pragma mark UniqueTagsReport

- (SRFID_RESULT)getUniqueTagsReportConfiguration:(NSString **)responseMessage
{
    srfidUniqueTagsReport *utrConfig = [[[srfidUniqueTagsReport alloc]init]autorelease];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result=[m_RfidSdkApi srfidGetUniqueTagReportConfiguration:[m_ActiveReader getReaderID] aUtrConfiguration:&utrConfig aStatusMessage:responseMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setUniqueTagsReport:utrConfig];
        [m_TemporarySledConfigurationCopy setUniqueTagsReport:utrConfig];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setUniqueTagsReport:[m_SledConfiguration getUniqueTagsReport]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}


- (SRFID_RESULT)setUniqueTagsReportConfigurationFromLocal:(NSString **)responseMessage{
    srfidUniqueTagsReport *uniqueTagsRepotConfiguration = [m_TemporarySledConfigurationCopy getUniqueTagsReport];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetUniqueTagReportConfiguration:[m_ActiveReader getReaderID] aUtrConfiguration:uniqueTagsRepotConfiguration aStatusMessage:responseMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
        // purge tags on settings change
        [m_RfidSdkApi srfidPurgeTags:[m_ActiveReader getReaderID] aStatusMessage:NULL];
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getUniqueTagsReportConfiguration:responseMessage];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getUniqueTagsReportConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return srfid_result;
    
}

// Trigger Config

/// To get the trigger configuration from sdk.
- (SRFID_RESULT)getTriggerConfigurationUpperTrigger{
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE upperTrigger = RFID_SCAN;
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE lowerTrigger = TERMINAL_SCAN;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = ZT_TRIGGER_MAPPING_ZERO; i < ZT_MAX_RETRY; i++){
        srfid_result = [m_RfidSdkApi srfidGetKeylayoutType:[m_ActiveReader getReaderID] upperTrigger:&upperTrigger lowerTrigger:&lowerTrigger];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS){
        [m_SledConfiguration setCurrentSelectedUpperTrigger:upperTrigger];
        [m_SledConfiguration setCurrentSelectedLowerTrigger:lowerTrigger];
    }else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
        [m_SledConfiguration setCurrentSelectedUpperTrigger:upperTrigger];
        [m_SledConfiguration setCurrentSelectedLowerTrigger:lowerTrigger];
    }else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
        [self readerProblem];
    }
    return srfid_result;
}

/// To set the trigger configuration from sdk.
/// @param configuration The trigger configuration to sdk.
/// @param statusMessage Status message.
- (SRFID_RESULT)setTriggerConfigurationUpperTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)upper andLowerTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)lower{
    
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE upperTrigger = upper;
    SRFID_NEW_ENUM_KEYLAYOUT_TYPE lowerTrigger = lower;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = ZT_TRIGGER_MAPPING_ZERO; i < ZT_MAX_RETRY; i++){
        srfid_result = [m_RfidSdkApi srfidSetKeylayoutType:[m_ActiveReader getReaderID] upperTrigger:upperTrigger lowerTrigger:lowerTrigger];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS){
        srfid_result = [self getTriggerConfigurationUpperTrigger];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
        [self getTriggerConfigurationUpperTrigger];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
        [self readerProblem];
    }
    return srfid_result;
}


/// Reboot the reader
/// @param readerID The reader id
/// @param statusMessage The status message
- (SRFID_RESULT)setReaderReboot:(int)readerID status:(NSString **)statusMessage{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    srfid_result = [m_RfidSdkApi srfidReboot:readerID aStatusMessage:statusMessage];
    return srfid_result;
}

/// Factory reset the reader
/// @param readerID The reader id
/// @param statusMessage The status message
- (SRFID_RESULT)setReaderFactoryReset:(int)readerID status:(NSString **)statusMessage{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    srfid_result = [m_RfidSdkApi srfidFactoryReset:readerID aStatusMessage:statusMessage];
    return srfid_result;
}



/// Get wifi status
/// @param readerID The reader id
/// @param wifiStatusInfo The wifi status info
/// @param statusMessage The status message
- (SRFID_RESULT)getWifiStatus:(int)readerID wifiStatusInfo:(srfidGetWifiStatusInfo **)wifiStatusInfo status:(NSString **)statusMessage
{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    //srfidGetWifiStatusInfo *info = [[[srfidGetWifiStatusInfo alloc] init] autorelease];
    
    for(int i = ZT_TRIGGER_MAPPING_ZERO; i < 1; i++){
        srfid_result = [m_RfidSdkApi srfidGetWifiStatus:readerID wifiStatusInfo:wifiStatusInfo aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE )) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS){
        
        NSLog(@"getWifiStatus success");
        
        
    }else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
        
        NSLog(@"SRFID_RESULT_RESPONSE_ERROR");
        
    }else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
        
        [self readerProblem];
        
    }
    
    
    return srfid_result;
}


/// Set wifi enable disable
/// @param readerID The reader id
/// @param wifiEnableStatus The status of wifi enable disable
/// @param statusMessage The status message
- (SRFID_RESULT)setWifiEnable:(int)readerID wifiEnable:(BOOL)wifiEnableStatus status:(NSString **)statusMessage
{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = ZT_TRIGGER_MAPPING_ZERO; i < 1; i++){
        srfid_result = [m_RfidSdkApi srfidWifiEnableDisable:readerID enable:wifiEnableStatus aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE )) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS){
        
        NSLog(@"===WiIF enable disable success===");
        
        
    }else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
        
        NSLog(@"SRFID_RESULT_RESPONSE_ERROR");
        
    }else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
        
        [self readerProblem];
        
    }
    
    
    return srfid_result;
}

/// Set reader attribute
/// @param readerID The reader id
/// @param attributeInfo The attribute information
/// @param statusMessage The status message
-(SRFID_RESULT)setReaderAttribute:(int)readerID attributeInformation:(srfidAttribute*)attributeInfo aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    srfid_result = [m_RfidSdkApi srfidSetAttribute:readerID aAttrInfo:attributeInfo aStatusMessage:statusMessage];
    return srfid_result;
    
}



/// Get reader attribute
/// @param readerID The reader id
/// @param attrNum The attribute number
/// @param attrInfo The attribute information
/// @param statusMessage The status message
-(SRFID_RESULT)getReaderAttribute:(int)readerID
                     attributeNum:(int)attrNum
                        aAttrInfo:(srfidAttribute**)attrInfo
                   aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    srfid_result = [m_RfidSdkApi srfidGetAttribute:readerID
                                          aAttrNum:attrNum
                                         aAttrInfo:attrInfo
                                    aStatusMessage:statusMessage];
    return srfid_result;
    
}


/// Get battery status
/// @param readerID The reader id
/// @param statusMessage The status message
-(SRFID_RESULT)getBatteryStatus:(int)readerID  aStatusMessage:(NSString**)statusMessage {
    
    NSMutableArray *batteryStatusValueList = [[[NSMutableArray alloc] init] autorelease];
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetBatteryStatus:[m_ActiveReader getReaderID] batteryStatusArray:&batteryStatusValueList aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setBatteryStatusArray:batteryStatusValueList];
        
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
    
    
}





/// Add wlan profile
/// @param readerID The reader id
/// @param ssidWlan The ssid
/// @param wlanPassword The password
/// @param statusMessage The status message
-(SRFID_RESULT)addWlanProfile:(int)readerID srfidProfileConfig:(sRfidAddProfileConfig*)profileConfig aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    srfid_result = [m_RfidSdkApi srfidAddWlanProfile:readerID srfidProfileConfig:profileConfig aStatusMessage:statusMessage];
    
    if (srfid_result == SRFID_RESULT_SUCCESS){
        NSLog(@"Add profile sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
        
        NSLog(@"Add profile SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
        
        [self readerProblem];
    }
    
    return srfid_result;
    
}


/// Remove wlan profile
/// @param readerID The reader id
/// @param ssidWlan The ssid
/// @param statusMessage The status message
-(SRFID_RESULT)removeWlanProfile:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
  
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidRemoveWlanProfile:readerID ssidWlan:ssidWlan aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Remove profile sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
        NSLog(@"Remove profile SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
    
}


/// Get wlan profile list
/// @param readerID The reader id
/// @param statusMessage The status  message
- (SRFID_RESULT)getWlanProfileList:(int)readerID wlanProfileList:(NSMutableArray **)wlanProfileList status:(NSString **)statusMessage{
    
  //  NSMutableArray *wlanProfileList = [[NSMutableArray alloc]init];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;

    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetWlanProfileList:readerID wlanProfileList:wlanProfileList aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"App engine reader Wlan profile sucess");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"App engine reader Wlan profile SRFID_RESULT_RESPONSE_ERROR");
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        NSLog(@"App engine reader Wlan profile readerProblem");
        //[self readerProblem];
    }
 
    
    return srfid_result;
}
/// Get wlan scan list data.
/// @param readerID The reader id.
/// @param statusMessage The status message.
- (SRFID_RESULT)getWlanScanList:(int)readerID status:(NSString **)statusMessage{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 3; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetWlanScanList:readerID aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"reader scan Wlan success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}



/// Save wlan profile
/// @param readerID The reader id
/// @param statusMessage The status message
-(SRFID_RESULT)saveWlanProfile:(int)readerID aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    if (YES == [wlanProfileListGuard lockBeforeDate:[NSDate distantFuture]]){
        
        srfid_result = [m_RfidSdkApi srfidWlanSaveProfile:readerID aStatusMessage:statusMessage];
        
        if (srfid_result == SRFID_RESULT_SUCCESS){
            NSLog(@"Save profile sucees");
        }
        else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR){
            
            NSLog(@"Save profile SRFID_RESULT_RESPONSE_ERROR");
            
        }
        else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT){
            
            [self readerProblem];
        }
        [wlanProfileListGuard unlock];
    }

    
    return srfid_result;
    
}
- (SRFID_RESULT)getWlanCertificatesList:(int)readerID wlanCertificatesList:(NSMutableArray **)wlanCertificatesList status:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;

    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetWlanCertificatesList:readerID wlanCertificatesList:wlanCertificatesList aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"App engine reader Wlan certificate list sucess");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"App engine reader Wlan profile SRFID_RESULT_RESPONSE_ERROR");
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        NSLog(@"App engine reader Wlan profile readerProblem");
        //[self readerProblem];
    }

    return srfid_result;
}

/// Connect to the wlan profile.
/// @param readerID The reader id.
/// @param ssidWlan Profile name.
/// @param statusMessage The status message.
-(SRFID_RESULT)connectWlanProfile:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidConnectWlanProfile:readerID ssidWlan:ssidWlan aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Connect profile sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Connect profile SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
}

/// Disconnect waln profile.
/// @param readerID The reader id.
/// @param statusMessage The status message.
-(SRFID_RESULT)disconnectWlanProfile:(int)readerID aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidWlanDisConnectProfile:readerID aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Connect profile sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Connect profile SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
    
}
/// Set the preferred ssid.
/// @param readerID The reader id.
/// @param ssidWlan Profile name.
/// @param statusMessage The status message.
-(SRFID_RESULT)setWlanPreferredSSID:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetPreferredSSID:readerID ssidWlan:ssidWlan aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Connect profile sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Connect profile SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
}

/// Add certificate to the reader.
/// @param readerID The connected reader id.
/// @param fileName The file name to be removed.
/// @param statusMessage The status message.
/// @param filePath The filepath need to be uploaded.
-(SRFID_RESULT)addCertificate:(int)readerID fileName:(NSString*)fileName fileSize:(NSString*)fileSize andFilePath:(NSURL*)filePath aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    srfid_result = [m_RfidSdkApi srfidAddCertificate:readerID fileName:fileName fileSize:fileSize andFilePath:filePath aStatusMessage:statusMessage];
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Add certificate success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Add certificate SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
    
}

/// Remove certificate from the reader.
/// @param readerID The connected reader id.
/// @param fileName The file name to be removed.
/// @param statusMessage The status message.
-(SRFID_RESULT)removeCertificate:(int)readerID fileName:(NSString*)fileName  aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidRemoveCertificate:readerID fileName:fileName aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Remove certificate sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
        NSLog(@"Remove certificate SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
    
}


/// Remove all the certificates from reader.
/// @param readerID The connected reader id.
/// @param statusMessage the status message.
-(SRFID_RESULT)removeAllCertificate:(int)readerID  aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidRemoveAllCertificates:readerID aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Remove certificate succes");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
        NSLog(@"Remove certificate SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
    
}

/// Save the certificate.
/// @param readerID The connected reader id.
/// @param statusMessage the status message.
-(SRFID_RESULT)saveCertificate:(int)readerID aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSaveCertificate:readerID aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"save certificate sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"save certificate SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

-(SRFID_RESULT)getCertificatesList:(int)readerID certificatesList:(NSMutableArray **)certificatesList status:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;

    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetCertificatesList:readerID certificatesList:certificatesList aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"App engine reader certificate list sucess");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"App engine reader Wlan profile SRFID_RESULT_RESPONSE_ERROR");
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }

    return srfid_result;
}

-(SRFID_RESULT)addEndPointConfig:(int)readerID endPointConfig:(RfidSetEndPointConfig*)endpointConfig aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;

    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetEndPointConfig:readerID endPointConfig:endpointConfig aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"App engine reader certificate list sucess");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"App engine reader Wlan profile SRFID_RESULT_RESPONSE_ERROR");
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }

    return srfid_result;
}
-(SRFID_RESULT)getEndPointList:(int)readerID endPointList:(NSMutableArray **)endPointList status:(NSString **)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;

    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetEndPointList:readerID endPointList:endPointList aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"App engine reader certificate list sucess");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"App engine reader Wlan profile SRFID_RESULT_RESPONSE_ERROR");
        // do nothing
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }

    return srfid_result;
}

-(SRFID_RESULT)saveEndPointConfig:(int)readerID aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSaveEndPointConfig:readerID aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"save endpoint sucees");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"save endpoint SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}
-(SRFID_RESULT)removeEndPointConfig:(int)readerID endPointName:(NSString*)endPointName  aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidRemoveEndPointConfig:readerID endPointName:endPointName aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Remove endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
        NSLog(@"Remove endpoint SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
    
}
- (SRFID_RESULT)getEndpointConfig:(int)readerID endPointName:(NSString*)endPointName endPointConfig:(srfidGetEndPointConfig **)endPointConfig aStatusMessage:(NSString**)astatusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    for(int i = 0; i < 1; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetEndpointConfig:readerID endPointName:endPointName endPointConfig:endPointConfig aStatusMessage:astatusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE))
        {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Get active endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
        NSLog(@"Get active endpoint SRFID_RESULT_RESPONSE_ERROR");
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        
        [self readerProblem];
        
    }
    return srfid_result;
    
}

- (SRFID_RESULT)getActiveEndPoints:(srfidGetActiveEnpoints **)activeEndPoints aStatusMessage:(NSString **)responseMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidGetActiveEndPoints:[m_ActiveReader getReaderID] endPointConfig:activeEndPoints aStatusMessage:responseMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Get active endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Get active endpoint SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT) activateEndPoint:(int)readerID endPointType:(NSString*)endPointType andEndPointName:(NSString*)endPointName aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidActivateEndPoint:readerID endPointType:endPointType andEndPointName:endPointName aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Get active endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Get active endpoint SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

//Set pair by scan reader name
/// @param readerName The reader name
- (void)setPairByScanConnectReaderName:(NSString*)readerName {
    
    [[NSUserDefaults standardUserDefaults] setObject:readerName forKey:ZT_PAIR_BY_CONNECT_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Get pair by  scanner details
-(BOOL)isPairByScanReaderIsFound:(srfidReaderInfo*)readerInfo {
    
    NSString *readerName = [[NSUserDefaults standardUserDefaults] stringForKey:ZT_PAIR_BY_CONNECT_ENABLE];
    NSString *trimmedPairByScanDetectedReader =[readerName substringFromIndex:MAX((int)[readerName length]-13, 0)];
    NSString *trimmedSdkAppearReader =[[readerInfo getReaderName] substringFromIndex:MAX((int)[[readerInfo getReaderName] length]-13, 0)];
 
    if ([trimmedPairByScanDetectedReader isEqualToString:trimmedSdkAppearReader]){
        return YES;
    }else{
        return NO;
    }
    
}

//Pair by Scan Connect
/// @param ex_info reader information
-(void)pairByScanConnectByReader:(srfidReaderInfo *)ex_info {
    
    NSString *readerName = [[NSUserDefaults standardUserDefaults] stringForKey:ZT_PAIR_BY_CONNECT_ENABLE];
    if (!readerName) {
        return;
    }
    if (![ex_info isActive] == YES) {
        
            [self connect:[ex_info getReaderID]];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZT_PAIR_BY_CONNECT_ENABLE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}

- (SRFID_RESULT)requestConnectedInterfaceStatus
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
      
        srfid_result = [m_RfidSdkApi srfidRequestDeviceConnectionInterfaceStatus:[m_ActiveReader getReaderID]];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        //[self readerProblem];
        // do nothing
    }
    return srfid_result;
}

-(void)srfidEventConnectedInterfaceNotity:(int)readerID aConnectedInterfaceEvent:(sfidConnectedInterfaceEvent*)connectedInterfaceEvent;
{
    
    NSLog(@"\nUserInterFace for Connection:(%u)\n", [connectedInterfaceEvent getConneted_Interface_Type]);
    if (SRFID_CONNECTION_TYPE_BLUETOOTH  == [connectedInterfaceEvent getConneted_Interface_Type]) {
        
        NSLog(@" Bluetooth Connection");
        _connectedUserInterfaceType = SRFID_CONNECTION_TYPE_BLUETOOTH;
        //[self showMessageBox:@"Bluetooth Connection"];
    }
    else if (SRFID_CONNECTION_TYPE_USB  == [connectedInterfaceEvent getConneted_Interface_Type]) {
        
        NSLog(@" USB Connection");
       // [self showMessageBox:@"USB Connection" ];
        _connectedUserInterfaceType = SRFID_CONNECTION_TYPE_USB;
    }
    else if (SRFID_CONNECTION_TYPE_NO_INTERFACE  == [connectedInterfaceEvent getConneted_Interface_Type]){
        NSLog(@" NO_INTERFACE Connection");
        //[self showMessageBox:@" NO_INTERFACE  Connection" ];
        _connectedUserInterfaceType = SRFID_CONNECTION_TYPE_NO_INTERFACE;
    }
    else if (SRFID_CONNECTION_TYPE_ETHERNET  == [connectedInterfaceEvent getConneted_Interface_Type]){
        
        NSLog(@" SRFID_ETHERNET Connection");
        //[self showMessageBox:@" ETHERNET  Connection" ];
        _connectedUserInterfaceType = SRFID_CONNECTION_TYPE_ETHERNET;
        
    } else if (SRFID_CONNECTION_TYPE_TERMINAL  == [connectedInterfaceEvent getConneted_Interface_Type]){
        
        NSLog(@" SRFID_CONNECTION_TYPE_TERMINAL Connection");
        //[self showMessageBox:@"TERMINAL  Connection" ];
        _connectedUserInterfaceType = SRFID_CONNECTION_TYPE_TERMINAL;
    }
}

- (SRFID_RESULT)requestChargeTerminalStatus
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    BOOL chargeTerminalStatus = NO;
    for(int i = 0; i < 1; i++)
    {
      
        srfid_result = [m_RfidSdkApi srfidGetChargeTerminalStatus:[m_ActiveReader getReaderID] chargeTerminalStatus:&chargeTerminalStatus];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
        self.statusOfChargeTerminal = chargeTerminalStatus;
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        //[self readerProblem];
        // do nothing
    }
    return srfid_result;
}




//- (SRFID_RESULT) srfidEnableCommandChargeTerminal:(int)readerID :(BOOL)enableChargeTerminal;

- (SRFID_RESULT)requestChargeTerminalStatusEnable:(BOOL)status
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 1; i++)
    {
      
        srfid_result = [m_RfidSdkApi srfidEnableChargeTerminal:[m_ActiveReader getReaderID] enableStatus:status];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        // do nothing
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        //[self readerProblem];
        // do nothing
    }
    return srfid_result;
}

- (SRFID_RESULT) adminLogin:(int)readerID password:(NSString*)password aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 1; i++)
    {
        srfid_result = [m_RfidSdkApi srfidAdminLogin:readerID password:password aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Get active endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Get active endpoint SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}
- (SRFID_RESULT) changePassword:(int)readerID oldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword andreEnterPassword:(NSString*)reEnterPassword aStatusMessage:(NSString**)statusMessage
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidChangePassword:readerID oldPassword:oldPassword andNewPassword:newPassword andreEnterPassword:reEnterPassword aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"Get active endpoint success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"Get active endpoint SRFID_RESULT_RESPONSE_ERROR");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}
- (SRFID_RESULT)unprotectTag:(NSString*)tagID
                   withTagData:(srfidTagData **)tagData
                withPassword:(NSString*)password
              aStatusMessage:(NSString**)statusMessage
{
    
    if (m_RfidSdkApi != nil)
    {
    
        return [m_RfidSdkApi srfidUnprotectTag:[m_ActiveReader getReaderID]
                                        aTagID:tagID
                                aAccessTagData:tagData
                                     aPassword:password
                                aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)protectTag:(NSString*)tagID withTagData:(srfidTagData **)tagData   withPassword:(NSString*)password  aStatusMessage:(NSString**)statusMessage
{
    
    
    if (m_RfidSdkApi != nil)
    {

        return [m_RfidSdkApi srfidProtectTag:[m_ActiveReader getReaderID] aTagID:tagID aAccessTagData:tagData aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)disableVisibilityTag:(NSString*)password
              aStatusMessage:(NSString**)statusMessage
{
    
    if (m_RfidSdkApi != nil)
    {
    
        return [m_RfidSdkApi srfidDisableTagVisibility:[m_ActiveReader getReaderID]
                                            aPassword:password
                                       aStatusMessage:statusMessage];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)enableVisibilityTag:(NSString*)password
              aStatusMessage:(NSString**)statusMessage
{
    
    if (m_RfidSdkApi != nil)
    {
    
        return [m_RfidSdkApi srfidEnableTagVisibility:[m_ActiveReader getReaderID]
                                            aPassword:password
                                       aStatusMessage:statusMessage];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)enableTagFocus:(BOOL)enableTagFocus
                aStatusMessage:(NSString**)statusMessage {
    
    if (m_RfidSdkApi != nil)
    {

    
        return [m_RfidSdkApi srfidSetTagFocus:[m_ActiveReader getReaderID] isTagFocusEnable:enableTagFocus aStatusMessage:statusMessage];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)setSingulationConfigurationTagFoucus: (srfidSingulationConfig*)singulationConfiguration status:(NSString **)statusMessage
{
 
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetSingulationConfiguration:[m_ActiveReader getReaderID]aSingulationConfig:singulationConfiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getSingulationConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getSingulationConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)deleteAllPrefilter:(NSString**)statusMessage
{
    
    if (m_RfidSdkApi != nil)
    {
        srfidAntennaConfiguration *antenaCofiguration = [[[srfidAntennaConfiguration alloc]init] autorelease];
        
        SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
        
        for(int i = 0; i < ZT_MAX_RETRY; i++)
        {
            srfid_result = [m_RfidSdkApi srfidGetAntennaConfiguration:[m_ActiveReader getReaderID] aAntennaConfiguration:&antenaCofiguration aStatusMessage:statusMessage];
            
            if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
                break;
            }
        }
        NSString *response2 = @"";
      
        return [m_RfidSdkApi srfidSetDefaultConfiguration:[m_ActiveReader getReaderID]  aAntennaRconfig:antenaCofiguration aSingulationControl:nil aTagStorageSettings:nil aDeleteAllPrefilters:YES aDpoEnable:YES aSetAttributes:Nil aStatusMessage:&response2];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

- (void)srfidSetReaderDefaultConfiguration {
    // Log the function entry
    //[self logText:@"Inside function srfidSetReaderDefaultConfiguration"];
    // Create and configure singulation settings
    srfidSingulationConfig *singulationConfig = [[srfidSingulationConfig alloc] init];
    [singulationConfig setSession:SRFID_SESSION_S0];
    [singulationConfig setInventoryState:SRFID_INVENTORYSTATE_A];
    [singulationConfig setSlFlag:SRFID_SLFLAG_ALL];
    [singulationConfig setTagPopulation:30];
    //[self dispSingulationConfig:singulationConfig];
    // Create and configure tag report settings
    srfidTagReportConfig *tagReportConfig = [[srfidTagReportConfig alloc] init];
    [tagReportConfig setIncTagSeenCount:YES];
    [tagReportConfig setIncChannelIdx:YES];
    [tagReportConfig setIncFirstSeenTime:YES];
    [tagReportConfig setIncLastSeenTime:YES];
    [tagReportConfig setIncRSSI:YES];
    [tagReportConfig setIncPhase:YES];
    [tagReportConfig setIncPC:YES];
    // Retrieve reader capabilities
    srfidReaderCapabilitiesInfo *readerCapabilitiesInfo = [[srfidReaderCapabilitiesInfo alloc] init];
    NSString *status = nil;
    SRFID_RESULT srfidResult = [m_RfidSdkApi srfidGetReaderCapabilitiesInfo:[m_ActiveReader getReaderID]
                                                aReaderCapabilitiesInfo:&readerCapabilitiesInfo
                                                         aStatusMessage:&status];
    //[self logAPIResult:srfidResult apiName:@"srfidGetReaderCapabilitiesInfo"];
    // Create and configure antenna settings
    srfidAntennaConfiguration *antennaConfig = [[srfidAntennaConfiguration alloc] init];
    [antennaConfig setPower:(int16_t)[readerCapabilitiesInfo getMaxPower]];
    [antennaConfig setTari:0];
    [antennaConfig setDoSelect:NO];
    [antennaConfig setLinkProfileIdx:0];
    // Prepare attributes array
    NSMutableArray *setAttributes = [[NSMutableArray alloc] init];
    // Set default configuration
    srfidResult = [m_RfidSdkApi srfidSetDefaultConfiguration:[m_ActiveReader getReaderID]
                                         aAntennaRconfig:antennaConfig
                                   aSingulationControl:singulationConfig
                                 aTagStorageSettings:tagReportConfig
                                  aDeleteAllPrefilters:YES
                                           aDpoEnable:NO
                                        aSetAttributes:setAttributes
                                       aStatusMessage:&status];
    //[self logAPIResult:srfidResult apiName:@"srfidSetDefaultConfiguration"];
    // Check for errors
    if (srfidResult != SRFID_RESULT_SUCCESS) {
        //NSString *errorMessage = [NSString stringWithFormat:@"srfidSetDefaultConfiguration ***** FAILED, ErrorCode: %@, Status: %@", LOG_RESULTCODE[@(srfidResult)], status];
        //[self logText:errorMessage];
        return;
    }
}


-(SRFID_RESULT)enableTagQuiet:(BOOL)status meesage:(NSString**)statusMessage {
   
   if (m_RfidSdkApi != nil)
   {
       NSMutableArray<NSNumber *> *tagQuietMaskArray = [NSMutableArray array];
       // Add three enum values to the array
       [tagQuietMaskArray addObject:@(ENUM_TAGQUIET_MASK_S3B)];
       NSLog(@"Tag Quiet Mask Array: %@", tagQuietMaskArray);
       SRFID_RESULT resultTagquit = SRFID_RESULT_FAILURE;
       srfidSingulationConfig *config = [[[srfidSingulationConfig alloc] init] autorelease];
       
       if (status){
           
           resultTagquit = [m_RfidSdkApi srfidConfigureTagQuiet:[m_ActiveReader getReaderID] enumTagquietMasks:tagQuietMaskArray enumTarget:SRFID_SELECTTARGET_SL stateAwareAction:SRFID_SELECTACTION_INV_A__OR__ASRT_SL aStatusMessage:statusMessage];
           
           SRFID_SLFLAG sl_flag = SRFID_SLFLAG_DEASSERTED;
           SRFID_SESSION session = SRFID_SESSION_S2;
           SRFID_INVENTORYSTATE inv_state = SRFID_INVENTORYSTATE_AB_FLIP;
           
           [config setSlFlag:sl_flag];
           [config setSession:session];
           [config setInventoryState:inv_state];
           
           SRFID_RESULT resultSigulation = SRFID_RESULT_FAILURE;
           NSString *response2 = @"";
           resultSigulation = [[zt_RfidAppEngine sharedAppEngine] setSingulationConfigurationTagFoucus:config status:&response2];
           if (resultSigulation == SRFID_RESULT_SUCCESS)
           {
               NSLog(@"SRFID_RESULT_SUCCESS SingulationConfig");
           }else{
               NSLog(@"SRFID_RESULT_Fail SingulationConfig");
           }
           

           
       }
       else
       {
           resultTagquit = [m_RfidSdkApi srfidConfigureTagQuiet:[m_ActiveReader getReaderID]
                                              enumTagquietMasks:tagQuietMaskArray
                                                     enumTarget:SRFID_SELECTTARGET_SL
                                               stateAwareAction:SRFID_SELECTACTION_INV_B__OR__DSRT_SL
                                                 aStatusMessage:statusMessage];
           
       }
       
       return resultTagquit;
   }
   
   return SRFID_RESULT_FAILURE;
}


-(SRFID_RESULT)setPreFilterForTagQuiet:(NSMutableArray *)prefilters status:(NSString **)statusMessage;
{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [m_RfidSdkApi srfidSetPreFilters:[m_ActiveReader getReaderID] aPreFilters:prefilters aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getPrefilters:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self restorePrefilters];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

@end
