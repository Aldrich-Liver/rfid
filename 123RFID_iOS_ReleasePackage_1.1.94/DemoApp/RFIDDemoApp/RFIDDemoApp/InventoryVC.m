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
 *  Description:  InventoryVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "InventoryVC.h"
#import "config.h"
#import "ui_config.h"
#import "AlertView.h"
#import "ScannerEngine.h"
#import "HexToAscii.h"
#import "AppConfiguration.h"
#import "UIColor+DarkModeExtension.h"
#import "CSVHelper.h"
#import "InventoryData.h"
#import "Sgtin96.h"
#import "RFIDDemoApp-Swift.h"
// toDo check if inventory public header
#import "InventoryItem.h"

#define ZT_INVENTORY_CFG_OPTION_COUNT        5

#define ZT_INVENTORY_TIMER_INTERVAL          0.2

#define   DEFAULT_EXPANDED_CELL_ID  1
#define   SECTION_O  0

@interface zt_InventoryVC ()

@end

@implementation zt_InventoryVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ExpandedCellIdx = -1;
        
        m_Tags = [[NSMutableArray alloc] init];
        
        m_SearchString = [[NSMutableString alloc] init];
        
        selectIndexPathArray = [[NSMutableArray alloc] init];
        
        matchingArray = [[NSMutableArray alloc] init];
        missingArray = [[NSMutableArray alloc] init];
        totalTagsCount = -ZT_EXPORTDATA_INIT_VALUE;
        uniqueTagsCount = -ZT_EXPORTDATA_INIT_VALUE;
        readTimeValue = -ZT_EXPORTDATA_INIT_VALUE;
        cycleCountArray = [[NSMutableArray alloc] init];
        tagListFilterArray = [[NSMutableArray alloc]init];
        filteredArray = [[NSMutableArray alloc]init];
        unknownTagsArray = [[NSMutableArray alloc]init];
        isInventoryStarted = FALSE;
        isCreateCSVFileMethodExcute = FALSE;
        inventoryTriggered = FALSE;
        
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        if (tagListOption)
        {
            [self createTaglistFilter];
            m_btnOptions = [[UIBarButtonItem alloc] initWithTitle:ZT_TAGLIST_BATBUTTON_OPTIONS style:UIBarButtonItemStylePlain target:self action:@selector(buttonFilterPressed)];
            
            selectedTagListFilter = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagListFilter];
            m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
            [m_btnOptions setTitle:[tagListFilterArray objectAtIndex:selectedTagListFilter]];
        }else
        {
            m_btnOptions = [[UIBarButtonItem alloc] initWithTitle:ZT_TAGLIST_BATBUTTON_OPTIONS style:UIBarButtonItemStylePlain target:self action:@selector(btnOptionsPressed)];
            
            m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
            
            m_InventoryOptions = [m_Mapper getStringArray];
            
            m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
            [m_btnOptions setTitle:[m_Mapper getStringByEnum:m_SelectedInventoryOption]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    
    // Do any additional setup after loading the view.
    [m_tblTags setDelegate:self];
    [m_tblTags setDataSource:self];

    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblTags setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [m_txtSearch setDelegate:self];
    
    [m_tblTags setEstimatedRowHeight:120.0];
    
    [self configureAppearance];
    
    // Taglist matchmode
       tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
       tagListArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvTagListArray];
    for (TaglistDataObject * tagListObject in tagListArray) {
        [missingArray addObject:[tagListObject getTagId]];
    }
    if (tagListOption) {
        [self updateInventoryObject:missingArray];
    }
}

- (void)dealloc {
    // Don't forget to remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appWillEnterForeground {
    // Reload your table view data here
    [m_tblTags reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    selectIndexPathArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray];
    inventoryTriggered = FALSE;
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSearchFieldChanged:) name:UITextFieldTextDidChangeNotification object:m_txtSearch];
    
    /* add options button */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:m_btnOptions];
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    
    /* set title */
    [self.tabBarController setTitle:@"Inventory"];
    
    // get active profile
    activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];

    /* load saved search criteria */
    [m_SearchString setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagSearchCriteria]];
    [m_txtSearch setText:m_SearchString];
        
    /* load saved selected index */
    m_ExpandedCellIdx = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryItemIndex];
    m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
    [m_btnOptions setTitle:[m_Mapper getStringByEnum:m_SelectedInventoryOption]];
    
    BOOL is_inventory = (ZT_RADIO_OPERATION_INVENTORY == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    if (NO == is_inventory && ![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_INVENTORY];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        if (YES == requested)
        {
            /* simple logic of radioStateChangedOperationRequested w/o cleaning of selected inventory item */
            [UIView performWithoutAnimation:^{
                [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
                [m_btnStartStop layoutIfNeeded];
                [m_btnStartStop setSelected:YES];
            }];
            
            [m_btnOptions setEnabled:NO];
            
            [m_Tags removeAllObjects];
            
            [self updateOperationDataUI];
            
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
            if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
            {
                [m_Tags removeAllObjects];
                [m_tblTags reloadData];
                batchModeLabel.hidden = NO;
                [self setTotalTagCount:ZT_EXPORTDATA_SET_ZERO];
                [self setReadTime:ZT_EXPORTDATA_SET_ZERO];
                
                BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
                
                if (tagListOption) {
                    m_tblTags.hidden = YES;
                    m_lblTotalTagsData.hidden = YES;
                    m_lblUniqueTagsData.hidden = YES;
                }else
                {
                    m_tblTags.hidden = NO;
                    m_lblTotalTagsData.hidden = NO;
                    m_lblUniqueTagsData.hidden = NO;
                }
                
            }
        }
        else
        {
            [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_INVENTORY];
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
        }
    }
    activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX]) {
        m_buttonCycleCount.hidden=NO;
    }else
    {
        m_buttonCycleCount.hidden=YES;
    }
    
    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
    if (tagListOption) {
        int index = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagListFilter];
        [m_btnOptions setTitle:[tagListFilterArray objectAtIndex:index]];
        NSLog(@"Reader tagListFilterArray index: %@", [tagListFilterArray objectAtIndex:index]);
    }
    
    [self handleButtonOptions];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    //BOOL hasTagQueitEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"TagQueitEnabled"];

    
    
    if ([local prefilterEnabled])
    {
//        if(hasTagQueitEnabled){
//            labelPrefilterEnabled.text = @"Tag Queit Enabled";
//            labelPrefilterEnabled.hidden = NO;
//            prefilterLabelHeightConstraint.constant = 15;
//        }else{
//            labelPrefilterEnabled.hidden = YES;
//            prefilterLabelHeightConstraint.constant = 0;
//        }
        labelPrefilterEnabled.hidden = NO;
        prefilterLabelHeightConstraint.constant = 15;
    }else
    {
//        if(hasTagQueitEnabled){
//            labelPrefilterEnabled.text = @"Tag Queit Enabled";
//            labelPrefilterEnabled.hidden = NO;
//            prefilterLabelHeightConstraint.constant = 15;
//        }else{
//            labelPrefilterEnabled.hidden = YES;
//            prefilterLabelHeightConstraint.constant = 0;
//        }
        labelPrefilterEnabled.hidden = YES;
        prefilterLabelHeightConstraint.constant = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:m_txtSearch];
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
    
}

