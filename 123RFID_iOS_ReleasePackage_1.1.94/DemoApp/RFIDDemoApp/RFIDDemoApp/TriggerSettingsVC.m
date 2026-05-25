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
 *  Description:  TriggerSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TriggerSettingsVC.h"
#import "UIColor+DarkModeExtension.h"

#define ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER             0
#define ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER              1

#define ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION         0
#define ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD         1

#define ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION          0
#define ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1         1
#define ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_2         2

#define ZT_VC_TRIGGER_CELL_TAG_START_TRIGGER_PERIOD         0
#define ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_1         1
#define ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_2         2

@interface zt_TriggerSettingsVC ()

@end

/* TBD: save & apply (?) configuration during hide */

@implementation zt_TriggerSettingsVC


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        m_PickerCellSectionIdx = -1;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [m_tblTriggerOptions release];
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != m_cellStartTriggerOption)
    {
        [m_cellStartTriggerOption release];
    }
    if (nil != m_cellStartTriggerPeriod)
    {
        [m_cellStartTriggerPeriod release];
    }
    if (nil != m_cellStopTriggerOption)
    {
        [m_cellStopTriggerOption release];
    }
    if (nil != m_cellStopTriggerParam1)
    {
        [m_cellStopTriggerParam1 release];
    }
    
    if (nil != m_cellStartTriggerType)
    {
        [m_cellStartTriggerType release];
    }
    
    if (nil != m_cellStopTriggerParam2)
    {
        [m_cellStopTriggerParam2 release];
    }
    
    if (nil != m_cellStopTriggerType)
    {
        [m_cellStopTriggerType release];
    }
    
    if (nil != m_strStartDelay)
    {
        [m_strStartDelay release];
    }
    if (nil != m_strStopTag)
    {
        [m_strStopTag release];
    }
    if (nil != m_strStopInventory)
    {
        [m_strStopInventory release];
    }
    if (nil != m_strStopTimeout)
    {
        [m_strStopTimeout release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    m_strStartDelay = [[NSMutableString alloc] init];
    m_strStopTag = [[NSMutableString alloc] init];
    m_strStopInventory = [[NSMutableString alloc] init];
    m_strStopTimeout = [[NSMutableString alloc] init];
    
    /* configure table view */
    
    [m_tblTriggerOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [m_tblTriggerOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [m_tblTriggerOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblTriggerOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Start\\Stop Triggers"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblTriggerOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblTriggerOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblTriggerOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblTriggerOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [m_tblTriggerOptions setDelegate:self];
    [m_tblTriggerOptions setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartDelayFieldChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellStartTriggerPeriod getTextField] ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopParam1FieldChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellStopTriggerParam1 getTextField] ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopParam2FieldChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellStopTriggerParam2 getTextField]];
    
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
        m_tblTriggerOptions.userInteractionEnabled = YES;
    }else
    {
        self.view.userInteractionEnabled = NO;
        m_tblTriggerOptions.userInteractionEnabled = NO;
    }
    [self updateStopTriggerParamCell];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_tblTriggerOptions setDelegate:nil];
    [m_tblTriggerOptions setDataSource:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellStartTriggerPeriod getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellStopTriggerParam1 getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellStopTriggerParam2 getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleStartDelayFieldChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellStartTriggerPeriod getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [m_strStartDelay setString:_input];
        if ([m_strStartDelay isEqualToString:[m_cellStartTriggerPeriod getCellData]] == NO)
        {
            [m_cellStartTriggerPeriod setData:m_strStartDelay];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellStartTriggerPeriod setData:m_strStartDelay];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellStartTriggerPeriod getTextField] undoManager] removeAllActions];
    }
    
    [_input release];

}
- (void)handleStopParam1FieldChanged:(NSNotification *)notif
{
    NSMutableString *string = nil;
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int selected = sled.currentStopTriggerOption;
    
    if (ZT_SLED_CFG_TRIGGER_STOP_DURATION == selected)
    {
        string = m_strStopTimeout;
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == selected)
    {
        string = m_strStopInventory;
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == selected)
    {
        string = m_strStopTag;
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellStopTriggerParam1 getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellStopTriggerParam1 getCellData]] == NO)
        {
            [m_cellStopTriggerParam1 setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellStopTriggerParam1 setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellStopTriggerParam1 getTextField] undoManager] removeAllActions];
    }
    
    [_input release];

}

