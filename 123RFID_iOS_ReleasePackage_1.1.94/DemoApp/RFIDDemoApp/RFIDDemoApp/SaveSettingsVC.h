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
 *  Description:  SaveSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "InfoCellView.h"

@interface zt_SaveSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *m_tblSledConfigOptions;
    IBOutlet UIButton *m_btnSave;
    zt_InfoCellView *m_OffscreenInfoCell;
    BOOL inventoryRequested;
}


- (IBAction)btnSaveConfigPressed:(id)sender;

- (void)saveConfigAction;

- (void)configureInfoCell:(zt_InfoCellView*)cell forRow:(int)row forSection:(int)section;
- (void)configureInfoCellTriggerType:(zt_InfoCellView*)cell withType:(int)type;
- (void)configureInfoCellStop:(zt_InfoCellView*)cell;
- (void)configureInfoCellDuration:(zt_InfoCellView*)cell;
- (void)configureInfoCellStartPeriod:(zt_InfoCellView*)cell;
- (void)configureInfoCellStopParam:(zt_InfoCellView*)cell withParam:(int)param;

@end
