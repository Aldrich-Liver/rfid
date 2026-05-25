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
 *  Description:  LocateTagVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LocateTagVC.h"
#import "BarcodeData.h"
#import "ScannerEngine.h"
#import "MultiTagTableViewCell.h"
#import "HexToAscii.h"
#import "RFIDDemoApp-Swift.h"

#define ZT_LOCATIONING_TIMER_INTERVAL          0.2
#define ZT_VC_LOCATE_OPERATION_SINGLE_TAG                      0
#define ZT_VC_LOCATE_OPERATION_MULTIPLE_TAG                    1
#define ZT_VC_LOCATE_MULTIPLE_TAG_CELL_HEIGHT                  60

#define RSSI_VALUE 40
#define DEFAULT_TAG_SEEN_COUNT @"0"
#define DEFAULT_TAG_PRECENTAGE_VALUE @"0%"



@interface zt_LocateTagVC ()

@end

@implementation zt_LocateTagVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        multipleTagsReportConfig = [[srfidReportConfig alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSearchText:m_txtTagIdInput];
    [self setupSearchText:txtMultiTagIdInput];
    
    m_strTagInput = [[NSMutableString alloc] init];
    multiTagEventList = [[NSMutableArray alloc]init];
    theStatusOfMultiTagLocationingStartStop = NO;
    filterArray = [[NSMutableArray alloc]init];
    multiTagDataDictionary = [[NSMutableDictionary alloc]init];
    multiTagSeenCountArray = [[NSMutableArray alloc]init];
    currentlySelectedTagIdArray = [[NSMutableArray alloc]init];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    refereshPressed = NO;

    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    /* configure segments */
    [segmentedControlOperations addTarget:self action:@selector(actionSelectedOperationChanged) forControlEvents:UIControlEventValueChanged];
    
    [self configureAppearance];
    [self configureSegmentAppearance];
    [self setupConfigurationInitial];
}


-(IBAction)clearAllMultiTagsBtnPressed:(id)sender {
    
    bool multiTagLocationing = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    if (!multiTagLocationing) {
        multiTagEventList = [[NSMutableArray alloc]init];
        
        multiTagDataDictionary = [[NSMutableDictionary alloc]init];
        multiTagSeenCountArray = [[NSMutableArray alloc]init];
        
        multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
        
        [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] removeAllObjects];
        [temporaryTagSelectedArray removeAllObjects];
        [currentlySelectedTagIdArray removeAllObjects];
        [multiTagDataDictionary removeAllObjects];
        [self->tableView reloadData];
        txtMultiTagIdInput.text = @"";
    }
 
    
}


/// Setup the search textfield.
/// @param textField A control that displays an editable text interface.
- (void)setupSearchText:(UITextField*)textField
{
    [textField setDelegate:self];
    if (@available(iOS 13.0, *)) {
        textField.layer.borderColor = UIColor.systemGray4Color.CGColor;
    } else {
        textField.layer.borderColor = UIColor.lightGrayColor.CGColor;
    }
    textField.layer.borderWidth = BORDER_WIDTH;
}


/// To setup the initial configuration
- (void)setupConfigurationInitial
{
    currentOperation = ZT_VC_LOCATE_OPERATION_SINGLE_TAG;
    [segmentedControlOperations setSelectedSegmentIndex:currentOperation];
    
    [self configureForSelectedOperation];
}

/// To setup the segment appearance.
- (void)configureSegmentAppearance
{
    /* configure segmented control */
    float titleFontSize = ZT_UI_ACCESS_FONT_SZ_MEDIUM;
    
    [segmentedControlOperations setTitle:LOCATE_SINGLE_TAG forSegmentAtIndex:ZT_VC_LOCATE_OPERATION_SINGLE_TAG];
    [segmentedControlOperations setTitle:LOCATE_MULTI_TAG forSegmentAtIndex:ZT_VC_LOCATE_OPERATION_MULTIPLE_TAG];
    [segmentedControlOperations setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:
      [UIFont systemFontOfSize:titleFontSize] forKey:NSFontAttributeName]
                                   forState:UIControlStateNormal];
    segmentedControlOperations.tintColor = THEME_BLUE_COLOR
}


