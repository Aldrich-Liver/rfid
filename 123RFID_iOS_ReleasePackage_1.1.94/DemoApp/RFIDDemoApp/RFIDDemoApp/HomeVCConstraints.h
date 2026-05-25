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
 *  Description:  HomeVCConstraints.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RFIDTabVC.h"
#import "FilterConfigVC.h"
#import "SettingsVC.h"
#import "AboutVC.h"
#import "ui_config.h"
#import "AlertView.h"
#import "UIViewController+ZT_ResponseHandler.h"

IB_DESIGNABLE
@interface zt_HomeVCConstraints : UIViewController
{
    
}
- (IBAction)btnRapidReadPressed:(id)sender;
- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnSettingsPressed:(id)sender;
- (IBAction)btnLocateTagPressed:(id)sender;
- (IBAction)btnFilterPressed:(id)sender;
- (IBAction)btnAccessPressed:(id)sender;

- (void)showTabInterfaceActiveView:(int)identifier;

@end
