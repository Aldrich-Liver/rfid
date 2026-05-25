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
 *  Description:  TagReportSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TagReportSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"
#import "AlertView.h"

#define ZT_VC_TAG_REPORT_CELL_TAG_PC                  0
#define ZT_VC_TAG_REPORT_CELL_TAG_RSSI                1
//#define ZT_VC_TAG_REPORT_CELL_TAG_PHASE               2
//#define ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX         3
//#define ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT          4

#define ZT_VC_TAG_REPORT_SECTION_IDX                   0
#define ZT_VC_BATCH_MODE_SECTION_IDX                   1
#define ZT_VC_REPORTUNIQUETAGS_SECTION_IDX             2
#define ZT_VC_NXPBRANDID_CHECK_SECTION_IDX             3

#define ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS     2
#define ZT_VC_NXP_CHECKBRANDIDTAGS    3
#define ZT_VC_NXP_BRANDIDTAGS         4
#define ZT_VC_NXP_EPCLENGTHTAGS       5

#define ZT_VC_TAG_REPORT_CELL_BATCHMODE                  0
#define ZT_VC_TAG_REPORT_CELL_USB_BATCHMODE              1

@interface zt_TagReportSettingsVC ()

@end

@implementation zt_TagReportSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_OffscreenSwitchCell = [[zt_SwitchCellView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_OffscreenSwitchCell)
    {
        [m_OffscreenSwitchCell release];
    }
    if( nil != m_cellBatchMode)
    {
        [m_cellBatchMode release];
    }
    if( nil != m_cellUSBBatchMode)
    {
        [m_cellUSBBatchMode release];
    }
    if(m_cellPicker != nil)
    {
        [m_cellPicker release];
    }
    if (nil != brandIdCell)
    {
        [brandIdCell release];
    }
    if (nil != tapGestureRecognizer)
    {
        [tapGestureRecognizer release];
    }
    
    [m_tblTagReportOptions release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblTagReportOptions setDelegate:self];
    [m_tblTagReportOptions setDataSource:self];
    [m_tblTagReportOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblTagReportOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:TAG_REPORT_TITLE];
    
    localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    /* Batch Mode elements */
    
    m_OptionsBatchMode = [[NSArray alloc] initWithObjects:ZT_TAGREPORT_BATCHMODE_DISABLE, ZT_TAGREPORT_BATCHMODE_AUTO,ZT_TAGREPORT_BATCHMODE_ENABLE, nil];
    m_OptionsUSBBatchMode = [[NSArray alloc] initWithObjects:ZT_TAGREPORT_BATCHMODE_DISABLE,ZT_TAGREPORT_BATCHMODE_ENABLE, nil];
    m_SelectedOptionMemoryBank = 0;
    
    m_PickerCellIdx = -1;
    
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    m_cellBatchMode = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellBatchMode setInfoNotice:BATCH_MODE];
    
    m_cellUSBBatchMode = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellUSBBatchMode setInfoNotice:USB_BATCH_MODE];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    /* just to hide keyboard */
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [m_tblTagReportOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    
    /* Default values*/
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:BRANDID_KEY_DEFAULTS] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:SAMPLE_BRANDID forKey:BRANDID_KEY_DEFAULTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:SAMPLE_EPC_LENGTH forKey:EPCLENGTH_KEY_DEFAULTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:BRANDIDCHECK_KEY_DEFAULTS] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BRANDIDCHECK_KEY_DEFAULTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TAGREPORT_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setupConfigurationInitial];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBrandIDChanged:) name:UITextFieldTextDidChangeNotification object:[brandIdCell getTextField]];
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multitag_locate_Requested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (inventoryRequested == NO) {
        self.view.userInteractionEnabled = YES;
        m_tblTagReportOptions.userInteractionEnabled = YES;
    }else
    {
        self.view.userInteractionEnabled = NO;
        m_tblTagReportOptions.userInteractionEnabled = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TAGREPORT_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/// To check the field input is numbers
/// @param address The requires string to be pass from the textfield.
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

/// Notify the keyboard to show on the required time
/// @param aNotification Will give the notification to the system if keyboard should show.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblTagReportOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblTagReportOptions.contentInset = contentInsets;
    m_tblTagReportOptions.scrollIndicatorInsets = contentInsets;
}

