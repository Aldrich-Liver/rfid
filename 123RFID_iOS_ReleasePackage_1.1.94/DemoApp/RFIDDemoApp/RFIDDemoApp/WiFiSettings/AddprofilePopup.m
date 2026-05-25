//
//  AddprofilePopup.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 29/02/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "AddprofilePopup.h"
#import "UIColor+DarkModeExtension.h"
#import "config.h"
#import "RFIDDemoApp-Swift.h"
#import <ZebraRfidSdkFramework/RfidWlanCertificates.h>
#import "WiFiSettingsViewControler.h"
#import "AlertView.h"

#define ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL              0
#define ZT_VC_ADDPROFILE_CELL_IDX_EAP                   1
#define ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE        2
#define ZT_VC_ADDPROFILE_CELL_IDX_IDENTITY              3
#define ZT_VC_ADDPROFILE_CELL_IDX_ANNO_IDENTIFIER       4
#define ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE    4
#define ZT_VC_ADDPROFILE_CELL_IDX_PASSWORD              5
#define ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_PASSWORD      6
#define ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY           5
#define ZT_VC_ADDPROFILE_CELL_IDX_PREFFERED_PROFILE     7
#define ZT_VC_ADDPROFILE_CELL_IDX_HIDDEN_SSID           8

#define ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_NO_ENCRIPTION 2
#define ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_PERSONAL      3
#define ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_ENTERPRISE    7
#define ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_FULL          8

#define ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_NO_ENCRIPTION 3
#define ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_PERSONAL      4
#define ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_ENTERPRISE    8
#define ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_FULL          9

#define PROTOCOL_TYPE_WPAPSK                 @"WPAPSK"
#define PROTOCOL_TYPE_IEEE8021X              @"IEEE8021X"
// Personal Protocols
#define PROTOCOL_TYPE_NO_ENCRIPTION                 @"No_Encryption"
#define PROTOCOL_TYPE_WPA_PERSONAL_TKIP             @"WPA_Personal_TKIP"
#define PROTOCOL_TYPE_WPA2_PERSONAL_CCMP            @"WPA2_Personal_CCMP"
#define PROTOCOL_TYPE_WPA3_PERSONAL_SAE             @"WPA3_Personal_SAE"

// Enterprise Protocols
#define PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP               @"WPA_Enterprise_TKIP"
#define PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP              @"WPA2_Enterprise_CCMP"
#define PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP              @"WPA3_Enterprise_CCMP"
#define PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256          @"WPA3_Enterprise_CCMP_256"
#define PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128          @"WPA3_Enterprise_GCMP_128"
#define PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256      @"WPA3_Enterprise_GCMP_256_SHA256"
#define PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192         @"WPA3_Enterprise_GCMP_256_SUITEB_192"
#define PROTOCOL_TYPE_UNSUPPORTED         @"UNSUPPORTED"

// Enterprise EAP
#define EAP_TYPE_TTLS                 @"TTLS"
#define EAP_TYPE_PEAP                 @"PEAP"
#define EAP_TYPE_TLS                  @"TLS"

#define MSG_PROFILE_ADDING @"Please wait.\nWlan profile is saving..."
#define USERNAME_REGEX      @"^[\x20-\x7E]{1,32}$"
@interface AddprofilePopup ()
{
    NSString * protocol;
    NSString * profileProtocol;
    NSString * selectedEAP;
    int passwordIndex;
    sRfidAddProfileConfig * profileConfig;
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
}
@property (nonatomic) NSArray *protocolChoices;
@property (nonatomic) NSArray *EAPChoices;
@property (nonatomic) NSArray *CertificateChoices;
@end

