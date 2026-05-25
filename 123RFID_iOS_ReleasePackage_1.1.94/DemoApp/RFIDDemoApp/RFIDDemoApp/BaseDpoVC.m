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
 *  Description:  BaseDpoVC.m
 *
 *  Notes: Base View Controller that contains functionality common
 *         to multiple view controllers including:
 *             - Dynamic Power Optimization UIBarButtonItem
 *             - ...
 *
 ******************************************************************************/

#import "BaseDpoVC.h"
#import "BatteryStatusVC.h"
#import "RfidAppEngine.h"

// Bar Button Item - Battery - States
typedef enum
{
    BATTERY_LEVEL_EMPTY = 0,    // Battery level is empty
    BATTERY_LEVEL_25,           // Battery level is 25% full
    BATTERY_LEVEL_50,           // Battery level is 50% full
    BATTERY_LEVEL_75,           // Battery level is 75% full
    BATTERY_LEVEL_100,          // Battery level is 100% full
    TOTAL_BATTERY_LEVELS
    
} BATTERY_LEVEL;

@interface BaseDpoVC ()
{
    NSTimer *batteryRequestTimer;
}

@end

@implementation BaseDpoVC

// Bar Button Item - DPO - Properties
static const int kBarButtonHeightDpo = 30;
static const int kBarButtonWidthDpo = 20;

// Bar Button Item - DPO - Images
//
// Note: There's two sets of images, one when DPO is enabled, and one when DPO is disabled.
//       The set listed below is for when DPO is disabled. Append "_dpo" to the image
//       names listed below to retrieve the DPO version.
//
static NSString *kImageBatteryLevelEmpty = @"bat_lvl_empty"; // battery level:  empty
static NSString *kImageBatteryLevel25 = @"bat_lvl_25";       // battery level:  25%
static NSString *kImageBatteryLevel50 = @"bat_lvl_50";       // battery level:  50%
static NSString *kImageBatteryLevel75 = @"bat_lvl_75";       // battery level:  75%
static NSString *kImageBatteryLevel100 = @"bat_lvl_100";     // battery level:  100%

// KVO - Dpo enable state
static NSString *kKeyPathDpoEnable = @"currentDpoEnable";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.

    // Create the bar button item for DPO
    [self createBarButtonDpo];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    // observe "currentDpoEnable" property changes using KVO
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] addObserver:self
        forKeyPath:kKeyPathDpoEnable
        options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld
        context:nil];
    
    // Register for device list change event
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    // Register for battery event
    [[zt_RfidAppEngine sharedAppEngine] addBatteryEventDelegate:self];
    
    // request battery status so we know how much battery is left
    [self requestBatteryStatus];
    
    // refresh dpo bar button item
    [self refreshDpoButton];
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    // Create a timer that requests the battery status once every 60 seconds (f = 1 Hz)
    batteryRequestTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(requestBatteryStatus) userInfo:nil repeats:YES];
    
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Stop observing the "currentDpoEnable" property changes
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] removeObserver:self forKeyPath:kKeyPathDpoEnable];
    
    // Unregister for device list change event
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];
    
    // Unregister for battery event
    [[zt_RfidAppEngine sharedAppEngine] removeBatteryEventDelegate:self];
    
    if (nil != batteryRequestTimer)
    {
        [batteryRequestTimer invalidate];
        batteryRequestTimer = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void) createBarButtonDpo
{
    UIButton *barBt =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, kBarButtonWidthDpo, kBarButtonHeightDpo)];

    [barBt setImage:[UIImage imageNamed:kImageBatteryLevelEmpty] forState:UIControlStateNormal];
    [barBt addTarget:self action: @selector(barButtonDpoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Fixed width
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:barBt
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:kBarButtonWidthDpo];
    // Fixed Height
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:barBt
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:kBarButtonHeightDpo];
    
    // Add the size constraints
    [barBt addConstraints:@[widthConstraint, heightConstraint]];
    
    barButtonDpo = [[UIBarButtonItem alloc] init];
    [barButtonDpo setEnabled:NO];
    [barButtonDpo setCustomView:barBt];
    
}

- (void)requestBatteryStatus
{
    // Request the battery status if there is an active reader
    if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        [[zt_RfidAppEngine sharedAppEngine] requestBatteryStatus:nil];
    }
}

