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
 *  Description:  TextFieldCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_TEXT_FIELD              @"ID_CELL_TEXT_FIELD"

@interface zt_TextFieldCellView : zt_OptionCellView <UITextFieldDelegate>
{
    UITextField *m_txtDataField;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)configureAppearance;
- (void)setData:(NSString*)data;
- (NSString*)getCellData;
- (void)setPlaceholder:(NSString*)placeholder;
- (UITextField *)getTextField;
-(void)darkModeCheck:(UITraitCollection *)traitCollection;
-(void)setBarcodeValue: (NSString *) barcodeValue;
- (void)setDataForASCIIMode:(NSString*)data;
- (void) setTagDataTextColorForASCIIMode;

@end