@implementation AddprofilePopup
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [addProfile_table release];
    
    if (nil != cellProtocol)
    {
        [cellProtocol release];
    }
    if (nil != cellEAP)
    {
        [cellEAP release];
    }
    if (nil != cellCACertificates)
    {
        [cellCACertificates release];
    }
    if (nil != cellIdentity)
    {
        [cellIdentity release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    
    if (nil != cellAnnonymousIdentity)
    {
        [cellAnnonymousIdentity release];
    }
    if (nil != cellPassword)
    {
        [cellPassword release];
    }
    if (nil != cellPrivatePassword)
    {
        [cellPrivatePassword release];
    }
    if (nil != cellPrivateKey)
    {
        [cellPrivateKey release];
    }
    if (nil != cellClientCertificates)
    {
        [cellClientCertificates release];
    }
    if (nil != _protocolChoices)
    {
        [_protocolChoices release];
    }
    if (nil != _EAPChoices)
    {
        [_EAPChoices release];
    }
    if (nil != _CertificateChoices)
    {
        [_CertificateChoices release];
    }
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != certificates_list)
    {
        [certificates_list release];
    }
    if (nil != cellHiddenSSID)
    {
        [cellHiddenSSID release];
    }
    if (nil != cellPreferredWIFI)
    {
        [cellPreferredWIFI release];
    }
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    /* configure table view */
    [addProfile_table registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [addProfile_table registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [addProfile_table registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    certificates_list = [[NSMutableArray alloc] init];
    profileConfig = [[sRfidAddProfileConfig alloc] init];
    activityView = [[zt_AlertView alloc] init];
    
    [cellPassword setDelegate:self];
    [cellIdentity setDelegate:self];
    [cellPrivatePassword setDelegate:self];
    [cellAnnonymousIdentity setDelegate:self];
    
    [cellIdentity setTag:1];
    [cellAnnonymousIdentity setTag:2];
    [cellPassword setTag:3];
    [cellPrivatePassword setTag:4];
    
    [profileName_Field setDelegate:self];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [addProfile_table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    addProfileView.layer.cornerRadius = 20;
    addProfileView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    [self setupConfigurationInitial];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIdentityChanged:) name:UITextFieldTextDidChangeNotification object:[cellIdentity getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAnnonymousIdentityChanged:) name:UITextFieldTextDidChangeNotification object:[cellAnnonymousIdentity getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePasswordChanged:) name:UITextFieldTextDidChangeNotification object:[cellPassword getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrivatePasswordChanged:) name:UITextFieldTextDidChangeNotification object:[cellPrivatePassword getTextField]];
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [addProfile_table setDelegate:self];
    [addProfile_table setDataSource:self];
    
    [self getWlanCertificatesListApiCall];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[cellIdentity getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [addProfile_table setDelegate:nil];
    [addProfile_table setDataSource:nil];
}

- (void)createPreconfiguredOptionCells
{
    cellIdentity = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellAnnonymousIdentity = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPassword = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPrivatePassword = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    //[cellIdentity setKeyboardType:UIKeyboardTypeDecimalPad];
    cellProtocol = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellEAP = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellCACertificates = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellClientCertificates = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPrivateKey = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    cellHiddenSSID = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    cellPreferredWIFI = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    [cellIdentity setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellIdentity setDataFieldWidth:50];
    [cellIdentity setInfoNotice:@"Identity"];
    
    [cellAnnonymousIdentity setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellAnnonymousIdentity setDataFieldWidth:50];
    [cellAnnonymousIdentity setInfoNotice:@"Annonymous Identity"];
    
    [cellPassword setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPassword setDataFieldWidth:50];
    [cellPassword setInfoNotice:@"Password"];
    
    [cellPrivatePassword setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPrivatePassword setDataFieldWidth:50];
    [cellPrivatePassword setInfoNotice:@"Private Password"];
    
    [cellProtocol setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellProtocol setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellProtocol setInfoNotice:@"Protocol"];
    
    [cellEAP setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellEAP setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellEAP setInfoNotice:@"EAP"];
    
    [cellPrivateKey setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPrivateKey setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellPrivateKey setInfoNotice:@"Private Key"];
    
    [cellCACertificates setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellCACertificates setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellCACertificates setInfoNotice:@"CA Cert"];
    
    [cellClientCertificates setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellClientCertificates setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellClientCertificates setInfoNotice:@"Client Cert"];
    
    [cellHiddenSSID setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellHiddenSSID setInfoNotice:@"Hidden SSID"];
    [cellHiddenSSID setOption:0];
    
    [cellPreferredWIFI setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPreferredWIFI setInfoNotice:@"Preferred Wi-Fi"];
    [cellPreferredWIFI setOption:0];
}
- (void)setupConfigurationInitial
{
    heightConstraint.constant = 560;
    
    if ([self.popup_type isEqualToString:@"Manual"]) {
        profileName.hidden = YES;
        profileNameLabelHC.constant = 0;
        profileName_Field.hidden = NO;
        profileNameFieldHC.constant = 37;
        
        NSArray *array = [[NSArray alloc] initWithObjects:PROTOCOL_TYPE_WPAPSK,PROTOCOL_TYPE_IEEE8021X,PROTOCOL_TYPE_NO_ENCRIPTION,PROTOCOL_TYPE_WPA_PERSONAL_TKIP,PROTOCOL_TYPE_WPA2_PERSONAL_CCMP,PROTOCOL_TYPE_WPA3_PERSONAL_SAE,PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP,PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP,PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP,PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256,PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128,PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256,PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192, nil];
        
        self.protocolChoices = [[NSArray alloc] initWithArray:array];
        [cellProtocol setData:[self.protocolChoices firstObject]];
        
        profileProtocol = [NSString stringWithString:[self.protocolChoices firstObject]];
        
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK]|| [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
            heightConstraint.constant = 320;
        }
        else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
            heightConstraint.constant = 380;
        }else
        {
            self.EAPChoices = [[NSArray alloc] initWithObjects:EAP_TYPE_TTLS,EAP_TYPE_PEAP,EAP_TYPE_TLS, nil];
            [cellEAP setData:[self.EAPChoices firstObject]];
            selectedEAP = [NSString stringWithString:[self.EAPChoices firstObject]];
            passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_PASSWORD;
            heightConstraint.constant = 620;
        }
        
    }else
    {
        profileName.hidden = NO;
        profileNameLabelHC.constant = 37;
        profileName_Field.hidden = YES;
        profileNameFieldHC.constant = 0;
        NSString * wifiName = [NSString stringWithFormat:@"%@",[_profile_listObject getWlanSSID]];
        protocol = [NSString stringWithFormat:@"%@",[_profile_listObject getWlanProtocol]];
        
        [profileName setText:wifiName];
        
        NSArray *array = [protocol componentsSeparatedByString:@"|"];
        self.protocolChoices = [[NSArray alloc] initWithArray:array];
        [cellProtocol setData:[self.protocolChoices firstObject]];
        
        profileProtocol = [NSString stringWithString:[self.protocolChoices firstObject]];
                
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
            heightConstraint.constant = 260;
        }
        else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
            heightConstraint.constant = 320;
        }else
        {
            self.EAPChoices = [[NSArray alloc] initWithObjects:EAP_TYPE_TTLS,EAP_TYPE_PEAP,EAP_TYPE_TLS, nil];
            [cellEAP setData:[self.EAPChoices firstObject]];
            selectedEAP = [NSString stringWithString:[self.EAPChoices firstObject]];
            passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_PASSWORD;
            heightConstraint.constant = 560;
        }
    }
}

