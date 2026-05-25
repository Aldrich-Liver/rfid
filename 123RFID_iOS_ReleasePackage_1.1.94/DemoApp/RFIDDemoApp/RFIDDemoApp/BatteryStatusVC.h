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
 *  Description:  BatteryStatusVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "BatteryIndicatorView.h"
#import "RfidAppEngine.h"

@interface zt_BatteryStatusVC : UIViewController <zt_IRfidAppEngineBatteryEventDelegate>
{
    IBOutlet UILabel *m_lblBatteryPercent;
    IBOutlet zt_BatteryIndicatorView *m_BatteryIndicator;
    IBOutlet UILabel *m_lblBatteryStatus;
    
    int _tst_BatteryLevel;
    BOOL _tst_BatteryCharging;
    
    NSTimer *m_BatteryRequestTimer;
}

- (void)batteryStatusDidChanged;
- (void)requestBatteryStatus;

- (void)testBatteryIndicator;

@end
