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
 *  Description:  AccessOperationsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AccessOperationsVC.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"
#import "BarcodeData.h"
#import "ScannerEngine.h"
#import "HexToAscii.h"
#import "AsciiToHex.h"
#import "RFIDDemoApp-Swift.h"


#define ZT_VC_ACCESS_OPERATION_READ_WRITE                      0
#define ZT_VC_ACCESS_OPERATION_LOCK                            1
#define ZT_VC_ACCESS_OPERATION_KILL                            2

#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_TAG_ID      0
#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_PASSWORD    1
#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY      2
#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_OFFSET      3
#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_LENGTH      4
#define ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_DATA        5

#define ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_TAG_ID            0
#define ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_PASSWORD          1
#define ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY            2
#define ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE    3

#define ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_TAG_ID            0
#define ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_KILL_PASSWORD     1

#define ZT_OFFSET_MIN                                           0
#define ZT_OFFSET_MAX                                           1024
#define ZT_OFFSET_DEFAULT_SELECTED                              @"2"
#define ZT_OFFSET_DEFAULT_NOT_SELECTED                          @"0"

#define ZT_OFFSET_ACCESS_PASSWORD                               @"2"
#define ZT_OFFSET_KILL_PASSWORD                                 @"0"
#define ZT_OFFSET_TID_USER                                      @"0"
#define ZT_OFFSET_EPC                                           @"2"

#define ZT_LENGTH_MIN                                           0
#define ZT_LENGTH_MAX                                           1024
#define ZT_LENGTH_DEFAULT                                       @"0"
#define ZT_LENGTH_ACCESS_PASSWORD                               @"2"
#define ZT_LENGTH_KILL_PASSWORD                                 @"2"
#define ZT_LENGTH_EPC_TID_USER                                  @"0"

#define ZT_PASSWORD_LENGTH                                      8
#define ZT_PASSWORD_DEFAULT                                     @"00"

#define ZT_DEFAULT_MEMORY_BANK                                  SRFID_MEMORYBANK_EPC
#define ZT_DEFAULT_LOCK_MEMORY_BANK                             SRFID_MEMORYBANK_EPC
#define ZT_DEFAULT_LOCK_PRIVELEGE                               SRFID_ACCESSPERMISSION_ACCESSIBLE_SECURED
#define ZT_INVALID_PARAMETERS_STR                               @"Invalid Parameters"
#define ZT_SELECTED_MEMORY_BANK                         2

@interface zt_AccessOperationsVC ()
- (IBAction)onReadButton:(id)sender;
- (IBAction)onWriteButton:(id)sender;
- (IBAction)onKillLockButton:(id)sender;

@end

