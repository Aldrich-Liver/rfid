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
 *  Description:  SettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SettingsVC.h"
#import "ReaderListVC.h"
#import "ConnectionSettingsVC.h"
#import "AntennaSettingsVC.h"
#import "SingulationSettingsVC.h"
#import "TagReportSettingsVC.h"
#import "RegulatorySettingsVC.h"
#import "TriggerSettingsVC.h"
#import "BeeperSettingsVC.h"
#import "SaveSettingsVC.h"
#import "BatteryStatusVC.h"
#import "PowerManagementVC.h"
#import "ui_config.h"
#import "AlertView.h"
#import "UIColor+DarkModeExtension.h"
#import "ProfilesViewController.h"
#import "AdvancedReaderOptionsTableViewController.h"
#import "ScannerSettingsViewController.h"
#import "UpdateFirmwareViewController.h"
#import "AssetDetailsVC.h"
#import "TriggerTableViewController.h"
#import "SledConfiguration.h"
#import "ui_config.h"
#import "config.h"
#import "FactoryResetViewController.h"
#import "SbtScannerInfo+AssetsTblRepresentation.h"
#import "ScannerEngine.h"
#import "ProClipSettingViewController.h"
#import "GetBatteryStatusViewController.h"
#import "BaseWIFITableViewController.h"
#import "CertificatesViewController.h"
#import "EndPointSettingsViewController.h"
#import "AdminLoginVC.h"
#import "BaseImpinjTagConfigViewController.h"


#define ZT_VC_SETTINGS_CELL_IDX_READER_LIST                    0
#define ZT_VC_SETTINGS_CELL_IDX_APPLICATION                    2
#define ZT_VC_SETTINGS_CELL_IDX_PROFILE                        1
#define ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION         3
#define ZT_VC_SETTINGS_CELL_IDX_REGULATORY                     4
#define ZT_VC_SETTINGS_CELL_IDX_BATTERY                        5
#define ZT_VC_SETTINGS_CELL_IDX_BEEPER                         6
#define ZT_VC_SETTINGS_CELL_IDX_SCANNER                        7
#define ZT_VC_SETTINGS_CELL_IDX_ADVANCED_SCANNER_OPTION        8
#define ZT_VC_SETTINGS_CELL_IDX_FIRMWARE_UPDATE                9
#define ZT_VC_SETTINGS_CELL_IDX_TRIGGER_MAP 10
#define ZT_VC_SETTINGS_CELL_IDX_SHARE_FILE 11
#define ZT_VC_SETTINGS_CELL_IDX_FACTORY_RESET 12
#define ZT_VC_SETTINGS_CELL_IDX_PRO_CLIP 13
#define ZT_VC_SETTINGS_CELL_IDX_BATTERY_STATUS 14
#define ZT_VC_SETTINGS_CELL_IDX_WIFI                           15
#define ZT_VC_SETTINGS_CELL_IDX_CERTIFICATES                   16
#define ZT_VC_SETTINGS_CELL_IDX_ENDPOINTCONFIG                 17
#define ZT_VC_SETTINGS_CELL_IDX_ADMINLOGIN                     18
//#define ZT_VC_SETTINGS_CELL_IDX_IMPINJ                         19

#define ZT_VC_SETTINGS_OPTIONS_NUMBER                          19


#define ZT_VC_SETTINGS_CELL_IMAGE_READER_LIST                  @"title_rdl.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_CONNECTION                   @"title_sett.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_ANTENNA                      @"title_antn.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_START_STOP_TRIGGER           @"title_strstp.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_SINGULATION_CONTROL          @"title_singl.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_REGULATORY                   @"title_reg.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_BEEPER                       @"title_beep.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_SAVE                         @"title_save.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_BATTERY                      @"title_batt.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_TAG_REPORT                   @"title_tags.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_PWR_MANAGEMENT_ON            @"title_pwr_on.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_PWR_MANAGEMENT_OFF           @"title_pwr_off.png"
#define ZT_VC_SETTINGS_CELL_IMAGE_FACTORY_RESET                @"reload_icon"
#define ZT_VC_SETTINGS_CELL_IMAGE_WIFI                         @"settings_wifi"
#define ZT_VC_SETTINGS_CELL_IMAGE_CERTIFICATES                 @"certificates_icon"
#define ZT_VC_SETTINGS_CELL_IMAGE_ENDPOINTCONFIG               @"endpoints_icon"
#define ZT_VC_SETTINGS_CELL_IMAGE_ADMINLOGIN                   @"admin_login"



