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
 *  Description:  RFIDTabVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

#define ZT_VC_RFIDTAB_RAPID_READ_VC_IDX       0
#define ZT_VC_RFIDTAB_INVENTORY_VC_IDX        1
#define ZT_VC_RFIDTAB_LOCATE_TAG_VC_IDX       2
#define ZT_VC_RFIDTAB_ACCESS_VC_IDX           3

@interface zt_RFIDTabVC : UITabBarController <UITabBarControllerDelegate>
{
    int m_SelectedTabView;
}

- (void)setActiveView:(int)identifier;

@end