@implementation zt_AccessOperationsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
       
        m_MapperMemoryBank = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperAccess];
        m_MapperLockMemoryBank = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperAccessLock];
        m_MapperLockPrivelege = [[zt_EnumMapper alloc] initWithACCESSPERMISSIONMapper];
        
        /* fill choises for picker cells */
        m_OptionsMemoryBank = [[m_MapperMemoryBank getStringArray] retain];
        m_LockOptionsMemoryBank = [[m_MapperLockMemoryBank getStringArray] retain];
        m_OptionsLockPrivilege = [[m_MapperLockPrivelege getStringArray] retain];
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [m_segOperations release];
    [m_tblOperationOptions release];
    [m_btnRead release];
    [m_btnWrite release];
    [m_btnOperation release];
    
    if (nil != m_MapperLockMemoryBank) {
        [m_MapperLockMemoryBank release];
    }
    
    if (nil != m_MapperMemoryBank) {
        [m_MapperMemoryBank release];
    }
    
    if (nil != m_MapperLockPrivelege) {
        [m_MapperLockPrivelege release];
    }
    
    if (nil != m_OptionsMemoryBank)
    {
        [m_OptionsMemoryBank release];
    }
    if(nil != m_LockOptionsMemoryBank)
    {
        [m_LockOptionsMemoryBank release];
    }
    
    if (nil != m_OptionsLockPrivilege)
    {
        [m_OptionsLockPrivilege release];
    }
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != m_cellTagId)
    {
        [m_cellTagId release];
    }
    if (nil != m_cellPassword)
    {
        [m_cellPassword release];
    }
    if (nil != m_cellMemoryBank)
    {
        [m_cellMemoryBank release];
    }
    if (nil != m_cellOffset)
    {
        [m_cellOffset release];
    }
    if (nil != m_cellLength)
    {
        [m_cellLength release];
    }
    if (nil != m_cellData)
    {
        [m_cellData release];
    }
    if (nil != m_cellLockPrivilege)
    {
        [m_cellLockPrivilege release];
    }
    if (nil != m_cellKillPassword)
    {
        [m_cellKillPassword release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    if(nil != m_LockPicker)
    {
        [m_LockPicker release];
    }
    
    if (nil != m_strTagId)
    {
        [m_strTagId release];
    }
    if (nil != m_strRWPassword)
    {
        [m_strRWPassword release];
    }
    if (nil != m_strOffset)
    {
        [m_strOffset release];
    }
    if (nil != m_strLength)
    {
        [m_strLength release];
    }
    if (nil != m_strLPassword)
    {
        [m_strLPassword release];
    }
    if (nil != m_strKillPassword)
    {
        [m_strKillPassword release];
    }
    if (nil != m_strData) {
        [m_strData release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    m_strTagId = [[NSMutableString alloc] init];
    m_strRWPassword = [[NSMutableString alloc] init];
    m_strOffset = [[NSMutableString alloc] init];
    m_strLength = [[NSMutableString alloc] init];
    m_strLPassword = [[NSMutableString alloc] init];
    m_strKillPassword = [[NSMutableString alloc] init];
    m_strData = [[NSMutableString alloc] init];
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    /* configure table view */
    [m_tblOperationOptions registerClass:[zt_TextFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    [m_tblOperationOptions registerClass:[zt_TextViewCellView class] forCellReuseIdentifier:ZT_CELL_ID_TEXT_VIEW];
    [m_tblOperationOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [m_tblOperationOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [m_tblOperationOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOperationOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* configure segments */
    [m_segOperations addTarget:self action:@selector(actionSelectedOperationChanged) forControlEvents:UIControlEventValueChanged];
    
    /* configure buttons*/
    m_btnRead.backgroundColor = THEME_BLUE_COLOR
    m_btnWrite.backgroundColor = THEME_BLUE_COLOR
    m_btnOperation.backgroundColor = THEME_BLUE_COLOR
    
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
    
    [m_tblOperationOptions setDelegate:self];
    [m_tblOperationOptions setDataSource:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTagIdChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePasswordChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellPassword getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOffsetChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLengthChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellLength getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePasswordChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellPassword getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKillPasswordChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellKillPassword getTextField]];
    
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    /* set title */
    [self.tabBarController setTitle:@"Access Control"];
    
    [self displaySelectedTag];
    
    
    /* add buttons in title bar */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
    [self darkModeCheck:self.view.traitCollection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* reload data to update cell height */
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tblOperationOptions reloadData];
    });
}
- (void)setFieldDefaults
{

    if (nil == [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryItem])
    {
        [m_cellOffset setData:ZT_OFFSET_DEFAULT_NOT_SELECTED];
    }
    else
    {
        [m_cellOffset setData:ZT_OFFSET_DEFAULT_SELECTED];
    }
    
    [m_cellLength setData:ZT_LENGTH_DEFAULT];
    [m_cellData setData:@""];
    [m_strData setString:@""];
    [m_cellPassword setData:ZT_PASSWORD_DEFAULT];
    [m_cellKillPassword setData:ZT_PASSWORD_DEFAULT];
    
    m_SelectedOptionMemoryBank = [m_MapperMemoryBank getIndxByEnum:ZT_DEFAULT_MEMORY_BANK]; /* TBD: EPC is default */
    [m_cellMemoryBank setData:[m_MapperMemoryBank getStringByEnum:ZT_DEFAULT_MEMORY_BANK]];
    
    m_selectedLockMemoryBank = [m_MapperLockMemoryBank getIndxByEnum:ZT_DEFAULT_LOCK_MEMORY_BANK];
    m_SelectedOptionLockPrivilege = [m_MapperLockPrivelege getIndxByEnum:ZT_DEFAULT_LOCK_PRIVELEGE]; /* TBD: Read & Write is default */
    [m_cellLockPrivilege setData:[m_MapperLockPrivelege getStringByEnum:ZT_DEFAULT_LOCK_PRIVELEGE]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_tblOperationOptions setDelegate:nil];
    [m_tblOperationOptions setDataSource:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellPassword getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellLength getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellPassword getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellKillPassword getTextField]];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleTagIdChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellTagId getCellData] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [m_strTagId setString:_input];
        NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagId];
        if ([m_strTagId isEqualToString:[m_cellTagId getCellData]] == NO)
        {
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                [m_cellTagId setDataForASCIIMode:asciiTagData];
            }
            else
            {
                [m_cellTagId setData:m_strTagId];
            }
        }
        /* maintain edited tag id */
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdAccess:asciiTagData];
        }
        else
        {
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdAccess:m_strTagId];
        }
    }
    else
    {
        /* restore previous one */
        NSString * asciiTagData = [HexToAscii stringFromHexString:m_strTagId];
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            [m_cellTagId setDataForASCIIMode:asciiTagData];
        }
        else
        {
            [m_cellTagId setData:m_strTagId];
        }
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellTagId getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    
}

- (void)handleDataChanged
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellData getCellData] uppercaseString]];
    
    NSMutableString *defaultData = [[NSMutableString alloc] init];
    [defaultData setString:[m_cellData getCellData]];
    
    memoryBank = [m_MapperMemoryBank getEnumByIndx:m_SelectedOptionMemoryBank];
    
    if (memoryBank == SRFID_MEMORYBANK_USER)
    {
        if ([self checkHexPatternForLengthyTags:_input] == YES)
        {
            [m_strData setString:_input];
            if ([m_strData isEqualToString:[m_cellData getCellData]] == NO)
            {
                [m_cellData setData:m_strData];
            }
        }
        else
        {
            /* restore previous one */
            [m_cellData setData:m_strData];
        }
    }else
    {
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
        {
            [m_cellData setData:defaultData];
        }
        else
        {
            if ([self checkHexPattern:_input] == YES)
            {
                [m_strData setString:_input];
                if ([m_strData isEqualToString:[m_cellData getCellData]] == NO)
                {
                    [m_cellData setData:m_strData];
                }
            }
            else
            {
                /* restore previous one */
                [m_cellData setData:m_strData];
            }
        }
    }
    [_input release];
    
}

