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
 *  Description:  BaseDpoVC.h
 *
 *  Notes: Base View Controller that contains functionality common
 *         to multiple view controllers including:
 *             - Dynamic Power Optimization UIBarButtonItem
 *             - ...
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"

@interface BaseDpoVC : UIViewController <zt_IRfidAppEngineDevListDelegate, zt_IRfidAppEngineBatteryEventDelegate>
{
    UIBarButtonItem *barButtonDpo;
}

- (void) refreshDpoButton;
- (void)requestBatteryStatus;

@end