/// Get wlan profile list api call
-(void)getWlanCertificatesListApiCall
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
            
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                
                self.CertificateChoices = [[NSArray alloc] initWithArray:[filesArray mutableCopy]];
                [cellCACertificates setData:[self.CertificateChoices firstObject]];
                [cellClientCertificates setData:[self.CertificateChoices firstObject]];
                [cellPrivateKey setData:[self.CertificateChoices firstObject]];
                [addProfile_table reloadData];
            }else if ([self.popup_type isEqualToString:@"Manual"])
            {
                self.CertificateChoices = [[NSArray alloc] initWithArray:[filesArray mutableCopy]];
                [cellCACertificates setData:[self.CertificateChoices firstObject]];
                [cellClientCertificates setData:[self.CertificateChoices firstObject]];
                [cellPrivateKey setData:[self.CertificateChoices firstObject]];
                [addProfile_table reloadData];
            }
        }
    }
}

BOOL isValidUsername(NSString *username) {
    NSError *error = nil;
    NSString *pattern = USERNAME_REGEX;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

    if (error) {
        NSLog(@"Error creating regex: %@", error.localizedDescription);
        return NO;
    }

    NSRange range = NSMakeRange(0, username.length);
    NSTextCheckingResult *match = [regex firstMatchInString:username options:0 range:range];

    return match != nil;
}