/// The action of selected segment operation.
- (void)actionSelectedOperationChanged
{
    currentOperation = (int)[segmentedControlOperations selectedSegmentIndex];
    [self configureForSelectedOperation];
}


/// Configuration of selected segment operation.
- (void)configureForSelectedOperation
{
    /* disable view animation to avoid buttons blinking
    during UI changes */
    [UIView setAnimationsEnabled:NO];
    switch (currentOperation)
    {
        case ZT_VC_LOCATE_OPERATION_SINGLE_TAG:
            singleTagView.hidden = NO;
            multiTagView.hidden = YES;
            break;
        case ZT_VC_LOCATE_OPERATION_MULTIPLE_TAG:
            singleTagView.hidden = YES;
            multiTagView.hidden = NO;
            break;
    }
}

- (BOOL)onNewProximityEvent:(int)value
{
    [self setRelativeDistance:value];
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkTagPatternSelectedFromBarcode];
    
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    if (multiTagLocated) {
        if ([[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] count] != 0) {
            [self createMultitagDictionary];
        }else
        {
            [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] removeAllObjects];
            [multiTagDataDictionary removeAllObjects];
            [self->tableView reloadData];
        }
        
    }else
    {
        currentlySelectedTagIdArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray];
        [self->tableView reloadData];
    }
    //Create a temporary tag id array for reload  tags
    [self createTemporaryArrayForReloadTag];
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTagIdChanged:) name:UITextFieldTextDidChangeNotification object:m_txtTagIdInput];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMultiTagIdChanged:) name:UITextFieldTextDidChangeNotification object:txtMultiTagIdInput];
    
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];
    [[zt_RfidAppEngine sharedAppEngine] multiTagEventDelegate:(id)self];

     /* set title */
    [self.tabBarController setTitle:@"Locate Tag"];
    
    /* add dpo button to the title bar */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    BOOL is_locationing = (ZT_RADIO_OPERATION_LOCATIONING == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdLocationing]];
    
    if (NO == is_locationing)
    {
        [[[zt_RfidAppEngine sharedAppEngine] operationEngine] clearLocationingStatistics];
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_LOCATIONING];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];

        if (NO == requested)
        {
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] clearLocationingStatistics];
        }
        else
        {
            [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLocationingTagId]];
        }
        
        [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_LOCATIONING];
        [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_LOCATIONING];
    }
    
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode]){
        NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagInput];
        [m_txtTagIdInput setText:asciiTagData];
        [self setTagDataTextColorForASCIIMode:m_txtTagIdInput];
        [txtMultiTagIdInput setText:asciiTagData];
        [self setTagDataTextColorForASCIIMode:txtMultiTagIdInput];
    }else{
        [m_txtTagIdInput setText:m_strTagInput];
        [txtMultiTagIdInput setText:m_strTagInput];
    }
    [self enableAndDisableButtons];
    [self enableAndDisableButtonsForInventory];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:m_txtTagIdInput];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:txtMultiTagIdInput];

    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
}

- (void)handleTagIdChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_txtTagIdInput text] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [m_strTagInput setString:_input];
        if ([m_strTagInput isEqualToString:[m_txtTagIdInput text]] == NO)
        {
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagInput];
                [m_txtTagIdInput setText:asciiTagData];
                [self setTagDataTextColorForASCIIMode:m_txtTagIdInput];
                /* maintain edited tag id */
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdLocationing:asciiTagData];
            }
            else
            {
                [m_txtTagIdInput setText:m_strTagInput];
                
                /* maintain edited tag id */
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdLocationing:m_strTagInput];
            }
        }
      
    }
    else
    {
        /* restore previous one */
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagInput];
            [m_txtTagIdInput setText:asciiTagData];
            [self setTagDataTextColorForASCIIMode:m_txtTagIdInput];
        }
        else
        {
            [m_txtTagIdInput setText:m_strTagInput];
            
        }
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[m_txtTagIdInput undoManager] removeAllActions];
    }
}

