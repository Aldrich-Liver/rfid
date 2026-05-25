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
 *  Description:  PowerManagementVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SelectionTableVC.h"
#import "SwitchCellView.h"

@interface zt_PowerManagementVC : UIViewController <UITableViewDataSource, UITableViewDelegate,zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblOptions;
    BOOL inventoryRequested;
    zt_SwitchCellView *m_cellDynamicPowerOptimization;
}
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;

@end