#define ZT_CELL_ID_ACTIVE                                      @"ID_CELL_ACTIVE"
#define ZT_CELL_ID_DISABLE                                     @"ID_CELL_DISABLE"
#define DEFAULT_RESPONSE_MESSAGE    @""

@interface zt_SettingsVC () {
    NSNumber *m_LoadedViewIndex;
}

@property (nonatomic, retain) zt_SledConfiguration *localSled;

@end

@implementation zt_SettingsVC

/* Key to observe to detect change in DPO setting (KVO) */
static NSString *kKeyPathDpoEnable = @"currentDpoEnable";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_SettingsOptionsHeaders = [[NSMutableArray alloc] initWithCapacity:ZT_VC_SETTINGS_OPTIONS_NUMBER];
        m_SettingsOptionsImages = [[NSMutableArray alloc] initWithCapacity:ZT_VC_SETTINGS_OPTIONS_NUMBER];
        
        /* fill with empty elements to be replaced later */
        for (int i = 0; i < ZT_VC_SETTINGS_OPTIONS_NUMBER; i++)
        {
            [m_SettingsOptionsHeaders addObject:@""];
            [m_SettingsOptionsImages addObject:@""];
        }
        
        
        //Set title
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_READER_LIST withObject:ZT_STR_SETTINGS_SECTION_READER_LIST];//0
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_APPLICATION withObject:ZT_STR_SETTINGS_SECTION_APPLICATION];//1
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_PROFILE withObject:ZT_STR_SETTINGS_SECTION_PROFILE];//2
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION withObject:ZT_STR_SETTINGS_SECTION_ADVANCED_READER_OPTIONS];//3
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_REGULATORY withObject:ZT_STR_SETTINGS_SECTION_REGULATORY];//4
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BATTERY withObject:ZT_STR_SETTINGS_SECTION_BATTERY];//5
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BEEPER withObject:ZT_STR_SETTINGS_SECTION_BEEPER];//6
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_SCANNER withObject:ZT_STR_SETTINGS_SECTION_SCANNER];//7
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADVANCED_SCANNER_OPTION withObject:ZT_STR_SETTINGS_SECTION_DEVICE_INFORMATION];//8
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_FIRMWARE_UPDATE withObject:ZT_STR_SETTINGS_SECTION_FIRMWARE_UPDATE];//9
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_TRIGGER_MAP withObject:ZT_STR_SETTINGS_SECTION_TRIGGER_MAPPING];//10
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_SHARE_FILE withObject:ZT_STR_SETTINGS_SECTION_SHARE_FILE];//11
       
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_FACTORY_RESET withObject:ZT_STR_SETTINGS_SECTION_FACTORY_RESET];//12
        
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_PRO_CLIP withObject:ZT_STR_SETTINGS_SECTION_PRO_CLIP];//13
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BATTERY_STATUS withObject:ZT_STR_SETTINGS_SECTION_GET_BATTERY_STATUS];//14
        
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_WIFI withObject:ZT_STR_SETTINGS_SECTION_WIFI];//15
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_CERTIFICATES withObject:ZT_STR_SETTINGS_SECTION_CERTIFICATES];//16
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ENDPOINTCONFIG withObject:ZT_STR_SETTINGS_SECTION_ENDPOINTCONFIG];//17
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADMINLOGIN withObject:ZT_STR_SETTINGS_SECTION_ADMINLOGIN];//18
        