/// To handling multitag when changed.
/// @param notification An object containing information broadcast to registered observers that bridges.
- (void)handleMultiTagIdChanged:(NSNotification *)notification
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[txtMultiTagIdInput text] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [m_strTagInput setString:_input];
        if ([m_strTagInput isEqualToString:[txtMultiTagIdInput text]] == NO)
        {
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagInput];
                [m_txtTagIdInput setText:asciiTagData];
                [self setTagDataTextColorForASCIIMode:m_txtTagIdInput];
            }
            else
            {
                [m_txtTagIdInput setText:m_strTagInput];
            }
        }
    }
    else
    {
        /* restore previous one */
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagInput];
            [txtMultiTagIdInput setText:asciiTagData];
            [self setTagDataTextColorForASCIIMode:txtMultiTagIdInput];
        }
        else
        {
            [txtMultiTagIdInput setText:m_strTagInput];
        }
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[txtMultiTagIdInput undoManager] removeAllActions];
    }
}


/// To Create the multitag dictionary when add or remove new tags.
- (void)createMultitagDictionary
{
    // Remove tags
    for (int i = 0; i < multiTagDataDictionary.count; i++) {
        NSString *tagIdValue = [multiTagDataDictionary allKeys][i];
        BOOL isRemoved = NO;
        NSMutableArray * tagIdArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray];
        if (![tagIdArray containsObject:tagIdValue]) {
            isRemoved = YES;
        }
        if(isRemoved){
            [multiTagDataDictionary removeObjectForKey:tagIdValue];
            [self->tableView reloadData];
        }
    }
    
    // Add tags
    for (NSString* tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray]) {
        BOOL isExist = NO;
        for (int i = 0; i < multiTagDataDictionary.count; i++) {
            NSString *tagIdValue = [multiTagDataDictionary allKeys][i];
            if ([tagId isEqualToString:tagIdValue]) {
                isExist = YES;
            }
        }
        if(!isExist){
            [multipleTagsReportConfig addItem:tagId aRSSIValueLimit:-(RSSI_VALUE)];
            [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:tagId];
            [self->tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnStartStopPressed:(id)sender
{
    
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        if (inventoryRequested == NO) {
            BOOL locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
            SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
            
            if (NO == locationing_requested)
            {
                if([m_txtTagIdInput.text length] != 0){
                    
                    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
                    {
                        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startTagLocationing:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration]getTagIdLocationing] message:nil];
                        
                    }else{
                        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startTagLocationing:m_txtTagIdInput.text message:nil];
                    }
            
                }else{
                    [self showMessageBox:EMPTY_TAG];
                }
                
            }
            else
            {
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopTagLocationing:nil];
            }
        }else
        {
            [self showWarning:ZT_INVENTORY_ERROR_MESSAGE];
        }
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        });
        
    }
    
    
}

- (void)configureAppearance
{
    /* background colors & corners */
    UIColor * bgnd_ui_color = [UIColor colorWithRed:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_RED/255.0 green:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_GREEN/255.0 blue:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_BLUE/255.0 alpha:1.0];
    [m_indicatorValue setBackgroundColor:bgnd_ui_color];
    
    [[m_indicatorValue layer] setCornerRadius:ZT_UI_LOCATE_TAG_INDICATOR_CORNER_RADIUS];
    [[m_indicatorBackground layer] setCornerRadius:ZT_UI_LOCATE_TAG_INDICATOR_CORNER_RADIUS];
    
    /* configure tag id text field */
    [self configureTagIDField:m_txtTagIdInput];
    [self configureTagIDField:txtMultiTagIdInput];
}


/// To configure tagid textfield.
/// @param textField A control that displays an editable text interface.
- (void)configureTagIDField:(UITextField*)textField
{
    /* configure tag id text field */
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setBorderStyle:UITextBorderStyleNone];
    UILabel * leftView = [[UILabel alloc] initWithFrame:TAG_INPUT_TEXT_LOCATION];
    leftView.backgroundColor = [UIColor clearColor];
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [textField setText:@""];
    [textField setPlaceholder:LOCATE_TAG_PLACE_HOLDER];
}

