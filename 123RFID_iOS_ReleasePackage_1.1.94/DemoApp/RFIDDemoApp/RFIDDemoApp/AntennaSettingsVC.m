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
 *  Description:  AntennaSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AntennaSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "LinkProfileObject.h"

#define ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL            0
#define ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE           1
#define ZT_VC_ANTENNA_CELL_IDX_PIE                    2
#define ZT_VC_ANTENNA_CELL_IDX_TARI                   3
#define ZT_VC_ANTENNA_CELL_IDX_DO_SELECT              4

#define ZT_VC_ANTENNA_OPTION_ID_NOT_AN_OPTION         -1
#define ZT_VC_ANTENNA_OPTION_ID_POWER_LEVEL           0
#define ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE          1
#define ZT_VC_ANTENNA_OPTION_ID_PIE                   2
#define ZT_VC_ANTENNA_OPTION_ID_TARI                  3
#define ZT_VC_ANTENNA_OPTION_ID_DO_SELECT             4

@interface zt_AntennaSettingsVC ()
    @property zt_SledConfiguration *localSled;
@end

/* TBD: save & apply (?) configuration during hide */
@implementation zt_AntennaSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    isAutomac668Selected = NO;
    
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_NOT_AN_OPTION;
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_cellLinkProfile)
    {
        [m_cellLinkProfile release];
    }
    if (nil != m_cellPowerLevel)
    {
        [m_cellPowerLevel release];
    }
    if (nil != cellTari)
    {
        [cellTari release];
    }
    if (nil != cellPie)
    {
        [cellPie release];
    }
    if (nil != m_cellDoSelect)
    {
        [m_cellDoSelect release];
    }
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    if (nil != _linkChoices)
    {
        [_linkChoices release];
    }
    [m_tblOptions release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_localSled setAntennaOptionsWithConfig:[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getAntennaConfig]];
    
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    [m_tblOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
        
    /* set title */
    [self setTitle:@"Antenna"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    hasNewValuesInitiated = false;
    
    // IMPORTANT: Disable the interactive pop gesture recognizer.
        // This prevents the user from swiping back from the screen edge.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Replace the system's back button with a custom button.
    [self createCustomBack];

}

- (void)createCustomBack
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];

    // Create and configure the UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_icon"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(-5, 0, 30, 30); // Adjust the frame as needed
    [customView addSubview:imageView];

    // Create and configure the UILabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(28, 0, 45, 30)]; // Adjust the frame as needed
    label.text = @"Back";
    label.font = [UIFont systemFontOfSize:18.0]; // Adjust the font size as needed
    label.textColor = [UIColor whiteColor]; // Adjust the text color as needed
    [customView addSubview:label];

    
    // Add a tap gesture recognizer to the custom view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonTapped)];
    [customView addGestureRecognizer:tapGestureRecognizer];
    
    // Create the UIBarButtonItem with the custom view
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    self.navigationItem.leftBarButtonItem = customBackButton;
}


// Action method for the custom back button. This contains the core logic.
- (void)backButtonTapped {
    // Get the integer value from the text field.
    NSString *enteredValue = [m_cellPowerLevel getCellData];

    // Check if the entered value is greater than 300.
    if ([enteredValue intValue] > 300) {
        // Condition met: Block navigation and show an alert.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Navigation Blocked"
                                                                       message:@"Entered power level value greater than 300. Please enter a value between 0 - 300."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];

        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // Condition not met: Allow navigation.
        // Use the navigation controller to pop the current view controller.
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePowerLevelChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellPowerLevel getTextField]];
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    if (inventoryRequested == NO) {
        self.view.userInteractionEnabled = YES;
        m_tblOptions.userInteractionEnabled = YES;
    }else
    {
        self.view.userInteractionEnabled = NO;
        m_tblOptions.userInteractionEnabled = NO;
    }
    
    
    [self setupConfigurationInitial];
    
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