//        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_IMPINJ withObject:ZT_STR_SETTINGS_SECTION_IMPINJ];//20
//

        //Set image icon
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_READER_LIST withObject:CELL_IMAGE_READER_LIST];//0
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_APPLICATION withObject:CELL_IMAGE_APPLICATION];//1
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_PROFILE withObject:CELL_IMAGE_PROFILE];//2
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION withObject:CELL_IMAGE_ADVANCED_READER_OPTIONS];//3
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_REGULATORY withObject:CELL_IMAGE_REGULATORY];//4
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BATTERY withObject:CELL_IMAGE_BATTERY];//5
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BEEPER withObject:CELL_IMAGE_BEEPER];//6
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_SCANNER withObject:CELL_IMAGE_APPLICATION];//7
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADVANCED_SCANNER_OPTION withObject:CELL_IMAGE_DEVICE_INFORMATION];//8
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_FIRMWARE_UPDATE withObject:CELL_FIRMWARE_UPDATE];//9
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_TRIGGER_MAP withObject:CELL_TRIGGER];//10
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_SHARE_FILE withObject:CELL_SHARE];//11
        
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_FACTORY_RESET withObject:CELL_FACTORY_RESET];//12
        
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_PRO_CLIP withObject:CELL_PRO_CLIP];//13
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_BATTERY_STATUS withObject:CELL_GET_BATTERY_STATUS];//14
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_WIFI withObject:CELL_IMAGE_WIFI];//15
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_CERTIFICATES withObject:CELL_IMAGE_CERTIFICATES];//16
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ENDPOINTCONFIG withObject:ZT_VC_SETTINGS_CELL_IMAGE_ENDPOINTCONFIG];//17
        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_ADMINLOGIN withObject:ZT_VC_SETTINGS_CELL_IMAGE_ADMINLOGIN];//18