- (void)handleStopParam2FieldChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellStopTriggerParam2 getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [m_strStopTimeout setString:_input];
        if ([m_strStopTimeout isEqualToString:[m_cellStopTriggerParam2 getCellData]] == NO)
        {
            [m_cellStopTriggerParam2 setData:m_strStopTimeout];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellStopTriggerParam2 setData:m_strStopTimeout];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellStopTriggerParam2 getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
}

- (void)createPreconfiguredOptionCells
{
    m_cellStartTriggerPeriod = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellStartTriggerType = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellStartTriggerOption = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];

    m_cellStopTriggerParam1 = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellStopTriggerParam2 = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellStopTriggerOption= [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellStopTriggerType = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellStartTriggerPeriod setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellStopTriggerParam1 setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellStopTriggerParam2 setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    [m_cellStartTriggerPeriod setCellTag:ZT_VC_TRIGGER_CELL_TAG_START_TRIGGER_PERIOD];
    [m_cellStartTriggerPeriod setDelegate:self];
    
    [m_cellStopTriggerParam1 setCellTag:ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_1];
    [m_cellStopTriggerParam1 setDelegate:self];
    
    [m_cellStopTriggerParam2 setCellTag:ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_2];
    [m_cellStopTriggerParam2 setDelegate:self];
    
    [m_cellPicker setDelegate:self];
    
    [m_cellStartTriggerPeriod setDataFieldWidth:40];
    [m_cellStopTriggerParam1 setDataFieldWidth:40];
    [m_cellStopTriggerParam2 setDataFieldWidth:40];
    
    [m_cellStartTriggerPeriod setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellStopTriggerParam1 setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellStopTriggerParam2 setKeyboardType:UIKeyboardTypeDecimalPad];
    
    [m_cellStartTriggerOption setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellStopTriggerOption setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellStartTriggerType setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellStopTriggerType setStyle:ZT_CELL_INFO_STYLE_BLUE];
    
    [m_cellStartTriggerOption setInfoNotice:@"Start Trigger"];
    [m_cellStartTriggerPeriod setInfoNotice:@"Periodic"];
    [m_cellStartTriggerType setInfoNotice:@"Trigger Type"];
    
    [m_cellStopTriggerOption setInfoNotice:@"Stop Trigger"];
    [m_cellStopTriggerParam1 setInfoNotice:@""];
    [m_cellStopTriggerParam2 setInfoNotice:@""];
    [m_cellStopTriggerType setInfoNotice:@"Trigger Type"];
}

- (void)setupConfigurationInitial
{
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    NSArray *starts = [sled triggerStartOptions];
    int start_selected = [sled currentStartTriggerOption];
    [m_cellStartTriggerOption setData:(NSString*)[starts objectAtIndex:start_selected]];
    
    NSArray *stops = [sled triggerStopOptions];
    int stop_selected = [sled currentStopTriggerOption];
    [m_cellStopTriggerOption setData:(NSString*)[stops objectAtIndex:stop_selected]];
    
    [m_cellStartTriggerType setData:[sled.mapperTriggerType getStringByEnum:[sled currentStartTriggerType]]];
    [m_cellStopTriggerType setData:[sled.mapperTriggerType getStringByEnum:[sled currentStopTriggerType]]];
    
    long long startDelay = [sled currentStartDelay];
    [m_cellStartTriggerPeriod setData:[NSString stringWithFormat:@"%lld", startDelay]];
    
    long long option = 0;
    
    if (ZT_SLED_CFG_TRIGGER_STOP_DURATION == stop_selected)
    {
        [m_cellStopTriggerParam1 setInfoNotice:@"Duration"];
        option = [sled currentStopTimeout];
        [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == stop_selected)
    {
        // toDo implement in sled
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam1 setInfoNotice:@"No. of Attempts"];
        option = [sled currentStopInventoryCount];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];
        [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == stop_selected)
    {
        [m_cellStopTriggerParam1 setInfoNotice:@"Tag Observation"];
        option = [sled currentStopTagCount];
        [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];
        
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stop_selected)
    {
        SRFID_TRIGGERTYPE selectedType = [sled currentStopTriggerType];
        [m_cellStopTriggerType setData:[sled.mapperTriggerType getStringByEnum:selectedType]];
        
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];
    }
    else
    {
        [m_cellStopTriggerParam1 setInfoNotice:@""];
        [m_cellStopTriggerParam1 setData:@""];
    }
    
    [m_strStartDelay setString:[NSString stringWithFormat:@"%lld", sled.currentStartDelay ]];
    [m_strStopTag setString:[NSString stringWithFormat:@"%lld", sled.currentStopTagCount ]];
    [m_strStopInventory setString:[NSString stringWithFormat:@"%lld", sled.currentStopInventoryCount ]];
    [m_strStopTimeout setString:[NSString stringWithFormat:@"%lld", sled.currentStopTimeout ]];
    }

