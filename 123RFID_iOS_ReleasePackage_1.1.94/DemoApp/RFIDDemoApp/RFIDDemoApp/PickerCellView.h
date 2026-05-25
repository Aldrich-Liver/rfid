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
 *  Description:  PickerCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_PICKER                  @"ID_CELL_PICKER"

@interface zt_PickerCellView : zt_OptionCellView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *m_Choices;
    int m_SelectedChoice;
    UIPickerView* m_PickerView;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)configureAppearance;
- (void)setChoices:(NSArray*)choices;
- (int)getSelectedChoice;
- (void)setSelectedChoice:(int)choice;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end
