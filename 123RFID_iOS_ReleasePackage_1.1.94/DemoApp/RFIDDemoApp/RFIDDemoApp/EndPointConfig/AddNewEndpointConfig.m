//
//  AddNewEndpointConfig.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2024-09-24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AddNewEndpointConfig.h"
#import "UIColor+DarkModeExtension.h"
#import "config.h"
#import "AlertView.h"

#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_NAME              0
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE              1
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL          2
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_URL               3
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_PORT              4
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_KEEP_ALIVE        5
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_TENANT_ID         6
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLEAN_SESSION     7
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_MIN_RECONNECT_DELAY   8
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_MAX_RECONNECT_DELAY   9
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY       10
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_USER_NAME         11
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_PASSWORD          12
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE          13
// MDM Support
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_CMD_TOPIC         13
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_RES_TOPIC         14
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_ENT_TOPIC         15
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE    16
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE    17
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY           18

#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM          16
#define ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM_MQTT     19

// For the validation
//#define MAX_TOPIC_LENGTH                            128
#define MAX_EP_NAME_LENGTH                          16
#define MIN_EP_NAME_LENGTH                          2
#define MAX_USERNAME_LENGTH                         16
#define MAX_PASSWORD_LENGTH                         16
//#define MAX_PASSWORD_LENGTH_ENC_PADDING             48
//#define MAX_CLIENT_ID_LENGTH                        32
#define MAX_TENANT_ID_LENGTH                        48
#define MAX_URL_LENGTH                              512
#define MIN_PASSWORD_LENGTH                         8

#define ADD_NEW_ENDPOINT_CONFIG_TITLE @"Endpoint Settings"

@interface AddNewEndpointConfig ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
}
@property (nonatomic) NSArray *certificateChoices;
@property (nonatomic) NSArray *typeChoices;
@property (nonatomic) NSArray *protocolChoices;
@property (nonatomic) NSArray *hostVerifyChoices;
@end

