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
 *  Description:  FilterConfigVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TextFieldCellView.h"
#import "LabelInputFieldCellView.h"
#import "InfoCellView.h"
#import "PickerCellView.h"
#import "SwitchCellView.h"
#import "SelectionTableVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

@interface zt_FilterConfigVC : BaseDpoVC <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, zt_IOptionCellDelegate, zt_ISelectionTableVCDelegate>
{
    IBOutlet UISegmentedControl *m_segFilters;
    IBOutlet UITableView *m_tblFilterOptions;

    IBOutlet UILabel *lbl_NonMatch;
    int m_PickerCellIdx;
    
    IBOutlet UIView *view_NonMatch;
    IBOutlet NSLayoutConstraint * hightConstraints;
    
    /* cells */
    zt_TextFieldCellView *m_cellTagId;
    zt_InfoCellView *m_cellMemoryBank;
    zt_LabelInputFieldCellView *m_cellOffset;
    zt_InfoCellView *m_cellAction;
    zt_InfoCellView *m_cellTarget;
    zt_SwitchCellView *m_cellEnabled;
    zt_PickerCellView *m_cellPicker;
    zt_LabelInputFieldCellView *cellLength;
    
    IBOutlet UISwitch *m_switchSelectNonMatchingTags;
    
    
    NSMutableString *m_strTagIdOne;
    NSMutableString *m_strTagIdTwo;
    NSMutableString *m_strOffsetOne;
    NSMutableString *m_strOffsetTwo;
    
    NSMutableString *stringLengthOne;
    NSMutableString *stringLengthTwo;
    
    NSString *tagID_1;
    NSString *tagID_2;
    
    UITapGestureRecognizer *m_GestureRecognizer;
    
    int m_PresentedOptionId;
    
    NSNumber *targetIndex;
}

- (void)configureAppearance;
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;
- (void)actionSelectedFilterChanged;
- (void)configureForSelectedFilter;
- (void)saveCurrentFilterConfiguration;
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)dismissKeyboard;

@end