- (IBAction)addProfileAction:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        if ([self.popup_type isEqualToString:@"Manual"])
        {
            NSString *username = profileName_Field.text;
            if (!isValidUsername(username))
            {
                NSString *invalidusername = [NSString stringWithFormat:@"The username '%@' is invalid.", username];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self showFailurePopup:invalidusername];
                });
                return;
            }
        }

        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
        
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
            
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                [profileConfig setSSID:profileName_Field.text];
            }else
            {
                [profileConfig setSSID:[NSString stringWithFormat:@"\"%@\"", [_profile_listObject getWlanSSID]]];
            }
            
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                [profileConfig setSSID:profileName_Field.text];
            }else
            {
                [profileConfig setSSID:[NSString stringWithFormat:@"\"%@\"", [_profile_listObject getWlanSSID]]];
            }
            [profileConfig setPassword:[cellPassword getCellData]];
            [profileConfig setProtocol:[cellProtocol getCellData]];
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
        {
            
            if ([[cellEAP getCellData] isEqualToString:EAP_TYPE_TLS]) {
                if ([self.popup_type isEqualToString:@"Manual"])
                {
                    [profileConfig setSSID:profileName_Field.text];
                }else
                {
                    [profileConfig setSSID:[NSString stringWithFormat:@"\"%@\"", [_profile_listObject getWlanSSID]]];
                }
                [profileConfig setProtocol:[cellProtocol getCellData]];
                [profileConfig setEAP:[cellEAP getCellData]];
                [profileConfig setCa_Certificate:[cellCACertificates getCellData]];
                [profileConfig setIdentity:[cellIdentity getCellData]];
                [profileConfig setClientCertificate:[cellClientCertificates getCellData]];
                [profileConfig setPrivateKey:[cellPrivateKey getCellData]];
                [profileConfig setPrivatePassword:[cellPrivatePassword getCellData]];
                
            }else
            {
                if ([self.popup_type isEqualToString:@"Manual"])
                {
                    [profileConfig setSSID:profileName_Field.text];
                }else
                {
                    [profileConfig setSSID:[NSString stringWithFormat:@"\"%@\"", [_profile_listObject getWlanSSID]]];
                }
                [profileConfig setProtocol:[cellProtocol getCellData]];
                [profileConfig setEAP:[cellEAP getCellData]];
                [profileConfig setCa_Certificate:[cellCACertificates getCellData]];
                [profileConfig setIdentity:[cellIdentity getCellData]];
                [profileConfig setAnonyIdentity:[cellAnnonymousIdentity getCellData]];
                [profileConfig setPassword:[cellPassword getCellData]];
            }
        }
        
        if ([self.popup_type isEqualToString:@"Manual"])
        {
            [profileConfig setisHiddenSSID:[cellHiddenSSID getOption]];
        }
        
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] addWlanProfile:readerId srfidProfileConfig:profileConfig aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if ([cellPreferredWIFI getOption]) {
                [self setPreferredSSID];
            }else
            {
                [self saveProfile];
            }
        }
        else if (result == SRFID_RESULT_RESPONSE_ERROR)
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
                [self showFailurePopup:@"Add WLAN Profile Failed"];
            });
        }
    }else{
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)saveProfile
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveWlanProfile:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            [self dismissViewControllerAnimated:YES completion:^{
                [self.popupDelegate reloadTableData];
            }];
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
                [self showFailurePopup:@"Add WLAN Profile Failed"];
            });
        }
    }else{
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

-(void)setPreferredSSID
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        NSString * profile = [[NSString alloc] init];
        
        if ([self.popup_type isEqualToString:@"Manual"])
        {
            profile = [NSString stringWithFormat:@"\"%@\"", profileName_Field.text];
        }else
        {
            profile = [NSString stringWithFormat:@"\"%@\"", [_profile_listObject getWlanSSID]];
        }
        
        result = [[zt_RfidAppEngine sharedAppEngine] setWlanPreferredSSID:readerId ssidWlan:profile aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            [self saveProfile];
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Set prefer SSID Failed"];
            });
        }
    }
    else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)closeAddProfileView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