- (void)handlePasswordChanged:(NSNotification *)notif
{
    NSMutableString *string = nil;
    if (m_CurrentOperation == ZT_VC_ACCESS_OPERATION_READ_WRITE) {
        string = m_strRWPassword;
    }
    else if (m_CurrentOperation == ZT_VC_ACCESS_OPERATION_LOCK)
    {
        string = m_strLPassword;
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellPassword getCellData] uppercaseString]];
    
    if ([self checkPasswordInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellPassword getCellData]] == NO)
        {
            [m_cellPassword setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellPassword setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellPassword getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    
}
- (void)handleOffsetChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellOffset getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [m_strOffset setString:_input];
        if ([m_strOffset isEqualToString:[m_cellOffset getCellData]] == NO)
        {
            [m_cellOffset setData:m_strOffset];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellOffset setData:m_strOffset];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellOffset getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    
}
- (void)handleLengthChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellLength getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [m_strLength setString:_input];
        if ([m_strLength isEqualToString:[m_cellLength getCellData]] == NO)
        {
            [m_cellLength setData:m_strLength];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellLength setData:m_strLength];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellLength getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    
}

- (void)handleKillPasswordChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellKillPassword getCellData] uppercaseString]];
    
    if ([self checkPasswordInput:_input] == YES)
    {
        [m_strKillPassword setString:_input];
        if ([m_strKillPassword isEqualToString:[m_cellKillPassword getCellData]] == NO)
        {
            [m_cellKillPassword setData:m_strKillPassword];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellKillPassword setData:m_strKillPassword];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellKillPassword getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    
}

- (void)configureAppearance
{
    /* configure segmented control */
    float titleFontSize = ZT_UI_ACCESS_FONT_SZ_MEDIUM;
    
    /*iOS8.0. The first segment doesn't display the hole title with font size 17.0.
     For some reason segment width needs 5 pixels more.
     */
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        titleFontSize--;
    }
 
    [m_segOperations setTitle:@"Read \\ Write" forSegmentAtIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE];
    [m_segOperations setTitle:@"Lock" forSegmentAtIndex:ZT_VC_ACCESS_OPERATION_LOCK];
    [m_segOperations setTitle:@"Kill" forSegmentAtIndex:ZT_VC_ACCESS_OPERATION_KILL];
    [m_segOperations setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:
      [UIFont systemFontOfSize:titleFontSize] forKey:NSFontAttributeName]
                                   forState:UIControlStateNormal];
    m_segOperations.tintColor = THEME_BLUE_COLOR
}