- (IBAction) barButtonDpoAction:(id)sender
{
    zt_BatteryStatusVC *batteryStatusVc = (zt_BatteryStatusVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_BATTERY_STATUS_VC"];
    
    [self.navigationController pushViewController:batteryStatusVc animated:YES];
}

// Get the name of the image that corresponds to a battery level
- (NSString *) imageNameForBatteryLevel : (BATTERY_LEVEL) bLevel
{
    NSString *result = nil;
    
    switch(bLevel) {
        case BATTERY_LEVEL_EMPTY:
            result = kImageBatteryLevelEmpty;
            break;
        case BATTERY_LEVEL_25:
            result = kImageBatteryLevel25;
            break;
        case BATTERY_LEVEL_50:
            result = kImageBatteryLevel50;
            break;
        case BATTERY_LEVEL_75:
            result = kImageBatteryLevel75;
            break;
        case BATTERY_LEVEL_100:
            result = kImageBatteryLevel100;
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected Battery Level"];
    }
    
    return result;
}

- (BATTERY_LEVEL) getBatteryLevelForPercent : (int) batteryLevelPercent
{
    if (batteryLevelPercent > 0 && batteryLevelPercent <= 25)
    {
        return BATTERY_LEVEL_25;
    }
    else if (batteryLevelPercent > 25 && batteryLevelPercent <= 50)
    {
        return BATTERY_LEVEL_50;
    }
    else if (batteryLevelPercent > 50 && batteryLevelPercent <= 75)
    {
        return BATTERY_LEVEL_75;
    }
    else if (batteryLevelPercent > 75)
    {
        return BATTERY_LEVEL_100;
    }
    else
    {
        return BATTERY_LEVEL_EMPTY;
    }
}

- (void) updateDpoButtonForBatteryLevel : (BATTERY_LEVEL) bLevel andDpoEnableState:(BOOL) dpoEnable
{
    if (barButtonDpo != nil)
    {
        // Check if there is a connected reader
        if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            // Connected reader detected!
            
            // Enable user interaction with button, and update image based on battery level and dpo enable state
            dispatch_async(dispatch_get_main_queue(), ^{
                //update UI in main thread.
                [barButtonDpo setEnabled:YES];
            });
                        
            // Create image name string
            NSMutableString *dpoButtonImageName = [[NSMutableString alloc] initWithString:[self imageNameForBatteryLevel:bLevel]];
            
            // If DPO is enabled, append "_dpo" to image name string
            if (dpoEnable)
            {
                [dpoButtonImageName appendString:@"_dpo"];
            }
            
            // Set the image
            dispatch_async(dispatch_get_main_queue(), ^{

                           // do work here to Usually to update the User Interface

                            [(UIButton *)[barButtonDpo customView] setImage:[UIImage imageNamed:dpoButtonImageName] forState:UIControlStateNormal];

            });
        }
        else
        {
            // There is no connected reader!
            
            // Disable user interaction with button, and leave the image set to the last known state
            [barButtonDpo setEnabled:NO];
            
            // Set image to empty battery as placeholder when no reader is connected
            [(UIButton *)[barButtonDpo customView] setImage:[UIImage imageNamed:kImageBatteryLevelEmpty] forState:UIControlStateNormal];
        }
    }
}

- (void) refreshDpoButton
{
    // Get the current battery level
    srfidBatteryEvent *batteryInfo = [[zt_RfidAppEngine sharedAppEngine] getBatteryInfo];
    int batteryLevelPercent = [batteryInfo getPowerLevel];
    BATTERY_LEVEL currentBatteryLevel = [self getBatteryLevelForPercent:batteryLevelPercent];

    // Get the current dpo enable state
    BOOL currentDynamicPowerEnableState = [[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentDpoEnable] boolValue];

    // Update the DPO bar button based on the current battery level and DPO enable state
    [self updateDpoButtonForBatteryLevel:currentBatteryLevel andDpoEnableState:currentDynamicPowerEnableState];
}

#pragma zt_IRfidAppEngineDevListDelegate

- (BOOL) deviceListHasBeenUpdated
{
    [self refreshDpoButton];
    
    return TRUE;
}

#pragma zt_IRfidAppEngineBatteryEventDelegate

- (BOOL) onNewBatteryEvent
{
    [self refreshDpoButton];
    
    return TRUE;
}

#pragma mark - KVO observer methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // detect if the current dpo enable value has changed
    if ([keyPath isEqual:kKeyPathDpoEnable])
    {
        [self refreshDpoButton];
    }
}

@end