- (void)updateOperationDataUI
{
    int distance = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getProximityPercent];
    [self setRelativeDistance:distance];
    BOOL multitag_locate_Requested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (multitag_locate_Requested == YES) {
        [btnLocateMultiTag setSelected:YES];
        [btnLocateMultiTag setImage:[UIImage imageNamed:STOP_SCAN_ICON]   forState:UIControlStateSelected];
    }else
    {
        [btnLocateMultiTag setSelected:NO];
    }
}

- (void)setRelativeDistance:(int)distance
{
    
    [m_lblDistanceData setText:[NSString stringWithFormat:@"%d %%", distance]];
    m_lblDistanceData.textColor = THEME_BLUE_COLOR;

    [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObjects:m_IndicatorHeightConstraint, nil]];
    
    m_IndicatorHeightConstraint = [NSLayoutConstraint constraintWithItem:m_indicatorValue attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_indicatorBackground attribute:NSLayoutAttributeHeight multiplier:((float)distance / 100.0) constant:0.0];
    
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:m_IndicatorHeightConstraint, nil]];
    
}

- (void)dismissKeyboard
{
    /* just to hide keyboard */
    [m_txtTagIdInput resignFirstResponder];
}

- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_LOCATIONING != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_txtTagIdInput setUserInteractionEnabled:NO];
        
        [self updateOperationDataUI];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:START_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_txtTagIdInput setUserInteractionEnabled:YES];
        
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        /* update statictics */
        [self updateOperationDataUI];
    }
}

- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_LOCATIONING != operation_type)
    {
        return;
    }
    
    if (YES == in_progress)
    {
        /* start timer */
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_LOCATIONING_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
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


-(BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID{
    
    if (currentOperation == ZT_VC_LOCATE_OPERATION_SINGLE_TAG)
    {
        if (!isRFID){
            return YES;
        }
        __block zt_LocateTagVC *__weak_self = self;
        
        bool requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
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
                
                if (YES == requested)
                {
                    /* operation is already in progress or has been requested (case of periodic start trigger */
                    
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       [__weak_self btnStartStopPressed:nil];
                                   });
                }
            }
        }
        
    }else
    {
        if (!isRFID){
            return YES;
        }
        __block zt_LocateTagVC *__weak_self = self;
        
        if (YES == pressed)
        {
            if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerImmediate])
            {
                if ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count != 0) {
                    if (btnLocateMultiTag.selected != YES) {
                        
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           [__weak_self startMultitagLocate];
                                       });
                        [self enableAndDisableButtons];
                    }
                }
            }
        }
        else
        {
            if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerImmediate])
            {
                if ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count != 0) {
                    if (btnLocateMultiTag.selected == YES) {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                            [__weak_self stopMultitagLocate];
                                       });
                        [self enableAndDisableButtons];
                    }
                }
            }
        }
        
    }
    
    return YES;
}


/* ###################################################################### */
/* ########## Text Field Delegate Protocol implementation ############### */
/* ###################################################################### */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* just to hide keyboard */
    [textField resignFirstResponder];
    return YES;
}

/// Check selected tag pattern and set it into locate tag
-(void)checkTagPatternSelectedFromBarcode{
    BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
    if (barcodeData != NULL){
        [m_txtTagIdInput setText:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
    }
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return ZT_TAG_LOCATE_NUM_OF_SECTION;
}


/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView An object representing the table view requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    if(multiTagLocated){
        return multiTagDataDictionary.count;
    }
    else
    {
        return currentlySelectedTagIdArray.count;
    }
}


/// Asks the delegate for the height to use for a row in a specified location.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path that locates a row in tableView.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ZT_VC_LOCATE_MULTIPLE_TAG_CELL_HEIGHT;
}