- (void)createPreconfiguredOptionCells
{
    m_cellTagId = [[zt_TextFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    m_cellPassword = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellMemoryBank = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellOffset = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellLength = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellData = [[zt_TextViewCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_TEXT_VIEW];
    m_cellLockPrivilege = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellKillPassword = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_LockPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    [m_cellTagId setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPassword setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellOffset setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellLength setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellData setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellKillPassword setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_LockPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [m_cellData setTextViewDelegate:self];
    [m_cellTagId setDelegate:self];
    [m_cellPassword setDelegate:self];
    [m_cellOffset setDelegate:self];
    [m_cellLength setDelegate:self];
    [m_cellKillPassword setDelegate:self];
    
    [m_cellPicker setDelegate:self];
    [m_LockPicker setDelegate:self];
    
    [m_cellTagId setPlaceholder:@"Tag Pattern"];
    [m_cellPassword setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
    [m_cellPassword setInfoNotice:@"Password"];
    [m_cellMemoryBank setInfoNotice:@"Memory bank"];
    [m_cellOffset setInfoNotice:@"Offset(words)"];
    [m_cellOffset setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
    [m_cellOffset setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellLength setInfoNotice:@"Length(words)"];
    [m_cellLength setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
    [m_cellLength setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellData setInfoNotice:@"Data"];
    [m_cellLockPrivilege setInfoNotice:@"Lock privilege"];
    [m_cellKillPassword setInfoNotice:@"Kill Password"];
    [m_cellKillPassword setDataFieldWidth:ZT_ACCESS_CONTROL_FIELD_WIDTH];
}

- (void)setupConfigurationInitial
{
    [m_cellTagId setData:@""];
    
    [self setFieldDefaults];
    
    m_CurrentOperation = ZT_VC_ACCESS_OPERATION_READ_WRITE;
    [m_segOperations setSelectedSegmentIndex:m_CurrentOperation];
    
    [self configureForSelectedOperation];
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

- (void)actionSelectedOperationChanged
{
    m_CurrentOperation = (int)[m_segOperations selectedSegmentIndex];
    [self configureForSelectedOperation];
}

- (void)configureForSelectedOperation
{
    /* disable view animation to avoid buttons blinking
    during UI changes */
    [UIView setAnimationsEnabled:NO];
    switch (m_CurrentOperation)
    {
        case ZT_VC_ACCESS_OPERATION_READ_WRITE:
            [m_btnRead setHidden:NO];
            [m_btnWrite setHidden:NO];
            [m_btnOperation setTitle:(@"") forState:UIControlStateNormal];
            [m_btnOperation setHidden:YES];
            [m_cellMemoryBank setData:(NSString*)[m_OptionsMemoryBank objectAtIndex:m_SelectedOptionMemoryBank]];
            break;
        case ZT_VC_ACCESS_OPERATION_LOCK:
            [m_cellMemoryBank setData:(NSString*)[m_LockOptionsMemoryBank objectAtIndex:m_selectedLockMemoryBank]];

        case ZT_VC_ACCESS_OPERATION_KILL:
            [UIView performWithoutAnimation:^{
                [m_btnOperation setTitle:((m_CurrentOperation == ZT_VC_ACCESS_OPERATION_LOCK) ? @"LOCK" : @"KILL") forState:UIControlStateNormal];
                [m_btnRead setHidden:YES];
                [m_btnWrite setHidden:YES];
                [m_btnOperation setHidden:NO];
            }];
            break;
    }
    
    /* hide picker cells */
    m_PickerCellIdx = -1;
    [m_tblOperationOptions reloadData];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOperationOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblOperationOptions.contentInset = contentInsets;
    m_tblOperationOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOperationOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblOperationOptions.contentInset = contentInsets;
    m_tblOperationOptions.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)displaySelectedTag
{
    NSString *previousData = [m_cellTagId getCellData];
    NSString *selectedTag = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess];
    
    if (NO == [previousData isEqualToString:selectedTag])
    {
        [self setFieldDefaults];
    }
    
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        NSString * asciiTagData = [HexToAscii stringFromHexString:selectedTag];
        [m_cellTagId setDataForASCIIMode:asciiTagData];
        [m_strTagId setString:asciiTagData];
    }
    else
    {
        [m_cellTagId setData:selectedTag];
        [m_strTagId setString:selectedTag];
    }
    
    tagIDLength = [[m_cellTagId getCellData] length];
}

- (void)showWarning:(NSString *)message
{
    //[zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
    [self showOnlyMessageWithDurationWithMessage:message time:3];
    
}

- (IBAction)onReadButton:(id)sender
{
    if(NO == [self checkBeforeReadWriteOperation])
        return;
    
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if ([local prefilterEnabled])
    {
        // Return if original length on the tag is reduced (character deletion)
        NSUInteger len = [[m_cellTagId getCellData] length];
        if (len < tagIDLength){
            [self showWarning:@"Invalid Tag Length"];
            return;
        }
    }
    
    /* clear read data field */
    [m_cellData setData:@""];
    [m_strData setString:@""];
    
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(readTag) withObject:nil withString:@"Reading tags"];
}

- (void)readTag
{
    srfidTagData *tagData = [[srfidTagData alloc] init];
    
    short offset = 0;
    sscanf([[m_cellOffset getCellData] UTF8String], "%hi", &offset);
    
    short length = 0;
    sscanf([[m_cellLength getCellData] UTF8String], "%hi", &length);
    
    long password = 0;
    sscanf([[m_cellPassword getCellData] UTF8String], "%lx", &password);
    
    if (m_SelectedOptionMemoryBank > ZT_SELECTED_MEMORY_BANK)
    {
        memoryBank = [m_MapperMemoryBank getEnumForReservedMemoryBank];
    }else
    {
        memoryBank = [m_MapperMemoryBank getEnumByIndx:m_SelectedOptionMemoryBank];
    }
    NSString * tagID;
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        tagID = [AsciiToHex stringFromAsciiString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess]];
    }
    else
    {
        tagID = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess];
    }

    NSString *err_msg = nil;
    
    SRFID_RESULT rfid_result = [[zt_RfidAppEngine sharedAppEngine] readTag:tagID withTagData:&tagData withMemoryBankID:memoryBank withOffset:offset withLength:length withPassword:password aStatusMessage:&err_msg];
    
    /// Async read opration calling.
    //SRFID_RESULT rfid_result = [[zt_RfidAppEngine sharedAppEngine]readTagAsync:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess] withTagData:&tagData withMemoryBankID:memoryBank withOffset:offset withLength:length withPassword:password aStatusMessage:&err_msg];
    
    BOOL result = NO;
    NSString *str_failure = @"Access operation failed";
    
    if (SRFID_RESULT_SUCCESS == rfid_result)
    {
        /// Abort operation should be called when async operation is getting called.
        //SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
        //rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
        /* check tag data result */
        if (NO == [tagData getOperationSucceed])
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", [tagData getOperationStatus]];
        }
        else
        {
            if ([[tagData getTagId] isEqual:EMPTY_STRING] || [[tagData getTagId] isEqual:nil])
            {
//                str_failure = [NSString stringWithFormat:ACCESS_OPERATION_READ_TIMEOUT];
                str_failure = [NSString stringWithFormat:@"Access operation failed: Invalid Length"];
            }else
            {
                result = YES;
            }
            
        }
    }
    else if (SRFID_RESULT_RESPONSE_ERROR == rfid_result)
    {
        if (nil != err_msg)
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", err_msg];
        }
    }
    else if (SRFID_RESULT_RESPONSE_TIMEOUT == rfid_result)
    {
        str_failure = [NSString stringWithFormat:ACCESS_OPERATION_READ_TIMEOUT];
        //str_failure = [NSString stringWithFormat:@"Access operation failed: Length is invalid"];
    }
    else if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        str_failure = [NSString stringWithFormat:@"Operation failed: no active reader"];
    }
    
    if(!result){
        usleep(500*1000);
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (YES == result)
        {
            NSString *memoryData = [tagData getMemoryBankData];
            
            if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
            {
                NSString * asciiTagData = [HexToAscii stringFromHexString:memoryData];
                [m_cellData setData:asciiTagData];
                [m_strData setString:asciiTagData];
                
            }
            else
            {
                [m_cellData setData:memoryData];
                [m_strData setString:memoryData];
            }
            
            /* reload data to update cell height */
            [m_tblOperationOptions reloadData];
        }
        
        [tagData release];
        
        if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
        {
           // zt_AlertView *alert = [[zt_AlertView alloc] init];
           // [alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        }
        else
        {
//            zt_AlertView *alertView = [[zt_AlertView alloc] init];
//            [alertView showSuccessFailureWithText:self.view isSuccess:result aSuccessMessage:@"Read succeed" aFailureMessage:str_failure];
            
            [self showOnlySuccessFailureMessageWithDurationWithSuccessMessage:@"Read succeed" failureMessage:str_failure time:2 isSucess:result];
        }
    });
}