- (void)handleSearchFieldChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_txtSearch text] uppercaseString]];
    
    NSMutableString *defaultData = [[NSMutableString alloc] init];
    [defaultData setString:[m_txtSearch text]];
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        [m_txtSearch setText:defaultData];
        [m_SearchString setString:defaultData];
    }
    else
    {
        if ([self checkHexPattern:_input] == YES)
        {
            [m_SearchString setString:_input];
            if ([m_SearchString isEqualToString:[m_txtSearch text]] == NO)
            {
                [m_txtSearch setText:m_SearchString];
            }
        }
        else
        {
            /* restore previous input and return */
             
            /* restore previous one */
            [m_txtSearch setText:m_SearchString];
            /* clear undo stack as we have restored previous stack (i.e. user's action
             had no effect) */
            [[m_txtSearch undoManager] removeAllActions];
            return;
        }
    }
    
    
    
    
    /* UI update based on search criteria is going to be performed */
    /* clear selection information */
    m_ExpandedCellIdx = -1;
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
    
    /* save search criteria */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagSearchCriteria:m_SearchString];
    
    /* clear tags array to perform full UI update */
    [m_Tags removeAllObjects];
    
    /* update UI */
    [self updateOperationDataUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID{
    if (!isRFID){
        return YES;
    }
    __block zt_InventoryVC *__weak_self = self;
    BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    if (YES == pressed)
    {
        /* trigger press -> start operation if start trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerImmediate])
        {
            /* immediate start trigger */
            if (NO == requested)
            {
                /* operation is not in progress / requested */
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    else
    {
        /* trigger release -> stop operation if stop trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerImmediate])
        {
            /* immediate stop trigger */
            BOOL batchmodeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_BATCHMODE_ENABLED_KEY];
            
            if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] != YES && batchmodeEnabled == YES)
            {
                SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
                [self createCSVFileUsingInventoryData];
            }else
            {
                if (YES == requested)
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       [__weak_self btnStartStopPressed:nil];
                                   });
                }
            }
        }
    }
    return YES;
}

- (void)showWarning:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(),^{
        [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
    });
}

- (void)showSuccess:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(),^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:YES aSuccessMessage:message aFailureMessage:EMPTY_STRING];
    });
}

- (void)configureTagCell:(zt_RFIDTagCellView*)tag_cell forRow:(int)row isExpanded:(BOOL)expanded
{
    /* TBD */
    
    if ([m_Tags count] != 0)
    {
        zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:row];
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        BOOL friendlyName = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigFriendlyNames];
        
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode]){
            NSString * asciiTagData = [HexToAscii stringFromHexString:tag_data.getTagId];
            [tag_cell setTagDataASCIIMode:asciiTagData];
            
        }else if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigSgtin96]){
            if (![tag_data.getTagId  isEqual: @""]){
               Sgtin96* sgtin96decode = [[Sgtin96 alloc] init];
               NSString * sgtinData =  [sgtin96decode decode:tag_data.getTagId];
               [tag_cell setTagDataASCIIMode:sgtinData];
            }
        }
        else{
            // FriendlyNames
            
            if (tagListOption == true && friendlyName == true) {
                BOOL isMatched = NO;
                NSString * friendlyName = ZT_FRIENDLYNAME_EMPTY_STRING;
                for (TaglistDataObject * tagListObject in tagListArray) {
                    
                    if ([[tag_data getTagId] isEqualToString:[tagListObject getTagId]] && ![[tagListObject getTagFriendlyName] isEqualToString:ZT_FRIENDLYNAME_EMPTY_STRING]) {
                        isMatched = YES;
                        friendlyName = [tagListObject getTagFriendlyName];
                    }
                }
                
                if (isMatched) {
                    [tag_cell setTagData:friendlyName];
                }else
                {
                    [tag_cell setTagData:tag_data.getTagId];
                }
            }else if(tagListOption == true && friendlyName == false)
            {
                for (TaglistDataObject * tagListObject in tagListArray) {
                    
                    if ([[tag_data getTagId] isEqualToString:[tagListObject getTagId]]){
                        [tag_cell setTagData:tag_data.getTagId];
                    }else
                    {
                        [tag_cell setTagData:tag_data.getTagId];
                    }
                }
            }
            else
            {
                [tag_cell setTagData:tag_data.getTagId];
            }
        }
    
        if (tagListOption) {
            if ([matchingArray containsObject:[tag_data getTagId]]) {
                [tag_cell setTagDataTextColorForMatchedTags];
            }else if ([missingArray containsObject:[tag_data getTagId]]) {
                [tag_cell setTagDataTextColorForMissingTags];
            }else
            {
                [tag_cell setDefaultTextColorForRemainingTags];
            }
        }else
        {
            [tag_cell setDefaultTextColor];
        }
        
        BOOL checkBrandID = [[NSUserDefaults standardUserDefaults] boolForKey:BRANDIDCHECK_KEY_DEFAULTS];
        
        if (checkBrandID) {
            [tag_cell setNxpBrandIdStatusWithColorOnTag:tag_data.getBrandIdStatusFromSingleTagData];
        }
        
        [tag_cell setTagCount:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, tag_data.getCount]];
        
        if (YES == expanded)
        {
            m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
            if ([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank] == SRFID_MEMORYBANK_TAMPER) {
                [tag_cell setBankIdentifier:(NSString*)[m_Mapper getStringByEnum:SRFID_MEMORYBANK_EPC]];
            }else if ([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank] == 16) {
                [tag_cell setBankIdentifier:[m_Mapper getStringByEnum:SRFID_MEMORYBANK_NONE]];
                NSLog(@"MemoryBankENUM: %@",[m_Mapper getStringByEnum:SRFID_MEMORYBANK_NONE]);
            }else
            {
                [tag_cell setBankIdentifier:(NSString*)[m_Mapper getStringByEnum:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank]]];
            }
            
