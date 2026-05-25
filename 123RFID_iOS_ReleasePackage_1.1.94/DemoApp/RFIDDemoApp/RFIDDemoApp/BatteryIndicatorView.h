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
 *  Description:  BatteryIndicatorView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface zt_BatteryIndicatorView : UIView
{
    int m_BatteryLevel;
    BOOL m_IsCharging;
    NSTimer *m_RedrawTimer;
    int m_ChargingLevel;
}

- (void)setBatteryLevel:(int)level;
- (void)setBatteryCharging:(BOOL)charging;

- (void)redrawTimerFired;

@end