//        [m_SettingsOptionsImages replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_IMPINJ withObject:ZT_VC_SETTINGS_CELL_IMAGE_ENDPOINTCONFIG];//20
//        
        m_OffscreenImageLabelCell = [[zt_ImageLabelCellView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];

    if (nil != m_OffscreenImageLabelCell)
    {
        [m_OffscreenImageLabelCell release];
    }
    if (nil != m_SettingsOptionsImages)
    {
        [m_SettingsOptionsImages removeAllObjects];
        [m_SettingsOptionsImages release];
    }
    if (nil != m_SettingsOptionsHeaders)
    {
        [m_SettingsOptionsHeaders removeAllObjects];
        [m_SettingsOptionsHeaders release];
    }
    [m_tblSettingsOptions release];
    
    if( nil != _localSled)
    {
        [_localSled release];
    }
    
    if( nil != alertController)
    {
        [alertController release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    [m_tblSettingsOptions setDelegate:self];
    [m_tblSettingsOptions setDataSource:self];
    [m_tblSettingsOptions registerClass:[zt_ImageLabelCellView class] forCellReuseIdentifier:ZT_CELL_ID_ACTIVE];
    [m_tblSettingsOptions registerClass:[zt_ImageLabelCellView class] forCellReuseIdentifier:ZT_CELL_ID_DISABLE];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblSettingsOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    /* set title */
    [self setTitle:@"Settings"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    // Checking if auto-reconnect is enabled to get the connection status
    BOOL reconnection = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigConnectionAutoReconnection];
    if (reconnection) {
        [self getConnectionInterfaceStatus];
    }
    
}

// Connection Status
-(void)getConnectionInterfaceStatus{
       SRFID_RESULT result = SRFID_RESULT_FAILURE;
     
       result = [[zt_RfidAppEngine sharedAppEngine] requestConnectedInterfaceStatus] ;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (m_LoadedViewIndex == nil) {
        // do nothing
    }
    else
    {
        BOOL isApplicationChanged = [[NSUserDefaults standardUserDefaults] boolForKey:APPLICATION_DEFAULTS_KEY];
        switch ([m_LoadedViewIndex intValue])
        {
            case ZT_VC_SETTINGS_CELL_IDX_APPLICATION:
                    
                    if(isApplicationChanged == YES)
                    {
                        [self applyNewSetting:SAVE_APPLICATION_SETTINGS];
                    }
                    break;
            case ZT_VC_SETTINGS_CELL_IDX_PROFILE:
                
                if (inventoryRequested == NO) {
                    BOOL profileChanged = [[NSUserDefaults standardUserDefaults] boolForKey:PROFILE_DEFAULTS_KEY];
                    
                    if (profileChanged)
                        [self applyNewSetting:SAVE_PROFILE_SETTINGS];
                    break;
                }
            case ZT_VC_SETTINGS_CELL_IDX_REGULATORY:
                
                if (inventoryRequested == NO) {
                    if(![sled isRegulatoryConfigEqual:local])
                        {
                            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:REGULATORY_DEFAULTS_KEY];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        [self applyNewSetting:SAVE_REGULATORY_SETTINGS];
                        }else
                        {
                            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:REGULATORY_DEFAULTS_KEY];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    break;
                    }
            case ZT_VC_SETTINGS_CELL_IDX_BEEPER:
                if (inventoryRequested == NO) {
                    if (![sled isBeeperConfigEqual:local]) {
                        [self applyNewSetting:SAVE_BEEPER_SETTINGS];
                        return;
                    }else if (![sled isHostBeeperConfigEqual:local])
                    {
                        [self applyNewSetting:SAVE_BEEPER_SETTINGS];
                        return;
                    }
                    else
                    {
                        /* equal -> overwrite volume level in case of disabled beeper */
                        [sled setCurrentBeeperLevel:[local currentBeeperLevel]];
                    }
                    break;
                }
        }
    }
    
    [self darkModeCheck:self.view.traitCollection];
}

-(void)saveActiveProfileValues
{
    NSDictionary * tempActiveDic = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getActiveProfileFromLocalMemory];
    
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (tempActiveDic != nil) {
        BOOL isProfileUpdated = [[NSUserDefaults standardUserDefaults] boolForKey:PROFILE_UPDATED_KEY];
        
        if (!isProfileUpdated) {
            configuration.currentAntennaLinkProfile = [[tempActiveDic objectForKey:PROFILE_KEY_LINKPROFILE] intValue];
        }
        
        configuration.currentAntennaPowerLevel = [[tempActiveDic objectForKey:PROFILE_KEY_POWER] floatValue];
        configuration.currentSession = [[tempActiveDic objectForKey:PROFILE_KEY_SESSION] floatValue];
        configuration.currentDpoEnable = [tempActiveDic objectForKey:PROFILE_KEY_DYNAMICPOWER];
//        configuration.currentAntennaPie = 2000;
//        configuration.currentAntennaTari = 6250;
    }else
    {
        NSDictionary * fastestReadDic = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getFastestReadProfileFromLocalMemory];
        configuration.currentAntennaLinkProfile = [[fastestReadDic objectForKey:PROFILE_KEY_LINKPROFILE] intValue];
        configuration.currentAntennaPowerLevel = [[fastestReadDic objectForKey:PROFILE_KEY_POWER] floatValue];
        configuration.currentSession = [[fastestReadDic objectForKey:PROFILE_KEY_SESSION] floatValue];
        configuration.currentDpoEnable = [fastestReadDic objectForKey:PROFILE_KEY_DYNAMICPOWER];
        configuration.currentAntennaPie = 2000;
        configuration.currentAntennaTari = 6250;
        [self updatetoSled];
    }
}

-(void)updatetoSled
{
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *response = @"";
    result = [[zt_RfidAppEngine sharedAppEngine] setAntennaConfigurationFromLocal:&response];
}

