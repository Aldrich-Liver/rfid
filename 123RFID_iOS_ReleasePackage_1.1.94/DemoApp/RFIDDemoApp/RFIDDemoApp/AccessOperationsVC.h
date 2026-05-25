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
 *  Description:  AccessOperationsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TextFieldCellView.h"
#import "TextViewCellView.h"
#import "PickerCellView.h"
#import "LabelInputFieldCellView.h"
#import "InfoCellView.h"
#import "RfidAppEngine.h"
#import <ZebraRfidSdkFramework/RfidTagData.h>
#import "AlertView.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "config.h"
#import "BaseDpoVC.h"
#import "EnumMapper.h"

@interface zt_AccessOperationsVC : BaseDpoVC <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, zt_IOptionCellDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UISegmentedControl *m_segOperations;
    IBOutlet UITableView *m_tblOperationOptions;
    IBOutlet UIButton *m_btnRead;
    IBOutlet UIButton *m_btnWrite;
    IBOutlet UIButton *m_btnOperation;
    
    int m_CurrentOperation;
    int m_PickerCellIdx;
    
    NSUInteger tagIDLength;
    
    NSString *m_SelectedTagID;
    
    /* cells */
    zt_TextFieldCellView *m_cellTagId;
    zt_LabelInputFieldCellView *m_cellPassword;
    zt_InfoCellView *m_cellMemoryBank;
    zt_LabelInputFieldCellView *m_cellOffset;
    zt_LabelInputFieldCellView *m_cellLength;
    zt_TextViewCellView *m_cellData;
    zt_InfoCellView *m_cellLockPrivilege;
    zt_LabelInputFieldCellView *m_cellKillPassword;
    zt_PickerCellView *m_cellPicker;
    zt_PickerCellView *m_LockPicker;
    
    NSMutableString *m_strTagId;
    NSMutableString *m_strRWPassword;
    NSMutableString *m_strOffset;
    NSMutableString *m_strLength;
    NSMutableString *m_strLPassword;
    NSMutableString *m_strKillPassword;
    NSMutableString *m_strData;
    
    UITapGestureRecognizer *m_GestureRecognizer;
    
    zt_EnumMapper *m_MapperMemoryBank;
    zt_EnumMapper *m_MapperLockMemoryBank;
    zt_EnumMapper *m_MapperLockPrivelege;
    
    NSArray *m_OptionsMemoryBank;
    NSArray *m_LockOptionsMemoryBank;
    NSArray *m_OptionsLockPrivilege;
    int m_SelectedOptionMemoryBank,m_selectedLockMemoryBank;
    int m_SelectedOptionLockPrivilege;
    SRFID_MEMORYBANK memoryBank;
}

- (void)configureAppearance;
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;
- (void)actionSelectedOperationChanged;
- (void)configureForSelectedOperation;
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)dismissKeyboard;
- (void)displaySelectedTag;

@end
