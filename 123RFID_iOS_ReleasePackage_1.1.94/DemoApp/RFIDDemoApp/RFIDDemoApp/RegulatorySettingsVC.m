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
 *  Description:  RegulatorySettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RegulatorySettingsVC.h"
#import "RfidAppEngine.h"
#import "AlertView.h"
#import "ui_config.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"

#define ZT_VC_REGULATORY_SECTION_IDX_REGION                   0
#define ZT_VC_REGULATORY_SECTION_IDX_CHANNEL                  1

#define ZT_VC_REGULATORY_CELL_IDX_REGION                      0

#define ZT_VC_REGULATORY_OPTION_ID_NOT_AN_OPTION              -1

#define CHECKED_IMAGE @"checkbox_checked_icon"
#define UN_CHECKED_IMAGE @"checkbox_icon"

@interface zt_RegulatorySettingsVC ()

@end

@implementation zt_RegulatorySettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_OffscreenSwitchCell = [[zt_SwitchCellView alloc] init];
        
        m_btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(btnSavePressed)];
        
        m_ModalMode = NO;
        m_HasAppeared = NO;
        checkBoxStatus = NO;
        valueDidChanged = NO;
        
        if ([[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions] count]==0) {
                   //[[zt_RfidAppEngine sharedAppEngine] getSupportedRegions:nil];
        }
               
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_OffscreenSwitchCell)
    {
        [m_OffscreenSwitchCell release];
    }
    if (nil != m_btnSave)
    {
        [m_btnSave release];
    }
    
    [m_tblRegulatoryOptions release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblRegulatoryOptions setDelegate:self];
    [m_tblRegulatoryOptions setDataSource:self];
    [m_tblRegulatoryOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    [m_tblRegulatoryOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblRegulatoryOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Regulatory"];
    // Change the 'Save' button color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self createCustomBack];
    
//    UIBarButtonItem *GoBackToSettingsViewButton = [[UIBarButtonItem alloc] initWithTitle:@"< Settings" style:UIBarButtonItemStyleDone target:self action:@selector(GoBackToSettingsView)];
//    self.navigationItem.leftBarButtonItem = GoBackToSettingsViewButton;
//    [GoBackToSettingsViewButton release];
    
    [self configureWarningTextView];
}

-(IBAction)GoBackToSettingsView {
    zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    if ([[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8] || [[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR]) {
        if (0 == [[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionChannelList] count])
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:ZT_RFID_APP_NAME
                                         message:@"At least one channel shall be enabled"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* cancelButton = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * action) {
                //Handle cancel button here
            }];
            
            [alert addAction:cancelButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if (!checkBoxStatus && valueDidChanged)
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:ZT_RFID_APP_NAME
                                         message:@"Please accept the responsibility for selecting the correct country of operation"
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
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else
    {
        if (0 == [[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionChannelList] count])
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:ZT_RFID_APP_NAME
                                         message:@"At least one channel shall be enabled"
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
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)createCustomBack
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];

    // Create and configure the UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_icon"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(-5, 0, 26, 26); // Adjust the frame as needed
    [customView addSubview:imageView];

    // Create and configure the UILabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 80, 26)]; // Adjust the frame as needed
    label.text = @"Settings";
    label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular]; // Adjust the font size as needed
    label.textColor = [UIColor whiteColor]; // Adjust the text color as needed
    [customView addSubview:label];

    
    // Add a tap gesture recognizer to the custom view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GoBackToSettingsView)];
    [customView addGestureRecognizer:tapGestureRecognizer];
    
    // Create the UIBarButtonItem with the custom view
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    self.navigationItem.leftBarButtonItem = customBackButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (YES == m_ModalMode)
    {
        NSMutableArray *right_items = [[NSMutableArray alloc] init];
        
        [right_items addObject:m_btnSave];
        
        self.navigationItem.rightBarButtonItems = right_items;
        
        [right_items removeAllObjects];
        [right_items release];
        
    }
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    [self setupConfigurationInitial];
    
    if (inventoryRequested == NO) {
        self.view.userInteractionEnabled = YES;
        m_tblRegulatoryOptions.userInteractionEnabled = YES;
    }else
    {
        self.view.userInteractionEnabled = NO;
        m_tblRegulatoryOptions.userInteractionEnabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    if (YES == m_ModalMode)
    {
        if (NO == m_HasAppeared)
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
            
            m_HasAppeared = YES;
        }
    }
}

-(void)configureWarningTextView
{
    zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    if ([[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8] || [[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR]) {
        
        NSString *warningText = @"Warning: This Zebra device operates in different cybersecurity modes to meet the requirements of the selected country. This Zebra device will only comply with the cybersecurity requirements of the EU Radio Equipment Directive (RED) Article 3.3 (d) by selecting a country which requires compliance to EU regulations. Therefore, anyone configuring this Zebra device accepts full responsibility for correctly selecting the country of operation to ensure regulatory compliance.";
        [warningLabel setText:warningText];
        
        UIFont *font = [UIFont systemFontOfSize:15];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat constrainedWidth = screenWidth - 30;
        CGFloat calculatedHeight = [self heightForString:warningText withFont:font constrainedToWidth:constrainedWidth];
        mainView_heightConstraint.constant = calculatedHeight + 90;
        subView_heightConstraint.constant = 50;
        [self.btnCheckBox setHidden:NO];
        [self.view layoutIfNeeded];
        
        [self enableAndDisableCheckBox];
        
    }else
    {
        [warningLabel setText:@"Warning: Please select only the country in which you are using the reader"];
        
        mainView_heightConstraint.constant = 60;
        subView_heightConstraint.constant = 0;
        [self.btnCheckBox setHidden:YES];
        [self.view layoutIfNeeded];
    }
}

- (CGFloat)heightForString:(NSString *)string withFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    // Define the maximum size we want to calculate the height for
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    
    // Define the attributes dictionary with the font
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    // Calculate the bounding rectangle for the string
    CGRect boundingRect = [string boundingRectWithSize:maxSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
    
    // Return the calculated height
    return ceil(boundingRect.size.height);
}

- (void)enableAndDisableCheckBox
{
    checkBoxStatus = [[NSUserDefaults standardUserDefaults] boolForKey:REGULATORY_CHECKBOX_KEY];
    if(checkBoxStatus) {
        [self.btnCheckBox setImage:[UIImage imageNamed:CHECKED_IMAGE] forState:UIControlStateNormal];
    }
    else {
        [self.btnCheckBox setImage:[UIImage imageNamed:UN_CHECKED_IMAGE] forState:UIControlStateNormal];
    }
}

- (void)createPreconfiguredOptionCells
{
    m_cellRegion = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellRegion setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellRegion setInfoNotice:@"Region"];
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(int)row
{
    NSMutableArray *regions = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions];
    int selectedRegion =[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfCurrentRegion];
    zt_RegionData *rdata = (zt_RegionData*)[regions objectAtIndex:selectedRegion];
    
    NSString *_channel = [[rdata supporteChannels] objectAtIndex:row];
    BOOL is_enabled = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] isChannelEnabled:_channel forRegion:[rdata regionCode]];
    
    [cell setInfoNotice:_channel];
    [cell setOption:is_enabled];
    [cell setCellTag:row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    
    [cell setEnabled:rdata.hoppingConfigurable];
}

- (void)setupConfigurationInitial
{
    NSMutableArray *regions = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions];
    NSString *cur_region = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionCode];
    if (NSOrderedSame != [cur_region caseInsensitiveCompare:@"NA"])
    {
        int selectedRegion =[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfCurrentRegion];
        [m_cellRegion setData:[[regions objectAtIndex:selectedRegion] regionName]];
    }
    else
    {
        [m_cellRegion setData:@"Not Selected"];
    }
    
}

