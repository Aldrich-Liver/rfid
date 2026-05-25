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
 *  Description:  ConnectionSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SwitchCellView.h"

@interface zt_ConnectionSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate, UIDocumentPickerDelegate>
{
    IBOutlet UITableView *m_tblOptions;

    NSArray *m_OptionsConnection;
    NSArray *m_OptionsNotification;
    NSArray *m_OptionsDataExport;
    NSArray *m_OptionsMatchMode;
    NSArray *m_OptionsGlobalSettings;
    NSArray *m_OptionsHeaders;
    zt_SwitchCellView *m_OffscreenSwitchCell;
    BOOL isUpdated;
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(int)row inSection:(int)section;
- (void)setupConfigurationInitial;

@end