/// Check whether the conected device supports for scanning barcodes or not
-(void)canDeviceScanBarcodes {
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];

    NSString *statusPL33Support = sled.readerPL33 == nil ? EMPTY_STRING:sled.readerPL33;

    NSLog(@"Reader: %@", sled.readerPL33);

    if ([statusPL33Support isEqualToString: EMPTY_STRING])
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsScanFeatureSupporting:NO];
    }else
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsScanFeatureSupporting:YES];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    // observe "currentDpoEnable" property changes using KVO
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] addObserver:self forKeyPath:kKeyPathDpoEnable options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    BOOL isReaderActive = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_ACTIVE_READER_KEY];
    
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive] && isReaderActive) {
       
        [self canDeviceScanBarcodes];
        isScannerSupport = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsScanFeatureSupporting];
        [self saveActiveProfileValues];
    }
    
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Remove KVO observer for the DPO option
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] removeObserver:self forKeyPath:kKeyPathDpoEnable];
}

- (void)applyNewSetting:(NSString *)name
{
    NSString *message = [NSString stringWithFormat:@"%@", name];
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(updateSled) withObject:nil withString:message];
}

- (void)updateSled
{
    int idx = [m_LoadedViewIndex intValue];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *response = @"";
    
    switch (idx) {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            
            break;
        case ZT_VC_SETTINGS_CELL_IDX_APPLICATION:
            result = SRFID_RESULT_SUCCESS;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_PROFILE:
            result = [[zt_RfidAppEngine sharedAppEngine] setAntennaConfigurationFromLocal:&response];
            break;
        
        case ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION:
            result = [[zt_RfidAppEngine sharedAppEngine] setSingulationConfigurationFromLocal:&response];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_REGULATORY:
            [zt_RfidAppEngine sharedAppEngine].popupAuthDelegate = self;
            result = [[zt_RfidAppEngine sharedAppEngine] setRegulatoryConfig:&response];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_BEEPER:
            result = [[zt_RfidAppEngine sharedAppEngine] setBeeperConfig:&response];
            break;
    }
    sleep(3);
    
    //[self handleCommandResult:result withStatusMessage:response];
    m_LoadedViewIndex = [NSNumber numberWithInt:-1];
}

#pragma mark - Event AddprofilePopupDelegate

-(void)showAuthorisation:(NSString*)status
{
    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
}

