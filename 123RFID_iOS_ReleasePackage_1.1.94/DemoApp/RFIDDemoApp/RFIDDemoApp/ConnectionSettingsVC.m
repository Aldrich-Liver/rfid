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
 *  Description:  ConnectionSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConnectionSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "AlertView.h"
#import "config.h"

#define ZT_VC_CONNECTION_SECTION_IDX_CONNECTION               0
#define ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION             1
#define ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT              2
#define ZT_VC_CONNECTION_SECTION_IDX_MATCH_MODE               3
#define ZT_VC_CONNECTION_SECTION_IDX_GLOBAL_SETTINGS          4

#define ZT_VC_CONNECTION_CELL_IDX_AUTO_RECONNECT              0

#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_AVAILABLE      0
#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_ACTIVE         1
#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_BATTERY        2

#define ZT_VC_CONNECTION_CELL_IDX_DATA_EXPORT_DATA            0

#define ZT_VC_CONNECTION_CELL_IDX_TAG_LIST                    0
#define ZT_VC_CONNECTION_CELL_IDX_FRIENDLY_NAMES              1

#define ZT_VC_CONNECTION_CELL_IDX_ASCII_MODE                  0
#define ZT_VC_CONNECTION_CELL_IDX_SGTIN96_MODE                1

#define ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT              0
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE      1
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE         2
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY        3
#define ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT                 4
#define ZT_VC_CONNECTION_CELL_TAG_LIST                        5
#define ZT_VC_CONNECTION_CELL_TAG_FRIENDLY_NAMES              6
#define ZT_VC_CONNECTION_CELL_TAG_ASCII_MODE                  7
#define ZT_VC_CONNECTION_CELL_TAG_SGTIN96_MODE                8

@interface zt_ConnectionSettingsVC ()

@end

@implementation zt_ConnectionSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_OptionsHeaders = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_HEADER_CONNECTION, ZT_STR_SETTINGS_CONNECTION_HEADER_NOTIFICATION,ZT_STR_SETTINGS_CONNECTION_HEADER_DATA_EXPORT, ZT_STR_SETTINGS_CONNECTION_HEADER_MATCH_MODE, ZT_STR_SETTINGS_CONNECTION_HEADER_GLOBAL_SETTINGS, nil];
        m_OptionsConnection = [[NSArray alloc] initWithObjects:
            ZT_STR_SETTINGS_CONNECTION_AUTO_RECONNECT,
            nil];
        m_OptionsNotification = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_AVAILABLE, ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_ACTIVE, ZT_STR_SETTINGS_CONNECTION_NOTIFICAtiON_BATTERY, nil];
        m_OptionsDataExport = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_DATA_EXPORT, nil];
        m_OptionsMatchMode = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_TAG_LIST, ZT_STR_SETTINGS_CONNECTION_FRIENDLY_NAMES, nil];
        m_OptionsGlobalSettings = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_ASCII_MODE, ZT_STR_SETTINGS_CONNECTION_SGTIN96_MODE, nil];
        
        m_OffscreenSwitchCell = [[zt_SwitchCellView alloc] init];
        isUpdated = NO;
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_OffscreenSwitchCell)
    {
        [m_OffscreenSwitchCell release];
    }
    if (nil != m_OptionsHeaders)
    {
        [m_OptionsHeaders release];
    }
    if (nil != m_OptionsConnection)
    {
        [m_OptionsConnection release];
    }
    if (nil != m_OptionsNotification)
    {
        [m_OptionsNotification release];
    }
    if (nil != m_OptionsDataExport)
    {
        [m_OptionsDataExport release];
    }
    [m_tblOptions release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:ZT_STR_SETTINGS_SECTION_APPLICATION];
    
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
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APPLICATION_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/// Notifies the view controller that its view was added to a view hierarchy
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(int)row inSection:(int)section
{
    NSArray *options = nil;
    
    switch (section) {
        case ZT_VC_CONNECTION_SECTION_IDX_CONNECTION:
            options = m_OptionsConnection;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION:
            options = m_OptionsNotification;
            break;
        
        case ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT:
            options = m_OptionsDataExport;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_MATCH_MODE:
            options = m_OptionsMatchMode;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_GLOBAL_SETTINGS:
            options = m_OptionsGlobalSettings;
            break;
            
        default:
            break;
    }

    [cell setInfoNotice:(NSString*)[options objectAtIndex:row]];
    
    if (ZT_VC_CONNECTION_SECTION_IDX_CONNECTION == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_AUTO_RECONNECT == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigConnectionAutoReconnection];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT];
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_ACTIVE == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationConnection];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_AVAILABLE == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationAvailable];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_BATTERY == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationBattery];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY];
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_DATA_EXPORT_DATA == row) {
            int option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigDataExport ];
            [cell setOption:option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT];
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_MATCH_MODE == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_TAG_LIST == row) {
            int option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
            [cell setUserInteraction:YES];
            [cell setOption:option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_LIST];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_FRIENDLY_NAMES == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigFriendlyNames];
            if ([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode])
            {
                [cell setUserInteraction:YES];
            }else
            {
                [cell setUserInteraction:NO];
            }
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_FRIENDLY_NAMES];
            
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_GLOBAL_SETTINGS == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_ASCII_MODE == row) {
            int option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode ];
            [cell setOption:option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_ASCII_MODE];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_SGTIN96_MODE == row) {
            int option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigSgtin96 ];
            [cell setOption:option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_SGTIN96_MODE];
        }
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