//            [tag_cell setBankData:[NSString stringWithFormat:@"%@", tag_data.getMemoryBankData]];
            if ([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank] == 16)
            {
                [tag_cell setBankData:[NSString stringWithFormat:@"NONE"]];
                NSLog(@"tag_data.getMemoryBankData: %@", [NSString stringWithFormat:@"%@", tag_data.getMemoryBankData]);
                
            }else {
                [tag_cell setBankData:[NSString stringWithFormat:@"%@", tag_data.getMemoryBankData]];
                NSLog(@"tag_data.getMemoryBankData: %@", [NSString stringWithFormat:@"%@", tag_data.getMemoryBankData]);
            }
            
            srfidReportConfig *report_fields = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryReportConfig];
            
            if (YES == [report_fields getIncPC])
            {
                [tag_cell setPCData:tag_data.getPC];
            }
            else
            {
                [tag_cell setUnperfomPCData];
            }
            
            if (YES == [report_fields getIncRSSI])
            {
                [tag_cell setRSSIData:tag_data.getRSSI];
            }
            else
            {
                [tag_cell setUnperfomRSSIData];
            }

            if (YES == [report_fields getIncPhase])
            {
                [tag_cell setPhaseData:tag_data.getPhase];
            }
            else
            {
                [tag_cell setUnperfomPhaseData];
            }

            if (YES == [report_fields getIncChannelIndex])
            {
                [tag_cell setChannelData:tag_data.getChannelIndex];
            }
            else
            {
                [tag_cell setUnperfomChannelData];
            }
            if (YES == [report_fields getIncTagSeenCount])
            {
                [tag_cell setTagCount:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT,tag_data.getCount]];
            }
            else
            {
                [tag_cell setUnperfomTagSeenCount];
            }
        }
        
        [tag_cell configureViewMode:expanded];
        
        //Change the selection color in cell
        BOOL isTheTagIdExistInMultitagIdArray = [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] containsObject:tag_data.getTagId];
        if (isTheTagIdExistInMultitagIdArray) {
            tag_cell.backgroundColor = TAG_SELECTION_COLOR;
        }else{
            tag_cell.backgroundColor = [UIColor getDarkModeInventoryCellBackgroundColor:self.view.traitCollection];;
        }
        
        if (m_SelectedInventoryOption == SRFID_MEMORYBANK_TAMPER) {
            NSString * epcData = tag_data.getMemoryBankData;
            MySwiftObject * swiftObject = [[MySwiftObject alloc] init];
            
            BOOL result = [swiftObject convertToHexaWithTagID:epcData];
            if(result)
            {
                [tag_cell setTagDataTextColorForTamperTags];
                [tag_cell setTagData:epcData];
                [tag_cell setBankData:tag_data.getTagId];
            }else
            {
                if ([epcData  isEqual: NON_TAMPER_TAGVALUE] || [epcData  isEqual: NON_TAMPER_TAGVALUE1]) {
                    [tag_cell setTagData:epcData];
                    [tag_cell setBankData:tag_data.getTagId];
                }
                [tag_cell setDefaultTextColor];
            }
        }
    }
}

- (void)setLabelTextToFit:(NSString*)text forLabel:(UILabel*)label withMaxFontSize:(float)max_font_size
{
    float lbl_height = label.frame.size.height;
    float lbl_width = label.frame.size.width;
    
    CGFloat font_size = max_font_size + 1.0;
    CGSize text_size;
    
    do
    {
        font_size--;
        text_size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font_size]}];
        
    } while ((text_size.height > lbl_height) || (text_size.width > lbl_width));
    
    [label setFont:[UIFont systemFontOfSize:font_size]];
    [label setText:text];
}

- (void)configureAppearance
{
    /* configure search text field */
    [m_txtSearch setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_txtSearch setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_txtSearch setKeyboardType:UIKeyboardTypeDefault];
    [m_txtSearch setReturnKeyType:UIReturnKeySearch];
    [m_txtSearch setClearButtonMode:UITextFieldViewModeAlways];
    [m_txtSearch setPlaceholder:@"Search"];
    [m_txtSearch setText:@""];
    
    UIImageView *search_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find.png"]];
    
    [m_txtSearch setLeftView:search_icon];
    [m_txtSearch setLeftViewMode:UITextFieldViewModeUnlessEditing];
    
    /* font size */
    [m_lblTotalTagsData setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]];
    [m_lblUniqueTagsData setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]];
    [m_txtSearch setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_MEDIUM]];
    [m_btnStartStop.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BUTTON]];
    
    // Label Title
    tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
    
    if (tagListOption) {
        [labelUniqueTags setText:ZT_TAGLIST_MATCHING_TAGS];
        [labelTotalTags setText:ZT_TAGLIST_MISSING_TAGS];
    }else
    {
        [labelUniqueTags setText:ZT_TAGLIST_UNIQUE_TAGS];
        [labelTotalTags setText:ZT_TAGLIST_TOTAL_TAGS];
    }
}

- (void)btnOptionsPressed
{
    UIAlertController *optionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < [m_InventoryOptions count]; i++)
    {
        NSString *title = [NSString stringWithFormat:@"%@ %@ \u2001", (([m_Mapper getIndxByEnum:m_SelectedInventoryOption] == i) ? @"\u2713" : @"\u2001"), (NSString*)[m_InventoryOptions objectAtIndex:i]];
        
        [optionsMenu addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Handle UIActionSheet button here
            m_SelectedInventoryOption = [m_Mapper getEnumByIndx:i];
            [m_btnOptions setTitle:[m_InventoryOptions objectAtIndex:i]];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setSelectedInventoryMemoryBankUI:m_SelectedInventoryOption];
        }]];
    }
    
    [optionsMenu addAction:[UIAlertAction actionWithTitle:ZT_TAGLIST_BATBUTTON_HIDE style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Handle CANCEL UIActionSheet button here
    }]];
    
    [self presentViewController:optionsMenu animated:YES completion:nil];
    
}

