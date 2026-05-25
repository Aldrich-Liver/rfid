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
 *  Description:  AboutVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AboutVC.h"
#import "ui_config.h"
#import "config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "ScannerEngine.h"

#define APP_VERSION  @"v.%@ "

@interface zt_AboutVC ()

@end

@implementation zt_AboutVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self)
    {

    }
    return self;
}

- (void)dealloc
{
    [m_lblOrganization release];
    [m_lblApplicationCaption release];
    [m_lblApplicationVersionNotice release];
    [m_lblApplicationVersionData release];
    [m_lblCopyright release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"About"];
    
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    [self configureAppearance];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];

}


/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    
}

- (BOOL)deviceListHasBeenUpdated
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureAppearance
{
    [m_lblOrganization setTextAlignment:NSTextAlignmentCenter];
    [m_lblApplicationCaption setTextAlignment:NSTextAlignmentCenter];
    [m_lblApplicationVersionNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblApplicationVersionData setTextAlignment:NSTextAlignmentLeft];
    [m_lblCopyright setTextAlignment:NSTextAlignmentCenter];
    [m_lblOrganization setTextColor:[UIColor lightGrayColor]];
    [m_lblApplicationCaption setTextColor:[UIColor lightGrayColor]];
    [m_lblApplicationVersionNotice setTextColor:[UIColor blackColor]];
    [m_lblApplicationVersionData setTextColor:[UIColor blackColor]];
    [m_lblCopyright setTextColor:[UIColor blackColor]];
    [m_lblOrganization setNumberOfLines:0];
    [m_lblApplicationCaption setNumberOfLines:0];
    [m_lblApplicationVersionNotice setNumberOfLines:1];
    [m_lblApplicationVersionData setNumberOfLines:1];
    [m_lblCopyright setNumberOfLines:0];
    [m_lblOrganization setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_BIG weight:UIFontWeightMedium]];
    [m_lblApplicationCaption setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_BIG weight:UIFontWeightMedium]];
    [m_lblApplicationVersionNotice setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblApplicationVersionData setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblCopyright setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_BIG weight:UIFontWeightMedium]];
    
    [m_lblOrganization setText:ZT_ORG_NAME];
    [m_lblApplicationCaption setText:ZT_INFO_RFID_APP_NAME];
    [m_lblOrganization setLineBreakMode:NSLineBreakByWordWrapping];
    [m_lblApplicationCaption setLineBreakMode:NSLineBreakByWordWrapping];

    [m_lblApplicationVersionNotice setText:ZT_RFID_APPLICATION_VERSION];
    [m_lblApplicationVersionData setText:[NSString stringWithFormat: @"v.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    
    [m_lblCopyright setText:[NSString stringWithFormat:@"%@ %@",  ZT_INFO_COPYRIGHT_YEAR, ZT_INFO_COPYRIGHT_TEXT]];
  
    [lableSdkVersionNumber setText:[NSString stringWithFormat: APP_VERSION,[[zt_RfidAppEngine sharedAppEngine] getSDKVersion]]];
    [lableSdkVersionTitle setText:ZT_RFID_SDK_VERSION];
    
    [lableBarcodeSdkVersionNumber setText:[NSString stringWithFormat: APP_VERSION,[[ScannerEngine sharedScannerEngine] getSDKVersion]]];
    [lableBarcodeSdkVersionTitle setText:ZT_BARCODE_SDK_VERSION];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_lblOrganization.textColor = [UIColor getDarkModeLabelTextColorForAbout:traitCollection];
    m_lblApplicationCaption.textColor = [UIColor getDarkModeLabelTextColorForAbout:traitCollection];
    m_lblApplicationVersionNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblApplicationVersionData.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblCopyright.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
