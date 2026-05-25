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
 *  Description:  AntennaSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "InfoCellView.h"
#import "SelectionTableVC.h"
#import "LabelInputFieldCellView.h"
#import "PickerCellView.h"

@interface zt_AntennaSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_ISelectionTableVCDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblOptions;

    zt_LabelInputFieldCellView *m_cellPowerLevel;
    zt_InfoCellView *m_cellLinkProfile;
    
    /*  
        tari and doSelect not performed in ui
        to perform see - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
        in AntennaSettings.m
     */
    zt_InfoCellView *cellTari;
    zt_InfoCellView * cellPie;
    zt_PickerCellView *m_cellPicker;
    zt_InfoCellView *m_cellDoSelect;
    int m_PresentedOptionId;
    int m_PickerCellIdx;
    UITapGestureRecognizer *m_GestureRecognizer;
    NSArray *tariArray;
    NSArray *pieArray;
    int m_SelectedOptionPie;
    int m_SelectedOptionTari;
    BOOL inventoryRequested;
    BOOL isAutomac668Selected;
    NSString *selectedLinkProfile;
    NSArray *lpArray;
    NSString *newPieValue;
    NSString *newTariValue;
    int localLinkIndex;
    
    BOOL hasNewValuesInitiated;
    
}
@property (nonatomic,retain) NSArray *linkChoices;

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;

@end