/// Wlan profile add
/// @param wlanSSID The wlan ssid
-(void)wlanProfileAdd:(NSString*)profile {
    if ([profile isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profile isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profile isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
    {
        passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
    }
}
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)option_cell getSelectedChoice];
        
        if (ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL == (m_PickerCellIdx - 1))
        {
            NSString *value = _protocolChoices[choice];
            [cellProtocol setData:value];
            profileProtocol = [NSString stringWithString:value];
            
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK]|| [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                    heightConstraint.constant = 540;
                }
                else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
                {
                    passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
                    heightConstraint.constant = 600;
                }else
                {
                    self.EAPChoices = [[NSArray alloc] initWithObjects:EAP_TYPE_TTLS,EAP_TYPE_PEAP,EAP_TYPE_TLS, nil];
                    [cellEAP setData:[self.EAPChoices firstObject]];
                    selectedEAP = [NSString stringWithString:[self.EAPChoices firstObject]];
                    passwordIndex = ZT_VC_ADDPROFILE_CELL_IDX_PASSWORD;
                    if ([self.popup_type isEqualToString:@"Manual"])
                    {
                        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                            heightConstraint.constant = 750;
                        }else
                        {
                            heightConstraint.constant = 720;
                        }
                    }else
                    {
                        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                            heightConstraint.constant = 720;
                        }else
                        {
                            heightConstraint.constant = 690;
                        }
                    }
                }
                [addProfile_table reloadData];
                [addProfile_table reloadInputViews];
            }
        }
        else if (ZT_VC_ADDPROFILE_CELL_IDX_EAP == (m_PickerCellIdx - 1))
        {
            NSString *value = _EAPChoices[choice];
            [cellEAP setData:value];
            
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                if ([value isEqualToString:EAP_TYPE_TLS]) {
                    heightConstraint.constant = 750;
                }else
                {
                    heightConstraint.constant = 720;
                }
            }else
            {
                if ([value isEqualToString:EAP_TYPE_TLS]) {
                    heightConstraint.constant = 720;
                }else
                {
                    heightConstraint.constant = 690;
                }
            }
            
            selectedEAP = [NSString stringWithString:value];
            [addProfile_table reloadData];
        }
        else if (ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE == (m_PickerCellIdx - 1))
        {
            NSString *value = _CertificateChoices[choice];
            [cellCACertificates setData:value];
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                heightConstraint.constant = 750;
            }else
            {
                heightConstraint.constant = 550;
            }
        }
        else if (ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE == (m_PickerCellIdx - 1))
        {
            NSString *value = _CertificateChoices[choice];
            [cellClientCertificates setData:value];
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                heightConstraint.constant = 750;
            }else
            {
                heightConstraint.constant = 550;
            }
        }
        else if (ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY == (m_PickerCellIdx - 1))
        {
            NSString *value = _CertificateChoices[choice];
            [cellPrivateKey setData:value];
        }
    }else if (YES == [option_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                heightConstraint.constant = 380;
            }else
            {
                heightConstraint.constant = 320;
            }
            
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
        {
            
            if ([self.popup_type isEqualToString:@"Manual"])
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    heightConstraint.constant = 780;
                }else
                {
                    heightConstraint.constant = 750;
                }
            }else
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    heightConstraint.constant = 580;
                }else
                {
                    heightConstraint.constant = 560;
                }
            }
            
        }
    }
}

/// Tells the delegate when editing begins in the specified text field.
/// @param textField The text field in which an editing session began.
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION])
    {
        heightConstraint.constant = 560;
    }
    else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
    {
        heightConstraint.constant = 560;
    }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
    {
        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
            heightConstraint.constant = 750;
        }else{
            heightConstraint.constant = 720;
        }
    }
}

/// Tells the delegate when editing stops for the specified text field.
/// @param textField The text field for which editing ended.
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION])
    {
        heightConstraint.constant = 320;
    }
    else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
    {
        heightConstraint.constant = 380;
    }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
    {
        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
            heightConstraint.constant = 630;
        }else{
            heightConstraint.constant = 610;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)didBeginEditing:(id)option_cell
{
    if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
    {
        heightConstraint.constant = 560;
    }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
    {
        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
            heightConstraint.constant = 750;
        }else{
            heightConstraint.constant = 720;
        }
    }
}