- (IBAction)btnStartStopPressed:(id)sender
{
    BOOL locationingRequested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (!locationingRequested) {
        /// Clearing selected barcode value
        [[ScannerEngine sharedScannerEngine] removeSelectedBarcodeValue];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] removeAllMultiTagIds];
        NSString *statusMsg;
        if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
        {
            [self showWarning:INVENTORY_TAG_READING_INPROGRESS];
            return;
        }
        BOOL inventory_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        inventoryTriggered = TRUE;

        if (NO == inventory_requested)
        {
            if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES])
            {
                rfid_res = [[zt_RfidAppEngine sharedAppEngine] purgeTags:&statusMsg];
            }
            
            NSString * brandID = [[NSUserDefaults standardUserDefaults] objectForKey:BRANDID_KEY_DEFAULTS];
            NSString * epcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];
            
            BOOL checkBrandID = [[NSUserDefaults standardUserDefaults] boolForKey:BRANDIDCHECK_KEY_DEFAULTS];
            
            if (checkBrandID) {
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] performBrandCheckInventory:YES aMemoryBank:m_SelectedInventoryOption message:&status brandId:brandID epcLenth:[epcLength intValue]];
            }else
            {
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:m_SelectedInventoryOption message:&status];
            }
            [self enableBatchMode:status];
            
        }
        else
        {
            rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
        }
        
        if (m_btnStartStop.selected == YES) {
            [m_btnStartStop setSelected:NO];
            m_lblTotalTagsData.hidden = NO;
            m_lblUniqueTagsData.hidden = NO;
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] stopHostBeeper];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
                if ([activeProfile  isEqual: CYCLE_COUNT_INDEX] || [[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
                {
                    [self getTotalTagsCountInCycleCount];
                }
                [self createCSVFileUsingInventoryData];
            });
        }else{
            [m_btnStartStop setSelected:YES];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] playHostBeeper];
        }
        
    }else
    {
        [self showWarning:ZT_MULTITAG_ERROR_MESSAGE];
    }
    

    // request battery status so we know how much battery is left
    [[zt_RfidAppEngine sharedAppEngine] requestBatteryStatus:nil];
    
    // refresh dpo bar button item to show battery status
    [self refreshDpoButton];
    
}

/// To enable the batchmode label.
/// - Parameter status: Batchmode status.
-(void)enableBatchMode:(NSString*)status
{
    if ([status isEqualToString:INVENTORY_IN_BATCH_MODE]) {
        [m_Tags removeAllObjects];
        [m_tblTags reloadData];
        batchModeLabel.hidden = NO;
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
            [m_btnStartStop setSelected:YES];
            [self setReadTime:ZT_EXPORTDATA_SET_ZERO];
            [self setTotalTagCount:ZT_EXPORTDATA_SET_ZERO];
        }];
        
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        
        if (tagListOption) {
            m_tblTags.hidden = YES;
            m_lblTotalTagsData.hidden = YES;
            m_lblUniqueTagsData.hidden = YES;
        }else
        {
            m_tblTags.hidden = NO;
            m_lblTotalTagsData.hidden = NO;
            m_lblUniqueTagsData.hidden = NO;
        }
        
    }
}

/// To get the total reads tags count when cyclecount is enabled
-(void)getTotalTagsCountInCycleCount
{
    [NSThread sleepForTimeInterval:ZT_CYCLECOUNT_THREAD_SLEEP];
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
    int totalTagCount = [zt_InventoryData getTotalCount:_tags];
        
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
    {
        
        totalTagsCountForCycleCount += totalTagCount;
        [self addingArrayforCycleCount:_tags];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalTagsCountForCycleCount] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(),^{
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        
        if (!tagListOption) {
            if (totalTagsCountForCycleCount != ZT_TAG_LIST_COUNT_ZERO){
                [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalTagsCountForCycleCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
                [self setTotalTagCount:totalTagsCountForCycleCount];
            }
        }
        
    });
}
/// Adding array to get the proper tags count when cyclecount is enabled.
/// @param tagsArray Tags array for the cyclecount operation.
-(void)addingArrayforCycleCount:(NSArray *) tagsArray
{
    for (zt_InventoryItem * tag in tagsArray) {
        BOOL isMatch = NO;
        for (zt_InventoryItem * cycleCountTag in cycleCountArray) {
            if ([[cycleCountTag getTagId] isEqual:[tag getTagId]]) {
                isMatch = YES;
                [cycleCountTag addCount:[tag getCount]];
            }
        }
        if (!isMatch) {
            [cycleCountArray addObject:tag];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        
        if (!tagListOption) {
            [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT, (unsigned long)[cycleCountArray count]] forLabel:m_lblUniqueTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
            int totalUniqueTagCount = (int)[cycleCountArray count];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalUniqueTagCount] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setUniqueTagCount:totalUniqueTagCount];
        }
        [m_Tags removeAllObjects];
        if ([missingArray count] != 0 && tagListOption) {
            [self updateInventoryObject:missingArray];
        }
        [NSThread sleepForTimeInterval:0.1];
        [m_Tags addObjectsFromArray:cycleCountArray];
        [m_tblTags reloadData];
        
    });

}

- (void)updateOperationDataUI
{
    /* unique tags */
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
    int uniqueTagCount = (int)[zt_InventoryData getUniqueCount:_tags];
    
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
    {
        if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            [NSThread sleepForTimeInterval:0.1];
            if (!tagListOption) {
                int uniqueTagsCount = [[[NSUserDefaults standardUserDefaults] objectForKey:ZT_UNIQUETAGS_DEFAULTS_KEY] intValue];
                [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, uniqueTagsCount] forLabel:m_lblUniqueTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self setUniqueTagCount:uniqueTagCount];
                });
                
            }
            
        }else
        {
            
            if (batchModeLabel.hidden) {
                if (!tagListOption) {
                    [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, uniqueTagCount] forLabel:m_lblUniqueTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self setUniqueTagCount:uniqueTagCount];
                    });
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:uniqueTagCount] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }else
            {
                [self setUniqueTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    }else
    {
        [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, uniqueTagCount] forLabel:m_lblUniqueTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
        dispatch_async(dispatch_get_main_queue(),^{
            [self setUniqueTagCount:uniqueTagCount];
        });
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:uniqueTagCount] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /* total tags */
    int totalTagCount = [zt_InventoryData getTotalCount:_tags];
    
    NSTimeInterval read_time = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getRadioOperationTime];
    BOOL in_progress = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress];
    if (YES == in_progress){
        NSDate *last_start = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLastStartOperationTime];
        if (nil != last_start)
        {
            read_time += [[NSDate date] timeIntervalSinceDate:last_start];
        }
    }

    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
    {
        if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            [NSThread sleepForTimeInterval:0.1];
            if (!tagListOption) {
                int totalReadsCount = [[[NSUserDefaults standardUserDefaults] objectForKey:ZT_TOTALREADS_DEFAULTS_KEY] intValue];
                [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalReadsCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [self setTotalTagCount:totalReadsCount];
                });
            }
            
        }else
        {
            [NSThread sleepForTimeInterval:0.1];
            if (batchModeLabel.hidden) {
                if (!tagListOption) {
                    [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalTagCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self setTotalTagCount:totalTagCount];
                    });
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalTagCount] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }else
            {
                [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    }else
    {
        [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalTagCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self setTotalTagCount:totalTagCount];
        });
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalTagCount] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (tagListOption) {
        [self getMatchingTagList];
    }
    
    if (0 < [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagSearchCriteria] length])
    {
        /* we have search criteria */
        _tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:YES];
    }

    [m_Tags removeAllObjects];
    if ([missingArray count] != 0) {
        [self updateInventoryObject:missingArray];
    }
    
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
    {
        NSMutableArray * arrayCycleCount = [[NSMutableArray alloc] initWithArray:cycleCountArray];
        
        for (zt_InventoryItem * tag in _tags) {
            BOOL isMatch = NO;
            for (zt_InventoryItem * cycleCountTag in arrayCycleCount) {
                if ([[cycleCountTag getTagId] isEqual:[tag getTagId]]) {
                    isMatch = YES;
                }
            }
            if (!isMatch) {
                [arrayCycleCount addObject:tag];
            }
        }
        [NSThread sleepForTimeInterval:0.1];
        [m_Tags addObjectsFromArray:arrayCycleCount];
    }else
    {
        [m_Tags addObjectsFromArray:_tags];
        
    }
    if (tagListOption) {
        [self applyTaglistFilter:selectedTagListFilter];
    }
    
    /* tags data */
    if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        batchModeLabel.hidden = YES;
        [m_tblTags reloadData];
        dispatch_async(dispatch_get_main_queue(),^{
            [self setReadTime:read_time];
        });
        
    }
    
   // [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] playHostBeeper];
}

- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        isInventoryStarted = TRUE;
        
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
            [m_btnStartStop setSelected:YES];
        }];
        
        [m_btnOptions setEnabled:NO];

        /* clear selection information */
        m_ExpandedCellIdx = -1;
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
        
        /* clear tags only on start of new operation */
        if (!tagListOption) {
            [m_Tags removeAllObjects];
        }
        if(batchModeLabel.hidden)
        {
            if (!tagListOption) {
                [m_Tags removeAllObjects];
            }
            [m_tblTags reloadData];
            batchModeLabel.hidden = NO;
            [self setReadTime:ZT_EXPORTDATA_SET_ZERO];
            [self setTotalTagCount:ZT_EXPORTDATA_SET_ZERO];
        }
        
        [self updateOperationDataUI];
        
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:START_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
            [m_btnStartStop setSelected:NO];
        }];
        
        [self createCSVForStopTriggerDelayTimeInventory];
        isInventoryStarted = FALSE;
        
        [m_btnOptions setEnabled:YES];
        
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        if(!batchModeLabel.hidden)
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getTags:&statusMsg];
            [self updateOperationDataUI];
            batchModeLabel.hidden=YES;
            m_tblTags.hidden = NO;
        }
        else if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] purgeTags:&statusMsg];
            if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
            {
                [[zt_RfidAppEngine sharedAppEngine] reconnectAfterBatchMode];
            }
        }
        /* update statictics */
        [self updateOperationDataUI];
    }
}

- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == in_progress)
    {
        /* start timer */
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_INVENTORY_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
    }
    else
    {
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        /* update statistics */
        [self updateOperationDataUI];
    }
}

/* ###################################################################### */
/* ########## Text Field Delegate Protocol implementation ############### */
/* ###################################################################### */

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    /* clear selection due to upcoming ui update */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
    m_ExpandedCellIdx = -1;
    
    /* clear search criteria */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagSearchCriteria:@""];
    
    /* clear tags array to perform full UI update */
    [m_Tags removeAllObjects];
    
    /* update UI */
    [self updateOperationDataUI];
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* just to hide keyboard */
    [textField resignFirstResponder];

    return YES;
}

- (BOOL) textField: (UITextField *)theTextField shouldChangeCharactersInRange: (NSRange)range replacementString: (NSString *)string {
    
        return YES;
}
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([m_Tags count] != 0)
    {
        return 1;
    }else
    {
        return 0;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([m_Tags count] != 0)
    {
        return [m_Tags count];
    }else
    {
        return 0;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([m_Tags count] != 0)
    {
        return UITableViewAutomaticDimension;
    }else
    {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
//    if ([m_Tags count] != 0)
//    {
        static NSString *RFIDTagCellIdentifier = ZT_CELL_ID_TAG_DATA;
        
        zt_RFIDTagCellView *tag_cell = [tableView dequeueReusableCellWithIdentifier:RFIDTagCellIdentifier forIndexPath:indexPath];
        
        if (tag_cell == nil)
        {
            tag_cell = [[zt_RFIDTagCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RFIDTagCellIdentifier];
        }
        
        BOOL expanded = ((m_ExpandedCellIdx == [indexPath row]) ? YES : NO);
        [self configureTagCell:tag_cell forRow:(int)[indexPath row] isExpanded:expanded];
        
        return tag_cell;
//    }else
//    {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//
//        return cell;
//    }
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL locationingRequested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (!locationingRequested) {
        @try {
            
            UITableViewCell *inventoryTagCell = [tableView cellForRowAtIndexPath:indexPath];

            /// Clearing selected barcode value
            [[ScannerEngine sharedScannerEngine] removeSelectedBarcodeValue];
            // condition check if cell is opened
            if (m_ExpandedCellIdx != [indexPath row])
            {
                int row_to_collapse = m_ExpandedCellIdx;
                m_ExpandedCellIdx = (int)[indexPath row];
                
                NSMutableArray *index_paths = [[NSMutableArray alloc] init];
                
                if (-1 != row_to_collapse)
                {
                    [index_paths addObject:[NSIndexPath indexPathForRow:row_to_collapse inSection:0]];
                }
                [index_paths addObject:[NSIndexPath indexPathForRow:m_ExpandedCellIdx inSection:0]];
                
                [UIView setAnimationsEnabled:NO];
                
                [UIView performWithoutAnimation:^{
                    [tableView beginUpdates];
                    [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationNone];
                    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    [tableView endUpdates];
                }];
                
                [index_paths removeAllObjects];

                [tableView reloadData];
                // save data to appEngine
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setSelectedInventoryItem:(zt_InventoryItem *)[m_Tags objectAtIndex:m_ExpandedCellIdx] withIdx:m_ExpandedCellIdx];
                
                // Save the selected tag data in a NSUSerDefaults Array to retreive in Prefilter View
                NSString *selectedItemData = [(zt_InventoryItem *)[m_Tags objectAtIndex:indexPath.row] getTagId];
                NSLog(@"selectedItemData: %@", selectedItemData);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *selectedItems = [[defaults objectForKey:@"SelectedItemsArray"] mutableCopy];
                if (!selectedItems) {
                        selectedItems = [NSMutableArray array];
                    }
                    // Check if the item is already in the array
                    if ([selectedItems containsObject:selectedItemData]) {
                        [selectedItems removeObject:selectedItemData];
                    }
                    // Add the new item
                    [selectedItems addObject:selectedItemData];
                
                    // Remove any empty values from array
                    [selectedItems removeObject:@""];
                
                    // Ensure the array only contains the last two items
                    if (selectedItems.count > 2) {
                        [selectedItems removeObjectAtIndex:0];
                    }
                // Store updated array in NSUserDefaults
                [defaults setObject:selectedItems forKey:@"SelectedItemsArray"];
                if(selectedItems.count == 2) {
                    [defaults setObject:selectedItems[1] forKey:@"ChangedTagIDStringOne"];
                    [defaults setObject:selectedItems[0] forKey:@"ChangedTagIDStringTwo"];
                }else {
                    [defaults setObject:selectedItems[0] forKey:@"ChangedTagIDStringOne"];
                }
                
                [defaults synchronize];
                
                /* overwrite saved tag ids for locationing and access screens */
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdAccess:[(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx] getTagId]];
                selectedTagId = [(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx] getTagId];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdLocationing:[(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx] getTagId]];
                   
                //Check selected tag id is not contain in multi tag id array
                if (![[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] containsObject:selectedTagId])
                {
                   
                    inventoryTagCell.backgroundColor = TAG_SELECTION_COLOR;
                    [selectIndexPathArray addObject:selectedTagId];
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addTagIdIntoMultiTagArray:selectedTagId];
                    [self addSelectedTagIdObject:(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx]];
                    
                }
                else
                {
                   //Check selected tag id is  contain in multi tag id array and currently selected array(when cell expand)
                    if ([selectIndexPathArray containsObject:selectedTagId] && ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count > 0))
                    {
                        inventoryTagCell.backgroundColor = [UIColor getDarkModeInventoryCellBackgroundColor:self.view.traitCollection];
                        [selectIndexPathArray removeObject:selectedTagId];
                        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] removeItemInMultiTagIdLocationingArray:selectedTagId];
                    }
                    else
                    {
                        inventoryTagCell.backgroundColor = TAG_SELECTION_COLOR;
                        [selectIndexPathArray addObject:selectedTagId];
                        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addTagIdIntoMultiTagArray:selectedTagId];
                        [self addSelectedTagIdObject:(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx]];
                     
                    }
                }
           
               
               
            }
            else
            {
               //Handling cell selection color
                if ([selectIndexPathArray containsObject:selectedTagId] && ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count > 0))
                {
                    inventoryTagCell.backgroundColor = [UIColor getDarkModeInventoryCellBackgroundColor:self.view.traitCollection];
                    [selectIndexPathArray removeObject:selectedTagId];
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] removeItemInMultiTagIdLocationingArray:selectedTagId];
                }
                else
                {
                    inventoryTagCell.backgroundColor = TAG_SELECTION_COLOR;
                    [selectIndexPathArray addObject:selectedTagId];
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addTagIdIntoMultiTagArray:selectedTagId];
                  
                    [self addSelectedTagIdObject:(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx]];
                 
                }
                
                int row_to_collapse = m_ExpandedCellIdx;
                m_ExpandedCellIdx = -DEFAULT_EXPANDED_CELL_ID;

                NSMutableArray *index_paths = [[NSMutableArray alloc] init];
                
                [index_paths addObject:[NSIndexPath indexPathForRow:row_to_collapse inSection:SECTION_O]];
                
                [UIView performWithoutAnimation:^{
                    [tableView beginUpdates];
                    [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationNone];
                    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    [tableView endUpdates];
                }];
                
                [index_paths removeAllObjects];
                
                // save data to appEngine
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
            }
        }
            @catch (NSException *exception) {
               NSLog(@"%@", exception.reason);
            }
    }else
    {
        [self showWarning:ZT_MULTITAG_ERROR_MESSAGE];
    }
       
}



