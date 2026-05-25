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
 *  Description:  TagReportSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SwitchCellView.h"
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "SledConfiguration.h"
#import "LabelInputFieldCellView.h"

@interface zt_TagReportSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblTagReportOptions;
    zt_SwitchCellView *m_OffscreenSwitchCell;
    
    int m_PickerCellIdx;
    int m_PickerCellSectionIdx;
    zt_PickerCellView *m_cellPicker;
    zt_InfoCellView *m_cellBatchMode;
    zt_InfoCellView *m_cellUSBBatchMode;
    NSArray *m_OptionsBatchMode;
    NSArray *m_OptionsUSBBatchMode;
    int m_SelectedOptionMemoryBank;
    zt_SledConfiguration *localSled;
    zt_LabelInputFieldCellView *brandIdCell;
    UITapGestureRecognizer *tapGestureRecognizer;
    BOOL inventoryRequested;
    BOOL locationing_requested;
    BOOL multitag_locate_Requested;
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(NSIndexPath *)indexPath;
- (void)setupConfigurationInitial;
- (void)configureFieldCell:(zt_LabelInputFieldCellView*)cell forRow:(NSIndexPath *)indexPath;

@end
