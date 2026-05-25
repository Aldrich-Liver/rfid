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
 *  Description:  BatteryStatusVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BatteryStatusVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"

//#define ZT_TEST_BATTERY_INDICATOR 1

@interface zt_BatteryStatusVC ()

@end

@implementation zt_BatteryStatusVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self)
    {
        m_BatteryRequestTimer = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* set title */
    [self setTitle:@"Battery"];
    
#ifdef ZT_TEST_BATTERY_INDICATOR
    UITapGestureRecognizer * _gestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(testBatteryIndicator)];
    [_gestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:_gestureRecognizer];
    [_gestureRecognizer release];
    _tst_BatteryLevel = 98;
    _tst_BatteryCharging = NO;
#endif /* ZT_TEST_BATTERY_INDICATOR */

    [m_lblBatteryPercent setText:@"Loading..."];
    [m_lblBatteryStatus setText:@"Loading..."];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self batteryStatusDidChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[zt_RfidAppEngine sharedAppEngine] addBatteryEventDelegate:self];
    
    /* request battery info */
    [self requestBatteryStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_BatteryRequestTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(requestBatteryStatus) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeBatteryEventDelegate:self];
    if (nil != m_BatteryRequestTimer)
    {
        [m_BatteryRequestTimer invalidate];
        m_BatteryRequestTimer = nil;
    }
}

- (void)batteryStatusDidChanged
{
    int _level = 0;
    BOOL _charging = NO;
    
    srfidBatteryEvent *battery_info = [[zt_RfidAppEngine sharedAppEngine] getBatteryInfo];
    
    _level = [battery_info getPowerLevel];
    _charging = [battery_info getIsCharging];
    
#ifdef ZT_TEST_BATTERY_INDICATOR
    _level = _tst_BatteryLevel;
    _charging = _tst_BatteryCharging;
#endif /* ZT_TEST_BATTERY_INDICATOR */
    
    [m_lblBatteryPercent setText:[NSString stringWithFormat:@"%d %%", _level]];
    
    [m_lblBatteryStatus setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    
    /* nrv364 */
    if (YES == _charging)
    {
        if (100 == _level)
        {
            [m_lblBatteryStatus setText:@"Status: Battery is fully charged"];
        }
        else
        {
            [m_lblBatteryStatus setText:@"Status: Charging"];
        }
    }
    else
    {
        NSString *battery_criticial_status = [[zt_RfidAppEngine sharedAppEngine] getBatteryStatusString];
        if (NSOrderedSame == [battery_criticial_status caseInsensitiveCompare:ZT_BATTERY_EVENT_CAUSE_CRITICAL])
        {
            [m_lblBatteryStatus setText:@"Status: Battery level is critical"];
            [m_lblBatteryStatus setTextColor:[UIColor colorWithRed:0.9f green:0.0f blue:0.0f alpha:1.0f]];
        }
        else if (NSOrderedSame == [battery_criticial_status caseInsensitiveCompare:ZT_BATTERY_EVENT_CAUSE_LOW])
        {
            [m_lblBatteryStatus setText:@"Status: Battery level is low"];
            [m_lblBatteryStatus setTextColor:[UIColor colorWithRed:0.9f green:0.0f blue:0.0f alpha:1.0f]];
        }
        else
        {
            /* do not have stored critical/low battery status in one of following cases:
                - battery is ok
                - charging has been enabled
                - connection has been just established 
             */
            [m_lblBatteryStatus setText:@"Status: Discharging"];
        }
    }
        
    [m_BatteryIndicator setBatteryLevel:_level];
    [m_BatteryIndicator setBatteryCharging:_charging];
    m_BatteryIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
    m_BatteryIndicator.layer.borderWidth = 3.0f;
    [m_BatteryIndicator setNeedsDisplay];
    battery_info = nil;
}

- (void)requestBatteryStatus
{
    [[zt_RfidAppEngine sharedAppEngine] requestBatteryStatus:nil];
}

- (void)testBatteryIndicator
{
#ifdef ZT_TEST_BATTERY_INDICATOR
    if (YES == _tst_BatteryCharging)
    {
        _tst_BatteryCharging = NO;
        _tst_BatteryLevel = 100;
    }
    else
    {
        _tst_BatteryLevel -= 3;
        
        if (_tst_BatteryLevel < 0)
        {
            _tst_BatteryCharging = YES;
        }
    }
    [self batteryStatusDidChanged];
#endif /* ZT_TEST_BATTERY_INDICATOR */
}

- (BOOL)onNewBatteryEvent
{
    [self batteryStatusDidChanged];
    return YES;
}
@end
