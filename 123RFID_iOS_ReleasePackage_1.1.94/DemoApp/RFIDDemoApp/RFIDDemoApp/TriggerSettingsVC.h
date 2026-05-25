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
 *  Description:  TriggerSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "InfoCellView.h"
#import "PickerCellView.h"
#import "DatePickerCellView.h"
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"

@interface zt_TriggerSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblTriggerOptions;
    int m_PickerCellIdx;
    int m_PickerCellSectionIdx;
    
    /* cells */
    zt_InfoCellView *m_cellStartTriggerOption;
    zt_LabelInputFieldCellView *m_cellStartTriggerPeriod;
    zt_InfoCellView *m_cellStartTriggerType;
    
    zt_InfoCellView *m_cellStopTriggerOption;
    zt_LabelInputFieldCellView *m_cellStopTriggerParam1;
    zt_LabelInputFieldCellView *m_cellStopTriggerParam2;
    zt_InfoCellView *m_cellStopTriggerType;
    
    zt_PickerCellView *m_cellPicker;
    
    NSMutableString *m_strStartDelay;
    NSMutableString *m_strStopTag;
    NSMutableString *m_strStopInventory;
    NSMutableString *m_strStopTimeout;
    BOOL inventoryRequested;
    UITapGestureRecognizer *m_GestureRecognizer;
}

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (void)updateStopTriggerParamCell;
- (int)recalcCellIndex:(int)cell_index forSection:(int)section_index;
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)dismissKeyboard;

@end