/// Notifies the view controller that its view was added to a view hierarchy
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellPowerLevel getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if([[m_cellPowerLevel getCellData] length]>0)
    {
        NSString * floatString = [m_cellPowerLevel getCellData];
        if ([floatString floatValue] > 300) {
            floatString = @"300";
        }
        //configuration.currentAntennaPowerLevel = [floatString floatValue];
        
        NSString *savedPie = [cellPie getCellData];
        NSString *savedTari = [cellTari getCellData];
        NSString *savedLinkProfile = [m_cellLinkProfile getCellData];
        BOOL hasAUTOMACselected = isAutomac668Selected;
        [[NSUserDefaults standardUserDefaults] setObject:floatString forKey:@"SavedPowerLevelValue"];
       
        [[NSUserDefaults standardUserDefaults] setObject:savedPie forKey:@"SavedPieValue"];
        [[NSUserDefaults standardUserDefaults] setObject:savedTari forKey:@"SavedTariValue"];
        if (isAutomac668Selected) {
            [[NSUserDefaults standardUserDefaults] setObject:@"AUTOMAC 668" forKey:@"SavedLPValue"];
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:savedLinkProfile forKey:@"SavedLPValue"];
        }
        [[NSUserDefaults standardUserDefaults] setBool:hasAUTOMACselected forKey:@"hasAUTOMACselected"];
       
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPreconfiguredOptionCells
{
    m_cellPowerLevel = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellPowerLevel setKeyboardType:UIKeyboardTypeDecimalPad];
    m_cellLinkProfile = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellTari = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellPie = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_cellDoSelect = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellPowerLevel setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPowerLevel setDataFieldWidth:40];
    [m_cellPowerLevel setInfoNotice:ZT_STR_SETTINGS_ANTENNA_POWER_LEVEL];
    
    [m_cellLinkProfile setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellLinkProfile setInfoNotice:ZT_STR_SETTINGS_ANTENNA_LINK_PROFILE];
    
    [cellTari setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellTari setInfoNotice:ZT_STR_SETTINGS_ANTENNA_TARI];
    
    [cellPie setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellPie setInfoNotice:ANTENNA_KEY_PIE];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    [m_cellDoSelect setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellDoSelect setInfoNotice:ZT_STR_SETTINGS_ANTENNA_DO_SELECT];
}