- (void)updateStopTriggerParamCell
{
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    NSArray *starts = [sled triggerStartOptions];
    int start_selected = [sled currentStartTriggerOption];
    [m_cellStartTriggerOption setData:(NSString*)[starts objectAtIndex:start_selected]];
    
    NSArray *stops = [sled triggerStopOptions];
    int stop_selected = [sled currentStopTriggerOption];
    [m_cellStopTriggerOption setData:(NSString*)[stops objectAtIndex:stop_selected]];
    
    [m_cellStartTriggerType setData:[sled.mapperTriggerType getStringByEnum:[sled currentStartTriggerType]]];
    [m_cellStopTriggerType setData:[sled.mapperTriggerType getStringByEnum:[sled currentStopTriggerType]]];
    
    long long startDelay = [sled currentStartDelay];
    if (ZT_VC_EMPTY_FIELD == startDelay)
        [m_cellStartTriggerPeriod setData:@""];
    else
        [m_cellStartTriggerPeriod setData:[NSString stringWithFormat:@"%lld", startDelay]];
    
    long long option = 0;
    
    if (ZT_SLED_CFG_TRIGGER_STOP_DURATION == stop_selected)
    {
        [m_cellStopTriggerParam1 setInfoNotice:@"Duration"];
        option = [sled currentStopTimeout];
        
        if (ZT_VC_EMPTY_FIELD == option)
            [m_cellStopTriggerParam1 setData:@""];
        else
            [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == stop_selected)
    {
        // toDo implement in sled
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam1 setInfoNotice:@"No. of Attempts"];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        option = [sled currentStopInventoryCount];
        
        if (ZT_VC_EMPTY_FIELD == option)
            [m_cellStopTriggerParam1 setData:@""];
        else
            [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];

        if (ZT_VC_EMPTY_FIELD == timeout)
            [m_cellStopTriggerParam2 setData:@""];
        else
            [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == stop_selected)
    {
        [m_cellStopTriggerParam1 setInfoNotice:@"Tag Observation"];
        option = [sled currentStopTagCount];
        if (ZT_VC_EMPTY_FIELD == option)
            [m_cellStopTriggerParam1 setData:@""];
        else
            [m_cellStopTriggerParam1 setData:[NSString stringWithFormat:@"%lld", option]];
        
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        if (ZT_VC_EMPTY_FIELD == timeout)
            [m_cellStopTriggerParam2 setData:@""];
        else
            [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];

    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stop_selected)
    {
        [m_cellStopTriggerType setData:[sled.mapperTriggerType getStringByEnum:[sled currentStopTriggerType]]];
        
        long long timeout = [sled currentStopTimeout];
        [m_cellStopTriggerParam2 setInfoNotice:@"Timeout"];
        if (ZT_VC_EMPTY_FIELD == timeout)
            [m_cellStopTriggerParam2 setData:@""];
         else
            [m_cellStopTriggerParam2 setData:[NSString stringWithFormat:@"%lld", timeout]];
;
    }
    else
    {
        [m_cellStopTriggerParam1 setInfoNotice:@""];
        [m_cellStopTriggerParam1 setData:@""];
    }

}

- (int)recalcCellIndex:(int)cell_index forSection:(int)section_index;
{
    if (section_index != m_PickerCellSectionIdx)
    {
        return cell_index;
    }
    else
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
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblTriggerOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblTriggerOptions.contentInset = contentInsets;
    m_tblTriggerOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblTriggerOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblTriggerOptions.contentInset = contentInsets;
    m_tblTriggerOptions.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    // use temporary sled config for settings keeping
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)option_cell getSelectedChoice];
        if (ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER == m_PickerCellSectionIdx)
        {
            if (ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION == (m_PickerCellIdx - 1))
            {
                NSArray *starts = [sled triggerStartOptions];
                if (sled.currentStartTriggerOption == choice) {
                    return;
                }
                else if(choice == ZT_SLED_CFG_TRIGGER_START_PERIODIC)
                {
                    sled.currentStartDelay = ZT_START_TRIGGER_PERIODIC_DEFAULT;
                }
                else if(choice == ZT_SLED_CFG_TRIGGER_START_HANDHELD)
                {
                    [sled setCurrentStartTriggerType:ZT_START_TRIGGER_HANDHELD_DEFAULT];
                }
                
                [sled setCurrentStartTriggerOption:choice];
                
                int startSelected = [sled currentStartTriggerOption];
                [m_cellStartTriggerOption setData:(NSString*)[starts objectAtIndex:startSelected]];
            }
            
            if (ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD == (m_PickerCellIdx - 1)) {
                [sled setCurrentStartTriggerType:choice];
                
                NSArray *types = [sled.mapperTriggerType getStringArray];
                int typeSelected = [sled currentStartTriggerType];
                [m_cellStartTriggerType setData:(NSString *)[types objectAtIndex:typeSelected]];
            }
        }
        else if (ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER == m_PickerCellSectionIdx)
        {
            if (ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION == (m_PickerCellIdx - 1))
            {
                if (sled.currentStopTriggerOption == choice) {
                    return;
                }
                // check choices
                else if(choice == ZT_SLED_CFG_TRIGGER_STOP_DURATION)
                {
                    sled.currentStopTimeout = ZT_STOP_TRIGGER_DURATION_DEFAULT;
                }
                else if(choice == ZT_SLED_CFG_TRIGGER_STOP_HANDHELD)
                {
                    [sled setCurrentStopTriggerType:ZT_STOP_TRIGGER_HADHELD_DEFAULT];
                    sled.currentStopTimeout = ZT_STOP_TRIGGER_TIMEOUT_DEFAULT;
                }
                else if(choice == ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS)
                {
                    sled.currentStopInventoryCount = ZT_STOP_TRIGGER_ATTEMPTS_DEFAULT;
                    sled.currentStopTimeout = ZT_STOP_TRIGGER_TIMEOUT_DEFAULT;
                }
                else if(choice == ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION)
                {
                    sled.currentStopTagCount = ZT_STOP_TRIGGER_TAG_OBSERVATION_DEFAULT;
                    sled.currentStopTimeout = ZT_STOP_TRIGGER_TIMEOUT_DEFAULT;
                }
                
                [sled setCurrentStopTriggerOption:choice];
                
                NSArray *stops = [sled triggerStopOptions];
                int stop_selected = [sled currentStopTriggerOption];
                [m_cellStopTriggerOption setData:(NSString*)[stops objectAtIndex:stop_selected]];
            }
            
            if (ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1 == (m_PickerCellIdx - 1)) {
                if( ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == [sled currentStopTriggerOption])
                {
                    [sled setCurrentStopTriggerType:[sled.mapperTriggerType getEnumByIndx:choice]];
                    
                    SRFID_TRIGGERTYPE  typeSelected = [sled currentStopTriggerType];
                    [m_cellStopTriggerType setData:[sled.mapperTriggerType getStringByEnum:typeSelected]];
                }
            }
        }
        
        [self updateStopTriggerParamCell];
        [m_tblTriggerOptions reloadData];
    }
    else if (YES == [option_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        zt_LabelInputFieldCellView *_cell = (zt_LabelInputFieldCellView*)option_cell;
        long long data = [[_cell getCellData] longLongValue];
        BOOL isEmpty = [self isEmptyField:[_cell getCellData]];
        
        if (ZT_VC_TRIGGER_CELL_TAG_START_TRIGGER_PERIOD == [_cell getCellTag])
        {
            if (isEmpty)
            {
                sled.currentStartDelay = ZT_VC_EMPTY_FIELD;
            }
            else
            {
                sled.currentStartDelay = data;
            }
        }
        else if (ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_1 == [_cell getCellTag])
        {
            int stopSelected = [sled currentStopTriggerOption];
            
            switch (stopSelected)
            {
                case ZT_SLED_CFG_TRIGGER_STOP_DURATION:
                    if (isEmpty)
                    {
                        sled.currentStopTimeout = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopTimeout = data;
                    }
                    break;
                case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
                    if (isEmpty)
                    {
                        sled.currentStopInventoryCount = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopInventoryCount = data;
                    }
                    break;
                case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
                    if (isEmpty)
                    {
                        sled.currentStopTagCount = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopTagCount = data;
                    }
                    break;
            }
        }
        else if (ZT_VC_TRIGGER_CELL_TAG_STOP_TRIGGER_PARAM_2 == [_cell getCellTag])
        {
            int stopSelected = [sled currentStopTriggerOption];
            
            switch (stopSelected)
            {
                case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
                    if (isEmpty)
                    {
                        sled.currentStopTimeout = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopTimeout = data;
                    }
                    break;
                case ZT_SLED_CFG_TRIGGER_STOP_HANDHELD:
                    if (isEmpty)
                    {
                        sled.currentStopTimeout = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopTimeout = data;
                    }
                    break;
                case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
                    if (isEmpty)
                    {
                        sled.currentStopTimeout = ZT_VC_EMPTY_FIELD;
                    }
                    else
                    {
                        sled.currentStopTimeout = data;
                    }
                    break;

            }
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER:
            return @"Start";
        case ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER:
            return @"Stop";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    int count = 0;
    int stop_selected = [localSled currentStopTriggerOption];
    int start_selected = [localSled currentStartTriggerOption];
    switch (section)
    {
        case ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER:
            count = 1 + ((start_selected == ZT_SLED_CFG_TRIGGER_START_PERIODIC) || (start_selected == ZT_SLED_CFG_TRIGGER_START_HANDHELD)?  1 : 0);
            break;
        case ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER:
            count = 1;
            
            if (ZT_SLED_CFG_TRIGGER_STOP_DURATION == stop_selected)
            {
                count = 2;
            }
            else if ((ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stop_selected) ||
                     (ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == stop_selected) ||
                     (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == stop_selected)
                     )
            {
                count = 3;
            }
            break;
    }
    
    if (section == m_PickerCellSectionIdx)
    {
        count += ((m_PickerCellIdx != -1) ? 1 : 0);
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    int section_idx = (int)[indexPath section];
    
    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    int stop_selected = [localSled currentStopTriggerOption];
    int start_selected = [localSled currentStartTriggerOption];
    
    if (ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx)
        {
            cell = m_cellStartTriggerOption;
        }
        else if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx)
        {
            if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == start_selected)
            {
                cell=m_cellStartTriggerType;
            }
            else if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == start_selected)
            {
                cell = m_cellStartTriggerPeriod;
            }
        }
        else
        {
            if (m_PickerCellSectionIdx == section_idx)
            {
                if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
                {
                    cell = m_cellPicker;
                }
            }
        }
    }
    else if (ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            cell = m_cellStopTriggerOption;
        }
        else if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_2 forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            cell = m_cellStopTriggerParam2;
        }
        else if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1 forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stop_selected)
            {
                cell=m_cellStopTriggerType;
            }
            else
            {
                cell = m_cellStopTriggerParam1;
            }

        }
        else
        {
            if (m_PickerCellSectionIdx == section_idx)
            {
                if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
                {
                    cell = m_cellPicker;
                }
            }
        }
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
    int section_idx = (int)[indexPath section];
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];

    int stop_selected = [localSled currentStopTriggerOption];
    int start_selected = [localSled currentStartTriggerOption];
    
    if (ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx)
        {
            [m_cellStartTriggerOption darkModeCheck:self.view.traitCollection];
            return m_cellStartTriggerOption;
        }
        else if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx)
        {
            if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == start_selected ) {
                [m_cellStartTriggerType darkModeCheck:self.view.traitCollection];
                return m_cellStartTriggerType;
            }
            else if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == start_selected)
            {
                [m_cellStartTriggerPeriod darkModeCheck:self.view.traitCollection];
                return m_cellStartTriggerPeriod;
            }
        }
        else
        {
            if (m_PickerCellSectionIdx == section_idx)
            {
                if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
                {
                    return m_cellPicker;
                }
            }
        }
    }
    else if (ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            [m_cellStopTriggerOption darkModeCheck:self.view.traitCollection];
            return m_cellStopTriggerOption;
        }
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_2 forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            [m_cellStopTriggerParam2 darkModeCheck:self.view.traitCollection];
            return m_cellStopTriggerParam2;
        }

        else if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1 forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stop_selected ) {
                [m_cellStopTriggerType darkModeCheck:self.view.traitCollection];
                return m_cellStopTriggerType;
            }
            else
            {
                [m_cellStopTriggerParam1 darkModeCheck:self.view.traitCollection];
                return m_cellStopTriggerParam1;
            }
        }
        else
        {
            if (m_PickerCellSectionIdx == section_idx)
            {
                if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
                {
                    return m_cellPicker;
                }
            }
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
    int cell_idx = (int)[indexPath row];
    int section_idx = (int)[indexPath section];
    int row_to_hide_idx = -1;
    int row_to_hide_section = -1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int main_cell_idx = -1;
    int main_cell_section = -1;
    
    /* expected index for new picker cell */
    row_to_hide_idx = m_PickerCellIdx;
    row_to_hide_section = m_PickerCellSectionIdx;
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx)
        {
            NSArray *starts = [localSled triggerStartOptions];
            int start_selected = [localSled currentStartTriggerOption];
            
            [m_cellPicker setChoices:starts];
            [m_cellPicker setSelectedChoice:start_selected];
            
            main_cell_idx = ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_OPTION;
            main_cell_section = ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER;
        }
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD forSection:ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER] == cell_idx) {
            
            if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == [localSled currentStartTriggerOption])
            {
                NSArray *types = [localSled.mapperTriggerType getStringArray];
                int typeSelectedIndx = [localSled.mapperTriggerType getIndxByEnum:[localSled currentStartTriggerType]];
                
                [m_cellPicker setChoices:types];
                [m_cellPicker setSelectedChoice:typeSelectedIndx];
                
                main_cell_idx = ZT_VC_TRIGGER_CELL_IDX_START_TRIGGER_PERIOD;
                main_cell_section = ZT_VC_TRIGGER_SECTION_IDX_START_TRIGGER;

            }
        }
    }
    else if (ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER == section_idx)
    {
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx)
        {
            NSArray *stops = [localSled triggerStopOptions];
            int stopSelected = [localSled currentStopTriggerOption];
            
            [m_cellPicker setChoices:stops];
            [m_cellPicker setSelectedChoice:stopSelected];
            
            main_cell_idx = ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_OPTION;
            main_cell_section = ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER;
        }
        
        if ([self recalcCellIndex:ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1 forSection:ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER] == cell_idx) {
            
            if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == [localSled currentStopTriggerOption])
            {
                NSArray *types = [localSled.mapperTriggerType getStringArray];
                int typeSelected = [localSled currentStopTriggerType];
                
                [m_cellPicker setChoices:types];
                [m_cellPicker setSelectedChoice:typeSelected];
                
                main_cell_idx = ZT_VC_TRIGGER_CELL_IDX_STOP_TRIGGER_PARAM_1;
                main_cell_section = ZT_VC_TRIGGER_SECTION_IDX_STOP_TRIGGER;
                
            }
        }

    }
    
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        int _picker_cell_section = m_PickerCellSectionIdx;
        
        if (-1 != row_to_hide_idx)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            m_PickerCellSectionIdx = -1;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide_idx inSection:row_to_hide_section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ( ((main_cell_idx + 1) != _picker_cell_idx) || (main_cell_section != _picker_cell_section) )
        {
            m_PickerCellIdx = main_cell_idx + 1;
            m_PickerCellSectionIdx = main_cell_section;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:m_PickerCellSectionIdx]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:m_PickerCellSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    //[self.view endEditing:YES];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_tblTriggerOptions.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [m_tblTriggerOptions reloadData];
}

@end