- (void)handleIdentityChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellIdentity getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellIdentity setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellIdentity getTextField] undoManager] removeAllActions];
    [_input release];
    
}
- (void)handleAnnonymousIdentityChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellAnnonymousIdentity getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellAnnonymousIdentity setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellAnnonymousIdentity getTextField] undoManager] removeAllActions];
    [_input release];
}
- (void)handlePasswordChanged:(NSNotification *)notif
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
- (void)handlePrivatePasswordChanged:(NSNotification *)notif
{
    
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[cellPrivatePassword getCellData]];
    [string setString:_input];
    
    /* restore previous one */
    [cellPrivatePassword setData:string];
    /* clear undo stack as we have restored previous stack (i.e. user's action
     had no effect) */
    [[[cellPrivatePassword getTextField] undoManager] removeAllActions];
    [_input release];
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
    if ([self.popup_type isEqualToString:@"Manual"])
    {
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
            return ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_NO_ENCRIPTION + ((m_PickerCellIdx != -1) ? 1 : 0);
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            return ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_PERSONAL + ((m_PickerCellIdx != -1) ? 1 : 0);
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
        {
            
            if ([[cellEAP getCellData] isEqualToString:EAP_TYPE_TLS]) {
                return ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_FULL + ((m_PickerCellIdx != -1) ? 1 : 0);
            }else
            {
                return ZT_VC_ADDPROFILE_MANUAL_TABLE_NO_OF_ROWS_ENTERPRISE + ((m_PickerCellIdx != -1) ? 1 : 0);
            }
            
        }else
        {
            NSLog(@"Not supported");
        }
    }else
    {
        if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
            return ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_NO_ENCRIPTION + ((m_PickerCellIdx != -1) ? 1 : 0);
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
        {
            return ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_PERSONAL + ((m_PickerCellIdx != -1) ? 1 : 0);
        }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
        {
            
            if ([[cellEAP getCellData] isEqualToString:EAP_TYPE_TLS]) {
                return ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_FULL + ((m_PickerCellIdx != -1) ? 1 : 0);
            }else
            {
                return ZT_VC_ADDPROFILE_TABLE_NO_OF_ROWS_ENTERPRISE + ((m_PickerCellIdx != -1) ? 1 : 0);
            }
            
        }else
        {
            NSLog(@"Not supported");
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.popup_type isEqualToString:@"Manual"])
    {
        int cell_idx = (int)[indexPath row];
        
        CGFloat height = 0.0;
        UITableViewCell *cell = nil;
        
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            cell = cellProtocol;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                cell = cellPreferredWIFI;
            }else
            {
                if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
                {
                    cell = cellPassword;
                }else
                {
                    cell = cellEAP;
                }
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION])
            {
                cell = cellHiddenSSID;
            }
            else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                cell = cellPreferredWIFI;
            }else
            {
                cell = cellCACertificates;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx || [self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_ANNO_IDENTIFIER] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellClientCertificates;
            }else
            {
                cell = cellAnnonymousIdentity;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellPrivateKey;
            }else
            {
                cell = cellPassword;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_IDENTITY] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                cell = cellHiddenSSID;
            }else
            {
                cell = cellIdentity;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_PASSWORD] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellPrivatePassword;
            }else
            {
                cell = cellPreferredWIFI;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PREFFERED_PROFILE] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellPreferredWIFI;
            }else
            {
                cell = cellHiddenSSID;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_HIDDEN_SSID] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellHiddenSSID;
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
    }else
    {
        int cell_idx = (int)[indexPath row];
        
        CGFloat height = 0.0;
        UITableViewCell *cell = nil;
        
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            cell = cellProtocol;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                cell = cellPreferredWIFI;
            }else
            {
                if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
                {
                    cell = cellPassword;
                }else
                {
                    cell = cellEAP;
                }
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                cell = cellPreferredWIFI;
            }else
            {
                cell = cellCACertificates;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx || [self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_ANNO_IDENTIFIER] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellClientCertificates;
            }else
            {
                cell = cellAnnonymousIdentity;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellPrivateKey;
            }else
            {
                cell = cellPassword;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_IDENTITY] == cell_idx)
        {
            cell = cellIdentity;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_PASSWORD] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                cell = cellPrivatePassword;
            }else
            {
                cell = cellPreferredWIFI;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PREFFERED_PROFILE] == cell_idx)
        {
            cell = cellPreferredWIFI;
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
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.popup_type isEqualToString:@"Manual"])
    {
        int cell_idx = (int)[indexPath row];
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            [cellProtocol darkModeCheck:self.view.traitCollection];
            return cellProtocol;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }else
            {
                if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
                {
                    [cellPassword darkModeCheck:self.view.traitCollection];
                    return cellPassword;
                }else
                {
                    [cellEAP darkModeCheck:self.view.traitCollection];
                    return cellEAP;
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION])
            {
                [cellHiddenSSID darkModeCheck:self.view.traitCollection];
                return cellHiddenSSID;
            }
            else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }else
            {
                [cellCACertificates darkModeCheck:self.view.traitCollection];
                return cellCACertificates;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx || [self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_ANNO_IDENTIFIER] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellClientCertificates darkModeCheck:self.view.traitCollection];
                return cellClientCertificates;
            }else
            {
                [cellAnnonymousIdentity darkModeCheck:self.view.traitCollection];
                return cellAnnonymousIdentity;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_IDENTITY] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                [cellHiddenSSID darkModeCheck:self.view.traitCollection];
                return cellHiddenSSID;
            }else
            {
                [cellIdentity darkModeCheck:self.view.traitCollection];
                return cellIdentity;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellPrivateKey darkModeCheck:self.view.traitCollection];
                return cellPrivateKey;
            }else
            {
                [cellPassword darkModeCheck:self.view.traitCollection];
                return cellPassword;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_PASSWORD] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellPrivatePassword darkModeCheck:self.view.traitCollection];
                return cellPrivatePassword;
            }else
            {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PREFFERED_PROFILE] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }else
            {
                [cellHiddenSSID darkModeCheck:self.view.traitCollection];
                return cellHiddenSSID;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_HIDDEN_SSID] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellHiddenSSID darkModeCheck:self.view.traitCollection];
                return cellHiddenSSID;
            }
            
        }
        
    }else
    {
        int cell_idx = (int)[indexPath row];
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            [cellProtocol darkModeCheck:self.view.traitCollection];
            return cellProtocol;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION])
            {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }else
            {
                if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
                {
                    [cellPassword darkModeCheck:self.view.traitCollection];
                    return cellPassword;
                }else
                {
                    [cellEAP darkModeCheck:self.view.traitCollection];
                    return cellEAP;
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx || [self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_ANNO_IDENTIFIER] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellClientCertificates darkModeCheck:self.view.traitCollection];
                return cellClientCertificates;
            }else
            {
                [cellAnnonymousIdentity darkModeCheck:self.view.traitCollection];
                return cellAnnonymousIdentity;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }else
            {
                [cellCACertificates darkModeCheck:self.view.traitCollection];
                return cellCACertificates;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_IDENTITY] == cell_idx)
        {
            [cellIdentity darkModeCheck:self.view.traitCollection];
            return cellIdentity;
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellPrivateKey darkModeCheck:self.view.traitCollection];
                return cellPrivateKey;
            }else
            {
                [cellPassword darkModeCheck:self.view.traitCollection];
                return cellPassword;
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_PASSWORD] == cell_idx)
        {
            if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                [cellPrivatePassword darkModeCheck:self.view.traitCollection];
                return cellPrivatePassword;
            }else
            {
                [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
                return cellPreferredWIFI;
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PREFFERED_PROFILE] == cell_idx)
        {
            [cellPreferredWIFI darkModeCheck:self.view.traitCollection];
            return cellPreferredWIFI;
        }
    }
    
    
    return nil;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.popup_type isEqualToString:@"Manual"])
    {
        int cell_idx = (int)[indexPath row];
        int row_to_hide = -1;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        int main_cell_idx = -1;
        
        /* expected index for new picker cell */
        row_to_hide = m_PickerCellIdx;
        
        if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            [m_cellPicker setChoices:_protocolChoices];
            main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL;
            
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 550;
                }else
                {
                    heightConstraint.constant = 320;
                }
            }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 620;
                }else
                {
                    heightConstraint.constant = 380;
                }
            }else
            {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                        heightConstraint.constant = 620;
                    }else
                    {
                        heightConstraint.constant = 570;
                    }
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                [m_cellPicker setChoices:_EAPChoices];
                main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
                
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                        heightConstraint.constant = 620;
                    }else
                    {
                        heightConstraint.constant = 570;
                    }
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                [m_cellPicker setChoices:_CertificateChoices];
                main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE;
                
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                        heightConstraint.constant = 620;
                    }else
                    {
                        heightConstraint.constant = 570;
                    }
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    [m_cellPicker setChoices:_CertificateChoices];
                    main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE;
                    if (row_to_hide == -1) {
                        heightConstraint.constant = 750;
                    }else
                    {
                        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                            heightConstraint.constant = 620;
                        }else
                        {
                            heightConstraint.constant = 570;
                        }
                    }
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    [m_cellPicker setChoices:_CertificateChoices];
                    main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY;
                }
            }
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
    }else
    {
        int cell_idx = (int)[indexPath row];
        int row_to_hide = -1;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        int main_cell_idx = -1;
        
        /* expected index for new picker cell */
        row_to_hide = m_PickerCellIdx;
        
        if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL] == cell_idx)
        {
            [m_cellPicker setChoices:_protocolChoices];
            main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_PROTOCOL;
            
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPAPSK] || [profileProtocol isEqualToString:PROTOCOL_TYPE_IEEE8021X] || [profileProtocol isEqualToString:PROTOCOL_TYPE_NO_ENCRIPTION]) {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 500;
                }else
                {
                    heightConstraint.constant = 260;
                }
            }else if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_PERSONAL_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_PERSONAL_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_PERSONAL_SAE])
            {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 560;
                }else
                {
                    heightConstraint.constant = 320;
                }
            }else
            {
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    heightConstraint.constant = 560;
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_EAP] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                [cellEAP setUserInteractionEnabled:YES];
                [m_cellPicker setChoices:_EAPChoices];
                main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_EAP;
                
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                        heightConstraint.constant = 560;
                    }else
                    {
                        heightConstraint.constant = 520;
                    }
                    
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                [m_cellPicker setChoices:_CertificateChoices];
                main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_CA_CERTIFICATE;
                
                if (row_to_hide == -1) {
                    heightConstraint.constant = 750;
                }else
                {
                    if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                        heightConstraint.constant = 560;
                    }else
                    {
                        heightConstraint.constant = 520;
                    }
                }
            }
            
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    [m_cellPicker setChoices:_CertificateChoices];
                    main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_CLIENT_CERTIFICATE;
                    if (row_to_hide == -1) {
                        heightConstraint.constant = 750;
                    }else
                    {
                        if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                            heightConstraint.constant = 560;
                        }else
                        {
                            heightConstraint.constant = 520;
                        }
                    }
                }
            }
        }
        else if ([self recalcCellIndex:ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY] == cell_idx || [self recalcCellIndex:passwordIndex] == cell_idx)
        {
            if ([profileProtocol isEqualToString:PROTOCOL_TYPE_WPA2_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA_ENTERPRISE_TKIP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SHA256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_CCMP_256]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_128]||[profileProtocol isEqualToString:PROTOCOL_TYPE_WPA3_ENTERPRISE_GCMP_256_SUITEB_192])
            {
                if ([selectedEAP isEqualToString:EAP_TYPE_TLS]) {
                    [m_cellPicker setChoices:_CertificateChoices];
                    main_cell_idx = ZT_VC_ADDPROFILE_CELL_IDX_PRIVATE_KEY;
                }
            }
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
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(addProfile_table.contentInset.top, 0.0, kbSize.height, 0.0);
    addProfile_table.contentInset = contentInsets;
    addProfile_table.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(addProfile_table.contentInset.top, 0.0, 0.0, 0.0);
    addProfile_table.contentInset = contentInsets;
    addProfile_table.scrollIndicatorInsets = contentInsets;
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
    addProfile_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [addProfile_table reloadData];
}

@end
