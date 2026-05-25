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
 *  Description:  LabelInputFieldCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_LABEL_TEXT_FIELD        @"ID_CELL_LABEL_TEXT_FIELD"

@interface zt_LabelInputFieldCellView : zt_OptionCellView <UITextFieldDelegate>
{
    UITextField *m_txtDataField;
    UILabel *m_lblInfoNotice;
    NSLayoutConstraint *m_InputFieldWidthConstraint;
    BOOL m_AutoLayoutIsPerformed;
    int m_InputFieldWidth;
}

- (void)disableLbl;
- (void)configureAppearance;
- (void)setData:(NSString*)data;
- (void)setPlaceHolder:(NSString*)data;
- (NSString*)getCellData;
- (void)setInfoNotice:(NSString*)notice;
- (void)setDataFieldWidth:(int)width;
- (void)setKeyboardType:(UIKeyboardType)type;
- (UITextField *)getTextField;
-(void)darkModeCheck:(UITraitCollection *)traitCollection;

@end