- (IBAction)onWriteButton:(id)sender
{
    if(NO == [self checkBeforeReadWriteOperation])
        return;
    
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(writeTag) withObject:nil withString:@"Writing Data"];
}

- (void)writeTag
{
    short offset;
    sscanf([[m_cellOffset getCellData] UTF8String], "%hi", &offset);
    
    NSString * data;
    
    NSString * tagdata;
    
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        tagdata = [AsciiToHex stringFromAsciiString:[m_cellTagId getCellData]];
        data = [AsciiToHex stringFromAsciiString:[m_cellData getCellData]];
    }else
    {
        tagdata = [m_cellTagId getCellData];
        data = [m_cellData getCellData];
    }

    long password = 0;
    sscanf([[m_cellPassword getCellData] UTF8String], "%lx", &password);
    
    // toDo check parametr
    BOOL doBlockWrite = NO;
        
    if (m_SelectedOptionMemoryBank > ZT_SELECTED_MEMORY_BANK)
    {
        memoryBank = [m_MapperMemoryBank getEnumForReservedMemoryBank];
    }else
    {
        memoryBank = [m_MapperMemoryBank getEnumByIndx:m_SelectedOptionMemoryBank];
    }
    
    srfidTagData *tagData = [[srfidTagData alloc] init];
    
    NSString *err_msg = nil;
    
    SRFID_RESULT rfid_result = [[zt_RfidAppEngine sharedAppEngine] writeTag:tagdata withTagData:&tagData withMemoryBankID:memoryBank withOffset:offset withData:data withPassword:password doBlockWrite:doBlockWrite aStatusMessage:&err_msg];
    
    BOOL result = NO;
    NSString *str_failure = @"Access operation failed";
    
    if (SRFID_RESULT_SUCCESS == rfid_result)
    {
        /* check tag data result */
        if (NO == [tagData getOperationSucceed])
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", [tagData getOperationStatus]];
        }
        else
        {
            if ([[tagData getTagId] isEqual:EMPTY_STRING] || [[tagData getTagId] isEqual:nil])
            {
                //str_failure = [NSString stringWithFormat:ACCESS_OPERATION_WRITE_TIMEOUT];
                str_failure = [NSString stringWithFormat:@"Access operation failed: Invalid Length"];
            }else
            {
                result = YES;
            }
        }
    }
    else if (SRFID_RESULT_RESPONSE_ERROR == rfid_result)
    {
        if (nil != err_msg)
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", err_msg];
        }
    }
    else if (SRFID_RESULT_RESPONSE_TIMEOUT == rfid_result)
    {
        str_failure = [NSString stringWithFormat:ACCESS_OPERATION_WRITE_TIMEOUT];
    }
    else if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        str_failure = [NSString stringWithFormat:@"Operation failed: no active reader"];
    }
    
    if(!result){
        usleep(500*1000);
    }
    
    [tagData release];
    
    if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //zt_AlertView *alert = [[zt_AlertView alloc] init];
            //[alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        });
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
           // zt_AlertView *alertView = [[zt_AlertView alloc] init];
           // [alertView showSuccessFailureWithText:self.view isSuccess:result aSuccessMessage:@"Write succeed" aFailureMessage:str_failure];
            //[alertView release];
            [self showOnlySuccessFailureMessageWithDurationWithSuccessMessage:@"Write succeed" failureMessage:str_failure time:2 isSucess:result];
           
        });
    }
}

- (IBAction)onKillLockButton:(id)sender
{
    if(NO == [self checkBeforLockKill])
        return;
    
    if (m_CurrentOperation == ZT_VC_ACCESS_OPERATION_LOCK) {
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(lockTag) withObject:nil withString:@"Executing Lock command"];
    }
    else if(m_CurrentOperation == ZT_VC_ACCESS_OPERATION_KILL)
    {
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(killTag) withObject:nil withString:@"Executing Kill command"];
    }
}