/// Add selected tag id object
/// @param inventoryItemObject The inventory item object
-(void)addSelectedTagIdObject:(zt_InventoryItem*)inventoryItemObject
{
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addInvetoryTagObjectIntoMultiTagArray:inventoryItemObject];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    [m_txtSearch resignFirstResponder];
}

- (IBAction)btnCycleCountPressed:(id)sender
{
    BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    if (YES == requested)
    {
        [self showWarning:INVENTORY_TAG_READING_INPROGRESS];
    }
    else
    {
        totalTagsCountForCycleCount = ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO;
        [cycleCountArray removeAllObjects];
        [m_Tags removeAllObjects];
        [m_tblTags reloadData];
        
        [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalTagsCountForCycleCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
        
        /* clear inventory data*/
        [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] clearInventoryItemList];
        /* update UI */
        [self updateOperationDataUI];
        [self getTotalTagsCountInCycleCount];
        
        [self setLabelTextToFit:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, totalTagsCountForCycleCount] forLabel:m_lblTotalTagsData withMaxFontSize:ZT_CYCLECOUNT_FONT_SIZE];
        
        NSString * activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];
        if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
        {
            [m_lblTotalTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)missingArray.count]];
        }
        
        [[[zt_RfidAppEngine sharedAppEngine] operationEngine] setRadioOperationTime:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
    }
    
}

// Taglist Matchmode feature

/// To handle the multiple buttons when the taglist and fastest read enabled.
- (void)handleButtonOptions
{
    NSString * activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];
    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
    
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX] && tagListOption) {
        m_buttonCycleCount.hidden=NO;
        buttonBrowseFiles.hidden = NO;
        cycleCountButtonWidthConstraint.constant = ZT_TAG_LOCATE_BUTTON_WIDTH_ACTIVE;
    }else
    {
        if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
        {
            cycleCountButtonWidthConstraint.constant = ZT_TAG_LOCATE_BUTTON_WIDTH_ACTIVE;
            buttonBrowseFiles.hidden = YES;
            m_buttonCycleCount.hidden=NO;
        }else if (tagListOption)
        {
            m_buttonCycleCount.hidden=YES;
            cycleCountButtonWidthConstraint.constant = ZT_TAG_LOCATE_BUTTON_WIDTH_INACTIVE;
            buttonBrowseFiles.hidden = NO;
        }else
        {
            m_buttonCycleCount.hidden=YES;
            cycleCountButtonWidthConstraint.constant = ZT_TAG_LOCATE_BUTTON_WIDTH_INACTIVE;
            buttonBrowseFiles.hidden = YES;
        }
    }
}

