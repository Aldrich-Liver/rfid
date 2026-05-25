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
 *  Description:  FilterConfigVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "FilterConfigVC.h"
#import "UIColor+DarkModeExtension.h"
#import "ScannerEngine.h"
#import "BarcodeData.h"
#import "HexToAscii.h"

#define ZT_VC_FILTER_CELL_IDX_TAG_ID              0
#define ZT_VC_FILTER_CELL_IDX_MEMORY              1
#define ZT_VC_FILTER_CELL_IDX_OFFSET              2
#define ZT_VC_FILTER_CELL_IDX_ACTION              3
#define ZT_VC_FILTER_CELL_IDX_TARGET              4
#define ZT_VC_FILTER_CELL_IDX_LENGTH              5
#define ZT_VC_FILTER_CELL_IDX_ENABLED             6

#define ZT_VC_FILTER_OPTION_ID_NOT_AN_OPTION      -1
#define ZT_VC_FILTER_OPTION_ID_TARGET             0
#define ZT_VC_FILTER_OPTION_ID_ACTION             1

#define ZT_VC_FILTER_CELL_TAG_TAG_ID              0
#define ZT_VC_FILTER_CELL_TAG_PASSWORD            1
#define ZT_VC_FILTER_CELL_TAG_OFFSET              2
#define ZT_VC_FILTER_CELL_TAG_LENGTH              3
#define ZT_VC_FILTER_CELL_TAG_ENABLED             4

#define ZT_OFFSET_MIN                               0
#define ZT_OFFSET_MAX                               1024
#define ZT_OFFSET_DEFAULT                           0

@interface zt_FilterConfigVC ()

@end

