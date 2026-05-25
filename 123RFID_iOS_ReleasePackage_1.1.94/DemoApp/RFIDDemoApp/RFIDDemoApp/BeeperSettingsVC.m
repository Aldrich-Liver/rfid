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
 *  Description:  BeeperSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BeeperSettingsVC.h"
#import "UIColor+DarkModeExtension.h"

#define ZT_VC_BEEPER_CELL_IDX_SLED_BEEPER                 0
#define ZT_VC_BEEPER_CELL_IDX_HOST_BEEPER                 1
#define ZT_VC_BEEPER_CELL_IDX_VOLUME                      2
#define ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER               3

#define ZT_VC_BEEPER_CELL_TAG_SLED_BEEPER                 0
#define ZT_VC_BEEPER_CELL_TAG_HOST_BEEPER                 1
#define ZT_VC_BEEPER_CELL_TAG_VOLUME                      2
#define ZT_VC_BEEPER_CELL_TAG_VOLUME_PICKER               3

@interface zt_BeeperSettingsVC ()

@end

/* TBD: save beeper settings on "back" button */
/* TBD: save & apply (?) configuration during hide */
@implementation zt_BeeperSettingsVC

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
    [m_tblBeeperOptions release];
    
    if (nil != m_cellSledBeeper)
    {
        [m_cellSledBeeper release];
    }
    
    if (nil != m_cellHostBeeper)
    {
        [m_cellHostBeeper release];
    }
    
    if(nil != m_cellVolumeLevel){
        [m_cellVolumeLevel release];
    }
    if (nil != m_cellVolumePicker)
    {
        [m_cellVolumePicker release];
    }
      
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    m_LocalConfig = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    /* configure table view */
    [m_tblBeeperOptions setDelegate:self];
    [m_tblBeeperOptions setDataSource:self];
    [m_tblBeeperOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    [m_tblBeeperOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    [m_tblBeeperOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblBeeperOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Beeper"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblBeeperOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblBeeperOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblBeeperOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblBeeperOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    [self setupConfigurationInitial];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    if (inventoryRequested == NO) {
        self.view.userInteractionEnabled = YES;
        m_tblBeeperOptions.userInteractionEnabled = YES;
    }else
    {
        self.view.userInteractionEnabled = NO;
        m_tblBeeperOptions.userInteractionEnabled = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPreconfiguredOptionCells
{
    m_cellSledBeeper = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    m_cellVolumePicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_cellVolumeLevel = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellHostBeeper = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    
    [m_cellSledBeeper setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellHostBeeper setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellVolumeLevel setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellVolumePicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [m_cellSledBeeper setInfoNotice:SLED_BEEPER_TEXT];
    [m_cellHostBeeper setInfoNotice:HOST_BEEPER_TEXT];
    [m_cellVolumeLevel setInfoNotice:BEEPER_VOLUME_TEXT];
    
    /* delegates */
    [m_cellSledBeeper setCellTag:ZT_VC_BEEPER_CELL_TAG_SLED_BEEPER];
    [m_cellHostBeeper setCellTag:ZT_VC_BEEPER_CELL_TAG_HOST_BEEPER];
    [m_cellVolumeLevel setCellTag:ZT_VC_BEEPER_CELL_TAG_VOLUME];
    [m_cellVolumePicker setCellTag:ZT_VC_BEEPER_CELL_TAG_VOLUME_PICKER];
    [m_cellSledBeeper setDelegate:self];
    [m_cellHostBeeper setDelegate:self];
    [m_cellVolumeLevel setDelegate:self];
    [m_cellVolumePicker setDelegate:self];
}

- (void)setupConfigurationInitial
{
    BOOL sled_beeper = [m_LocalConfig currentBeeperEnable];
    [m_cellSledBeeper setOption:sled_beeper];
    
    BOOL host_beeper = [m_LocalConfig hostBeeperEnable];
    [m_cellHostBeeper setOption:host_beeper];

    [m_cellVolumePicker setChoices:[m_LocalConfig.mapperBeeper getStringArray]];
    
    int sled_volume = [m_LocalConfig currentBeeperLevel];
    [m_cellVolumePicker setSelectedChoice:sled_volume];
    [m_cellVolumeLevel setData:(NSString *)[m_LocalConfig.mapperBeeper getStringByEnum:sled_volume]];
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
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL sled_beeper = [m_LocalConfig currentBeeperEnable];
    BOOL host_beeper = [m_LocalConfig hostBeeperEnable];
    return 1 + ((YES == sled_beeper) ? 1 : 1)+ ((YES == host_beeper) ? 1:1) + ((YES == isPickerShown) ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
   if (ZT_VC_BEEPER_CELL_IDX_SLED_BEEPER == cell_idx)
    {
        cell = m_cellSledBeeper;
    }
   else if (ZT_VC_BEEPER_CELL_IDX_HOST_BEEPER == cell_idx)
   {
       cell = m_cellHostBeeper;
   }
   else if (ZT_VC_BEEPER_CELL_IDX_VOLUME == cell_idx)
   {
       cell = m_cellVolumeLevel;
   }
    
    if (isPickerShown && ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER == cell_idx)
    {
        cell =  m_cellVolumePicker;
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
    
    if (ZT_VC_BEEPER_CELL_IDX_SLED_BEEPER == cell_idx)
    {
        [m_cellSledBeeper darkModeCheck:self.view.traitCollection];
        return m_cellSledBeeper;
    }
    else if (ZT_VC_BEEPER_CELL_IDX_HOST_BEEPER == cell_idx)
    {
        [m_cellHostBeeper darkModeCheck:self.view.traitCollection];
        return m_cellHostBeeper;
    }
    else if (ZT_VC_BEEPER_CELL_IDX_VOLUME == cell_idx)
    {
        [m_cellVolumeLevel darkModeCheck:self.view.traitCollection];
        return m_cellVolumeLevel;
    }
    if (isPickerShown)
    {
        return m_cellVolumePicker;
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [UIView setAnimationsEnabled:YES];
    
    if(ZT_VC_BEEPER_CELL_IDX_VOLUME == cell_idx)
    {
        if(isPickerShown)
        {
            isPickerShown = NO;
            [m_tblBeeperOptions deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            isPickerShown = YES;
            
            int sled_volume = [m_LocalConfig currentBeeperLevel];
            [m_cellVolumePicker setSelectedChoice:sled_volume];
            
            [m_tblBeeperOptions insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [m_tblBeeperOptions scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    if(ZT_VC_BEEPER_CELL_IDX_SLED_BEEPER == cell_idx)
    {
        if(isPickerShown)
        {
            isPickerShown = NO;
            [m_tblBeeperOptions deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    if(ZT_VC_BEEPER_CELL_IDX_HOST_BEEPER == cell_idx)
    {
        if(isPickerShown)
        {
            isPickerShown = NO;
            [m_tblBeeperOptions deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:ZT_VC_BEEPER_CELL_IDX_VOLUME_PICKER inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    //[self.view endEditing:YES];
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    int tag = [option_cell getCellTag];
    
    if (ZT_VC_BEEPER_CELL_TAG_VOLUME_PICKER == tag)
    {
        int sled_volume = [(zt_PickerCellView*)option_cell getSelectedChoice];
        [m_LocalConfig setCurrentBeeperLevel:[m_LocalConfig.mapperBeeper getEnumByIndx:sled_volume]];
        [m_cellVolumeLevel setData:(NSString *)[[m_LocalConfig.mapperBeeper getStringArray] objectAtIndex:sled_volume]];
    }
    else if (ZT_VC_BEEPER_CELL_TAG_SLED_BEEPER == tag)
    {
        isPickerShown = NO;
        BOOL previous = [m_LocalConfig currentBeeperEnable];
        BOOL sled_beeper = [(zt_SwitchCellView*)option_cell getOption];
        
        if (previous != sled_beeper)
        {
            [m_LocalConfig setCurrentBeeperEnable:sled_beeper];
            [m_tblBeeperOptions reloadData];
        }
    }
    else if (ZT_VC_BEEPER_CELL_TAG_HOST_BEEPER == tag)
    {
        isPickerShown = NO;
        BOOL previous = [m_LocalConfig hostBeeperEnable];
        BOOL host_beeper = [(zt_SwitchCellView*)option_cell getOption];

        if (previous != host_beeper)
        {
            [[NSUserDefaults standardUserDefaults] setBool:host_beeper forKey:ZT_APP_CFG_HOST_BEEPER_ENABLED];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [m_LocalConfig setHostBeeperEnable:host_beeper];
            [m_tblBeeperOptions reloadData];
        }
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
    m_tblBeeperOptions.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [m_tblBeeperOptions reloadData];
}
@end
