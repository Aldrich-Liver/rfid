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
 *  Description:  SelectionTableVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SelectionTableVC.h"
#import "RfidAppEngine.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"
#import "ui_config.h"

#define ZT_CELL_ID_SINGLE_OPTION                 @"ID_CELL_SINGLE_OPTION"

@interface zt_SelectionTableVC ()

@end

@implementation zt_SelectionTableVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        //m_SelectedValue = @"";
        m_Caption = @"";
        m_Options = [[NSMutableArray alloc] init];
        m_Delegate = nil;
        m_ModalMode = NO;
        m_btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(btnSavePressed)];
    }
    return self;
}

- (void)dealloc
{
    [m_tblOptions release];
    if (nil != m_Options)
    {
        [m_Options removeAllObjects];
        [m_Options release];
    }
    if (nil != m_btnSave)
    {
        [m_btnSave release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* configure table view */
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:m_Caption];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c20];
    
    NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c30];
    
    NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c40];
    
    [m_tblOptions reloadData];
    [self setSelectedOptionInt:m_SelectedOption];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:m_SelectedOption inSection:0];
    if(m_SelectedOption >= 0 && m_SelectedOption < [m_Options count])
        [m_tblOptions selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
    if (YES == m_ModalMode)
    {
        NSMutableArray *right_items = [[NSMutableArray alloc] init];
        
        [right_items addObject:m_btnSave];
        
        self.navigationItem.rightBarButtonItems = right_items;
        
        [right_items removeAllObjects];
        [right_items release];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (YES == m_ModalMode)
    {
       
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"Regulatory configuration is required"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           //Handle cancel button here
                                       }];
        
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self darkModeCheck:self.view.traitCollection];
}

- (void)setModalMode:(BOOL)enabled
{
    m_ModalMode = enabled;
}

- (void)btnSavePressed
{
    /* save configuration */
    
    int region_idx = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfRegionWithName:[m_Options objectAtIndex:m_SelectedOption]];
    NSString *code = [[[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions] objectAtIndex:region_idx] regionCode];
    
    NSLog(@"Initial region is selected: %@ (%@)", [m_Options objectAtIndex:m_SelectedOption], code);
    
    [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] setCurrentRegionCode:code];
    
    /* save configuration on sled */
    [[zt_RfidAppEngine sharedAppEngine] setRegulatoryConfig:nil];
    /* disconnect & reconnect to configure default protocol parameters */
    [[zt_RfidAppEngine sharedAppEngine] disconnect:[[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID]];
    /* dismiss */
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDelegate:(id<zt_ISelectionTableVCDelegate>)delegate
{
    m_Delegate = delegate;
}

- (void)setCaption:(NSString*)caption
{
    m_Caption = [NSString stringWithString:caption];
    [self setTitle:m_Caption];
}

- (void)setOptionsWithDictionary:(NSDictionary*)options withStringPrefix:(NSString *)dataPrefix
{
    [m_Options removeAllObjects];
    NSArray *values = [options allValues];
    if (dataPrefix != nil)
    {
        m_Options = [[NSMutableArray arrayWithArray:[values sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            int prefixLength = (int)[dataPrefix length];
            int intValue1 = [[obj1 substringFromIndex:prefixLength] intValue];
            int intValue2 = [[obj2 substringFromIndex:prefixLength] intValue];
            if (intValue1 == intValue2)
                return NSOrderedSame;
    
            else if (intValue1<intValue2)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }]] mutableCopy];
    }
    else
    {
        [m_Options addObjectsFromArray:values];
        [m_Options sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    if (nil != m_tblOptions)
    {
        [m_tblOptions reloadData];
    }
}

- (void)setOptionsWithFloatArray:(NSArray *)options withStringFormat:(NSString *) format
{
    [m_Options removeAllObjects];
    if(format != nil)
    {
        for (NSNumber * value in options) {
            [m_Options addObject:[NSString stringWithFormat:format,[value floatValue]]];
        }
    }
    
    [m_Options sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (nil != m_tblOptions)
    {
        [m_tblOptions reloadData];
    }
}

- (void)setOptionsWithStringArray:(NSArray*)options
{
    [m_Options removeAllObjects];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:options];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    [m_Options addObjectsFromArray:arrayWithoutDuplicates];
    [m_Options sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (nil != m_tblOptions)
    {
        [m_tblOptions reloadData];
    }
}

- (void)setSelectedOptionInt:(int)option
{
    m_SelectedOption = option;
    if (nil != m_tblOptions)
    {
        [m_tblOptions reloadData];
    }
}

- (void)setSelectedValue:(NSString *)value;
{
    //m_SelectedValue = [value copy];
    NSUInteger idx = (int)[m_Options indexOfObject:value];
    if (idx == NSNotFound)
    {
        m_SelectedOption = -1;
    }
    else
    {
        m_SelectedOption = (int)idx;
    }
    if (nil != m_tblOptions)
    {
        [m_tblOptions reloadData];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_Options count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SINGLE_OPTION forIndexPath:indexPath];
    
    if (_cell == nil)
    {
        // toDo autoRelease
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SINGLE_OPTION];
    }
    
    [_cell.textLabel setTextColor:[UIColor getDarkModeLabelTextColor:self.view.traitCollection]];
    [_cell.textLabel setText:(NSString*)[m_Options objectAtIndex:cell_idx]];
    [_cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    //int selectedOption = [m_Options indexOfObject:m_SelectedValue];
    if (m_SelectedOption == cell_idx)
    {
        [_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [_cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return _cell;
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
    
    //NSUInteger selectedOption =[m_Options indexOfObject:m_SelectedValue];
    //if (selectedOption == NSNotFound) {
    //    selectedOption = -1;
    //}
    
    if (m_SelectedOption != cell_idx)
    {
        if (-1 != m_SelectedOption)
        {
            NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:m_SelectedOption inSection:0];
            UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:prevIndexPath];
            [tableView deselectRowAtIndexPath:prevIndexPath animated:NO];
            if (prevCell.accessoryType == UITableViewCellAccessoryCheckmark) {
                prevCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        m_SelectedOption = cell_idx;
        //m_SelectedValue = m_Options[cell_idx];
        [tableView selectRowAtIndexPath:indexPath animated:YES
                         scrollPosition:UITableViewScrollPositionMiddle];
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

        if (nil != m_Delegate)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PROFILE_UPDATED_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:PROFILE_OPENED_KEY];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PROFILE_OPENED_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [m_Delegate didChangeSelectedOption:m_Options[cell_idx]];
        }
    }
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
