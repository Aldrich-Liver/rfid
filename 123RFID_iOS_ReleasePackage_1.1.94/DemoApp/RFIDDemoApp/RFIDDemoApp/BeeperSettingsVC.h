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
 *  Description:  BeeperSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SwitchCellView.h"
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"

@interface zt_BeeperSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblBeeperOptions;
    
    zt_SwitchCellView *m_cellSledBeeper;
    zt_SwitchCellView *m_cellHostBeeper;
    zt_PickerCellView *m_cellVolumePicker;
    zt_InfoCellView *m_cellVolumeLevel;
    
    // reference to local copy of sled configuration
    zt_SledConfiguration *m_LocalConfig;
    BOOL inventoryRequested;
    BOOL isVolumeEnable;
    BOOL isPickerShown;
}

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;

@end