- (void)configureImageLabelCell:(zt_ImageLabelCellView*)cell forRow:(int)row
{
    NSString *settingHeader = (NSString*)[m_SettingsOptionsHeaders objectAtIndex:row];
    if ([settingHeader isEqualToString:ZT_STR_SETTINGS_CONNECTION] ||
        [settingHeader isEqualToString:ZT_STR_SETTINGS_READER_LIST] || [settingHeader isEqualToString:ZT_STR_SETTINGS_SECTION_SHARE_FILE])
    {
        [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
        [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
    }
    else
    {
        if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
            
            // Power management has more than one possible image.
            if ([settingHeader isEqualToString:ZT_STR_SETTINGS_PWR_MANAGEMENT])
            {
                [cell setCellImage:[self getImageNameForPowerManagementIcon]];
            }
            else
            {
                [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
            }
            cell.userInteractionEnabled = YES;
        }
        else
        {
            [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
            [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
            [cell setDisableStyle];
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
    }
}

- (BOOL)deviceListHasBeenUpdated
{
    /* This refreshes the power management button and the rest of the table */
    [self refreshPowerManagementButton];
    
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive]) {
        return YES;
    }
    
    switch ([m_LoadedViewIndex intValue])
    {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            // do nothing
            break;
        case ZT_VC_SETTINGS_CELL_IDX_APPLICATION:
            // do nothing
            break;
        case ZT_VC_SETTINGS_CELL_IDX_PROFILE:
            [self.navigationController popToViewController:self animated:YES];
            break;
       
        case ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_REGULATORY:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_BEEPER:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_PRO_CLIP:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_SCANNER:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_FIRMWARE_UPDATE:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_TRIGGER_MAP:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_SHARE_FILE:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_FACTORY_RESET:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_BATTERY_STATUS:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_WIFI:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_CERTIFICATES:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_ENDPOINTCONFIG:
            [self.navigationController popToViewController:self animated:YES];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_ADMINLOGIN:
            [self.navigationController popToViewController:self animated:YES];
            break;
    }

    
    return YES;
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_SettingsOptionsHeaders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    [self configureImageLabelCell:m_OffscreenImageLabelCell forRow:(int)[indexPath row]];
    
    [m_OffscreenImageLabelCell setNeedsUpdateConstraints];
    [m_OffscreenImageLabelCell updateConstraintsIfNeeded];
    [m_OffscreenImageLabelCell setNeedsLayout];
    [m_OffscreenImageLabelCell layoutIfNeeded];
    
    height = [m_OffscreenImageLabelCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    zt_ImageLabelCellView *_cell = nil;
    NSString *settingHeader = (NSString*)[m_SettingsOptionsHeaders objectAtIndex:(int)[indexPath row]];
    if ([settingHeader isEqualToString:ZT_STR_SETTINGS_CONNECTION] ||
        [settingHeader isEqualToString:ZT_STR_SETTINGS_READER_LIST] || [settingHeader isEqualToString:ZT_STR_SETTINGS_SECTION_SCANNER])
    {
        _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_ACTIVE forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_ACTIVE];
        }

    }
    else
    {
        if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_ACTIVE forIndexPath:indexPath];
            
            if (_cell == nil)
            {
                _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_ACTIVE];
            }

        }
        else
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_DISABLE forIndexPath:indexPath];
            
            if (_cell == nil)
            {
                _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_DISABLE];
            }
        }
    }
        
    [self configureImageLabelCell:_cell forRow:(int)[indexPath row]];
    [_cell darkModeCheck:self.view.traitCollection];
    _cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [_cell setNeedsUpdateConstraints];
    [_cell updateConstraintsIfNeeded];
    
    return _cell;
}
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int idx = (int)[indexPath row];
    
    UIViewController *vc = nil;
    zt_ReaderListVC *reader_list_vc = nil;
    zt_ConnectionSettingsVC *connection_vc = nil;
    zt_RegulatorySettingsVC *regulatory_vc = nil;
    zt_BeeperSettingsVC *beeper_vc = nil;
    zt_BatteryStatusVC *battery_vc = nil;
    zt_ProfilesViewController *profile_vc = nil;
    AdvancedReaderOptionsTableViewController *advancedReaderOptionsTableViewController = nil;
    ScannerSettingsViewController * scanner_settings_vc = nil;
    UpdateFirmwareViewController *firmwareUpdateVC = nil;
    AssetDetailsVC *assetDetailsVC;
    TriggerTableViewController *triggerMappingVC = nil;
    FactoryResetViewController *factoryResetViewController = nil;
    ProClipSettingViewController *proClipSettingViewController = nil;
    GetBatteryStatusViewController *getBatteryStatusViewController = nil;
    BaseWIFITableViewController *wifi_settings_vc = nil;
    CertificatesViewController *certificates_vc = nil;
    EndPointSettingsViewController *endpointconfig_vc = nil;
    AdminLoginVC *adminlogin_vc = nil;
    BaseImpinjTagConfigViewController *impinjTagConfig_vc = nil;
    
    
    
    zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    switch (idx)
    {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            reader_list_vc = (zt_ReaderListVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:READER_LIST_STORY_BOARD_ID];
            vc = reader_list_vc;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_APPLICATION:
            connection_vc = (zt_ConnectionSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:APPLICATION_STORY_BOARD_ID];
            vc = connection_vc;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_PROFILE:
            profile_vc = (zt_ProfilesViewController*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:PROFILE_STORY_BOARD_ID];
            vc = profile_vc;
            break;
        
        case ZT_VC_SETTINGS_CELL_IDX_ADVANCED_READER_OPTION:
            advancedReaderOptionsTableViewController = (AdvancedReaderOptionsTableViewController*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADVANCED_OPTIONS_STORY_BOARD_ID];
            vc = advancedReaderOptionsTableViewController;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_REGULATORY:
            regulatory_vc = (zt_RegulatorySettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:REGULATORY_STORY_BOARD_ID];
            vc = regulatory_vc;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_BATTERY:
            battery_vc = (zt_BatteryStatusVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:BATTERY_STORY_BOARD_ID];
            vc = battery_vc;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_BEEPER:
            beeper_vc = (zt_BeeperSettingsVC*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:BEPPER_SETTINGS_STORY_BOARD_ID];
            vc = beeper_vc;
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_SCANNER:
            if (isScannerSupport)
            {
                scanner_settings_vc = (ScannerSettingsViewController*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:STORY_BOARD_ID_SETTINGS];
                vc = scanner_settings_vc;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_SCAN_FEATURE_STRING_FORMAT,ZT_SCAN_FEATURE_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            break;
        case ZT_VC_SETTINGS_CELL_IDX_ADVANCED_SCANNER_OPTION:
            assetDetailsVC = (AssetDetailsVC*)[[UIStoryboard storyboardWithName:SCANNER_ASSET_DETAILS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateInitialViewController];
            vc = assetDetailsVC;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_FIRMWARE_UPDATE:
            firmwareUpdateVC = (UpdateFirmwareViewController*)[[UIStoryboard storyboardWithName:SCANNER_FIRMWARE_UPDATE_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateInitialViewController];
            [firmwareUpdateVC setupCloseButton:NO];
            vc = firmwareUpdateVC;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_TRIGGER_MAP:
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS]) {
                triggerMappingVC = (TriggerTableViewController*)[[UIStoryboard storyboardWithName:TRIGGER_MAPPING_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateInitialViewController];
                vc = triggerMappingVC;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_TRIGGER_MAPPING_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            break;
        case ZT_VC_SETTINGS_CELL_IDX_SHARE_FILE:
            [self openSharedFiles];
            break;
        case ZT_VC_SETTINGS_CELL_IDX_FACTORY_RESET:
            factoryResetViewController = (FactoryResetViewController*)[[UIStoryboard storyboardWithName:SCANNER_FACTORY_RESET_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:FACTORY_RESET_BOARD_ID];
            vc = factoryResetViewController;
     
            break;
            
            
        case ZT_VC_SETTINGS_CELL_IDX_PRO_CLIP:
            
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS]) {
                proClipSettingViewController = (ProClipSettingViewController*)[[UIStoryboard storyboardWithName:SCANNER_PRO_CLIP_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:PRO_CLIP_BOARD_ID];
                vc = proClipSettingViewController;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_PRO_CLIP_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
     
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_BATTERY_STATUS:
            
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS]) {
                getBatteryStatusViewController = (GetBatteryStatusViewController*)[[UIStoryboard storyboardWithName:SCANNER_BATTERY_STATUS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:BATTERY_STATUS_BOARD_ID];
                vc = getBatteryStatusViewController;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_BATTERY_PP_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
     
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_WIFI:
            
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS] && ![[[zt_RfidAppEngine sharedAppEngine] getConnectedReaderName] containsString:ZT_READER_NAME_CONTAINS_STANDARD]) {
                wifi_settings_vc = (BaseWIFITableViewController*)[[UIStoryboard storyboardWithName:WIFI_SETTINGS_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:BASEWIFI_SETTINGS_BOARD_ID];
                vc = wifi_settings_vc;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_WIFI_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_CERTIFICATES:
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS] && ![[[zt_RfidAppEngine sharedAppEngine] getConnectedReaderName] containsString:ZT_READER_NAME_CONTAINS_STANDARD]){
                certificates_vc = (CertificatesViewController*)[[UIStoryboard storyboardWithName:CERTIFICATES_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:CERTIFICATES_BOARD_ID];
                vc = certificates_vc;
            }else {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_CERTIFICATE_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            
     
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_ENDPOINTCONFIG:
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS] && ![[[zt_RfidAppEngine sharedAppEngine] getConnectedReaderName] containsString:ZT_READER_NAME_CONTAINS_STANDARD]) {
                endpointconfig_vc = (EndPointSettingsViewController*)[[UIStoryboard storyboardWithName:ENDPOINT_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ENDPOINT_SET_BOARD_ID];
                vc = endpointconfig_vc;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_ENDPOINT_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            break;
            
        case ZT_VC_SETTINGS_CELL_IDX_ADMINLOGIN:
            if (![[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS]) {
                adminlogin_vc = (AdminLoginVC*)[[UIStoryboard storyboardWithName:LOGIN_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:LOGIN_BOARD_ID];
                adminlogin_vc.fromRootView = true;
                vc = adminlogin_vc;
            }else
            {
                NSString * alertMessage = [NSString stringWithFormat:ZT_TRIGGER_MAPPING_STRING_FORMAT,ZT_LOGIN_NOT_SUPPORT_MESSAGE,[sled readerModel]];
                [self displayErrorAlert:alertMessage];
                return;
            }
            break;
            
    }
    
    if (nil != vc)
    {
        m_LoadedViewIndex = [NSNumber numberWithInt:idx];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


/// To display error alert when user try with un supported readers.
/// @param alertMessage Alert message to show in the message.
-(void) displayErrorAlert:(NSString *)alertMessage
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:alertMessage];
    });
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

- (NSString *) getImageNameForPowerManagementIcon
{
    // Use grey image by default (dpo off)
    NSString *imageName = ZT_VC_SETTINGS_CELL_IMAGE_PWR_MANAGEMENT_OFF;
    
    // Check if there is a connected reader
    if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        // Check if DPO is active
        if([[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentDpoEnable] boolValue] )
        {
            // DPO is active, turn power management button green
            imageName = ZT_VC_SETTINGS_CELL_IMAGE_PWR_MANAGEMENT_ON;
            
        }
        else
        {
            // DPO is not active, turn power management button grey
            imageName = ZT_VC_SETTINGS_CELL_IMAGE_PWR_MANAGEMENT_OFF;
        }
    }

    return imageName;
}

- (void) refreshPowerManagementButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tblSettingsOptions reloadData];
    });
}