- (void)setupConfigurationInitial
{
    /* TBD: configure based on app / reader settings */
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    _linkChoices = nil;
    _linkChoices = [[configuration getLinkProfileArray] mutableCopy];
    
    NSNumber *powerLevelKey;
    
//    if ([configuration currentAntennaPowerLevel] != 0) {
//        powerLevelKey = [NSNumber numberWithFloat:[configuration currentAntennaPowerLevel]];
//    }else
//    {
//        powerLevelKey = [NSNumber numberWithInt:[[configuration getReaderMaxPowerLevel]intValue]];
//    }
    
    // Added this line due to, if the power level set to 0, the value is not changing and it automatically changes back to 300.
    powerLevelKey = [NSNumber numberWithFloat:[configuration currentAntennaPowerLevel]];
    [m_cellPowerLevel setData:[NSString stringWithFormat:@"%1.0f",[powerLevelKey floatValue]]];
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedPowerLevelValue"];
       if (savedValue) {
           [m_cellPowerLevel setData:savedValue];
       }
    

    NSDictionary * tempActiveDic = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getActiveProfileFromLocalMemory];
    
    if (tempActiveDic != nil) {
        configuration.currentAntennaLinkProfile = [[tempActiveDic objectForKey:PROFILE_KEY_LINKPROFILE] intValue];
    }else
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveActiveProfileintoLocalMemory:[configuration getReaderMaxPowerLevel] linkProfileIndex:@"1" sessionIndex:0 dynamicProfile:0];
        configuration.currentAntennaLinkProfile = [[tempActiveDic objectForKey:PROFILE_KEY_LINKPROFILE] intValue];
    }
    NSNumber *linkProfileKey = [NSNumber numberWithInt:configuration.currentAntennaLinkProfile];

    NSString * profileName = @"";
        
    if (tempActiveDic != nil) {
            configuration.currentAntennaLinkProfile = [[tempActiveDic objectForKey:PROFILE_KEY_LINKPROFILE] intValue];
    }
    @try {
        profileName = [[configuration getLinkProfileArray] objectAtIndex:[linkProfileKey intValue]];
    
        [m_cellLinkProfile setData:profileName];
    
        configuration.currentAntennaLinkProfile = [linkProfileKey intValue];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
    NSNumber *tari = [NSNumber numberWithInt:configuration.currentAntennaTari];
    if (configuration.currentAntennaTari == 0 && configuration.currentAntennaPie == 0)
    {
        [cellTari setData:(NSString *)tari];
    }else
    {
        if (configuration.currentAntennaTari != 0)
        {
            [cellTari setData:(NSString *)tari];
        }else
        {
            tariArray = TARI_ARRAY_12500_25000
            [cellTari setData:(NSString *)[tariArray lastObject]];
        }
    }
    
    NSNumber *pie = [NSNumber numberWithInt:configuration.currentAntennaPie];
    if (configuration.currentAntennaTari == 0 && configuration.currentAntennaPie == 0)
    {
        [cellPie setData:(NSString *)pie];
    }else
    {
        if (configuration.currentAntennaPie != 0)
        {
            [cellPie setData:(NSString *)pie];
            if (configuration.currentAntennaPie == LINK_PROFILE_TARI_668)
            {
                pieArray = PIE_ARRAY_668
            }else
            {
                pieArray = PIE_ARRAY_GENERAL
            }
        }else
        {
            if (configuration.pie_1500) {
                pieArray = PIE_ARRAY_GENERAL
                [cellPie setData:(NSString *)[pieArray firstObject]];
            }else
            {
                pieArray = PIE_ARRAY_2000
                [cellPie setData:(NSString *)[pieArray firstObject]];
            }
            
        }
    }
    
    NSNumber *doSelectKey = [NSNumber numberWithInt:configuration.currentAntennaDoSelect];
    [m_cellDoSelect setData:(NSString*)[configuration.antennaOptionsDoSelect objectForKey:doSelectKey]];
    
    /* hide picker cells */
    m_PickerCellIdx = -1;
    [m_tblOptions reloadData];
    
    [[NSUserDefaults standardUserDefaults] setValue:ANTENNA_DEFAULTS_VALUE forKey:ANTENNA_CHANGE_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    lpArray = @[@"M4 240K", @"M2 240K", @"M2 256K", @"M4 256K", @"M8 240K", @"M8 256K",//TARI_ARRAY_12500_25000,PIE_ARRAY_GENERAL
                @"M2 320K", @"M4 320K", @"FM0 320K", @"M8 320K", // TARI_ARRAY_12500_18800, PIE_ARRAY_GENERAL
                @"FM0 640K", // TARI_ARRAY_6250, PIE_ARRAY_GENERAL
                @"FM0 0K"]; // TARI_ARRAY_0, PIE_ARRAY_0
    
    savedValue =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedLPValue"];
    if (savedValue){
        [m_cellLinkProfile setData:savedValue];
    }
    
    selectedLinkProfile = [m_cellLinkProfile getCellData];
    NSUInteger item = [lpArray indexOfObject:selectedLinkProfile];
    //NSLog(@"selectedLinkProfile: %lu" , (unsigned long)item);
    switch (item) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            pieArray = PIE_ARRAY_GENERAL
            tariArray = TARI_ARRAY_12500_25000
            break;
        case 6:
        case 7:
        case 8:
        case 9:
            pieArray = PIE_ARRAY_GENERAL
            tariArray = TARI_ARRAY_12500_18800
            break;
        
        case 10:
            pieArray = PIE_ARRAY_GENERAL
            tariArray = TARI_ARRAY_6250
            break;
            
        case 11:
            pieArray = PIE_ARRAY_0
            tariArray = TARI_ARRAY_0
            break;
        
        default:
            break;
    }
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        


    isAutomac668Selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasAUTOMACselected"];
    if(isAutomac668Selected) {
        NSString *newLPValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedLPValue"];
        if (newLPValue) {
            [m_cellLinkProfile setData:newLPValue];
            pieArray = PIE_ARRAY_668
            [cellPie setData:(NSString *)[pieArray firstObject]];
            
            tariArray = TARI_ARRAY_668
            [cellTari setData:(NSString *)[tariArray lastObject]];
        }
        
        // Save the entered value of power Level
        NSString *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedPowerLevelValue"];
           if (savedValue) {
               [m_cellPowerLevel setData:savedValue];
           }
        
    }else {
        if (item == 11) {
            pieArray = PIE_ARRAY_0
        }else{
            newPieValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedPieValue"];
            if (([newPieValue isEqual:NULL] || [newPieValue isEqual:@"0"]) && selectedLinkProfile == lpArray[11]){
                [cellPie setData:@"0"];
            }
            else if ([newPieValue isEqual: @"668"])
            {
                [cellPie setData:(NSString *)[pieArray firstObject]];
                
            } else if([pieArray containsObject:newPieValue]) {
                [cellPie setData:newPieValue];
                if (localSled.pie_1500) {
                    pieArray = PIE_ARRAY_GENERAL
                }else
                {
                    pieArray = PIE_ARRAY_2000
                }
            }else {
                if (localSled.pie_1500) {
                    pieArray = PIE_ARRAY_GENERAL
                }else
                {
                    pieArray = PIE_ARRAY_2000
                }
                [cellPie setData:(NSString *)[pieArray firstObject]];
            }
        }

        
        
        newTariValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedTariValue"];
        if (([newTariValue isEqual:NULL] || [newTariValue isEqual:@"0"]) && selectedLinkProfile == lpArray[11]){
            [cellTari setData:@"0"];
        }
        else if ([newTariValue isEqual:@"668"]) {
            [cellTari setData:(NSString *)[tariArray lastObject]];
           
        }else if ([tariArray containsObject:newTariValue]) {
            [cellTari setData:newTariValue];
        }else {
            [cellTari setData:(NSString *)[tariArray lastObject]];
        }
    }
}