- (void)setModalMode:(BOOL)enabled
{
    m_ModalMode = enabled;
}

-(IBAction)AcceptRequlatoryPolicy:(id)sender
{
    checkBoxStatus = [[NSUserDefaults standardUserDefaults] boolForKey:REGULATORY_CHECKBOX_KEY];
    if(checkBoxStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:UN_CHECKED_IMAGE] forState:UIControlStateNormal];
                [self.btnCheckBox layoutIfNeeded];
            }];
            checkBoxStatus = NO;
            [[NSUserDefaults standardUserDefaults] setBool:checkBoxStatus forKey:REGULATORY_CHECKBOX_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView performWithoutAnimation:^{
                [self.btnCheckBox setImage:[UIImage imageNamed:CHECKED_IMAGE] forState:UIControlStateNormal];
                    [self.btnCheckBox layoutIfNeeded];
                }];
            checkBoxStatus = YES;
            [[NSUserDefaults standardUserDefaults] setBool:checkBoxStatus forKey:REGULATORY_CHECKBOX_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
}


- (void)btnSavePressed
{
    NSString *code = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionCode];
    
    if (NSOrderedSame == [code caseInsensitiveCompare:@"NA"])
    {
        /* nrv364: modal mode shall result in selection of region -> show error */
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"Region shall be selected"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           //Handle cancel button here
                                       }];
        
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    
    if (0 == [[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionChannelList] count])
    {
        /* nrv364: at least one channel shall be enabled for selected region
         (note: if hopping is not configurable all supported regions are supposed
         to be enabled by app automatically */
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:ZT_RFID_APP_NAME
                                     message:@"At least one channel shall be enabled"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           //Handle cancel button here
                                       }];
        
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    
    /* save configuration */
    [[zt_RfidAppEngine sharedAppEngine] setRegulatoryConfig:nil];
    
    /* disconnect & reconnect to configure default protocol parameters */
    [[zt_RfidAppEngine sharedAppEngine] establishAsciiConnection];
    /* dismiss */
   // [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.regulatoryDelegate updateProfileSettings];
    }];
}