/// Returns the table cell at the index path you specify.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath The index path locating the row in the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RFIDTagCellIdentifier = ZT_CELL_ID_MULTITAG_DATA;
    
    MultiTagTableViewCell *multiTagCell = [tableView dequeueReusableCellWithIdentifier:RFIDTagCellIdentifier forIndexPath:indexPath];
    
    if (multiTagCell == nil)
    {
        multiTagCell = [[MultiTagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RFIDTagCellIdentifier];
    }
        multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
        if(multiTagDataDictionary.count!=0 && multiTagDataDictionary.count > indexPath.row && multiTagLocated)
        {
            NSString *keyTagEPC = [multiTagDataDictionary allKeys][indexPath.row];
            NSString *strPercent = multiTagDataDictionary[keyTagEPC];
            [multiTagCell setPrecentage:strPercent];
            int occurrences = 0;
             for(NSString *string in multiTagSeenCountArray)
             {
             occurrences += ([string isEqualToString:keyTagEPC]?1:0);
             }
           [multiTagCell setTagSeenCount:[NSString stringWithFormat:@"%d", occurrences]];
            
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                if (!refereshPressed)
                {
                    NSString * asciiTagData = [HexToAscii stringFromHexString:keyTagEPC];
                    [multiTagCell setTagIdForASCIIMode:asciiTagData];
                }
            }
            else
            {
                [multiTagCell setTagId:keyTagEPC];
            }
        
        }else{
//                NSString* tagIdString = [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] objectAtIndex:indexPath.row];
            NSArray *multiTagIdArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray];
            NSString *tagIdString;
            if (multiTagIdArray.count > indexPath.row) {
                tagIdString = [multiTagIdArray objectAtIndex:indexPath.row];
                // Use the tagIdString as needed
            } else {
                // Handle the case where the array is empty or the index is out of bounds
                NSLog(@"Error: Index is out of bounds or array is empty");
                [self->tableView reloadData];
            }
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                if (!refereshPressed)
                {
                    NSString * asciiTagData = [HexToAscii stringFromHexString:tagIdString];
                    [multiTagCell setTagIdForASCIIMode:asciiTagData];
                }
                
            }
            else
            {
                [multiTagCell setTagId:tagIdString];
            }
                [multiTagCell setTagSeenCount:DEFAULT_TAG_SEEN_COUNT];
                [multiTagCell setPrecentage:DEFAULT_TAG_PRECENTAGE_VALUE];
        }

    return multiTagCell;
}


/// Tells the delegate a row is selected.
/// @param tableView A table view informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultiTagTableViewCell *tag_cell = [tableView cellForRowAtIndexPath:indexPath];
    txtMultiTagIdInput.text = tag_cell.getTagId;
}

/// To add multiple tag.
/// @param sender Button reference.
- (IBAction)btnAddTagPressed:(id)sender
{
    if(txtMultiTagIdInput.text.length > 0)
    {
        BOOL isTheTagIdExistInMutiTagArray = [temporaryTagSelectedArray containsObject:txtMultiTagIdInput.text];
        
        if (![currentlySelectedTagIdArray containsObject:txtMultiTagIdInput.text]) {
            
            if (isTheTagIdExistInMutiTagArray)
            {
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addTagIdIntoMultiTagArray:txtMultiTagIdInput.text];
                m_txtTagIdInput.text = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration]getTagIdLocationing];
                
                multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
                if (multiTagLocated) {
                    [multipleTagsReportConfig addItem:txtMultiTagIdInput.text aRSSIValueLimit:-(RSSI_VALUE)];
                    [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:txtMultiTagIdInput.text];
                }
                [self->tableView reloadData];
                [self showErrorWarning:ZT_MULTITAG_LOCATE_ADDTAG_SUCCESS_MESSAGE];
            }
            else
            {
                [self showErrorWarning:ZT_MULTITAG_LOCATE_ADDTAG_ERROR_MESSAGE];
            }
            
        }else
        {
            [self showErrorWarning:ZT_MULTITAG_LOCATE_ADDTAG_ERROR_MESSAGE];
        }
        
    }
}

/// Create multi tag object list to perform tag locationing
-(void)createMultiTagObjectListToPerformTagLocationing {
    
    multipleTagsReportConfig = [[srfidReportConfig alloc]init];
    for (NSString* tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray])
    {
        [multipleTagsReportConfig addItem:tagId aRSSIValueLimit:-(RSSI_VALUE)];
    }
}

