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
 *  Description:  LedActionVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>
///Responsible for led control  page with led on off options.
@interface LedActionViewController : UITableViewController
{
    int scannerID;
    NSString *scannerModel;
    NSMutableArray *ledNames;
    NSMutableArray *ledValues;
    BOOL requiredLedAction;
    zt_AlertView *activityView;
   
}

- (void)setScannerID:(int)scanner_id;
- (void)performLedAction:(NSString*)param;
- (void)showAlertForLedAction;

@end