- (void)setupConfigurationInitial
{

}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        zt_SwitchCellView *_cell = (zt_SwitchCellView*)option_cell;
        int cell_tag = [_cell getCellTag];
        BOOL cell_value = [_cell getOption];
        isUpdated = YES;
        switch (cell_tag)
        {
            case ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigConnectionAutoReconnection:cell_value];
                [[zt_RfidAppEngine sharedAppEngine] setAutoReconect:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationConnection:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationAvailable:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationBattery:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigDataExport:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_LIST:
                
                if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested] && ![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested])
                {
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:cell_value];
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:cell_value];
                    isUpdated = YES;
                    if (cell_value) {
                        [self openSharedFiles];
                    }else
                    {
                        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:NO];
                        [m_tblOptions reloadData];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZT_TAGLIST_ARRAY_DEFAULTS_KEY];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }else
                {
                    isUpdated = NO;
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:0];
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:0];
                    [m_tblOptions reloadData];
                    [self showWarning:ZT_GENERAL_ERROR_MESSAGE];
                }
                break;
            case ZT_VC_CONNECTION_CELL_TAG_FRIENDLY_NAMES:
                
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:cell_value];
                [m_tblOptions reloadData];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_ASCII_MODE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigASCIIMode:cell_value];
                if (cell_value) {
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigSgtin96:false];
                    [m_tblOptions reloadData];
                }
                break;
            case ZT_VC_CONNECTION_CELL_TAG_SGTIN96_MODE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigSgtin96:cell_value];
                if (cell_value) {
                    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigASCIIMode:false];
                    [m_tblOptions reloadData];
                }
                
                break;
        }
        
        if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested] && [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing] && [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested] && cell_tag == ZT_VC_CONNECTION_CELL_TAG_LIST)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APPLICATION_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else
        {
            if (isUpdated) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APPLICATION_DEFAULTS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}
- (void)didBeginEditing:(id)option_cell
{
}
/// Show alert view with given message
/// @param message The message
- (void)showWarning:(NSString *)message
{
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:ZT_ALERTVIEW_WAITING_TIME];
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [m_OptionsHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (NSString*)[m_OptionsHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *options = nil;
    switch (section) {
        case ZT_VC_CONNECTION_SECTION_IDX_CONNECTION:
            options = m_OptionsConnection;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION:
            options = m_OptionsNotification;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT:
            options = m_OptionsDataExport;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_MATCH_MODE:
            options = m_OptionsMatchMode;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_GLOBAL_SETTINGS:
            options = m_OptionsGlobalSettings;
            break;
            
        default:
            break;
    }
    return [options count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    [self configureSwitchCell:m_OffscreenSwitchCell forRow:(int)[indexPath row] inSection:(int)[indexPath section]];
    
    [m_OffscreenSwitchCell setNeedsUpdateConstraints];
    [m_OffscreenSwitchCell updateConstraintsIfNeeded];
    
    [m_OffscreenSwitchCell setNeedsLayout];
    [m_OffscreenSwitchCell layoutIfNeeded];
    
    height = [m_OffscreenSwitchCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
    
    if (_cell == nil)
    {
        // toDo autoRelease
        _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    }
    
    [self configureSwitchCell:_cell forRow:(int)[indexPath row] inSection:(int)[indexPath section]];
    
    [_cell setNeedsUpdateConstraints];
    [_cell updateConstraintsIfNeeded];
    
    [_cell darkModeCheck:self.view.traitCollection];
    return _cell;
}
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    NSString *filePath = [NSString stringWithFormat:@"%@",url]; // Assume this is the full path to your file
    NSString *fileExtension = [filePath pathExtension];
    
    if ([fileExtension isEqualToString:@"csv"]) {
        if (controller.documentPickerMode == UIDocumentPickerModeImport) {
            // Condition called when user download the file
            NSData *fileData = [NSData dataWithContentsOfURL:url];
            if (fileData != nil) {
                NSString *taglistSring = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] createTagListArrayFromCsvFile:taglistSring];
                isUpdated = YES;
            }else
            {
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:NO];
            }
        }else
        {
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:NO];
        }
        [m_tblOptions reloadData];
    }else
    {
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APPLICATION_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isUpdated = NO;
        [self showWarning:@"Incorrect file format. Please select a .csv file."];
        [m_tblOptions reloadData];
    }
}

/// Tells the delegate that the user canceled the document picker.
/// @param controller The document picker that called this method.
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigMatchMode:NO];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigFriendlyNames:NO];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APPLICATION_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [m_tblOptions reloadData];
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