/// Notify the keyboard to hide on the required time
/// @param aNotification Will give the notification to the system if keyboard should hide..
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblTagReportOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblTagReportOptions.contentInset = contentInsets;
    m_tblTagReportOptions.scrollIndicatorInsets = contentInsets;
}

/// To dismiss the keyboard while touch on the outside view.
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(NSIndexPath *)indexPath
{
    zt_SledConfiguration *config = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX){
        if (ZT_VC_TAG_REPORT_CELL_TAG_PC == [indexPath row])
        {
            [cell setInfoNotice:TAG_REPORT_PC];
            [cell setOption:config.tagReportPC];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_PC];
        }
        else if (ZT_VC_TAG_REPORT_CELL_TAG_RSSI == [indexPath row])
        {
            [cell setInfoNotice:TAG_REPORT_RSSI];
            [cell setOption:config.tagReportRSSI];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_RSSI];
        }
        
//        if (ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX == [indexPath row])
//        {
//            [cell setInfoNotice:CHANNEL_INDEX];
//            [cell setOption:config.tagReportChannelIdx];
//            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX];
//        }
//        else if (ZT_VC_TAG_REPORT_CELL_TAG_PC == [indexPath row])
//        {
//            [cell setInfoNotice:TAG_REPORT_PC];
//            [cell setOption:config.tagReportPC];
//            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_PC];
//        }
//        else if (ZT_VC_TAG_REPORT_CELL_TAG_PHASE == [indexPath row])
//        {
//            [cell setInfoNotice:TAG_REPORT_PHASE];
//            [cell setOption:config.tagReportPhase];
//            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_PHASE];
//        }
//        else if (ZT_VC_TAG_REPORT_CELL_TAG_RSSI == [indexPath row])
//        {
//            [cell setInfoNotice:TAG_REPORT_RSSI];
//            [cell setOption:config.tagReportRSSI];
//            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_RSSI];
//        }
//        else if (ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT == [indexPath row])
//        {
//            [cell setInfoNotice:TAG_SEEN_COUNT];
//            [cell setOption:config.tagReportSeenCount];
//            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT];
//        }
    }
    if(indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX){
        
        [cell setInfoNotice:REPORT_UNIQUE_TAGS];
        [cell setOption:[config.isUniqueTagsReport boolValue]];
        [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS];
    }
    
    if(indexPath.section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX){
        if ([indexPath row] == 0)
        {
            [cell setInfoNotice:CHECK_BRANDID];
            [cell setOption:[[NSUserDefaults standardUserDefaults]boolForKey:BRANDIDCHECK_KEY_DEFAULTS]];
            [cell setCellTag:ZT_VC_NXP_CHECKBRANDIDTAGS];
        }else
        {
            NSLog(@"nil");
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

/// To configuring the textfield cell where ever we need.
/// @param cell The required cell to be pass here.
/// @param indexPath The current indexpath of the cell.
- (void)configureFieldCell:(zt_LabelInputFieldCellView*)cell forRow:(NSIndexPath *)indexPath
{
    if(indexPath.section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX){
        
        if ([indexPath row] == 1)
        {
            [cell setInfoNotice:BRANDID];
            NSString * title = [[NSUserDefaults standardUserDefaults] objectForKey:BRANDID_KEY_DEFAULTS];
            
            if (title != nil) {
                [cell setData:title];
            }else
            {
                [cell setData:SAMPLE_BRANDID];
            }
            [[cell getTextField] setKeyboardType:UIKeyboardTypeDefault];
            [[cell getTextField] setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
            [cell setCellTag:ZT_VC_NXP_BRANDIDTAGS];
        }else if (indexPath.row == 2)
        {
            [cell setInfoNotice:EPC_LENGTH];
            NSString * length = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];
            if (length != nil) {
                [cell setData:length];
            }else
            {
                [cell setData:SAMPLE_EPC_LENGTH];
            }
            [cell setCellTag:ZT_VC_NXP_EPCLENGTHTAGS];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

- (void)setupConfigurationInitial
{
    /* TBD: fill with real data on view appearance */
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    int sled_mode = [sled currentBatchMode];
    int sled_mode_usb = [sled currentUSBBatchMode];
    
    if (sled_mode_usb == 2)
        sled_mode_usb = sled_mode_usb - 1;
    
    
    [m_cellBatchMode setData:(NSString *)[m_OptionsBatchMode objectAtIndex:sled_mode]];
    [m_cellUSBBatchMode setData:(NSString *)[m_OptionsUSBBatchMode objectAtIndex:sled_mode_usb]];
    [m_tblTagReportOptions reloadData];
}

/// To notify the system when the user changed the input value.
/// @param notification It will notify the system when the values changed.
- (void)handleBrandIDChanged:(NSNotification *)notification
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[brandIdCell getCellData] uppercaseString]];
        
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[brandIdCell getCellData]] == NO)
        {
            [brandIdCell setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [brandIdCell setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[brandIdCell getTextField] undoManager] removeAllActions];
    }
    [_input release];
    
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        zt_SwitchCellView *cell = (zt_SwitchCellView*)option_cell;
        int cellTag = [cell getCellTag];
        BOOL cellValue = [cell getOption];
        switch (cellTag)
        {
//            case ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX:
//                localSled.tagReportChannelIdx = cellValue;
//                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_PC:
                localSled.tagReportPC = cellValue;
                break;
//            case ZT_VC_TAG_REPORT_CELL_TAG_PHASE:
//                localSled.tagReportPhase = cellValue;
//                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_RSSI:
                localSled.tagReportRSSI = cellValue;
                break;
//            case ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT:
//                localSled.tagReportSeenCount = cellValue;
//                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS:
                localSled.isUniqueTagsReport = [NSNumber numberWithBool: cellValue];
                break;
            case ZT_VC_NXP_CHECKBRANDIDTAGS:
                
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    localSled.tagCheckBrandIdx = [NSNumber numberWithBool: cellValue];
                    [[NSUserDefaults standardUserDefaults] setBool:cellValue forKey:BRANDIDCHECK_KEY_DEFAULTS];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self saveBrandIDCheck];
                    break;
                }else
                {
                    break;
                }
        }
    }
    else if(YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        if (ZT_VC_TAG_REPORT_CELL_BATCHMODE == (m_PickerCellIdx - 1))
        {
            int sled_mode = [(zt_PickerCellView*)option_cell getSelectedChoice];
            localSled.currentBatchMode = sled_mode;
            [m_cellBatchMode setData:(NSString *)[m_OptionsBatchMode objectAtIndex:sled_mode]];
        }else if (ZT_VC_TAG_REPORT_CELL_USB_BATCHMODE == (m_PickerCellIdx - 1))
        {
            int sled_mode = [(zt_PickerCellView*)option_cell getSelectedChoice];
            localSled.currentUSBBatchMode = sled_mode;
            [m_cellUSBBatchMode setData:(NSString *)[m_OptionsUSBBatchMode objectAtIndex:sled_mode]];
        }
        
    }else if (YES == [option_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        zt_LabelInputFieldCellView *cell = (zt_LabelInputFieldCellView*)option_cell;
        int cellTag = [cell getCellTag];
        NSString * cellValue = [cell getCellData];
        
        if (cellTag == ZT_VC_NXP_BRANDIDTAGS) {
            if (![cellValue  isEqual: EMPTY_STRING]) {
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    [[NSUserDefaults standardUserDefaults] setObject:cellValue forKey:BRANDID_KEY_DEFAULTS];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else
            {
                NSString * brandID = [[NSUserDefaults standardUserDefaults] objectForKey:BRANDID_KEY_DEFAULTS];
                [cell setData:brandID];
                [self showFieldValidation:NXP_BRANDID_REQUIRED_STRING];
            }
            
        }else
        {
            NSString * oldEPCValue = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];
            [[NSUserDefaults standardUserDefaults] setObject:oldEPCValue forKey:EPCLENGTH_OLD_KEY_DEFAULTS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (![cellValue  isEqual: EMPTY_STRING]) {
                if (inventoryRequested == NO && locationing_requested == NO && multitag_locate_Requested == NO) {
                    [[NSUserDefaults standardUserDefaults] setObject:cellValue forKey:EPCLENGTH_KEY_DEFAULTS];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else
            {
                NSString * epcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];
                [cell setData:epcLength];
                [self showFieldValidation:NXP_EPC_REQUIRED_STRING];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TAGREPORT_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didBeginEditing:(id)option_cell
{
}
/// To handle the field validation messages.
/// @param message The messages getting from the conditions.
- (void)showFieldValidation:(NSString *)message
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NXP_BRANDID_WARNING_MESSAGE
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    //We add buttons to the alert controller by creating UIAlertActions:
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NXP_BRANDID_OK_MESSAGE
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// To save the defaults value locally.
- (void)saveBrandIDCheck
{
    BOOL checkBrandID = [[NSUserDefaults standardUserDefaults] boolForKey:BRANDIDCHECK_KEY_DEFAULTS];
    BOOL checkBrandIDNew = [[NSUserDefaults standardUserDefaults] boolForKey:EXISTING_BRAND_ID_VALUE_CHECK_KEY];
    if (checkBrandID != checkBrandIDNew) {
        [[NSUserDefaults standardUserDefaults] setBool:checkBrandID forKey:EXISTING_BRAND_ID_VALUE_CHECK_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:CHECK_BRAND_ID_VALUE_IS_CHANGED_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return ZT_SLED_TAG_REPORT_PROPERTY_NUMBER;
    if(section == ZT_VC_TAG_REPORT_SECTION_IDX)
        return ZT_SLED_TAG_REPORT_PROPERTY_NUMBER;
    else if (section == ZT_VC_BATCH_MODE_SECTION_IDX)
        return 2 + ((m_PickerCellIdx != -1) ? 1 : 0);
    else if (section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
        return 1 ;
    else if (section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX)
        return 3 ;
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == ZT_VC_TAG_REPORT_SECTION_IDX)
        return TAG_REPORTING_DATAFIELD;
    else if(section == ZT_VC_BATCH_MODE_SECTION_IDX)
        return BATCH_MODE_SECTION;
    else if(section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
        return UNIQUE_TAG_SETTINGS;
    else if(section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX)
        return NXP_BRANDID_CHECK;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    CGFloat height = 0.0;
    
    UITableViewCell *cell = nil;
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX)
    {
        
        [self configureSwitchCell:m_OffscreenSwitchCell forRow:indexPath];
        cell = m_OffscreenSwitchCell;
    }
    else if(indexPath.section == ZT_VC_BATCH_MODE_SECTION_IDX)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_TAG_REPORT_CELL_BATCHMODE] == cell_idx)
        {
            cell = m_cellBatchMode;
        }else
        {
            cell = m_cellUSBBatchMode;
        }
            
    }
    else if(indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
    {
        [self configureSwitchCell:m_OffscreenSwitchCell forRow:indexPath];
        cell = m_OffscreenSwitchCell;
        
    }
    else if(indexPath.section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX)
    {
        if (cell_idx == 0) {
            [self configureSwitchCell:m_OffscreenSwitchCell forRow:indexPath];
            cell = m_OffscreenSwitchCell;
        }else
        {
            [self configureFieldCell:brandIdCell forRow:indexPath];
            cell = brandIdCell;
        }

    }
    if(cell != nil)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1.0; /* for cell separator */
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX)
    {
        zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            // toDo autorelease
            _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
        }
        
        [self configureSwitchCell:_cell forRow:indexPath];
        
        [_cell setNeedsUpdateConstraints];
        [_cell updateConstraintsIfNeeded];
        [_cell darkModeCheck:self.view.traitCollection];
        return _cell;
    }
    else if (indexPath.section == ZT_VC_BATCH_MODE_SECTION_IDX)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_cellPicker;
        }else if ([self recalcCellIndex:ZT_VC_TAG_REPORT_CELL_BATCHMODE] == cell_idx)
        {
            [m_cellBatchMode darkModeCheck:self.view.traitCollection];
            [m_cellBatchMode setCellTag:ZT_VC_TAG_REPORT_CELL_BATCHMODE];
            return m_cellBatchMode;
        }
        else
            [m_cellUSBBatchMode darkModeCheck:self.view.traitCollection];
            [m_cellBatchMode setCellTag:ZT_VC_TAG_REPORT_CELL_USB_BATCHMODE];
            return m_cellUSBBatchMode;
    }
    else if (indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
    {
        zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
        }
        
        [self configureSwitchCell:_cell forRow:indexPath];
        
        [_cell setNeedsUpdateConstraints];
        [_cell updateConstraintsIfNeeded];
        [_cell darkModeCheck:self.view.traitCollection];
        return _cell;
    }
    else if (indexPath.section == ZT_VC_NXPBRANDID_CHECK_SECTION_IDX)
    {
        
        if (indexPath.row == 0) {
            zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
            
            if (_cell == nil)
            {
                _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
            }
            
            [self configureSwitchCell:_cell forRow:indexPath];
            
            [_cell setNeedsUpdateConstraints];
            [_cell updateConstraintsIfNeeded];
            [_cell darkModeCheck:self.view.traitCollection];
            return _cell;
        }else
        {
            brandIdCell = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
            
            [self configureFieldCell:brandIdCell forRow:indexPath];
            [brandIdCell darkModeCheck:self.view.traitCollection];
            [brandIdCell setKeyboardType:UIKeyboardTypeDecimalPad];
            [brandIdCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [brandIdCell setDataFieldWidth:40];
            return brandIdCell;
        }
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
    int row_to_hide = -1;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int main_cell_idx = -1;
    
    /* enable view animation that was disabled during
     switching between segments - see configureForSelectedOperation */
    [UIView setAnimationsEnabled:YES];
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    if (ZT_VC_BATCH_MODE_SECTION_IDX == indexPath.section)
    {
        if (indexPath.row == ZT_VC_TAG_REPORT_CELL_BATCHMODE)
        {
            [m_cellPicker setChoices:m_OptionsBatchMode];
            int sled_mode = localSled.currentBatchMode;
            [m_cellPicker setSelectedChoice:sled_mode];
            [m_cellPicker reloadInputViews];
            main_cell_idx = 0;
        }else
        {
            [m_cellPicker setChoices:m_OptionsUSBBatchMode];
            int sled_mode = localSled.currentUSBBatchMode;
            
            if (sled_mode == 2)
                sled_mode = sled_mode - 1;
            
            [m_cellPicker setSelectedChoice:sled_mode];
            [m_cellPicker reloadInputViews];
            main_cell_idx = 1;
        }
        
    }
    
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        
        if (-1 != row_to_hide)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:ZT_VC_BATCH_MODE_SECTION_IDX]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ((main_cell_idx + 1) != _picker_cell_idx)
        {
            m_PickerCellIdx = main_cell_idx + 1;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:ZT_VC_BATCH_MODE_SECTION_IDX]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:ZT_VC_BATCH_MODE_SECTION_IDX] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_tblTagReportOptions.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [m_tblTagReportOptions reloadData];
}

@end