@implementation AddNewEndpointConfig

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
    
        m_MapperEndpointConfigType = [[zt_EnumMapper alloc] initWithENDPOINTCONFIGType];
        m_MapperEndpointConfigProtocol = [[zt_EnumMapper alloc] initWithENDPOINTCONFIGProtocol];
        m_MapperEndpointConfigHostverify = [[zt_EnumMapper alloc] initWithENDPOINTCONFIGHostVerify];
        
        _typeChoices = [[m_MapperEndpointConfigType getStringArray] retain];
        _protocolChoices = [[m_MapperEndpointConfigProtocol getStringArray] retain];
        _hostVerifyChoices = [[m_MapperEndpointConfigHostverify getStringArray] retain];
        
        /* fill choises for picker cells */
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != cellName)
    {
        [cellName release];
    }
    if (nil != cellType)
    {
        [cellType release];
    }
    if (nil != cellProtocol)
    {
        [cellProtocol release];
    }
    if (nil != cellUrl)
    {
        [cellUrl release];
    }
    if (nil != cellPort)
    {
        [cellPort release];
    }
    if (nil != cellKeepAlive)
    {
        [cellKeepAlive release];
    }
    if (nil != cellTenantID)
    {
        [cellTenantID release];
    }
    if (nil != cellCleanSession)
    {
        [cellCleanSession release];
    }
    if (nil != cellMinRconnectDelay)
    {
        [cellMinRconnectDelay release];
    }
    if (nil != cellMaxReconnectDelay)
    {
        [cellMaxReconnectDelay release];
    }
    if (nil != cellHostVerify)
    {
        [cellHostVerify release];
    }
    if (nil != cellUserName)
    {
        [cellUserName release];
    }
    if (nil != cellPassword)
    {
        [cellPassword release];
    }
    // MDM Support
    if (nil != cellCommandTopic)
    {
        [cellCommandTopic release];
    }
    if (nil != cellResponseTopic)
    {
        [cellResponseTopic release];
    }
    if (nil != cellEventTopic)
    {
        [cellEventTopic release];
    }
    if (nil != cellCACertificate)
    {
        [cellCACertificate release];
    }
    if (nil != cellClientCertificate)
    {
        [cellClientCertificate release];
    }
    if (nil != cellPrivateKey)
    {
        [cellPrivateKey release];
    }
    if (nil != cellActivate)
    {
        [cellActivate release];
    }
    if (nil != certificates_list)
    {
        [certificates_list release];
    }
    
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ADD_NEW_ENDPOINT_CONFIG_TITLE];
    // Do any additional setup after loading the view.
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    /* configure table view */

    [addNewEndpoint_table registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [addNewEndpoint_table registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    [addNewEndpoint_table registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [addNewEndpoint_table registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    activityView = [[zt_AlertView alloc] init];
    certificates_list = [[NSMutableArray alloc] init];
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
 
    /* prevent table view from showing empty not-required cells or extra separators */
    [addNewEndpoint_table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    // Set separator style to none to remove the line between cells
    addNewEndpoint_table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    activeEndPoints = [[[srfidGetActiveEnpoints alloc] init] autorelease];
    
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"GetList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupConfigurationInitial];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [addNewEndpoint_table setDelegate:self];
    [addNewEndpoint_table setDataSource:self];
    [self getWlanCertificatesListApiCall];
    if ([self.operation isEqualToString:@"Update"]) {
        [addButton setTitle:@"Update" forState:UIControlStateNormal];
        [self getEndpointConfiguration:self.endPointName];
    }else
    {
        [addButton setTitle:@"Add" forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNameFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellName getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleURLFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellUrl getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePortFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellPort getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeepAliveFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellKeepAlive getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTenantIDFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellTenantID getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMinReconnectDelayFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellMinRconnectDelay getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMaxReconnectDelayFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellMaxReconnectDelay getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserNameFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellUserName getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePasswordFieldChanged:) name:UITextFieldTextDidChangeNotification object:[cellPassword getTextField]];
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [addNewEndpoint_table setDelegate:nil];
    [addNewEndpoint_table setDataSource:nil];
}
- (void)createPreconfiguredOptionCells
{
    cellName = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellUrl = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPort = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellKeepAlive = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellTenantID = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellMinRconnectDelay = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellMaxReconnectDelay = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellUserName = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPassword = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    cellType = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellProtocol = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellHostVerify = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    cellCleanSession = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    cellActivate = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    // MDM Support
    cellCommandTopic = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellResponseTopic = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellEventTopic = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    cellCACertificate = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    cellClientCertificate = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    cellPrivateKey = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    [cellName setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellName setDataFieldWidth:50];
    [cellName setInfoNotice:@"Name"];
    [cellName setData:@"SOTI_ACTIVE"];
    
    [cellUrl setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellUrl setDataFieldWidth:50];
    [cellUrl setInfoNotice:@"URL"];
    [cellUrl setKeyboardType:UIKeyboardTypeURL];
    
    [cellPort setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPort setDataFieldWidth:50];
    [cellPort setInfoNotice:@"Port"];
    [cellPort setKeyboardType:UIKeyboardTypeNumberPad];
    
    [cellKeepAlive setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellKeepAlive setDataFieldWidth:50];
    [cellKeepAlive setInfoNotice:@"KeepAlive (secs)"];
    [cellKeepAlive setKeyboardType:UIKeyboardTypeNumberPad];
    
    [cellTenantID setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellTenantID setDataFieldWidth:50];
    [cellTenantID setInfoNotice:@"TenantID"];
    
    [cellMinRconnectDelay setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellMinRconnectDelay setDataFieldWidth:35];
    [cellMinRconnectDelay setInfoNotice:@"Min Reconnect Delay (secs)"];
    [cellMinRconnectDelay setKeyboardType:UIKeyboardTypeNumberPad];
    
    [cellMaxReconnectDelay setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellMaxReconnectDelay setDataFieldWidth:35];
    [cellMaxReconnectDelay setInfoNotice:@"Max Reconnect Delay (secs)"];
    [cellMaxReconnectDelay setKeyboardType:UIKeyboardTypeNumberPad];
    
    [cellUserName setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellUserName setDataFieldWidth:50];
    [cellUserName setInfoNotice:@"UserName"];
    
    [cellPassword setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPassword setDataFieldWidth:50];
    [cellPassword setInfoNotice:@"Password"];
    
    [cellCleanSession setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellCleanSession setInfoNotice:@"Clean Session"];
    
    [cellActivate setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellActivate setInfoNotice:@"Activate"];
    
    [cellType setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellType setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellType setInfoNotice:@"Type"];
    
    [cellProtocol setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellProtocol setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellProtocol setInfoNotice:@"Protocol"];
    
    [cellHostVerify setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellHostVerify setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellHostVerify setInfoNotice:@"Host Verify"];
    
    [cellHostVerify setCellTag:0];
    [cellProtocol setCellTag:0];
    [cellType setCellTag:0];
    
    // MDM Support
    [cellCommandTopic setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellCommandTopic getTextField].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [cellCommandTopic setDataFieldWidth:50];
    [cellCommandTopic setInfoNotice:@"Command Topic"];
    
    [cellResponseTopic setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellResponseTopic getTextField].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [cellResponseTopic setDataFieldWidth:50];
    [cellResponseTopic setInfoNotice:@"Response Topic"];
    
    [cellEventTopic setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellEventTopic getTextField].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [cellEventTopic setDataFieldWidth:50];
    [cellEventTopic setInfoNotice:@"Event Topic"];
    
    [cellCACertificate setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellCACertificate setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellCACertificate setInfoNotice:@"CA Certificate"];
    
    [cellClientCertificate setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellClientCertificate setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellClientCertificate setInfoNotice:@"Client Certificate"];
    
    [cellPrivateKey setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPrivateKey setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellPrivateKey setInfoNotice:@"Private Key"];
}

- (void)setupConfigurationInitial
{
    [cellType setData:[self.typeChoices firstObject]];
    [cellProtocol setData:[self.protocolChoices firstObject]];
    [cellHostVerify setData:[self.hostVerifyChoices firstObject]];
}

- (void)getEndpointConfiguration:(NSString *)endPointName
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        srfidGetEndPointConfig *endPointConfig = [[[srfidGetEndPointConfig alloc] init] autorelease];
            
        result = [[zt_RfidAppEngine sharedAppEngine] getEndpointConfig:readerId endPointName:endPointName endPointConfig:&endPointConfig aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self getActiveEndpoints];
            });
            
            [cellName setData:[endPointConfig getepname]];
            [cellType setData:[[endPointConfig getType] uppercaseString]];
            [cellProtocol setData:[endPointConfig getProtocol]];
            [cellUrl setData:[endPointConfig getURL]];
            [cellPort setData:[endPointConfig getPort]];
            [cellKeepAlive setData:[endPointConfig getKeepalive]];
            [cellTenantID setData:[endPointConfig getTenantid]];
            if ([endPointConfig getEncleanss]) {
                [cellCleanSession setOption:1];
            }else
            {
                [cellCleanSession setOption:0];
            }
            [cellMinRconnectDelay setData:[endPointConfig getRcdelaymin]];
            [cellMaxReconnectDelay setData:[endPointConfig getRcdelaymax]];
            [cellHostVerify setData:[endPointConfig getHostvfy]];
            [cellUserName setData:[endPointConfig getUserName]];
            
            if ([endPointConfig getUserName] != nil && ![[endPointConfig getUserName]  isEqual: EMPTY_STRING]) {
                [cellPassword setData:[endPointConfig getPassword]];
            }
            [cellCommandTopic setData:[endPointConfig getSubname]];
            [cellResponseTopic setData:[endPointConfig getPub1name]];
            [cellEventTopic setData:[endPointConfig getPub2name]];
            [cellCACertificate setData:[endPointConfig getCACertname]];
            [cellClientCertificate setData:[endPointConfig getCertname]];
            [cellPrivateKey setData:[endPointConfig getKeyname]];
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Get endpoint data failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

/// Get wlan profile list api call
-(void)getWlanCertificatesListApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        result = [[zt_RfidAppEngine sharedAppEngine] getWlanCertificatesList:readerId wlanCertificatesList:&certificates_list status:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if (certificates_list.count != 0) {
                NSMutableArray * filesArray = [[NSMutableArray alloc] init];
                for (srfidWlanCertificates * certificates_info in certificates_list) {
                    [filesArray addObject:[certificates_info getWlanFile]];
                }
                self.certificateChoices = [[NSArray alloc] initWithArray:[filesArray mutableCopy]];
                [cellCACertificate setData:[self.certificateChoices firstObject]];
                [cellClientCertificate setData:[self.certificateChoices firstObject]];
                [cellPrivateKey setData:[self.certificateChoices firstObject]];
                [addNewEndpoint_table reloadData];
                
            }
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Get endpoint data failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)addNewEndpointConfig:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        RfidSetEndPointConfig * config = [[RfidSetEndPointConfig alloc] init];
        
        if ([self.operation isEqualToString:@"Update"]) {
            [config setOperation:@"update"];
        }else
        {
            [config setOperation:@"new"];
        }
    
        [config setepname:[cellName getCellData]];
        [config setType:[[cellType getCellData] lowercaseString]];
        [config setProtocol:[cellProtocol getCellData]];
        [config setURL:[cellUrl getCellData]];
        [config setPort:[cellPort getCellData]];
        [config setKeepalive:[cellKeepAlive getCellData]];
        [config setTenantid:[cellTenantID getCellData]];
        if ([cellCleanSession getOption]) {
            [config setEncleanss:1];
        }else
        {
            [config setDscleanss:1];
        }
        [config setRcdelaymin:[cellMinRconnectDelay getCellData]];
        [config setRcdelaymax:[cellMaxReconnectDelay getCellData]];
        [config setHostvfy:[cellHostVerify getCellData]];
        [config setUserName:[cellUserName getCellData]];
        [config setPassword:[cellPassword getCellData]];
        
        if ([[cellType getCellData] isEqualToString:@"MDM"]) {
            if ([[cellProtocol getCellData] isEqualToString:@"MQTT"]) {
                [config setSubname:[cellCommandTopic getCellData]];
                [config setPub1name:[cellResponseTopic getCellData]];
                [config setPub2name:[cellEventTopic getCellData]];
            }else if ([[cellProtocol getCellData] isEqualToString:@"MQTT_TLS"])
            {
                [config setSubname:[cellCommandTopic getCellData]];
                [config setPub1name:[cellResponseTopic getCellData]];
                [config setPub2name:[cellEventTopic getCellData]];
                [config setCacertname:[cellCACertificate getCellData]];
                [config setCertname:[cellClientCertificate getCellData]];
                [config setKeyname:[cellPrivateKey getCellData]];
            }
        }
    
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"GetList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        result = [[zt_RfidAppEngine sharedAppEngine] addEndPointConfig:readerId endPointConfig:config aStatusMessage:&status];

        if (result == SRFID_RESULT_SUCCESS)
        {

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self saveEndPointConfig];
            });
            
        }else if(result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Add endpoint failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)activateEndpoints:(NSString*)epName
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] activateEndPoint:readerId endPointType:@"activemgmtep" andEndPointName:epName aStatusMessage:&status];

        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            [self.navigationController popViewControllerAnimated:YES];
        }else if(result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)deActivateEndpoints:(NSString*)epName
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] activateEndPoint:readerId endPointType:@"activemgmtep" andEndPointName:epName aStatusMessage:&status];

        if (result == SRFID_RESULT_SUCCESS)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }else if(result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)getActiveEndpoints
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        srfidGetActiveEnpoints *endPointConfig = [[[srfidGetActiveEnpoints alloc] init] autorelease];
        
        result = [[zt_RfidAppEngine sharedAppEngine] getActiveEndPoints:&endPointConfig aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if([self getisActive:endPointConfig]) {
                [cellActivate setOption:true];
            }else
            {
                [cellActivate setOption:false];
            }

        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (BOOL) getisActive:(srfidGetActiveEnpoints *)activeEndPoints
{
    if ([[activeEndPoints getActivemgmtep] isEqualToString:self.endPointName] ||[[activeEndPoints getActivemgmtevtep] isEqualToString:self.endPointName]||
        [[activeEndPoints getActivectrlep] isEqualToString:self.endPointName]||
        [[activeEndPoints getActivedat1ep] isEqualToString:self.endPointName]||
        [[activeEndPoints getActivedat2ep] isEqualToString:self.endPointName]||
        [[activeEndPoints getBackupmgmtep] isEqualToString:self.endPointName]||
        [[activeEndPoints getBackupmgmtevtep] isEqualToString:self.endPointName]||
        [[activeEndPoints getBackupctrlep] isEqualToString:self.endPointName]||
        [[activeEndPoints getBackupdat1ep] isEqualToString:self.endPointName]||
        [[activeEndPoints getBackupdat2ep] isEqualToString:self.endPointName])
    {
        return true;
    }else
    {
        return false;
    }
}

- (void)saveEndPointConfig
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveEndPointConfig:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if ([cellActivate getSwitchOperated]) {
                if ([cellActivate getOption]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self activateEndpoints:[cellName getCellData]];
                        });
                }else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self deActivateEndpoints:@""];
                        });
                }
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                });
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)handleNameFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellName getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellName setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellName getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleURLFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellUrl getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellUrl setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellUrl getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handlePortFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellPort getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellPort setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellPort getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleKeepAliveFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellKeepAlive getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellKeepAlive setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellKeepAlive getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleTenantIDFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellTenantID getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellTenantID setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellTenantID getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleMinReconnectDelayFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellMinRconnectDelay getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellMinRconnectDelay setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellMinRconnectDelay getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleMaxReconnectDelayFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellMaxReconnectDelay getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellMaxReconnectDelay setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellMaxReconnectDelay getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handleUserNameFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellUserName getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellUserName setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellUserName getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handlePasswordFieldChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellPassword getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellPassword setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellPassword getTextField] undoManager] removeAllActions];
    [_input release];
}