// MARK: - IBAction for multi tag feature
/// Get previously selected tags.
/// @param sender  Button reference.
- (IBAction)btnReloadAllTagsPressed:(id)sender
{
    if(![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:NO];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setCurrentlySelectedTagIdArray:temporaryTagSelectedArray];
        currentlySelectedTagIdArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray];
        if ([currentlySelectedTagIdArray count] != 0) {
            txtMultiTagIdInput.text = [currentlySelectedTagIdArray objectAtIndex:0];
        }
        refereshPressed = YES;
        [self->tableView reloadData];

    }else
    {
        multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
        for (NSString* tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray]) {

            [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:tagId];
        }
        [multiTagSeenCountArray removeAllObjects];
        [self->tableView reloadData];
        
//        if (multiTagLocated)
//        {
//            for (NSString* tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray]) {
//
//                [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:tagId];
//            }
//            [multiTagSeenCountArray removeAllObjects];
//            [self->tableView reloadData];
//        }
    }
}


/// To remove a given tag from multi tag  array.
/// @param sender Button reference.
- (IBAction)btnRemoveTagPressed:(id)sender
{
    BOOL locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    
    BOOL multitag_locate_Requested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (locationing_requested == NO && multitag_locate_Requested == NO) {
        if(txtMultiTagIdInput.text.length > 0)
        {
            if(![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                if ([currentlySelectedTagIdArray containsObject:txtMultiTagIdInput.text] || multiTagDataDictionary[txtMultiTagIdInput.text] != nil) {
                    
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] removeItemInMultiTagIdLocationingArray:txtMultiTagIdInput.text];
                    
                    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
                    
                    if (multiTagLocated)
                    {
                        [multiTagDataDictionary removeObjectForKey:txtMultiTagIdInput.text];
                    }else
                    {
                        [currentlySelectedTagIdArray removeObject:txtMultiTagIdInput.text];
                    }
                    
                    if ([currentlySelectedTagIdArray count] == 0) {
                        txtMultiTagIdInput.text = EMPTY_STRING;
                    }else
                    {
                        txtMultiTagIdInput.text = [currentlySelectedTagIdArray objectAtIndex:0];
                    }
                    
                    [self->tableView reloadData];
                    [self showErrorWarning:ZT_MULTITAG_LOCATE_REMOVETAG_SUCCESS_MESSAGE];
                }else
                {
                    txtMultiTagIdInput.text = EMPTY_STRING;
                    [self showErrorWarning:ZT_MULTITAG_LOCATE_REMOVETAG_ERROR_MESSAGE];
                }
            }else
            {
                [self showErrorWarning:ZT_MULTITAG_LOCATE_REMOVETAG_ERROR_MESSAGE];
            }
        }
    }else
    {
        [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
    }
}

/// Show alert view with given message
/// @param message The message
- (void)showErrorWarning:(NSString *)message
{
   // [zt_AlertView showInfoMessage:self.view withHeader:ZT_MULTITAG_ALERTVIEW_EMPTY_TITLE withDetails:message withDuration:ZT_MULTITAG_ALERTVIEW_WAITING_TIME];
    [self showOnlyMessageWithDurationWithMessage:message time:ZT_MULTITAG_ALERTVIEW_WAITING_TIME];
}

/// To open the .csv file from the files folder.
/// @param sender Button reference.
- (IBAction)btnBrowseFilesPressed:(id)sender
{
    multiTagLocated = NO;
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:NO];
    [self openSharedFiles];
}

/// Start multi tag locationing
/// @param sender  Button reference.
-(IBAction)btnStartMultiTag:(id)sender
{
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        if (inventoryRequested == NO) {
            if ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count != 0) {
                BOOL locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
                __block zt_LocateTagVC *__weak_self = self;
                if (locationing_requested == NO) {
                    if (btnLocateMultiTag.selected==YES) {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                            [__weak_self stopMultitagLocate];
                                       });
                        
                    }else {
                        if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES]) {
                            [self showWarning:@"Command Not Allowed - Unique Tag Report is Enabled"];
                            
                        }else {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                [__weak_self startMultitagLocate];
                                           });
                        }
                       
                    }
                    
                }else
                {
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsMultitagLocationing:NO];
                    [self showWarning:ZT_SINGLETAG_ERROR_MESSAGE];
                }
            }
            
        }else
        {
            [self showWarning:ZT_INVENTORY_ERROR_MESSAGE];
        }
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        });
        
    }
    
}