/// Fetch the profile name using the index from linkprofiles array.
/// @param profileIndex The profile index from the linkprofile object.
/// @param linkProfilesArray The linkprofiles array to fetch matching index.
-(NSString *)getMatchingProfileNameByIndex:(int)profileIndex linkProfileArray:(NSMutableArray*) linkProfilesArray{
    
    NSString * profileName = @"";
    
    NSString * linkProfileName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LP_DEFAULTS_KEY];
    for (zt_LinkProfileObject *linkProfileObject in linkProfilesArray) {
        
        if (linkProfileName != nil || [linkProfileName isEqual:EMPTY_STRING])
        {
            if ([linkProfileObject.modeTableEntry getRFModeIndex] == profileIndex && [linkProfileObject getProfile] == linkProfileName){
                
                profileName = [linkProfileObject getProfile];
                break;
            }else
            {
                profileName = linkProfileName;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_LP_DEFAULTS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else
        {
            if ([linkProfileObject getIndex] == profileIndex){
                
                profileName = [linkProfileObject getProfile];
                break;
            }
        }
    }
    return profileName;
}

/// Fetch the index according to the selected tari and pie value from the linkprofiles array.
/// @param profileName The profile name from the linkprofile object.
/// @param tariValue The selected tari value from the list.
/// @param pieValue The selected pie value from the list.
/// @param linkProfilesArray The linkprofiles array to fetch matching index.
- (int)getMatchingIndexAccordingTariAndPie:(NSString*)profileName tariValue:(int)tariValue pieValue: (int)pieValue linkProfileArray:(NSMutableArray*) linkProfilesArray
{
    int modeIndex = 0;
    for (zt_LinkProfileObject *linkProfileObject in linkProfilesArray) {
        
        if ([linkProfileObject.profileName isEqual:profileName] && ([linkProfileObject.modeTableEntry getPIE] == pieValue) && ([linkProfileObject.modeTableEntry getMinTari] <= tariValue) && (tariValue <= [linkProfileObject.modeTableEntry getMaxTari])){
            modeIndex = [linkProfileObject.modeTableEntry getRFModeIndex];
            return modeIndex;
        }
    }
    return -1;
}

/// Fetch the proper matching index from the link profile array.
/// @param profileName The profile name from the link profile object.
/// @param linkProfilesArray The link profiles array to fetch matching index.
-(srfidLinkProfile*)getMatchingLinkProfileObject:(NSString*)profileName linkProfileArray:(NSMutableArray*) linkProfilesArray{
    
    srfidLinkProfile* object = [[srfidLinkProfile alloc]init];
    for (zt_LinkProfileObject *linkProfileObject in linkProfilesArray) {
        if ([linkProfileObject.profileName isEqual:profileName]){
            object =  linkProfileObject.modeTableEntry;
            break;
        }
    }
    return object;
}

/// Fetch the matching link profile object by using link profile index.
/// @param profileIndex The profile index from the link profile object.
/// @param linkProfilesArray The link profiles array to fetch matching index.
-(srfidLinkProfile*)getMatchingLinkProfileObjectByLinkProfileIndex:(int)profileIndex linkProfileArray:(NSMutableArray*) linkProfilesArray{
    
    srfidLinkProfile* object = [[srfidLinkProfile alloc]init];
    for (zt_LinkProfileObject *linkProfileObject in linkProfilesArray) {
        if ([linkProfileObject.modeTableEntry getRFModeIndex] == profileIndex){
            object =  linkProfileObject.modeTableEntry;
            break;
        }
    }
    return object;
}

// Method to check the model number contains the value rfd8500
- (BOOL)containsRfd8500:(NSString *)modelName
{
    if (modelName == nil)
    {
            return NO;  // Return NO if the modelName is nil to avoid potential crashes
    }
        
    NSRange range = [modelName rangeOfString:@"RFD8500"];
    return range.location != NSNotFound;
}


/* ###################################################################### */
/* ########## ISelectionTableVCDelegate Protocol implementation ######### */
/* ###################################################################### */
- (void)didChangeSelectedOption:(NSString *)value
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    // RFD8500 check
    NSString *modelName = [localSled readerModel];
    BOOL isRFD8500 = [self containsRfd8500:modelName];
    
    srfidLinkProfile* linkProfileObject = [self getMatchingLinkProfileObject:value linkProfileArray:localSled.linkProfilesArray];
    if (ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE == m_PresentedOptionId)
    {
        int profileIndex = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMatchingIndexLegacyIndex:value linkProfileArray:localSled.linkProfilesArray];
        localSled.currentAntennaLinkProfile = profileIndex;
        
        NSNumber *linkProfileKey = [NSNumber numberWithInt:localSled.currentAntennaLinkProfile];
       
        if ([linkProfileKey intValue] == 23 && isRFD8500) {
            isAutomac668Selected = YES;
            [m_cellLinkProfile setData:@"AUTOMAC 668"];
            [[NSUserDefaults standardUserDefaults] setObject:@"AUTOMAC 668" forKey:@"SavedLPValue"];
            [[NSUserDefaults standardUserDefaults] setBool:isAutomac668Selected forKey:@"hasAUTOMACselected"];
            localSled.currentAntennaPie = LINK_PROFILE_TARI_668;
            tariArray = TARI_ARRAY_668;
        }
        else if ([linkProfileKey intValue] == 23 && !isRFD8500)
        {
            isAutomac668Selected = NO;
            [m_cellLinkProfile setData:@"FM0 0K"];
            [[NSUserDefaults standardUserDefaults] setBool:isAutomac668Selected forKey:@"hasAUTOMACselected"];
            localSled.currentAntennaPie = 0;
            tariArray = TARI_ARRAY_0
            pieArray = PIE_ARRAY_0
            [cellPie setData:(NSString *)[pieArray firstObject]];
            [cellTari setData:(NSString *)[tariArray lastObject]];
            
        }
        else {
            isAutomac668Selected = NO;
            [[NSUserDefaults standardUserDefaults] setBool:isAutomac668Selected forKey:@"hasAUTOMACselected"];
//            [m_cellLinkProfile setData:(NSString*)[localSled.antennaOptionsLinkProfile objectForKey:linkProfileKey]];
        }
        linkProfileObject = [self getMatchingLinkProfileObject:value linkProfileArray:localSled.linkProfilesArray];
        
        [cellTari setData:[NSString stringWithFormat:@"%d",linkProfileObject.getMaxTari]];
        localSled.currentAntennaTari = linkProfileObject.getMaxTari;
        //newTariValue = [NSString stringWithFormat:@"%d",linkProfileObject.getMaxTari];
        
        [cellPie setData:[NSString stringWithFormat:@"%d",linkProfileObject.getPIE]];
        localSled.currentAntennaPie = linkProfileObject.getPIE;
        
//        newPieValue =[NSString stringWithFormat:@"%d",linkProfileObject.getPIE];
//        hasNewValuesInitiated = true;
        
        int linkIndex = 0;
        linkIndex = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMatchingIndexFromProfileName:value linkProfileArray:_linkChoices];
        localLinkIndex = linkIndex;
        [m_cellLinkProfile setData: _linkChoices[linkIndex]];
        [[NSUserDefaults standardUserDefaults] setObject:[m_cellLinkProfile getCellData] forKey:@"SavedLPValue"];
        
        NSDictionary * tempActiveDic = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getActiveProfileFromLocalMemory];
        
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveUserDefinedProfileintoLocalMemory:[NSString stringWithFormat:@"%1.0f",localSled.currentAntennaPowerLevel] linkProfileIndex:[NSString stringWithFormat:@"%d",linkIndex] sessionIndex:[tempActiveDic objectForKey:PROFILE_KEY_SESSION] dynamicProfile:[tempActiveDic objectForKey:PROFILE_KEY_DYNAMICPOWER]];
        
        
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveActiveProfileintoLocalMemory:[NSString stringWithFormat:@"%1.0f",localSled.currentAntennaPowerLevel] linkProfileIndex:[NSString stringWithFormat:@"%d",linkIndex] sessionIndex:[tempActiveDic objectForKey:PROFILE_KEY_SESSION] dynamicProfile:[tempActiveDic objectForKey:PROFILE_KEY_DYNAMICPOWER]];
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:ANTENNA_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else if (ZT_VC_ANTENNA_OPTION_ID_DO_SELECT == m_PresentedOptionId)
    {
        localSled.currentAntennaDoSelect = [[zt_SledConfiguration getKeyFromDictionary:localSled.antennaOptionsDoSelect withValue:value] boolValue];
        NSNumber *doSelectKey = [NSNumber numberWithInt:localSled.currentAntennaTari];
        [m_cellDoSelect setData:(NSString*)[localSled.antennaOptionsDoSelect objectForKey:doSelectKey]];
    }
    [[NSUserDefaults standardUserDefaults] setValue:ANTENNA_UPDATED_VALUE forKey:ANTENNA_CHANGE_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    // change to 5 for tari and do select options
    return 4 + ((m_PickerCellIdx != -1) ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    UITableViewCell *_info_cell = nil;
    
    int cell_idx = (int)[indexPath row];
    
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        _info_cell = m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE] == cell_idx)
    {
        _info_cell = m_cellLinkProfile;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL] == cell_idx)
    {
        _info_cell = m_cellPowerLevel;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_PIE] == cell_idx)
    {
        _info_cell = cellPie;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_TARI] == cell_idx)
    {
        _info_cell = cellTari;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_DO_SELECT] == cell_idx)
    {
        _info_cell = m_cellDoSelect;
    }
    
    if (nil != _info_cell)
    {
        [_info_cell setNeedsUpdateConstraints];
        [_info_cell updateConstraintsIfNeeded];
        
        [_info_cell setNeedsLayout];
        [_info_cell layoutIfNeeded];
        
        height = [_info_cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1.0; /* for cell separator */
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
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE] == cell_idx)
    {
        [m_cellLinkProfile darkModeCheck:self.view.traitCollection];
        return m_cellLinkProfile;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL] == cell_idx)
    {
        [m_cellPowerLevel darkModeCheck:self.view.traitCollection];
        return m_cellPowerLevel;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_PIE] == cell_idx)
    {
        [cellPie darkModeCheck:self.view.traitCollection];
        return cellPie;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_TARI] == cell_idx)
    {
        [cellTari darkModeCheck:self.view.traitCollection];
        return cellTari;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_DO_SELECT] == cell_idx)
    {
        [m_cellDoSelect darkModeCheck:self.view.traitCollection];
        return m_cellDoSelect;
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
    
    /* enable view animation that was disabled during
    switching between segments - see configureForSelectedOperation */
    [UIView setAnimationsEnabled:YES];
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    zt_SelectionTableVC *vc = (zt_SelectionTableVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SELECTION_TABLE_VC"];
    [vc setDelegate:self];

    
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_PIE] == cell_idx)
    {
        
        zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        NSString * profileName = @"";
        
        profileName = [m_cellLinkProfile getCellData];
                
        srfidLinkProfile* linkProfileObject = [self getMatchingLinkProfileObject:profileName linkProfileArray:localSled.linkProfilesArray];
        
        pieArray = [[NSArray alloc] init];
        
        if (linkProfileObject.getPIE == 0 && linkProfileObject.getMinTari == 0 && linkProfileObject.getMaxTari == 0)
        {
            pieArray = PIE_ARRAY_0
        }else if (linkProfileObject.getPIE == LINK_PROFILE_TARI_668)
        {
            pieArray = PIE_ARRAY_668
        }else
        {
            if (localSled.pie_1500) {
                pieArray = PIE_ARRAY_GENERAL
            }else
            {
                pieArray = PIE_ARRAY_2000
            }
            
        }
        [m_cellPicker setChoices:pieArray];
        for (int pieIndex = 0; pieIndex < [pieArray count]; pieIndex++)
        {
            NSNumber *pieValue = [NSNumber numberWithInt:configuration.currentAntennaPie];
            int selectedVal = [[pieArray objectAtIndex:pieIndex] intValue];
            NSNumber *currentPie = [NSNumber numberWithInt:selectedVal];
            
            if (currentPie == pieValue) {
                m_SelectedOptionPie = pieIndex;
            }
        }
        [m_cellPicker setSelectedChoice:m_SelectedOptionPie];
        configuration.currentAntennaPie = m_SelectedOptionPie;
        main_cell_idx = ZT_VC_ANTENNA_CELL_IDX_PIE;
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE;
        [vc setCaption:ZT_STR_SETTINGS_ANTENNA_LINK_PROFILE];
        [vc setOptionsWithStringArray:[configuration getLinkProfileArray]];
        [vc setSelectedValue:(NSString*)[m_cellLinkProfile getCellData]];
    }
    else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_DO_SELECT] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_DO_SELECT;
        [vc setCaption:ZT_STR_SETTINGS_ANTENNA_DO_SELECT];
        [vc setOptionsWithDictionary:configuration.antennaOptionsDoSelect withStringPrefix:nil];
        NSNumber *key = [NSNumber numberWithInt:configuration.currentAntennaDoSelect];
        [vc setSelectedValue:(NSString*)[configuration.antennaOptionsDoSelect objectForKey:key]];
    }else if ([self recalcCellIndex:ZT_VC_ANTENNA_CELL_IDX_TARI] == cell_idx)
    {
        zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        NSString * profileName = @"";
        
        
        profileName = [m_cellLinkProfile getCellData];
        
        srfidLinkProfile* linkProfileObject = [self getMatchingLinkProfileObject:profileName linkProfileArray:localSled.linkProfilesArray];
        linkProfileObject = [self getMatchingLinkProfileObject:profileName linkProfileArray:localSled.linkProfilesArray];
        
        tariArray = [self updateTariArray:linkProfileObject configuration:configuration];
        
        [m_cellPicker setChoices:tariArray];
        for (int tariIndex = 0; tariIndex < [tariArray count]; tariIndex++)
        {
            NSNumber *tariValue = [NSNumber numberWithInt:configuration.currentAntennaTari];
            int selectedValue = [[tariArray objectAtIndex:tariIndex] intValue];
            NSNumber *currentTari = [NSNumber numberWithInt:selectedValue];
            
            if (currentTari == tariValue) {
                m_SelectedOptionTari = tariIndex;
            }else
            {
                m_SelectedOptionTari = [configuration currentAntennaTari];
            }
        }
        [m_cellPicker setSelectedChoice:m_SelectedOptionTari];
        main_cell_idx = ZT_VC_ANTENNA_CELL_IDX_TARI;
    }
    else
    {
        if([[m_cellPowerLevel getCellData] length]>0)
            {
                NSString * floatString = [m_cellPowerLevel getCellData];
                configuration.currentAntennaPowerLevel = [floatString floatValue];
            }

    }
    if (ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE == cell_idx){
        [[self navigationController] pushViewController:vc animated:YES];
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
    }else
    {
        if (row_to_hide != 0 && row_to_hide != -1)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

/// To set the proper link profile index to fetch the correct link profile name.
/// @param value The profile name from the selected link profile.
- (void)setLinkProfileIndex:(NSString *)value
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    srfidLinkProfile* linkProfileObject = [self getMatchingLinkProfileObject:value linkProfileArray:localSled.linkProfilesArray];
    int profileIndex = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMatchingIndexLegacyIndex:value linkProfileArray:localSled.linkProfilesArray];
    localSled.currentAntennaLinkProfile = profileIndex;
    localSled.currentAntennaTari = linkProfileObject.getMaxTari;
    localSled.currentAntennaPie = linkProfileObject.getPIE;
    
    [[NSUserDefaults standardUserDefaults] setValue:ANTENNA_DEFAULTS_VALUE forKey:ANTENNA_CHANGE_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:ANTENNA_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Updating the tari array depends on the selected link profile.
/// @param linkProfileObject The link profile object from the selected link profile data.
/// @param configuration The sled configuration to reduce more declarations.
- (NSArray*)updateTariArray:(srfidLinkProfile*)linkProfileObject configuration:(zt_SledConfiguration*)sledConfiguration
{
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    NSString *reader_sku = [[sled readerModel] substringFromIndex: [[sled readerModel] length] - 2];
    
    tariArray = [[NSArray alloc] init];
    if (linkProfileObject.getPIE == 0 && linkProfileObject.getMinTari == 0 && linkProfileObject.getMaxTari == 0)
    {
        tariArray = TARI_ARRAY_0
    }else if ((linkProfileObject.getMinTari == MIN_TARI_25000 && sledConfiguration.isMinTari_12500) || (linkProfileObject.getMaxTari == MIN_TARI_23000 && linkProfileObject.getMinTari == MIN_TARI_12500)) {
        if (sledConfiguration.isStepTari_6300) {
            tariArray = TARI_ARRAY_25000_6300
        }else
        {
            tariArray = TARI_ARRAY_12500_25000
        }
    }else if ((linkProfileObject.getMinTari == MIN_TARI_25000 && sledConfiguration.isStepTari_non_0) || (linkProfileObject.getMaxTari == MIN_TARI_23000 && linkProfileObject.getMinTari == MIN_TARI_18800))
    {
        tariArray = TARI_ARRAY_18800_25000
    }else if (linkProfileObject.getMaxTari == MIN_TARI_18800 && linkProfileObject.getMinTari == MIN_TARI_12500)
    {
        if (sledConfiguration.isStepTari_6300) {
            tariArray = TARI_ARRAY_18800_6300
        }else
        {
            tariArray = TARI_ARRAY_12500_18800
        }
    }else if (linkProfileObject.getMinTari == MIN_TARI_18800)
    {
        tariArray = TARI_ARRAY_18800
    }else if (linkProfileObject.getMinTari == MIN_TARI_25000 && !sledConfiguration.isStepTari_non_0)
    {
        if ([reader_sku isEqualToString:@"E8"])
        {
            tariArray = TARI_ARRAY_18800_25000
        }else
        {
            tariArray = TARI_ARRAY_25000
        }
        
    }else if (linkProfileObject.getMaxTari == MIN_TARI_6250)
    {
        tariArray = TARI_ARRAY_6250
    }else if (linkProfileObject.getMaxTari == MIN_TARI_668)
    {
        tariArray = TARI_ARRAY_668
    }else
    {
        tariArray = TARI_ARRAY_GENERAL
    }
    return tariArray;
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    zt_OptionCellView *_cell = (zt_OptionCellView*)option_cell;
    
    if (YES == [_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)_cell getSelectedChoice];
        
        zt_SledConfiguration *localSledConfiguration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        NSNumber *linkProfileKey = [NSNumber numberWithInt:localSledConfiguration.currentAntennaLinkProfile];
        int linkProfileIndex = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] updateProfilesIndex:[linkProfileKey intValue]];
        srfidLinkProfile* linkProfileObject = [self getMatchingLinkProfileObject:[m_cellLinkProfile getCellData] linkProfileArray:localSledConfiguration.linkProfilesArray];
        linkProfileObject = [self getMatchingLinkProfileObject:[m_cellLinkProfile getCellData] linkProfileArray:localSledConfiguration.linkProfilesArray];
        tariArray = [self updateTariArray:linkProfileObject configuration:localSledConfiguration];
        int tariValue = localSledConfiguration.currentAntennaTari;
        if (ZT_VC_ANTENNA_CELL_IDX_TARI == (m_PickerCellIdx - 1))
        {
            tariValue = [[tariArray objectAtIndex:choice] intValue];
        }
       
        int pieValue = localSledConfiguration.currentAntennaPie;
        if (ZT_VC_ANTENNA_CELL_IDX_PIE == (m_PickerCellIdx - 1))
        {
            pieValue = [[pieArray objectAtIndex:choice] intValue];
        }
        
        localSledConfiguration.currentAntennaLinkProfile = linkProfileIndex;
        localSledConfiguration.currentAntennaPie = pieValue;
        localSledConfiguration.currentAntennaTari = tariValue;
                
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveUserDefinedProfileintoLocalMemory:[NSString stringWithFormat:@"%f",localSledConfiguration.currentAntennaPowerLevel] linkProfileIndex:[NSString stringWithFormat:@"%d",linkProfileIndex] sessionIndex:0 dynamicProfile:0];
        
        if (ZT_VC_ANTENNA_CELL_IDX_PIE == (m_PickerCellIdx - 1))
        {
            [cellPie setData:(NSString *)[pieArray objectAtIndex:choice]];
        }
        if (ZT_VC_ANTENNA_CELL_IDX_TARI == (m_PickerCellIdx - 1))
        {
            [cellTari setData:(NSString *)[tariArray objectAtIndex:choice]];
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:ANTENNA_UPDATED_VALUE forKey:ANTENNA_CHANGE_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void)didBeginEditing:(id)option_cell
{
}
- (void)handlePowerLevelChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    [_input setString:[[m_cellPowerLevel getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellPowerLevel getCellData]] == NO)
        {
            [m_cellPowerLevel setData:string];
        }
    
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:ANTENNA_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        /* restore previous one */
        [m_cellPowerLevel setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellPowerLevel getTextField] undoManager] removeAllActions];
    }
    
    zt_SledConfiguration *localSledConfiguration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    [localSledConfiguration setCurrentAntennaPowerLevel:[string floatValue]];
    
    if ([string floatValue] <= [localSledConfiguration.getReaderMaxPowerLevel floatValue]) {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveUserDefinedProfileintoLocalMemory:[NSString stringWithFormat:@"%@",string] linkProfileIndex:[NSString stringWithFormat:@"%d",localSledConfiguration.currentAntennaLinkProfile] sessionIndex:0 dynamicProfile:0];
    }else
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveUserDefinedProfileintoLocalMemory:[NSString stringWithFormat:@"%@",localSledConfiguration.getReaderMaxPowerLevel] linkProfileIndex:[NSString stringWithFormat:@"%d",localSledConfiguration.currentAntennaLinkProfile] sessionIndex:0 dynamicProfile:0];
    }
    
    [_input release];
    
    [[NSUserDefaults standardUserDefaults] setValue:ANTENNA_UPDATED_VALUE forKey:ANTENNA_CHANGE_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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

- (BOOL)checkNumInput:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* :, 0 .. 9, A .. F */
        if ((_ch < 48) || (_ch > 57) )
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblOptions.contentInset = contentInsets;
    m_tblOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblOptions.contentInset = contentInsets;
    m_tblOptions.scrollIndicatorInsets = contentInsets;
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
    [m_tblOptions reloadData];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