-(void)showFailurePopup:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (int)recalcCellIndex:(int)cell_index
{
    if (-1 == m_PickerCellIdx)
    {
        return cell_index;
    }
    else
    {
        if (cell_index < m_PickerCellIdx)
        {
            return cell_index;
        }
        else
        {
            return (cell_index + 1);
        }
    }
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
    if ([[cellType getCellData] isEqualToString:@"SOTI"]) {
        return 14 + ((m_PickerCellIdx != -1) ? 1 : 0);
    }else
    {
        if ([[cellProtocol getCellData] isEqualToString:@"MQTT"]) {
            return 17 + ((m_PickerCellIdx != -1) ? 1 : 0);
        }else
        {
            return 20 + ((m_PickerCellIdx != -1) ? 1 : 0);
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        cell = m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_NAME] == cell_idx)
    {
        cell = cellName;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE] == cell_idx)
    {
        cell = cellType;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL] == cell_idx)
    {
        cell = cellProtocol;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_URL] == cell_idx)
    {
        cell = cellUrl;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PORT] == cell_idx)
    {
        cell = cellPort;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_KEEP_ALIVE] == cell_idx)
    {
        cell = cellKeepAlive;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_TENANT_ID] == cell_idx)
    {
        cell = cellTenantID;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLEAN_SESSION] == cell_idx)
    {
        cell = cellCleanSession;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_MIN_RECONNECT_DELAY] == cell_idx)
    {
        cell = cellMinRconnectDelay;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_MAX_RECONNECT_DELAY] == cell_idx)
    {
        cell = cellMaxReconnectDelay;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY] == cell_idx)
    {
        cell = cellHostVerify;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_USER_NAME] == cell_idx)
    {
        cell = cellUserName;
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PASSWORD] == cell_idx)
    {
        cell = cellPassword;
    }
    if ([[cellType getCellData] isEqualToString:@"SOTI"]) {
        if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE] == cell_idx)
        {
            cell = cellActivate;
        }
    }else
    {
        if ([[cellProtocol getCellData] isEqualToString:@"MQTT"]) {
            if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CMD_TOPIC] == cell_idx)
           {
               cell = cellCommandTopic;
           }
           else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_RES_TOPIC] == cell_idx)
           {
               cell = cellResponseTopic;
           }
           else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ENT_TOPIC] == cell_idx)
           {
               cell = cellEventTopic;
           }
           else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM] == cell_idx)
           {
               cell = cellActivate;
           }
        }else
        {
            if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CMD_TOPIC] == cell_idx)
            {
                cell = cellCommandTopic;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_RES_TOPIC] == cell_idx)
            {
                cell = cellResponseTopic;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ENT_TOPIC] == cell_idx)
            {
                cell = cellEventTopic;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE] == cell_idx)
            {
                cell = cellCACertificate;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx)
            {
                cell = cellClientCertificate;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY] == cell_idx)
            {
                cell = cellPrivateKey;
            }
            else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM_MQTT] == cell_idx)
            {
                cell = cellActivate;
            }
        }
    }
    
    if (nil != cell)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        
        height += 1.0;
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        return m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_NAME] == cell_idx)
    {
        [cellName darkModeCheck:self.view.traitCollection];
        return cellName;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE] == cell_idx)
    {
        [cellType darkModeCheck:self.view.traitCollection];
        return cellType;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL] == cell_idx)
    {
        [cellProtocol darkModeCheck:self.view.traitCollection];
        return cellProtocol;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_URL] == cell_idx)
    {
        [cellUrl darkModeCheck:self.view.traitCollection];
        return cellUrl;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PORT] == cell_idx)
    {
        [cellPort darkModeCheck:self.view.traitCollection];
        return cellPort;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_KEEP_ALIVE] == cell_idx)
    {
        [cellKeepAlive darkModeCheck:self.view.traitCollection];
        return cellKeepAlive;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_TENANT_ID] == cell_idx)
    {
        [cellTenantID darkModeCheck:self.view.traitCollection];
        return cellTenantID;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLEAN_SESSION] == cell_idx)
    {
        [cellCleanSession darkModeCheck:self.view.traitCollection];
        return cellCleanSession;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_MIN_RECONNECT_DELAY] == cell_idx)
    {
        [cellMinRconnectDelay darkModeCheck:self.view.traitCollection];
        return cellMinRconnectDelay;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_MAX_RECONNECT_DELAY] == cell_idx)
    {
        [cellMaxReconnectDelay darkModeCheck:self.view.traitCollection];
        return cellMaxReconnectDelay;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY] == cell_idx)
    {
        [cellHostVerify darkModeCheck:self.view.traitCollection];
        return cellHostVerify;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_USER_NAME] == cell_idx)
    {
        [cellUserName darkModeCheck:self.view.traitCollection];
        return cellUserName;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PASSWORD] == cell_idx)
    {
        [cellPassword darkModeCheck:self.view.traitCollection];
        return cellPassword;
    }
    if ([[cellType getCellData] isEqualToString:@"SOTI"]) {
        if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE] == cell_idx)
        {
            [cellActivate darkModeCheck:self.view.traitCollection];
            return cellActivate;
        }
    }else
    {
        if ([[cellProtocol getCellData] isEqualToString:@"MQTT"]) {
            if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CMD_TOPIC] == cell_idx)
            {
                [cellCommandTopic darkModeCheck:self.view.traitCollection];
                return cellCommandTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_RES_TOPIC] == cell_idx)
            {
                [cellResponseTopic darkModeCheck:self.view.traitCollection];
                return cellResponseTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ENT_TOPIC] == cell_idx)
            {
                [cellEventTopic darkModeCheck:self.view.traitCollection];
                return cellEventTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM] == cell_idx)
            {
                [cellActivate darkModeCheck:self.view.traitCollection];
                return cellActivate;
            }
        }else
        {
            if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CMD_TOPIC] == cell_idx)
            {
                [cellCommandTopic darkModeCheck:self.view.traitCollection];
                return cellCommandTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_RES_TOPIC] == cell_idx)
            {
                [cellResponseTopic darkModeCheck:self.view.traitCollection];
                return cellResponseTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ENT_TOPIC] == cell_idx)
            {
                [cellEventTopic darkModeCheck:self.view.traitCollection];
                return cellEventTopic;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE] == cell_idx)
            {
                [cellCACertificate darkModeCheck:self.view.traitCollection];
                return cellCACertificate;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx)
            {
                [cellClientCertificate darkModeCheck:self.view.traitCollection];
                return cellClientCertificate;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY] == cell_idx)
            {
                [cellPrivateKey darkModeCheck:self.view.traitCollection];
                return cellPrivateKey;
            }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_ACTIVATE_MDM_MQTT] == cell_idx)
            {
                [cellActivate darkModeCheck:self.view.traitCollection];
                return cellActivate;
            }
        }
    }
    
    
    
    return nil;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    int row_to_hide = -1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int main_cell_idx = -1;
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE] == cell_idx)
    {
        [m_cellPicker setChoices:_typeChoices];
        NSUInteger index = [_typeChoices indexOfObject:[cellType getCellData]];
        [m_cellPicker setSelectedChoice:(int)index];
        main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE;
        [addNewEndpoint_table reloadData];
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL] == cell_idx)
    {
        [m_cellPicker setChoices:_protocolChoices];
        NSUInteger index = [_protocolChoices indexOfObject:[cellProtocol getCellData]];
        [m_cellPicker setSelectedChoice:(int)index];
        main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL;
        [addNewEndpoint_table reloadData];
    }else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY] == cell_idx)
    {
        [m_cellPicker setChoices:_hostVerifyChoices];
        NSUInteger index = [_hostVerifyChoices indexOfObject:[cellHostVerify getCellData]];
        [m_cellPicker setSelectedChoice:(int)index];
        main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE] == cell_idx)
    {
        if ([[cellType getCellData] isEqualToString:@"MDM"] && [[cellProtocol getCellData] isEqualToString:@"MQTT_TLS"])
        {
            [m_cellPicker setChoices:_certificateChoices];
            NSUInteger index = [_certificateChoices indexOfObject:[cellCACertificate getCellData]];
            [m_cellPicker setSelectedChoice:(int)index];
            main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE;
        }
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx)
    {
        [m_cellPicker setChoices:_certificateChoices];
        NSUInteger index = [_certificateChoices indexOfObject:[cellClientCertificate getCellData]];
        [m_cellPicker setSelectedChoice:(int)index];
        main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE;
    }
    else if ([self recalcCellIndex:ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY] == cell_idx)
    {
        [m_cellPicker setChoices:_certificateChoices];
        NSUInteger index = [_certificateChoices indexOfObject:[cellPrivateKey getCellData]];
        [m_cellPicker setSelectedChoice:(int)index];
        main_cell_idx = ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY;
    }
    
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        
        if (-1 != row_to_hide)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ((main_cell_idx + 1) != _picker_cell_idx)
        {
            m_PickerCellIdx = main_cell_idx + 1;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)option_cell getSelectedChoice];
        
        if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_TYPE == (m_PickerCellIdx - 1))
        {
            NSString *value = _typeChoices[choice];
            [cellType setData:value];
            [cellType setCellTag:choice];
            if ([[cellType getCellData] isEqualToString:@"SOTI"]) {
                [cellName setData:@"SOTI_ACTIVE"];
            }else
            {
                [cellName setData:@""];
            }
        }
        else if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_PROTOCOL == (m_PickerCellIdx - 1))
        {
            NSString *value = _protocolChoices[choice];
            [cellProtocol setData:value];
            [cellProtocol setCellTag:choice];
        }
        else if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_HOST_VERIFY == (m_PickerCellIdx - 1))
        {
            NSString *value = _hostVerifyChoices[choice];
            [cellHostVerify setData:value];
            [cellHostVerify setCellTag:choice];
        }
        else if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_CA_CERTIFICATE == (m_PickerCellIdx - 1))
        {
            NSString *value = _certificateChoices[choice];
            [cellCACertificate setData:value];
            [cellCACertificate setCellTag:choice];
        }
        else if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_CLIENT_CERTIFICATE == (m_PickerCellIdx - 1))
        {
            NSString *value = _certificateChoices[choice];
            [cellClientCertificate setData:value];
            [cellClientCertificate setCellTag:choice];
        }
        else if (ZT_VC_ENDPOINTCONFIG_CELL_IDX_PRIVATE_KEY == (m_PickerCellIdx - 1))
        {
            NSString *value = _certificateChoices[choice];
            [cellPrivateKey setData:value];
            [cellPrivateKey setCellTag:choice];
        }
        [addNewEndpoint_table reloadData];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(addNewEndpoint_table.contentInset.top, 0.0, kbSize.height, 0.0);
    addNewEndpoint_table.contentInset = contentInsets;
    addNewEndpoint_table.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(addNewEndpoint_table.contentInset.top, 0.0, 0.0, 0.0);
    addNewEndpoint_table.contentInset = contentInsets;
    addNewEndpoint_table.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    addNewEndpoint_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [addNewEndpoint_table reloadData];
}


@end