- (BOOL)checkBeforLockKill
{
    // check tag id
    if ([[[m_cellTagId getTextField] text] isEqualToString:@""]) {
        [self showWarning:@"Please fill Tag Id"];
        return NO;
    }
    
    // check password
    if (m_CurrentOperation == ZT_VC_ACCESS_OPERATION_LOCK)
    {
        if ( NO == [self checkDataLength:ZT_PASSWORD_LENGTH withData:[m_cellPassword getCellData]]) {
            [self showWarning:ZT_INVALID_PARAMETERS_STR];
            return NO;
        }
    }
    else if (m_CurrentOperation == ZT_VC_ACCESS_OPERATION_KILL)
    {
        if (NO == [self checkDataLength:ZT_PASSWORD_LENGTH withData:[m_cellKillPassword getCellData]]) {
            [self showWarning:ZT_INVALID_PARAMETERS_STR];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)checkBeforeReadWriteOperation
{
    // check tag id
    if (YES == [[[m_cellTagId getTextField] text] isEqualToString:@""]) {
        [self showWarning:@"Please fill Tag Id"];
        return NO;
    }

    // check offset
    if (NO == [self checkForMin:ZT_OFFSET_MIN forMax:ZT_OFFSET_MAX withValue:[[m_cellOffset getCellData] intValue]]) {
        [self showWarning:ZT_INVALID_PARAMETERS_STR];
        return NO;
    }
    
    if ( [@"" length] == [[m_cellOffset getCellData] length]) {
        [self showWarning:ZT_INVALID_PARAMETERS_STR];
        return NO;
    }

    // check length
    if (NO == [self checkForMin:ZT_LENGTH_MIN forMax:ZT_LENGTH_MAX withValue:[[m_cellLength getCellData] intValue]]) {
        [self showWarning:ZT_INVALID_PARAMETERS_STR];
        return NO;
    }
    
    if ( [@"" length] == [[m_cellLength getCellData] length]) {
        [self showWarning:ZT_INVALID_PARAMETERS_STR];
        return NO;
    }

    // check password
    if ( NO == [self checkDataLength:ZT_PASSWORD_LENGTH withData:[m_cellPassword getCellData]]) {
        [self showWarning:ZT_INVALID_PARAMETERS_STR];
        return NO;
    }
    
    return YES;
}

- (void)lockTag
{
    long password = 0;
    sscanf([[m_cellPassword getCellData] UTF8String], "%lx", &password);

    srfidTagData *tagData = [[srfidTagData alloc] init];
   
    SRFID_MEMORYBANK memoryBank = [m_MapperLockMemoryBank getEnumByIndx:m_selectedLockMemoryBank];
    
    SRFID_ACCESSPERMISSION permission = [m_MapperLockPrivelege getEnumByIndx:m_SelectedOptionLockPrivilege];
    
    NSString *err_msg = nil;
    
    SRFID_RESULT rfid_result = [[zt_RfidAppEngine sharedAppEngine] lockTag:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess] withTagData:&tagData memoryBank:memoryBank accessPermissions:permission withPassword:password aStatusMessage:&err_msg];
    
    BOOL result = NO;
    NSString *str_failure = @"Access operation failed";
    
    if (SRFID_RESULT_SUCCESS == rfid_result)
    {
        /* check tag data result */
        if (NO == [tagData getOperationSucceed])
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", [tagData getOperationStatus]];
        }
        else
        {
            if ([[tagData getTagId] isEqual:EMPTY_STRING] || [[tagData getTagId] isEqual:nil])
            {
                str_failure = [NSString stringWithFormat:ACCESS_OPERATION_LOCK_TIMEOUT];
            }else
            {
                result = YES;
            }
        }
    }
    else if (SRFID_RESULT_RESPONSE_ERROR == rfid_result)
    {
        if (nil != err_msg)
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", err_msg];
        }
    }
    else if (SRFID_RESULT_RESPONSE_TIMEOUT == rfid_result)
    {
        str_failure = [NSString stringWithFormat:ACCESS_OPERATION_LOCK_TIMEOUT];
    }
    else if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        str_failure = [NSString stringWithFormat:@"Operation failed: no active reader"];
    }
    else if (SRFID_RESULT_FAILURE == rfid_result)
    {
        str_failure = [NSString stringWithFormat:@"Operation failed:%@",err_msg];
    }
    if(!result){
        usleep(500*1000);
    }
    
    [tagData release];
    
    if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //zt_AlertView *alert = [[zt_AlertView alloc] init];
            //[alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
            [self showOnlyMessageWithDurationWithMessage:ZT_WARNING_NO_READER time:4];
        });
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
           // zt_AlertView *alertView = [[zt_AlertView alloc] init];
           // [alertView showSuccessFailureWithText:self.view isSuccess:result aSuccessMessage:@"Lock succeed" aFailureMessage:str_failure];
            //[alertView release];
            
            [self showOnlySuccessFailureMessageWithDurationWithSuccessMessage:@"Lock succeed" failureMessage:str_failure time:2 isSucess:result];
        });
    }
}