/// To get the matching tags from the inventory data.
- (void)getMatchingTagList
{
    NSArray *inventoryArray = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    NSArray * tagListArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvTagListArray];
    NSMutableArray * localMatchingArray = [[NSMutableArray alloc] init];
    
    for (zt_InventoryItem * inventoryData in inventoryArray) {
        
        for (TaglistDataObject * tagListObject in tagListArray) {
            if ([[tagListObject getTagId] isEqualToString:[inventoryData getTagId]]) {
                [localMatchingArray addObject:[inventoryData getTagId]];
            }
        }
    }
    matchingArray = localMatchingArray;
    for (NSString * tagListDataString in matchingArray) {
        if ([missingArray containsObject:tagListDataString]) {
            [missingArray removeObject:tagListDataString];
        }
    }
    
    int matchingArrayCount = (int)[matchingArray count];
    int tagListArrayCount = (int)[tagListArray count];
    
    [m_lblUniqueTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)matchingArrayCount]];
   
    [m_lblTotalTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)tagListArrayCount - matchingArrayCount]];
    
    if (tagListArrayCount >= ZT_FRIENDLYNAME_ARRAY_COUNT)
    {
        if (matchingArrayCount == tagListArrayCount) {
            SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
            rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
            if (selectedTagListFilter < ZT_TAGLIST_FILTER_CASE_TWO) {
                [zt_AlertView showInfoMessage:self.view withHeader:ZT_TAGLIST_FILE_CONTENT_EMPTY_STRING withDetails:ZT_TAGLIST_ALERT_MESSAGE_STRING withDuration:1];
            }
            
            [self createCSVFileUsingInventoryData];
        }
    }
}

// Taglist Filter
/// To create the taglist filter array.
- (void)createTaglistFilter
{
    tagListFilterArray = [NSMutableArray arrayWithObjects:ZT_TAGLIST_FILTER_ALL,ZT_TAGLIST_FILTER_MATCHING,ZT_TAGLIST_FILTER_MISSING,ZT_TAGLIST_FILTER_UNKNOWN, nil];
}


/// Button action for the filter dropdown.
- (void)buttonFilterPressed
{
    UIAlertController *filterOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < [tagListFilterArray count]; i++)
    {
        NSString *title = [NSString stringWithFormat:ZT_TAGLIST_STRING_FORMAT, (NSString*)[tagListFilterArray objectAtIndex:i]];
        
        [filterOptionsMenu addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Handle UIActionSheet button here
            selectedTagListFilter = i;
            [m_btnOptions setTitle:[tagListFilterArray objectAtIndex:i]];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagListFilter:selectedTagListFilter];
            [self applyTaglistFilter:selectedTagListFilter];
        }]];
    }
    
    [filterOptionsMenu addAction:[UIAlertAction actionWithTitle:ZT_TAGLIST_BATBUTTON_HIDE style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Handle CANCEL UIActionSheet button here
    }]];
    
    [self presentViewController:filterOptionsMenu animated:YES completion:nil];
}


/// The taglist filter to show seperated filtered values.
/// @param selectedFilter The selected filter from the dropdown.
- (void)applyTaglistFilter:(int)selectedFilter
{
    NSArray *_tags;
    switch (selectedFilter) {
        case ZT_TAGLIST_FILTER_CASE_ZERO:
            _tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
            if (![activeProfile  isEqual: CYCLE_COUNT_INDEX])
            {
                [m_Tags removeAllObjects];
            }
            
            if ([missingArray count] != ZT_TAGLIST_ARRAY_COUNT_ZERO) {
                [self updateInventoryObject:missingArray];
            }
            if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
            {
                [self addingArrayforCycleCount:_tags];
            }else
            {
                [m_Tags addObjectsFromArray:_tags];
            }
            
            [m_tblTags reloadData];
            break;
        case ZT_TAGLIST_FILTER_CASE_ONE:
            [self getMatchingTagList];
            _tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
            if (tagListOption) {
                [m_Tags removeAllObjects];
                NSMutableArray * matchingFilterArray = [[NSMutableArray alloc] init];
                for (TaglistDataObject * tagListObject in tagListArray) {
                    [matchingFilterArray addObject:[tagListObject getTagId]];
                }
                [m_Tags addObjectsFromArray:matchingFilterArray];
                [m_Tags addObjectsFromArray:_tags];
            }
            
            filteredArray = [self getMatchingTaglistObject:m_Tags];
            [m_Tags removeAllObjects];
            [m_Tags addObjectsFromArray:filteredArray];
            [m_tblTags reloadData];
            break;
        case ZT_TAGLIST_FILTER_CASE_TWO:
            [self getMatchingTagList];
            filteredArray = missingArray;
            [m_Tags removeAllObjects];
            [self updateInventoryObject:filteredArray];
            break;
        case ZT_TAGLIST_FILTER_CASE_THREE:
            _tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
            [m_Tags removeAllObjects];
            if ([missingArray count] != ZT_TAGLIST_ARRAY_COUNT_ZERO) {
                [self updateInventoryObject:missingArray];
            }
            [m_Tags addObjectsFromArray:_tags];
            [self getUnknownTagList:m_Tags];
            [m_Tags removeAllObjects];
            [m_Tags addObjectsFromArray:unknownTagsArray];
            [m_tblTags reloadData];
            break;
        default:
            break;
    }
    
}


/// To get the maching array object to show tagid and count.
/// @param matchedArray Matched array from the inventory data.
- (NSMutableArray *) getMatchingTaglistObject:(NSMutableArray *)matchedArray
{
    NSArray *inventoryArray = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    NSMutableArray * localMatchingArray = [[NSMutableArray alloc] init];
    
    for (zt_InventoryItem * inventoryData in inventoryArray) {
        if ([matchedArray containsObject:[inventoryData getTagId]]) {
            [localMatchingArray addObject:inventoryData];
        }
    }
    return localMatchingArray;
}



/// To get the unknown tags list from the inventory data.
/// @param totalTaglistArray Total tags list array for the looping.
- (void)getUnknownTagList:(NSMutableArray *)totalTaglistArray
{
    NSMutableArray * localUnknownArray = [[NSMutableArray alloc] initWithArray:totalTaglistArray];
    
    NSMutableArray * localMatchingArray = [[NSMutableArray alloc] init];
    NSMutableArray * localMissingArray = [[NSMutableArray alloc] init];
    [self getMatchingTagList];
    for (NSString * tagListMatchingString in matchingArray) {
        
        for (zt_InventoryItem * inventoryData in localUnknownArray) {
            
            if ([tagListMatchingString isEqualToString:[inventoryData getTagId]]) {
                [localMatchingArray addObject:inventoryData];
            }
        }
    }
    [localUnknownArray removeObjectsInArray:localMatchingArray];
    for (NSString * tagListMissingString in missingArray) {
        
        for (zt_InventoryItem * inventoryData in localUnknownArray) {
            
            if ([tagListMissingString isEqualToString:[inventoryData getTagId]]) {
                [localMissingArray addObject:inventoryData];
            }
        }
    }
    [localUnknownArray removeObjectsInArray:localMissingArray];
    unknownTagsArray = localUnknownArray;
}