/// To open shared files from the phone.
- (void)openSharedFiles{
    if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested] && ![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested])
    {
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[ZT_MULTI_TAGDATA_DOCUMENT_TYPE_TEXT,ZT_MULTI_TAGDATA_DOCUMENT_TYPE_DATA]
                                                                                                                    inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:documentPicker animated:YES completion:nil];
    }else
    {
        [self displayErrorAlert:ZT_GENERAL_ERROR_MESSAGE];
    }
}

///MARK:- Document picker delegate

/// Tells the delegate that the user has selected a document or a destination.
/// @param controller The document picker that called this method.
/// @param url The URL of the selected document or destination.
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        // Condition called when user download the file
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        if (fileData != nil) {
            NSString *urlString = [[NSString alloc] initWithFormat:ZT_SHARE_FILE_FORMAT,url];
            NSArray *activityItems = @[[NSURL fileURLWithPath:urlString]];
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:NULL];
            dispatch_async(dispatch_get_main_queue(),^{
                [self presentViewController:activityView animated:YES completion:NULL];
            });
        }
    }
}

/// Tells the delegate that the user canceled the document picker.
/// @param controller The document picker that called this method.
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    NSLog(@"Document picker was cancelled");
}

#pragma mark - KVO observer methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // detect if the current dpo enable value has changed
    if ([keyPath isEqual:kKeyPathDpoEnable])
    {
        [self refreshPowerManagementButton];
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    m_tblSettingsOptions.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [m_tblSettingsOptions reloadData];
}

@end