- (void)killTag
{
    long password = 0;
    //sscanf([[m_cellPassword getCellData] UTF8String], "%lx", &password);
    sscanf([[m_cellKillPassword getCellData] UTF8String], "%lx", &password);//fix for kill password issue
    
    srfidTagData *tagData = [[srfidTagData alloc] init];
    
    NSString *err_msg = nil;
    
    SRFID_RESULT rfid_result = [[zt_RfidAppEngine sharedAppEngine] killTag:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess] withTagData:&tagData withPassword:password aStatusMessage:&err_msg];
    
    BOOL result = NO;
    NSString *str_failure = @"Access operation failed";
    
    if (SRFID_RESULT_SUCCESS == rfid_result)
    {
        /* check tag data result */
        if (NO == [tagData getOperationSucceed])
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", [tagData getOperationStatus]];
        }
        else
        {
            if ([[tagData getTagId] isEqual:EMPTY_STRING] || [[tagData getTagId] isEqual:nil])
            {
                str_failure = [NSString stringWithFormat:ACCESS_OPERATION_KILL_TIMEOUT];
            }else
            {
                result = YES;
            }
        }
    }
    else if (SRFID_RESULT_RESPONSE_ERROR == rfid_result)
    {
        if (nil != err_msg)
        {
            str_failure = [NSString stringWithFormat:@"Access operation failed: %@", err_msg];
        }
    }
    else if (SRFID_RESULT_RESPONSE_TIMEOUT == rfid_result)
    {
        str_failure = [NSString stringWithFormat:ACCESS_OPERATION_KILL_TIMEOUT];
    }
    else if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        str_failure = [NSString stringWithFormat:@"Operation failed: no active reader"];
    }
    
    if(!result){
        usleep(500*1000);
    }
    
    [tagData release];
    
    if (SRFID_RESULT_READER_NOT_AVAILABLE == rfid_result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            zt_AlertView *alert = [[zt_AlertView alloc] init];
            [alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
        });
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
//            zt_AlertView *alertView = [[zt_AlertView alloc] init];
//            [alertView showSuccessFailureWithText:self.view isSuccess:result aSuccessMessage:@"Kill succeed" aFailureMessage:str_failure];
            //[alertView release];
            [self showOnlySuccessFailureMessageWithDurationWithSuccessMessage:@"Kill succeed" failureMessage:str_failure time:2 isSucess:result];
        });
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
    switch (m_CurrentOperation)
    {
        case ZT_VC_ACCESS_OPERATION_READ_WRITE:
            return 6 + ((m_PickerCellIdx != -1) ? 1 : 0);
        case ZT_VC_ACCESS_OPERATION_LOCK:
            return 4 + ((m_PickerCellIdx != -1) ? 1 : 0);
        case ZT_VC_ACCESS_OPERATION_KILL:
            return 2 + ((m_PickerCellIdx != -1) ? 1 : 0);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];

    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
    if (ZT_VC_ACCESS_OPERATION_READ_WRITE == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_TAG_ID] == cell_idx)
        {
            cell = m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_PASSWORD] == cell_idx)
        {
            cell = m_cellPassword;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY] == cell_idx)
        {
            cell = m_cellMemoryBank;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_OFFSET] == cell_idx)
        {
            cell = m_cellOffset;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_LENGTH] == cell_idx)
        {
            cell = m_cellLength;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_DATA] == cell_idx)
        {
            cell = m_cellData;
        }
    }
    else if (ZT_VC_ACCESS_OPERATION_LOCK == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_LockPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_TAG_ID] == cell_idx)
        {
            cell = m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_PASSWORD] == cell_idx)
        {
            cell = m_cellPassword;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY] == cell_idx)
        {
            cell = m_cellMemoryBank;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE] == cell_idx)
        {
            cell = m_cellLockPrivilege;
        }
    }
    else if (ZT_VC_ACCESS_OPERATION_KILL == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_TAG_ID] == cell_idx)
        {
            cell = m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_KILL_PASSWORD] == cell_idx)
        {
            cell = m_cellKillPassword;
        }
    }
    
    if (cell != nil)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        //cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(m_tblOperationOptions.bounds), CGRectGetHeight(cell.bounds));
        
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
    if (ZT_VC_ACCESS_OPERATION_READ_WRITE == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_TAG_ID] == cell_idx)
        {
            /// Set selected barcode value
            BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
            if (barcodeData != NULL){
                [m_cellTagId setBarcodeValue:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
            }
            [m_cellTagId darkModeCheck:self.view.traitCollection];
            return m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_PASSWORD] == cell_idx)
        {
            [m_cellPassword darkModeCheck:self.view.traitCollection];
            return m_cellPassword;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY] == cell_idx)
        {
            [m_cellMemoryBank darkModeCheck:self.view.traitCollection];
            return m_cellMemoryBank;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_OFFSET] == cell_idx)
        {
            [m_cellOffset darkModeCheck:self.view.traitCollection];
            return m_cellOffset;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_LENGTH] == cell_idx)
        {
            [m_cellLength darkModeCheck:self.view.traitCollection];
            return m_cellLength;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_DATA] == cell_idx)
        {
            [m_cellData darkModeCheck:self.view.traitCollection];
            return m_cellData;
        }
    }
    else if (ZT_VC_ACCESS_OPERATION_LOCK == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_LockPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_TAG_ID] == cell_idx)
        {
            /// Set selected barcode value
            BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
            if (barcodeData != NULL){
                [m_cellTagId setBarcodeValue:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
            }
            [m_cellTagId darkModeCheck:self.view.traitCollection];
            return m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_PASSWORD] == cell_idx)
        {
            [m_cellPassword darkModeCheck:self.view.traitCollection];
            return m_cellPassword;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY] == cell_idx)
        {
            [m_cellMemoryBank darkModeCheck:self.view.traitCollection];
            return m_cellMemoryBank;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE] == cell_idx)
        {
            [m_cellLockPrivilege darkModeCheck:self.view.traitCollection];
            return m_cellLockPrivilege;
        }

    }
    else if (ZT_VC_ACCESS_OPERATION_KILL == m_CurrentOperation)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            [m_cellPicker darkModeCheck:self.view.traitCollection];
            return m_cellPicker;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_TAG_ID] == cell_idx)
        {
            /// Set selected barcode value
            BarcodeData *barcodeData = [[ScannerEngine sharedScannerEngine] getSelectedBarcodeValue];
            if (barcodeData != NULL){
                [m_cellTagId setBarcodeValue:[barcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
            }
            [m_cellTagId darkModeCheck:self.view.traitCollection];
            return m_cellTagId;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_KILL_CELL_IDX_KILL_PASSWORD] == cell_idx)
        {
            [m_cellKillPassword darkModeCheck:self.view.traitCollection];
            return m_cellKillPassword;
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
    
    /* enable view animation that was disabled during
    switching between segments - see configureForSelectedOperation */
    [UIView setAnimationsEnabled:YES];
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    if (ZT_VC_ACCESS_OPERATION_READ_WRITE == m_CurrentOperation)
    {
        if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY] == cell_idx)
        {
            [m_cellPicker setChoices:m_OptionsMemoryBank];
            [m_cellPicker setSelectedChoice:m_SelectedOptionMemoryBank];
            
            memoryBank = [m_MapperMemoryBank getEnumByIndx:m_SelectedOptionMemoryBank];
            
            switch (memoryBank) {
                case SRFID_MEMORYBANK_EPC:
                default:
                    [m_cellOffset setData:ZT_OFFSET_EPC];
                    [m_cellLength setData:ZT_LENGTH_EPC_TID_USER];
                    break;
                    
                case SRFID_MEMORYBANK_TID:
                case SRFID_MEMORYBANK_USER:
                    [m_cellOffset setData:ZT_OFFSET_TID_USER];
                    [m_cellLength setData:ZT_LENGTH_EPC_TID_USER];
                    break;
                
                case SRFID_MEMORYBANK_ACCESS:
                    [m_cellOffset setData:ZT_OFFSET_ACCESS_PASSWORD];
                    [m_cellLength setData:ZT_LENGTH_ACCESS_PASSWORD];
                    break;
                
                case SRFID_MEMORYBANK_KILL:
                    [m_cellOffset setData:ZT_OFFSET_KILL_PASSWORD];
                    [m_cellLength setData:ZT_LENGTH_KILL_PASSWORD];
                    break;
            }
            
            main_cell_idx = ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY;
        }
    }
    else if (ZT_VC_ACCESS_OPERATION_LOCK == m_CurrentOperation)
    {
        if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY] == cell_idx)
        {
            [m_LockPicker setChoices:m_LockOptionsMemoryBank];
            [m_LockPicker setSelectedChoice:m_selectedLockMemoryBank];
            main_cell_idx = ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY;
        }
        else if ([self recalcCellIndex:ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE] == cell_idx)
        {
            [m_LockPicker setChoices:m_OptionsLockPrivilege];
            [m_LockPicker setSelectedChoice:m_SelectedOptionLockPrivilege];
            main_cell_idx = ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE;
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
    [m_tblOperationOptions beginUpdates];
    [m_tblOperationOptions endUpdates];
    /* TBD: scroll to cursor position ??? */
    [self handleDataChanged];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    /* scroll to cursor position */
    CGRect cursor_rect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursor_rect = [m_tblOperationOptions convertRect:cursor_rect fromView:textView];
    cursor_rect.size.height += 8;
    [m_tblOperationOptions scrollRectToVisible:cursor_rect animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
        if (ZT_VC_ACCESS_OPERATION_READ_WRITE == m_CurrentOperation)
        {
            if (ZT_VC_ACCESS_OPERATION_READ_WRITE_CELL_IDX_MEMORY == (m_PickerCellIdx - 1))
            {
                m_SelectedOptionMemoryBank = choice;
                [m_cellMemoryBank setData:(NSString*)[m_OptionsMemoryBank objectAtIndex:m_SelectedOptionMemoryBank]];
            }
        }
        else if (ZT_VC_ACCESS_OPERATION_LOCK == m_CurrentOperation)
        {
            if (ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_MEMORY == (m_PickerCellIdx - 1))
            {
                m_selectedLockMemoryBank = choice;
                [m_cellMemoryBank setData:(NSString*)[m_LockOptionsMemoryBank objectAtIndex:m_selectedLockMemoryBank]];
                
                if (m_selectedLockMemoryBank == 5)
                {
                    m_SelectedOptionLockPrivilege = 1;
                    [m_cellLockPrivilege setUserInteractionEnabled:NO];
                    [m_cellLockPrivilege setData:(NSString*)[m_OptionsLockPrivilege objectAtIndex:m_SelectedOptionLockPrivilege]];
                    [m_cellLockPrivilege setCellInActive];
                }else
                {
                    m_SelectedOptionLockPrivilege = 0;
                    [m_cellLockPrivilege setUserInteractionEnabled:YES];
                    [m_cellLockPrivilege setData:(NSString*)[m_OptionsLockPrivilege objectAtIndex:m_SelectedOptionLockPrivilege]];
                    [m_cellLockPrivilege setCellActive];
                }
            }
            else if (ZT_VC_ACCESS_OPERATION_LOCK_CELL_IDX_LOCK_PRIVILEGE == (m_PickerCellIdx - 1))
            {
                m_SelectedOptionLockPrivilege = choice;
                [m_cellLockPrivilege setData:(NSString*)[m_OptionsLockPrivilege objectAtIndex:m_SelectedOptionLockPrivilege]];
                
            }
        }
    }
    else if (YES == [_cell isKindOfClass:[zt_TextFieldCellView class]])
    {
        /*
         TBD:
         1) configure cell tags
         2) update appropriate value in accordance with [cell getCellTag]
         
         refer FilterConfigVC.m for example
         */
    }
    else if (YES == [_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        /*
         TBD: for TextViewCell, TextFieldCell, LabelInputFieldCell
         1) configure cell tags
         2) update appropriate value in accordance with [cell getCellTag]
         
         refer FilterConfigVC.m for example
         */
    }
    else if (YES == [_cell isKindOfClass:[zt_TextViewCellView class]])
    {
        /*
         TBD: for TextViewCell, TextFieldCell, LabelInputFieldCell
         1) configure cell tags
         2) update appropriate value in accordance with [cell getCellTag]
         
         refer FilterConfigVC.m for example
         */
    }
}
- (void)didBeginEditing:(id)option_cell
{
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
    [m_tblOperationOptions reloadData];
}

@end