/// Start multitag locate.
- (void) startMultitagLocate
{
    [multiTagDataDictionary removeAllObjects];
    [btnLocateMultiTag setSelected:YES];
    [btnLocateMultiTag setImage:[UIImage imageNamed:STOP_SCAN_ICON]   forState:UIControlStateSelected];
    theStatusOfMultiTagLocationingStartStop = YES;
    multiTagLocated = YES;
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:YES];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsMultitagLocationing:YES];
    [self enableAndDisableButtons];
    [self performMultiTagApiCall];
}


/// Stop multitag locate.
- (void) stopMultitagLocate
{
    [btnLocateMultiTag setSelected:NO];
    theStatusOfMultiTagLocationingStartStop = NO;
    [self performStopMultiTagApiCall];
    [multiTagSeenCountArray removeAllObjects];
    multipleTagsReportConfig = [[srfidReportConfig alloc]init];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsMultitagLocationing:NO];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:YES];
    [self enableAndDisableButtons];
}

/// Show alert view with given message
/// @param message The message
- (void)showWarning:(NSString *)message
{
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:ZT_ALERTVIEW_WAITING_TIME];
    //[self showOnlyMessageWithDurationWithMessage:message time:(ZT_ALERTVIEW_WAITING_TIME)];
}
/// Enable or disable buttons when multitag locate is running.
- (void)enableAndDisableButtons
{
    if (theStatusOfMultiTagLocationingStartStop) {
        btnAddTag.userInteractionEnabled = NO;
        btnRemoveTag.userInteractionEnabled = NO;
        btnReload.userInteractionEnabled = NO;
        btnBrowseFiles.userInteractionEnabled = NO;
    }else
    {
        btnAddTag.userInteractionEnabled = YES;
        btnRemoveTag.userInteractionEnabled = YES;
        btnReload.userInteractionEnabled = YES;
        btnBrowseFiles.userInteractionEnabled = YES;
    }
}

/// Enable or disable buttons when multitag locate is running.
- (void)enableAndDisableButtonsForInventory
{
    if (inventoryRequested == NO) {
        btnAddTag.userInteractionEnabled = YES;
        btnRemoveTag.userInteractionEnabled = YES;
        btnReload.userInteractionEnabled = YES;
        btnBrowseFiles.userInteractionEnabled = YES;
    }else
    {
        btnAddTag.userInteractionEnabled = NO;
        btnRemoveTag.userInteractionEnabled = NO;
        btnReload.userInteractionEnabled = NO;
        btnBrowseFiles.userInteractionEnabled = NO;
    }
}

// MARK: - Show message
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
                                                      handler:^(UIAlertAction * action) {}];
                       
                       [alert addAction:cancelButton];
                       
                       UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                       [topVC presentViewController:alert animated:YES completion:nil];

                   });
    
}
// MARK: - Perform multi tag
/// Perform multi tag api call
-(void)performMultiTagApiCall
{
    
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:YES];
        for (NSString* tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray]) {

            [multipleTagsReportConfig addItem:tagId aRSSIValueLimit:-(RSSI_VALUE)];
            [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:tagId];
        }

        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startMultiTagLocationing:multipleTagsReportConfig message:nil];

        if(rfid_res) {
            NSLog(@"Result sucess" );
        }
    }else
    {
        [btnLocateMultiTag setSelected:NO];
        theStatusOfMultiTagLocationingStartStop = NO;
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setIsMultitagLocationing:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
           // zt_AlertView *alert = [[zt_AlertView alloc] init];
            //[alert showWarningText:[[UIApplication sharedApplication] keyWindow].rootViewController.view withString:ZT_WARNING_NO_READER];
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        });
    }
}

// MARK: - Stop multi tag
/// Perform stop multi tag api call
-(void)performStopMultiTagApiCall
{
  
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopMultiTagLocationing:nil];

    if(rfid_res) {
        NSLog(@"Result sucess" );
    }
}

