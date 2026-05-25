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
 *  Description:  HomeVCConstraints.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "HomeVCConstraints.h"
#import "UIColor+DarkModeExtension.h"
#import "RFIDDemoApp-Swift.h"

@interface zt_HomeVCConstraints ()

@property (nonatomic, strong) UIButton *m_btnRapidRead;
@property (nonatomic, strong) UIButton *m_btnInventory;
@property (nonatomic, strong) UIButton *m_btnSettings;
@property (nonatomic, strong) UIButton *m_btnLocateTag;
@property (nonatomic, strong) UIButton *m_btnFilter;
@property (nonatomic, strong) UIButton *m_btnAccess;
@property (nonatomic, strong) UIStackView *row1_View;
@property (nonatomic, strong) UIStackView *row2_View;
@property (nonatomic, strong) UIStackView *row3_View;

@property (nonatomic, strong) NSNumber *m_padding;
@property (nonatomic) BOOL filterWasOpened;
@end

@implementation zt_HomeVCConstraints

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
       
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    if (_filterWasOpened) {
        _filterWasOpened = NO;
        
        zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        
        if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            //zt_AlertView *alert = [[zt_AlertView alloc] init];
            //[alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
            return;
        }
        
        
        if ((localSled.applyFirstFilter &&
             ![zt_SledConfiguration isPrefilterEqual:localSled.currentPrefilters[0] withPrefilter:sled.currentPrefilters[0]]) ||
            (localSled.applySecondFilter &&
             ![zt_SledConfiguration isPrefilterEqual:localSled.currentPrefilters[1] withPrefilter:sled.currentPrefilters[1]]) ||
            (localSled.applyFirstFilter != sled.applyFirstFilter || localSled.applySecondFilter != sled.applySecondFilter)
            )

        {
            BOOL valid = true;
    
            if (YES == localSled.applyFirstFilter)
            {
                valid = [localSled isPrefilterValid:localSled.currentPrefilters[0]];
            }
            if (YES == valid)
            {
                if (YES == localSled.applySecondFilter)
                {
                    valid = [localSled isPrefilterValid:localSled.currentPrefilters[1]];
                }
            }
            
            if (YES == valid)
            {
                [self applyNewSetting:@"Saving filter settings"];
                return;
            }
            else
            {
                [self showInvalidParamsWarning];
            }
        }
        else
        {
            return;
        }
    
        // if we get here, that means some parameters are invalid
        // restore values if need
        [[zt_RfidAppEngine sharedAppEngine] restorePrefilters];
        [self darkModeCheck:self.view.traitCollection];
    }
    
}
                   
- (void)showWarning:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        zt_AlertView *alertView = [[zt_AlertView alloc]init];
//        [alertView showSuccessFailureWithText:self.view isSuccess:NO aSuccessMessage:@"" aFailureMessage:message];
        [self showOnlyMessageWithDurationWithMessage:message time:2];
    });
}
           
                   
- (void)applyNewSetting:(NSString *)message
{
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(updateFilters) withObject:nil withString:message];
}

- (void)updateFilters
{
    NSString *response;
    SRFID_RESULT result = [[zt_RfidAppEngine sharedAppEngine] setPrefilters:&response];
    
    [self handleCommandResult:result withStatusMessage:response];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRapidReadPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_RAPID_READ_VC_IDX];
}

- (IBAction)btnInventoryPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_INVENTORY_VC_IDX];
}

- (IBAction)btnSettingsPressed:(id)sender
{
    zt_SettingsVC*settings_vc = (zt_SettingsVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SETTINGS_VC"];
    
    if (nil != settings_vc)
    {
        [[self navigationController] pushViewController:settings_vc animated:YES];
    }
}

- (IBAction)btnLocateTagPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_LOCATE_TAG_VC_IDX];
}

- (IBAction)btnFilterPressed:(id)sender
{
    zt_FilterConfigVC *filter_vc = (zt_FilterConfigVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_FILTER_CONFIG_VC"];
    
    if (nil != filter_vc)
    {
        _filterWasOpened = YES;
        [[self navigationController] pushViewController:filter_vc animated:YES];
    }
}

- (IBAction)btnAccessPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_ACCESS_VC_IDX];
}


- (void)showTabInterfaceActiveView:(int)identifier
{
    zt_RFIDTabVC *tab_vc = (zt_RFIDTabVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_RFID_TAB_VC"];
    [tab_vc setActiveView:identifier];
    
    if (nil != tab_vc)
    {
        [[self navigationController] pushViewController:tab_vc animated:YES];
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.m_btnRapidRead.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.m_btnInventory.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.m_btnSettings.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.m_btnLocateTag.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.m_btnFilter.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.m_btnAccess.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
   
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
