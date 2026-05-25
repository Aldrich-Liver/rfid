//
//  DebugVC.m
//  RFIDDemoApp
//
//  Created by Vincent Daempfle on 4/27/16.
//  Copyright © 2016 Motorola Solutions. All rights reserved.
//

#import "DebugVC.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "InfoCellView.h"

/* Table sections */
#define ZT_VC_DEBUG_SECTION_INVENTORY_DELAY    0

/* Table row tags */
#define ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY    0
#define ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY_MS 1

#define ZT_VC_DEBUG_OPTION_ID_NOT_AN_OPTION -1

@interface zt_DebugVC ()
@property zt_SledConfiguration *localSled;
@end

@implementation zt_DebugVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_cellInventoryDelay)
    {
        [m_cellInventoryDelay release];
    }
    
    if (nil != m_cellInventoryDelayMs)
    {
        [m_cellInventoryDelayMs release];
    }
    
    [m_tblOptions release];
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInventoryDelayChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellInventoryDelayMs getTextField]];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellInventoryDelayMs getTextField]];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    if([[m_cellInventoryDelayMs getCellData] length]>0)
    {
        NSString * valueString = [m_cellInventoryDelayMs getCellData];
    
        [[[zt_RfidAppEngine sharedAppEngine] debugConfiguration] setInventoryDelay:[valueString integerValue]];
    }
    
    
    NSLog(@"App Inventory Delay State = %d",[[[zt_RfidAppEngine sharedAppEngine] debugConfiguration] getInventoryDelayState]);
    NSLog(@"App Inventory Delay Delay = %lu",(unsigned long)[[[zt_RfidAppEngine sharedAppEngine] debugConfiguration] getInventoryDelay]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_localSled setDpoOptionsWithConfig:[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getDpoConfig]];
    
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Debug"];
    
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
    
    [self setupConfigurationInitial];
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPreconfiguredOptionCells
{
    m_cellInventoryDelay = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    
    [m_cellInventoryDelay setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellInventoryDelay setInfoNotice:ZT_STR_SETTINGS_DEBUG_INVENTORY_DELAY_STATE];
    [m_cellInventoryDelay setCellTag:ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY];
    [m_cellInventoryDelay setDelegate:self];
    
    m_cellInventoryDelayMs = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellInventoryDelayMs setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellInventoryDelayMs setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellInventoryDelayMs setDataFieldWidth:40];
    [m_cellInventoryDelayMs setInfoNotice:ZT_STR_SETTINGS_DEBUG_INVENTORY_DELAY_MS];
}

- (void)setupConfigurationInitial
{
    /* TBD: configure based on app / reader settings */
    zt_DebugConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] debugConfiguration];
    
    [m_cellInventoryDelay setOption:[configuration getInventoryDelayState]];
    
    [m_cellInventoryDelayMs setData:[NSString stringWithFormat:@"%lu",(unsigned long)[configuration getInventoryDelay]]];
    
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case ZT_VC_DEBUG_SECTION_INVENTORY_DELAY:
            return @"When this feature is enabled and the Start Inventory function is invoked, the RFID SDK applies a delay to the Bluetooth I/O processing thread. When the Stop Inventory function is invoked, the RFID SDK no longer applies the delay.";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    UITableViewCell *cell = nil;
    
    int cell_idx = (int)[indexPath row];
    
    if (ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY == cell_idx)
    {
        cell = m_cellInventoryDelay;
    }
    else if (ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY_MS == cell_idx)
    {
        cell = m_cellInventoryDelayMs;
    }
    
    if (nil != cell)
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
    int cellTag = (int)[indexPath row];
    
    if (ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY == cellTag)
    {
        return m_cellInventoryDelay;
    }
    else if (ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY_MS == cellTag)
    {
        return m_cellInventoryDelayMs;
    }
    
    return nil;
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    int cellTag = [option_cell getCellTag];
    
    if (ZT_VC_DEBUG_CELL_TAG_INVENTORY_DELAY == cellTag)
    {
        BOOL inventoryDelayEnabled = [(zt_SwitchCellView*)option_cell getOption];
        
        [[[zt_RfidAppEngine sharedAppEngine] debugConfiguration] setInventoryDelayState:inventoryDelayEnabled];
        
        NSLog(@"Setting localSled.inventoryDelayEnabled = %d",inventoryDelayEnabled);
    }
}

- (BOOL)checkNumInput:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* :, 0 .. 9 */
        if ((_ch < 48) || (_ch > 57) )
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

- (void)handleInventoryDelayChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellInventoryDelayMs getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellInventoryDelayMs getCellData]] == NO)
        {
            [m_cellInventoryDelayMs setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellInventoryDelayMs setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellInventoryDelayMs getTextField] undoManager] removeAllActions];
    }
    [_input release];
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

@end
