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
 *  Description:  DatePickerCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_DATE_PICKER                  @"ID_CELL_DATE_PICKER"

@interface zt_DatePickerCellView : zt_OptionCellView
{
    NSDate *m_SelectedDate;
    UIDatePicker* m_DatePickerView;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)configureAppearance;
- (void)setMinimumDate:(NSDate*)min_date;
- (void)setMaximumDate:(NSDate*)max_date;
- (NSDate*)getSelectedDate;
- (void)setSelectedDate:(NSDate*)date;
- (void)datePickerDidChangeValue;

@end