/// Browse the .csv files from the files folder.
/// @param sender Button reference.
- (IBAction)buttonBrowseFilesPressed:(id)sender
{
    [self openSharedFiles];
}
/// To open shared files from the phone.
- (void)openSharedFiles
{
    if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested] && ![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested])
    {
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[ZT_MULTI_TAGDATA_DOCUMENT_TYPE_TEXT,ZT_MULTI_TAGDATA_DOCUMENT_TYPE_DATA]
                                                                                                                    inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:documentPicker animated:YES completion:nil];
    }else
    {
        [self showWarning:ZT_GENERAL_ERROR_MESSAGE];
    }
}

///MARK:- Document picker delegate

/// Tells the delegate that the user has selected a document or a destination.
/// @param controller The document picker that called this method.
/// @param url The URL of the selected document or destination.
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    NSString *filePath = [NSString stringWithFormat:@"%@",url];
    NSString *fileExtension = [filePath pathExtension];
    
    if ([fileExtension isEqualToString:@"csv"]) {
        if (controller.documentPickerMode == UIDocumentPickerModeImport) {
            // Condition called when user download the file
            NSData *fileData = [NSData dataWithContentsOfURL:url];
            if (fileData != nil) {
                NSString *taglistSring = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] createTagListArrayFromCsvFile:taglistSring];
                tagListArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvTagListArray];
                [missingArray removeAllObjects];
                for (TaglistDataObject * tagListObject in tagListArray) {
                    NSCharacterSet *quoteCharset = [NSCharacterSet characterSetWithCharactersInString:@"\""];
                    NSString *trimmedString = [[tagListObject getTagId] stringByTrimmingCharactersInSet:quoteCharset];
                    [missingArray addObject:trimmedString];
                }
               
                [m_Tags removeAllObjects];
                [m_tblTags reloadData];
                /* clear inventory data*/
                [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] clearInventoryItemList];
                NSMutableArray * temporaryTagListArray = [[NSMutableArray alloc] init];
                for (TaglistDataObject * tagListObject in tagListArray) {
                    [temporaryTagListArray addObject:[tagListObject getTagId]];
                }
                
                [self updateInventoryObject:temporaryTagListArray];
                [self getMatchingTagList];
            }
        }
    }else
    {
        [self showWarning:@"Incorrect file format. Please select a .csv file."];
    }
}

/// Tells the delegate that the user canceled the document picker.
/// @param controller The document picker that called this method.
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    NSLog(@"Document Picker Cancelled");
}

/// To update the dummy inventory object when taglist is imported.
/// @param tagListArray Taglist array created from the csv file.
- (void) updateInventoryObject:(NSArray *) tagListArray
{
    for (NSString * tagID in tagListArray) {
        
        NSCharacterSet *quoteCharset = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        NSString *trimmedString = [tagID stringByTrimmingCharactersInSet:quoteCharset];
        
        zt_InventoryItem * inventoryItem = [[zt_InventoryItem alloc] initWithTagID:trimmedString];
        [m_Tags addObject:inventoryItem];
    }
    [m_tblTags reloadData];
}

/// Set read time
/// @param time value of time
- (void)setReadTime:(int)time{
    readTimeValue = time;
}


/// Set total tags count
/// @param count count value
- (void)setTotalTagCount:(int)count{
    if (count == totalTagsCount){
        return;
    }
    totalTagsCount = count;
}

/// Set unique tag count
/// @param count count value
- (void)setUniqueTagCount:(int)count{
    if (count == uniqueTagsCount){
        return;
    }
    uniqueTagsCount = count;
}

// Export data
/// Create the .csv file using the inventory data
/// @param tagListArray The taglist array from the inventory data.
- (void)createCSVFileUsingInventoryData {
    
    isCreateCSVFileMethodExcute = TRUE;
    
    BOOL exportOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigDataExport];
    if (!exportOption) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:ZT_EXPORTDATA_LOADING withDuration:ZT_EXPORTDATA_THREAD_SLEEP];
    });
    
    [NSThread sleepForTimeInterval:ZT_EXPORTDATA_THREAD_SLEEP];
    NSArray *inventoryArray = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    if ([inventoryArray count] <= ZT_EXPORTDATA_MIN_CHECK_ZERO) {
        return;
    }
    @try {
        ///Headers
        NSString *uniqueCount = [NSString stringWithFormat:ZT_EXPORTDATA__TOTAL_UNIQUE_COUNT_FORMAT,ZT_EXPORTDATA_UNIQUE_COUNT,uniqueTagsCount];
        NSString *totalCount = [NSString stringWithFormat:ZT_EXPORTDATA__TOTAL_UNIQUE_COUNT_FORMAT,ZT_EXPORTDATA_TOTAL_COUNT,totalTagsCount];
        NSString *readTime = [CSVHelper getTimeToString:readTimeValue];
        NSString *tagsRowsHeader = [CSVHelper tagListHeading];
        NSString *tagsRows = [CSVHelper getAllTagListAsStringForCSV:inventoryArray];
        
        NSString *fullFileString = [NSString stringWithFormat:ZT_EXPORTDATA_FULL_FILE_FORMAT,ZT_EXPORTDATA_INVENTORY_SUMMARY,uniqueCount,totalCount,readTime,tagsRowsHeader,tagsRows];
        
        NSMutableString *tagListRowsMutableString = [fullFileString mutableCopy];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:ZT_EXPORTDATA_FILE_INDEX];
        NSString *fileName = [CSVHelper generateFileName];
        NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
        NSError *error;
        [tagListRowsMutableString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding      error:&error];
        NSArray *activityItems = @[[NSURL fileURLWithPath:filePath]];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:NULL];
        dispatch_async(dispatch_get_main_queue(),^{
            [self presentViewController:activityView animated:YES completion:NULL];
        });
        
        // access the completion handler
        activityView.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,
            NSError *error){
                // react to the completion
                if (completed) {
                    [self showSuccess:ZT_EXPORTDATA_SUCCESS_MESSAGE];
                } else {
                    [self showWarning:ZT_EXPORTDATA_CANCELLED_MESSAGE];
                }
                
                if (error) {
                    NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
                }
            };
     }
     @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
         dispatch_async(dispatch_get_main_queue(),^{
             [zt_AlertView showInfoMessage:self.view withHeader:ZT_TAGLIST_FILE_CONTENT_EMPTY_STRING withDetails:ZT_EXPORTDATA_FAILURE_MESSAGE withDuration:1];
         });
     }
    
    isCreateCSVFileMethodExcute = false;
    isInventoryStarted = FALSE;
}

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection{
    [m_tblTags reloadData];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

// Create CSV for Stop TriggerDelayTime
-(void)createCSVForStopTriggerDelayTimeInventory {
    
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    long long timeoutStop = [sled currentStopTimeout];
    
    if (timeoutStop > 0) {
        
        if(isInventoryStarted && !isCreateCSVFileMethodExcute) {
           
            [self createCSVFileUsingInventoryData];
          
        }
        
    }

}


@end