// MARK: - Multi tag event
/// Multi tag event
/// @param tagdataObject The tag data object
- (void)onNewMultiTagEvent:(srfidTagData*)tagdataObject
{
    [multiTagSeenCountArray addObject:[tagdataObject getTagId]];
    NSString *epc = [tagdataObject getTagId];
    int precentage = [tagdataObject getProximity];
    NSString *precentageValue  = [NSString stringWithFormat:@"%d%%", precentage];
  
    theStatusOfMultiTagLocationingStartStop = YES;
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] saveIsMultitagLocated:YES];
    if ([[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] containsObject:epc]){
        [multiTagDataDictionary setObject:precentageValue forKey:epc];
    }else{
        [multiTagDataDictionary setObject:DEFAULT_TAG_PRECENTAGE_VALUE forKey:epc];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(multiTagDataDictionary.count >= [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count){
            [self->tableView reloadData];
       }
        
    });
  
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
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        // Condition called when user download the file
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        uint32_t rawInt = 0;
        [fileData getBytes:&rawInt length:sizeof(rawInt)];
        [self clearMultitagArray];
        
        if (fileData != nil && rawInt != 0) {
         
            NSString *taglistSring = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] createMultiTagArrayFromCsvFile:taglistSring];
            for (TaglistDataObject * tagListObject in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvMultiTagArray]) {
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] addTagIdIntoMultiTagArray:[tagListObject getTagId]];
            }
            
            [self createMultiTagObjectListToPerformTagLocationing];
            //Create a temporary tag id array for reload  tags
            [self createTemporaryArrayForReloadTag];
            
            if ([[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] count] > 0) {
                txtMultiTagIdInput.text = [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] objectAtIndex:0];
                currentlySelectedTagIdArray = temporaryTagSelectedArray;
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [self->tableView reloadData];
                });
            }
            
        }else
        {
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
        }
    }else
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
    }
}

/// Tells the delegate that the user canceled the document picker.
/// @param controller The document picker that called this method.
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    NSLog(@"Document Picker Cancelled");
}

/// To clear the multitag based array items.
- (void)clearMultitagArray
{
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] removeAllMultiTagIds];
    [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray] removeAllObjects];
    [multiTagDataDictionary removeAllObjects];
    [m_txtTagIdInput setText:EMPTY_STRING];
    [txtMultiTagIdInput setText:EMPTY_STRING];
    [self->tableView reloadData];
}

/// Color empty spaces in tag data for ASCII mode
/// @param textField color changing textfield
-(void) setTagDataTextColorForASCIIMode:(UITextField *) textField
{
    int tagDataTextIndex = 0;
    if(textField.text != nil && textField.text.length >0 )
    {
        
        while (tagDataTextIndex<(textField.text.length-ZT_TAG_DATA_EMPTY_SPACE.length))
        {
            NSRange tagDataTextRange = NSMakeRange(tagDataTextIndex, ZT_TAG_DATA_EMPTY_SPACE.length);
                
                if ([[textField.text substringWithRange:tagDataTextRange] isEqualToString:ZT_TAG_DATA_EMPTY_SPACE])
                {
                    NSMutableAttributedString *tempAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:textField.attributedText];
                    [tempAttributeText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:tagDataTextRange];
                    textField.attributedText = tempAttributeText;
                    tagDataTextIndex += ZT_TAG_DATA_EMPTY_SPACE.length;
                }
                else
                {
                    tagDataTextIndex++;
                }
        }
    }
}

// MARK: -  Create temporary array

/// Create a temporary tag id array for reload  tags
-(void)createTemporaryArrayForReloadTag {
    
    temporaryTagSelectedArray = [[NSMutableArray alloc]init];
    if ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count > 0)
    {
        temporaryTagSelectedArray = [[NSMutableArray alloc] initWithCapacity:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray].count];
        for (id tagId in [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getMultiTagIdArray])
        {
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                NSString * asciiTagData = [HexToAscii stringFromHexString:tagId];
                [temporaryTagSelectedArray addObject:[asciiTagData mutableCopy]];
            }
            else
            {
                [temporaryTagSelectedArray addObject:[tagId mutableCopy]];
            }
        }
    }
}

@end
