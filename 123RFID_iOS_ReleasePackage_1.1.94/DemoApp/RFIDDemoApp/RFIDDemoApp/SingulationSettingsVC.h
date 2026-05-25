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
 *  Description:  SingulationSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"

@interface zt_SingulationSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblSingulationOptions;
    int m_PickerCellIdx;
    
    /* cells */
    zt_InfoCellView *m_cellSession;
    zt_LabelInputFieldCellView *m_cellTagPopulation;
    zt_InfoCellView *m_cellInventoryState;
    zt_InfoCellView *m_cellSlFlag;
    BOOL inventoryRequested;
    zt_PickerCellView *m_cellPicker;
    UITapGestureRecognizer *m_GestureRecognizer;
}

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;

@end