@implementation zt_FilterConfigVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_NOT_AN_OPTION;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [m_segFilters release];
    [m_tblFilterOptions release];
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != m_cellTagId)
    {
        [m_cellTagId release];
    }
    if (nil != m_cellMemoryBank)
    {
        [m_cellMemoryBank release];
    }
    if (nil != m_cellOffset)
    {
        [m_cellOffset release];
    }
    if (nil != m_cellAction)
    {
        [m_cellAction release];
    }
    if (nil != m_cellTarget)
    {
        [m_cellTarget release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    if (nil != m_cellEnabled)
    {
        [m_cellEnabled release];
    }

    if (nil != m_strTagIdOne)
    {
        [m_strTagIdOne release];
    }
    if (nil != m_strTagIdTwo)
    {
        [m_strTagIdTwo release];
    }
    if (nil != m_strOffsetOne)
    {
        [m_strOffsetOne release];
    }
    if (nil != m_strOffsetTwo)
    {
        [m_strOffsetTwo release];
    }
    if (nil != cellLength)
    {
        [cellLength release];
    }
    if (nil != stringLengthOne)
    {
        [stringLengthOne release];
    }
    if (nil != stringLengthTwo)
    {
        [stringLengthTwo release];
    }
    if (nil != m_switchSelectNonMatchingTags)
    {
        [m_switchSelectNonMatchingTags release];
    }
    if (nil != lbl_NonMatch)
    {
        [lbl_NonMatch release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Setup the DPO button */
    self.navigationItem.rightBarButtonItem = barButtonDpo;
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    m_strTagIdOne = [[NSMutableString alloc] init];
    m_strTagIdTwo = [[NSMutableString alloc] init];
    m_strOffsetOne = [[NSMutableString alloc] init];
    m_strOffsetTwo = [[NSMutableString alloc] init];
    stringLengthOne = [[NSMutableString alloc] init];
    stringLengthTwo = [[NSMutableString alloc] init];
    
    /* configure table view */
    [m_tblFilterOptions registerClass:[zt_TextFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    [m_tblFilterOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [m_tblFilterOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [m_tblFilterOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    [m_tblFilterOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblFilterOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    
    /* configure segments */
    [m_segFilters addTarget:self action:@selector(actionSelectedFilterChanged) forControlEvents:UIControlEventValueChanged];
    m_segFilters.tintColor = THEME_BLUE_COLOR
    
    /* set title */
    [self setTitle:@"Pre Filters"];
    
    hightConstraints.constant = 120;
   
    // Load the saved state from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL switchState = [defaults boolForKey:@"switchState"];
    [m_switchSelectNonMatchingTags setOn:switchState animated:NO];
    if (switchState) {
        [m_cellAction setData:@"INV A OR ASRT SL "];
    }
    
    // Add target to UISegmentedControl
    [m_segFilters addTarget:self
                  action:@selector(actionSelectedSegmentChanged:)
                  forControlEvents:UIControlEventValueChanged];
    
    [m_switchSelectNonMatchingTags addTarget:self
                                   action:@selector(switchChanged:)
                                   forControlEvents:UIControlEventValueChanged];
    
    // Restore the saved state
    [self restoreState];
    
    [self configureAppearance];
    
    [self setupConfigurationInitial];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [m_tblFilterOptions setDelegate:self];
    [m_tblFilterOptions setDataSource:self];
    
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTagIdChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOffsetFieldChange:) name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLengthFieldChange:) name:UITextFieldTextDidChangeNotification object:[cellLength getTextField]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [self initialDataSetup];
    
}

// Non Matching Tag Switch
- (void)switchChanged:(UISwitch *)sender {
    NSString *message = @"By enabling this option, you'll only be able to set the offset and length. Other options will not be interactable.";
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    // Save the state of the switch to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender isOn] forKey:@"switchState"];
    [defaults synchronize];
    
    if ([sender isOn]) {

        m_cellMemoryBank.hidden = YES;
        m_cellAction.hidden = YES;
        m_cellTarget.hidden = YES;
        
        SRFID_SLFLAG sl_flag = SRFID_SLFLAG_DEASSERTED;
        SRFID_SESSION session = SRFID_SESSION_S0;
        SRFID_INVENTORYSTATE inv_state = SRFID_INVENTORYSTATE_A;
        int tag_pop = 30;
        
        srfidSingulationConfig *config = [[[srfidSingulationConfig alloc] init] autorelease];
        [config setSlFlag:sl_flag];
        [config setSession:session];
        [config setInventoryState:inv_state];
        [config setTagPopulation:tag_pop];
        
        [localSled setSingulationOptionsWithConfig:config];
        
         SRFID_RESULT result = SRFID_RESULT_FAILURE;
         NSString *response = @"";
         result = [[zt_RfidAppEngine sharedAppEngine] setSingulationConfigurationFromLocal:&response];
        
         [localSled setPrefilterMemoryBank:[localSled returnEPCMemoryBankForNonMatch]];
         [localSled setPrefilterAction:[localSled returnPreFilterActionforNonMatch]];
         [localSled setPrefilterTarget:[localSled returnPreFilterTargetforNonMatch]];
        
        // Lock segment control and force selection to the first segment
        m_segFilters.selectedSegmentIndex = 0;
        m_segFilters.userInteractionEnabled = NO;
        
        
        // Create the alert
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enable Non Matching Tags"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
         
         // Add an action to dismiss the alert
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
         [alert addAction:okAction];
         
         // Present the alert
         [self presentViewController:alert animated:YES completion:nil];
        
        
        
    } else {
        m_cellMemoryBank.hidden = NO;
        m_cellAction.hidden = NO;
        m_cellTarget.hidden = NO;
        m_segFilters.userInteractionEnabled = YES;
        
        SRFID_SLFLAG sl_flag = SRFID_SLFLAG_ALL;
        SRFID_SESSION session = SRFID_SESSION_S0;
        SRFID_INVENTORYSTATE inv_state = SRFID_INVENTORYSTATE_A;
        int tag_pop = 30;
        
        srfidSingulationConfig *config = [[[srfidSingulationConfig alloc] init] autorelease];
        [config setSlFlag:sl_flag];
        [config setSession:session];
        [config setInventoryState:inv_state];
        [config setTagPopulation:tag_pop];
        
        [localSled setSingulationOptionsWithConfig:config];
        
         SRFID_RESULT result = SRFID_RESULT_FAILURE;
         NSString *response = @"";
         result = [[zt_RfidAppEngine sharedAppEngine] setSingulationConfigurationFromLocal:&response];
    }
    
    [self saveState]; // Save the state when switch changes
}

- (void)saveState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Save the state of the switch
    [defaults setBool:m_switchSelectNonMatchingTags.isOn forKey:@"SwitchState"];
    
    // Save the selected segment index (only if switch is off)
    if (!m_switchSelectNonMatchingTags.isOn) {
        [defaults setInteger:m_segFilters.selectedSegmentIndex forKey:@"SelectedSegmentIndex"];
    } else {
        // Always force "Filter 1" if switch is on
        [defaults setInteger:0 forKey:@"SelectedSegmentIndex"];
    }
    
    [defaults synchronize];
}

- (void)restoreState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Restore the state of the switch
    BOOL switchState = [defaults boolForKey:@"SwitchState"];
    [m_switchSelectNonMatchingTags setOn:switchState];
    
    // Restore the selected segment index
    if (switchState) {
        // If the switch is on, always set to "Filter 1"
        [m_segFilters setSelectedSegmentIndex:0];
        m_segFilters.userInteractionEnabled = NO;
        m_cellMemoryBank.hidden = YES;
        m_cellAction.hidden = YES;
        m_cellTarget.hidden = YES;
    } else {
        NSInteger selectedIndex = [defaults integerForKey:@"SelectedSegmentIndex"];
        [m_segFilters setSelectedSegmentIndex:selectedIndex];
        m_segFilters.userInteractionEnabled = YES;
        m_cellMemoryBank.hidden = NO;
        m_cellAction.hidden = NO;
        m_cellTarget.hidden = NO;
    }
}

- (void)actionSelectedSegmentChanged:(UISegmentedControl *)sender {

    if (m_switchSelectNonMatchingTags.isOn) {
        
        // Optional: Show an alert to inform the user
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Segment Switch Disabled"
                                    message:@"You cannot switch segments while the Non-matching tags switch is ON."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:nil];
                                  [alert addAction:okAction];
                                  [self presentViewController:alert animated:YES completion:nil];
            // Prevent segment change and revert to the first segment
            sender.selectedSegmentIndex = 0;
        
        
        }
    else {
            // Save the selected segment index when changed
            [self saveState];
        }
}


/// To setup the initial data to the pre-filter.
- (void) initialDataSetup
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if ([[localSled prefilterTagPattern]  isEqual: ZT_FRIENDLYNAME_EMPTY_STRING]) {
        NSString * selectedTagData = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdLocationing];
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            NSString * asciiTagData = [HexToAscii stringFromHexString:selectedTagData];

            //[[m_cellTagId getTextField] setText:asciiTagData];
            [self setTagDataTextColorForASCIIMode:[m_cellTagId getTextField]];
        }
        else
        {
            //[[m_cellTagId getTextField] setText:selectedTagData];
            [[m_cellTagId getTextField] becomeFirstResponder];
        }
        [m_tblFilterOptions reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_tblFilterOptions setDelegate:nil];
    [m_tblFilterOptions setDataSource:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[cellLength getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    NSDictionary *userInfo = @{
//        @"tagID_1_Val": tagID_1 ?: @"",
//        @"tagID_2_Val": tagID_2 ?: @""
//    };
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"SaveTagIDsDataNotification" object:nil userInfo:userInfo];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:m_strTagIdOne forKey:@"ChangedTagIDStringOne"];
    [defaults setObject:m_strTagIdTwo forKey:@"ChangedTagIDStringTwo"];
    
    // Save the state when navigating away from the view
    [self saveState];
}

- (void)handleTagIdChanged:(NSNotification *)notif
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int prefilterIdx = localSled.currentPrefilterIndex;
    NSMutableString *string = nil;
    if (prefilterIdx == 0)
    {
        string = [m_strTagIdOne retain];
    }
    else if(prefilterIdx == 1)
    {
        string = [m_strTagIdTwo retain];
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellTagId getCellData] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellTagId getCellData]] == NO)
        {
            [m_cellTagId setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellTagId setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellTagId getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    [string release];
}

- (void)handleOffsetFieldChange:(NSNotification *)notif
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int prefilterIdx = localSled.currentPrefilterIndex;
    NSMutableString *string = nil;
    if (prefilterIdx == 0)
    {
        string = [m_strOffsetOne retain];
    }
    else if(prefilterIdx == 1)
    {
        string = [m_strOffsetTwo retain];
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellOffset getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellOffset getCellData]] == NO)
        {
            [m_cellOffset setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellOffset setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellOffset getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    [string release];
}

/// Handle the changes when length field changed.
/// - Parameter notification: Notifies the changes.
- (void)handleLengthFieldChange:(NSNotification *)notification
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int prefilterIdx = localSled.currentPrefilterIndex;
    NSMutableString *string = nil;
    if (prefilterIdx == 0)
    {
        string = [stringLengthOne retain];
    }
    else if(prefilterIdx == 1)
    {
        string = [stringLengthTwo retain];
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[cellLength getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[cellLength getCellData]] == NO)
        {
            [cellLength setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [cellLength setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[cellLength getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    [string release];
}

- (void)configureAppearance
{
    /* configure segmented control */
    [m_segFilters setTitle:@"Filter 1" forSegmentAtIndex:0];
    [m_segFilters setTitle:@"Filter 2" forSegmentAtIndex:1];
    
    [m_segFilters setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:
      [UIFont systemFontOfSize:ZT_UI_ACCESS_FONT_SZ_MEDIUM] forKey:NSFontAttributeName]
                                   forState:UIControlStateNormal];
    
    /* TBD: adjust font size for header of table view */
}

- (void)createPreconfiguredOptionCells
{
    m_cellTagId = [[zt_TextFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    m_cellMemoryBank = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellOffset = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    cellLength = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_cellEnabled = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    m_cellAction = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellTarget = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellTagId setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellOffset setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellLength setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellEnabled setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [m_cellEnabled setCellTag:ZT_VC_FILTER_CELL_TAG_ENABLED];
    [m_cellEnabled setDelegate:self];
    
    [m_cellTagId setCellTag:ZT_VC_FILTER_CELL_TAG_TAG_ID];
    [m_cellTagId setDelegate:self];

    [m_cellOffset setCellTag:ZT_VC_FILTER_CELL_TAG_OFFSET];
    [m_cellOffset setDelegate:self];
    
    [cellLength setCellTag:ZT_VC_FILTER_CELL_TAG_LENGTH];
    [cellLength setDelegate:self];
    
    [m_cellPicker setDelegate:self];
    
    [m_cellTagId setPlaceholder:@"Tag Pattern"];
    [m_cellMemoryBank setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellMemoryBank setInfoNotice:@"Memory bank"];
    [m_cellOffset setInfoNotice:@"Offset(words)"];
    [m_cellOffset setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
    [m_cellOffset setKeyboardType:UIKeyboardTypeDecimalPad];
    
    [cellLength setInfoNotice:@"Length(bits)"];
    [cellLength setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
    [cellLength setKeyboardType:UIKeyboardTypeDecimalPad];
    
    [m_cellEnabled setInfoNotice:@"Filter"];
    [m_cellAction setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellAction setInfoNotice:@"Action"];
    [m_cellTarget setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellTarget setInfoNotice:@"Target"];
}

- (void)setupConfigurationInitial
{
    [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] setCurrentPrefilterIndex:0];
    [m_segFilters setSelectedSegmentIndex:[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentPrefilterIndex]];
    
    [self configureForSelectedFilter];
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

- (void)actionSelectedFilterChanged
{
    [self saveCurrentFilterConfiguration];
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    [localSled setCurrentPrefilterIndex:(int)[m_segFilters selectedSegmentIndex]];
    
    [self configureForSelectedFilter];
}

- (void)configureForSelectedFilter
{
    NSUserDefaults *SelectedDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *selectedItems = [SelectedDefaults objectForKey:@"SelectedItemsArray"];
    NSLog(@"Selected Items: %@", selectedItems);
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *retrievedStringOne = [defaults stringForKey:@"ChangedTagIDStringOne"];
    NSString *retrievedStringTwo = [defaults stringForKey:@"ChangedTagIDStringTwo"];
    
//    if ([localSled prefilterEnabled])
//    {
//        if (selectedItems.count > 0)
//        {
//            //tagID_1 = selectedItems[0];
//            retrievedStringOne = selectedItems[0];
//            
//            if (selectedItems.count > 1)
//            {
//             tagID_1 = selectedItems[1];
//             tagID_2 = selectedItems[0];
//                retrievedStringOne = selectedItems[1];
//                retrievedStringTwo = selectedItems[0];
//            } else {
//                //tagID_2 = @"";
//                retrievedStringTwo = @"";
//            }
//        }
//        
//    }else
//    {
//        if (selectedItems.count > 0)
//        {
//            //tagID_1 = selectedItems[0];
//            retrievedStringOne = selectedItems[0];
//            
//            if (selectedItems.count > 1)
//            {
//               tagID_1 = selectedItems[1];
//               tagID_2 = selectedItems[0];
//                retrievedStringOne = selectedItems[1];
//                retrievedStringTwo = selectedItems[0];
//            } else {
//                //tagID_2 = @"";
//                retrievedStringTwo = @"";
//            }
//        }
//    }
    int offset = [[localSled prefilterOffset] intValue];
    int length = [[localSled prefilterLength] intValue];
    
    if (localSled.currentPrefilterIndex == 0)
    {
        view_NonMatch.hidden = NO;
        hightConstraints.constant = 120;

        
        if (retrievedStringOne != NULL){
            NSLog(@"retrievedString %@", retrievedStringOne);
            [m_strTagIdOne setString:retrievedStringOne];
        }
        

        
//        if (tagID_1 != NULL) {
//            [m_strTagIdOne setString:tagID_1];
//        }
        
        
        if (offset == ZT_VC_EMPTY_FIELD)
            [m_strOffsetOne setString:ZT_FRIENDLYNAME_EMPTY_STRING];
        else
            [m_strOffsetOne setString:[NSString stringWithFormat:@"%@",[localSled prefilterOffset]]];
        
        if (length == ZT_VC_EMPTY_FIELD)
        {
            [stringLengthOne setString:ZT_FRIENDLYNAME_EMPTY_STRING];
        }else
        {
            [stringLengthOne setString:[NSString stringWithFormat:@"%@",[localSled prefilterLength]]];
        }
        
        if ([[localSled prefilterTagPattern]  isEqual: ZT_FRIENDLYNAME_EMPTY_STRING]) {
            [self initialDataSetup];
//            [m_cellTagId setData:tagID_1];
            [m_cellTagId setData:retrievedStringOne];
        }else
        {
            //[m_cellTagId setData:[[localSled prefilterTagPattern] uppercaseString]];
//            [m_cellTagId setData:tagID_1];
            [m_cellTagId setData:retrievedStringOne];
        }
    }
    else if (localSled.currentPrefilterIndex == 1)
    {
        view_NonMatch.hidden = YES;
        hightConstraints.constant = 79;
        
        if (retrievedStringTwo != NULL){
            NSLog(@"retrievedString %@", retrievedStringTwo);
            [m_strTagIdTwo setString:retrievedStringTwo];
        }
        
//        [m_strTagIdTwo setString:[localSled prefilterTagPattern]];
//        if (tagID_2 != NULL) {
//            [m_strTagIdTwo setString:tagID_2];
//        }
        
        NSLog(@"tagID_2: %@", tagID_2);
//        [m_cellTagId setData:tagID_2];
       
        
        if (offset == ZT_VC_EMPTY_FIELD)
            [m_strOffsetTwo setString:ZT_FRIENDLYNAME_EMPTY_STRING];
        else
            [m_strOffsetTwo setString:[NSString stringWithFormat:@"%@",[localSled prefilterOffset]]];
        
        if (length == ZT_VC_EMPTY_FIELD)
        {
            [stringLengthTwo setString:ZT_FRIENDLYNAME_EMPTY_STRING];
        }else
        {
            [stringLengthTwo setString:[NSString stringWithFormat:@"%@",[localSled prefilterLength]]];
        }
        
        if ([[localSled prefilterTagPattern]  isEqual: ZT_FRIENDLYNAME_EMPTY_STRING]) {
            [self initialDataSetup];
//            [m_cellTagId setData:tagID_2];
            [m_cellTagId setData:retrievedStringTwo];
        }else
        {
            //[m_cellTagId setData:[[localSled prefilterTagPattern] uppercaseString]];
//            [m_cellTagId setData:tagID_2];
            [m_cellTagId setData:retrievedStringTwo];
        }
    }
    

    if (offset == ZT_VC_EMPTY_FIELD)
        [m_cellOffset setData:ZT_FRIENDLYNAME_EMPTY_STRING];
    else
        [m_cellOffset setData:[NSString stringWithFormat:@"%@", [localSled prefilterOffset]]];
    
    if (length == ZT_VC_EMPTY_FIELD || length == 0)
        [cellLength setData:ZT_PREFILTER_LENGTH_INTIAL_VALUE];
    else
        [cellLength setData:[NSString stringWithFormat:@"%@", [localSled prefilterLength]]];
    
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    [local setPrefilterLength:[NSNumber numberWithInt:[[cellLength getCellData] intValue]]];
    [m_cellEnabled setInfoNotice:[NSString stringWithFormat:@"Enable Filter %d", ([localSled currentPrefilterIndex] + 1)]];
    
    [m_cellEnabled setOption:[localSled prefilterEnabled]];
    
    [m_cellMemoryBank setData:[localSled prefilterMemoryBank]];
    
    [m_cellAction setData:[localSled prefilterAction]];
    
    [m_cellTarget setData:[localSled prefilterTagert]];
    
    /* hide picker cells */
    m_PickerCellIdx = -1;
    [m_tblFilterOptions reloadData];
}

- (void)saveCurrentFilterConfiguration
{
    /*
        TBD: filter configuration shall be saved at app-level:
            - currently config is saved only to local variables from ui elements
        when switching between filters via segmented control
            - future solution: save config from ui to local variables when vc is popped
        from navigation stack and save local variables at app-level
        (singleton engine, settings, etc)
     */
    
    /* memory bank, action and target option ids (indexes) are saved directly on changes ->
     refer IOptionCellDelegate and ISelectionTableVCDelegate protocols implementations
     */
    
    /* tag id, password, offset and enabled are saved directly on changes ->
     refer IOptionCellDelegate protocols implementations */
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblFilterOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblFilterOptions.contentInset = contentInsets;
    m_tblFilterOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblFilterOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblFilterOptions.contentInset = contentInsets;
    m_tblFilterOptions.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (NSNumber *)findIndexNumberForString:(NSString *)searchString inArray:(NSArray *)targetArray {
    NSUInteger index = [targetArray indexOfObject:searchString];

    if (index == NSNotFound) {
        return @(0); // Return an NSNumber representing 0 if the string is not found
    }
    
    // Otherwise, return an NSNumber representing the found index
    return @(index);
}

/* ###################################################################### */
/* ########## ISelectionTableVCDelegate Protocol implementation ######### */
/* ###################################################################### */
- (void)didChangeSelectedOption:(NSString *)value
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    NSArray *targetArray = @[@"SESSION S0", @"SESSION S1", @"SESSION S2", @"SESSION S3"];
    if (ZT_VC_FILTER_OPTION_ID_ACTION == m_PresentedOptionId)
    {
        [localSled setPrefilterAction:value];
        [m_cellAction setData:value];
        
    }
    else if (ZT_VC_FILTER_OPTION_ID_TARGET == m_PresentedOptionId)
    {
        [localSled setPrefilterTarget:value];
        [m_cellTarget setData:value];
    }
    
    targetIndex = [self findIndexNumberForString:value inArray:targetArray];
    NSLog(@"Target Index: %@", targetIndex);
    
    [[NSUserDefaults standardUserDefaults] setObject:targetIndex forKey:@"SavedSessionIndex"];
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int option = [(zt_PickerCellView*)option_cell getSelectedChoice];
        NSString *value = [[local.mapperBankPrefilters getStringArray] objectAtIndex:option];
        
        [local setPrefilterMemoryBank:value];
        
        [m_cellMemoryBank setData:local.prefilterMemoryBank];
    }
    else if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        BOOL cell_value = [(zt_SwitchCellView*)option_cell getOption];
        [local setPrefilterEnabled:cell_value];
    }
    else  if (YES == [option_cell isKindOfClass:[zt_TextFieldCellView class]])
    {
        zt_TextFieldCellView *_cell = (zt_TextFieldCellView*)option_cell;
        if (ZT_VC_FILTER_CELL_TAG_TAG_ID == [_cell getCellTag])
        {
            [local setPrefilterTagPattern:[_cell getCellData]];
        }
    }
    else if (YES == [option_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        zt_LabelInputFieldCellView *_cell = (zt_LabelInputFieldCellView*)option_cell;
        if (ZT_VC_FILTER_CELL_TAG_OFFSET == [_cell getCellTag])
        {
            if ([@"" length] == [[_cell getCellData] length])
                [local setPrefilterOffset:[NSNumber numberWithInt:ZT_VC_EMPTY_FIELD]];
            else
                [local setPrefilterOffset:[NSNumber numberWithInt:[[_cell getCellData] intValue]]];
        }else if(ZT_VC_FILTER_CELL_TAG_LENGTH == [_cell getCellTag])
        {
            if ([@"" length] == [[_cell getCellData] length])
                [local setPrefilterLength:[NSNumber numberWithInt:ZT_VC_EMPTY_FIELD]];
            else
                [local setPrefilterLength:[NSNumber numberWithInt:[[_cell getCellData] intValue]]];
        }
    }
}
- (void)didBeginEditing:(id)option_cell
{
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
    return 7 + ((m_PickerCellIdx != -1) ? 1 : 0);
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
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TAG_ID] == cell_idx)
    {
        /// Set selected barcode value
        BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
        if (barcodeData != NULL){
            [m_cellTagId setBarcodeValue:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
        }
        cell = m_cellTagId;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        cell = m_cellMemoryBank;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_OFFSET] == cell_idx)
    {
        cell = m_cellOffset;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        cell = m_cellAction;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        cell = m_cellTarget;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_LENGTH] == cell_idx)
    {
        cell = cellLength;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ENABLED] == cell_idx)
    {
        cell = m_cellEnabled;
    }

    if (nil != cell)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        //cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(m_tblFilterOptions.bounds), CGRectGetHeight(cell.bounds));
        
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
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TAG_ID] == cell_idx)
    {
        /// Set selected barcode value
        BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
        if (barcodeData != NULL){
            [m_cellTagId setBarcodeValue:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
        }
        [m_cellTagId darkModeCheck:self.view.traitCollection];
        return m_cellTagId;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        [m_cellMemoryBank darkModeCheck:self.view.traitCollection];
        return m_cellMemoryBank;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_OFFSET] == cell_idx)
    {
        [m_cellOffset darkModeCheck:self.view.traitCollection];
        return m_cellOffset;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        [m_cellAction darkModeCheck:self.view.traitCollection];
        return m_cellAction;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        [m_cellTarget darkModeCheck:self.view.traitCollection];
        return m_cellTarget;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_LENGTH] == cell_idx)
    {
        [cellLength darkModeCheck:self.view.traitCollection];
        return cellLength;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ENABLED] == cell_idx)
    {
        [m_cellEnabled darkModeCheck:self.view.traitCollection];
        return m_cellEnabled;
    }

    return nil;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        NSMutableArray *memory_banks = [local.mapperBankPrefilters getStringArray];
        [m_cellPicker setChoices:memory_banks];
        
        [m_cellPicker setSelectedChoice:[[zt_SledConfiguration getKeyFromDictionary:[local.mapperBankPrefilters getDictionary] withValue:[local prefilterMemoryBank]] intValue] - 1];
        
        main_cell_idx = ZT_VC_FILTER_CELL_IDX_MEMORY;
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
    
    /* check whether additional table view with list of options shall be presented */
    BOOL _need_present_options = NO;
    
    if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_TARGET;
        _need_present_options = YES;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_ACTION;
        _need_present_options = YES;
    }
    
    if (YES == _need_present_options)
    {
        zt_SelectionTableVC *vc = (zt_SelectionTableVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SELECTION_TABLE_VC"];
        [vc setDelegate:self];
        
        int selectedOption = 0;
        
        if (ZT_VC_FILTER_OPTION_ID_ACTION == m_PresentedOptionId)
        {
            [vc setCaption:@"Action"];
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            int dictionarySize =(int)[[local.mapperAction getDictionary] count];
            for (int i=0; i < dictionarySize; i++) {
                [actions addObject:[[local.mapperAction getDictionary] objectForKey:[NSNumber numberWithInt:i]]];
            }
            
            
            selectedOption = [[zt_SledConfiguration getKeyFromDictionary:[local.mapperAction getDictionary] withValue:[local prefilterAction]] intValue];

            [vc setOptionsWithStringArray:actions];
        }
        else if (ZT_VC_FILTER_OPTION_ID_TARGET == m_PresentedOptionId)
        {
            [vc setCaption:@"Target"];
            
            NSMutableArray *targets = [local.mapperTargetOption getStringArray];
            
            selectedOption = [[zt_SledConfiguration getKeyFromDictionary:[local.mapperTargetOption getDictionary] withValue:[local prefilterTagert]] intValue];
            
            [vc setOptionsWithStringArray:targets];
        }
        [vc setSelectedOptionInt:selectedOption];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    //[self.view endEditing:YES];
}

/* ###################################################################### */
/* ########## Text View Delegate Protocol implementation ################ */
/* ###################################################################### */
- (void)textViewDidChange:(UITextView *)textView
{
    /* update text view and cell height dynamically */
    [m_tblFilterOptions beginUpdates];
    [m_tblFilterOptions endUpdates];
    /* TBD: scroll to cursor position ??? */
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    /* scroll to cursor position */
    CGRect cursor_rect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursor_rect = [m_tblFilterOptions convertRect:cursor_rect fromView:textView];
    cursor_rect.size.height += 8;
    [m_tblFilterOptions scrollRectToVisible:cursor_rect animated:YES];
}



#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
   self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [m_tblFilterOptions reloadData];
}
/// Color empty spaces in tag data for ASCII mode
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
@end