/* ###################################################################### */
/* ########## ISelectionTableVCDelegate Protocol implementation ######### */
/* ###################################################################### */
- (void)didChangeSelectedOption:(NSString *)value
{
    zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    if ([[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8] || [[sled readerModel] containsString:ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR])
    {
        valueDidChanged = YES;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REGULATORY_CHECKBOX_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:REGULATORY_CHECKBOX_KEY];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self enableAndDisableCheckBox];
    }
    
    int selectedRegion = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfRegionWithName:value];
    NSString * code = [[[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions] objectAtIndex:selectedRegion] regionCode];
    [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] setCurrentRegionCode:code];
    
    /* nrv364: fill enabled channels with default values */
    [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] fillCurrentRegionChannelsListDefault];
    
    [m_cellRegion setData:value];
    
    SRFID_RESULT res = [[zt_RfidAppEngine sharedAppEngine] getAntennaConfiguration:nil];
    NSLog(@"%u", res);
    
    [m_tblRegulatoryOptions reloadData];
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
       
        /* nrv364: cell_value = OFF -> disable channel; cell_value = ON -> enable channel */
        
        NSMutableArray *regions = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions];
        int selectedRegion =[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfCurrentRegion];
        zt_RegionData *rdata = (zt_RegionData*)[regions objectAtIndex:selectedRegion];
        
        NSString *channel = (NSString*)[[rdata supporteChannels] objectAtIndex:cell_tag];
        
        if (YES == cell_value)
        {
            [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] enableCurrentRegionChannel:channel];
        }
        else
        {
            [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] disableCurrentRegionChannel:channel];
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

    BOOL region_not_set = (NSOrderedSame == [[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentRegionCode] caseInsensitiveCompare:@"NA"]);
    
    if (YES == region_not_set)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (ZT_VC_REGULATORY_SECTION_IDX_REGION == section)
    {
        return nil;
    }
    else if (ZT_VC_REGULATORY_SECTION_IDX_CHANNEL == section)
    {
        return @"Channel Selection";
    }
        
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (ZT_VC_REGULATORY_SECTION_IDX_REGION == section)
    {
        return 1;
    }
    else if (ZT_VC_REGULATORY_SECTION_IDX_CHANNEL == section)
    {
        NSMutableArray *regions = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions];
        int selectedRegion =[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfCurrentRegion];
        zt_RegionData *rdata = (zt_RegionData*)[regions objectAtIndex:selectedRegion];
        return [[rdata supporteChannels] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = (int)[indexPath section];
    
    CGFloat height = 0.0;
    
    UITableViewCell *_cell;
    
    if (ZT_VC_REGULATORY_SECTION_IDX_REGION == section)
    {
        _cell = m_cellRegion;
    }
    else if (ZT_VC_REGULATORY_SECTION_IDX_CHANNEL == section)
    {
        [self configureSwitchCell:m_OffscreenSwitchCell forRow:(int)[indexPath row]];
        _cell = m_OffscreenSwitchCell;
    }
    else
    {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unknownCell"];
    }
    
    [_cell setNeedsUpdateConstraints];
    [_cell updateConstraintsIfNeeded];
    
    [_cell setNeedsLayout];
    [_cell layoutIfNeeded];
    
    height = [_cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = (int)[indexPath section];
    
    UITableViewCell *cell;
    
    if (ZT_VC_REGULATORY_SECTION_IDX_REGION == section)
    {
        cell = m_cellRegion;
    }
    else if (ZT_VC_REGULATORY_SECTION_IDX_CHANNEL == section)
    {
        zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            // toDo add autorelease
            _cell = [[[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH] autorelease];
        }
        
        [self configureSwitchCell:_cell forRow:(int)[indexPath row]];
        
        [_cell setNeedsUpdateConstraints];
        [_cell updateConstraintsIfNeeded];
        [_cell darkModeCheck:self.view.traitCollection];
        cell = _cell;
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unknownCell"];
    }
    
   
    return cell;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int cell_idx = (int)[indexPath row];
    
    if (ZT_VC_REGULATORY_SECTION_IDX_REGION == [indexPath section])
    {
        if (ZT_VC_REGULATORY_CELL_IDX_REGION == cell_idx)
        {
            if([[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] supportedRegions] count]>[[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions] count])
            {
                NSString *status_msg = nil;
                SRFID_RESULT res = [[zt_RfidAppEngine sharedAppEngine] fetchAllRegionData:&status_msg];
                if (res != SRFID_RESULT_SUCCESS)
                {
                    /* proceed with error message */
                    NSString *error_msg = @"Failed to retrieve regions information";
                    if (SRFID_RESULT_RESPONSE_ERROR == res)
                    {
                        if (nil != status_msg)
                        {
                            error_msg = [NSString stringWithFormat:@"Failed to retrieve regions information: %@", status_msg];
                        }
                    }
                    else if (SRFID_RESULT_RESPONSE_TIMEOUT == res)
                    {
                        error_msg = [NSString stringWithFormat:@"Failed to retrieve regions information: timeout"];
                    }
                    else if (SRFID_RESULT_READER_NOT_AVAILABLE == res)
                    {
                        error_msg = [NSString stringWithFormat:@"Failed to retrieve regions information: no active reader"];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [zt_AlertView showInfoMessage:[[UIApplication sharedApplication] keyWindow].rootViewController.view withHeader:ZT_RFID_APP_NAME withDetails:error_msg withDuration:3];
                    });
                    return;
                }
            }
            
            zt_SelectionTableVC *vc = (zt_SelectionTableVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SELECTION_TABLE_VC"];
            [vc setDelegate:self];
            
            [vc setCaption:@"Region"];
            
            NSMutableArray *regionNames = [[NSMutableArray alloc] init];
            NSArray *regions = [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions];
            for (int i=0; i < [regions count]; i++) {
                [regionNames addObject:[[regions objectAtIndex:i] regionName]];
            }
            int selectedRegion =[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] indexOfCurrentRegion];

            [vc setOptionsWithStringArray:regionNames];
            [vc setSelectedOptionInt:selectedRegion];
            
            [regionNames release];
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    [self setupConfigurationInitial];
    [m_tblRegulatoryOptions reloadData];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];

}
@end
