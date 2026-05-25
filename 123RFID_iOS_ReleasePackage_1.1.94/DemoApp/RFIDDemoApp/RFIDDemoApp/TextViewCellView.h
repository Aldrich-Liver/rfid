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
 *  Description:  TextViewCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_TEXT_VIEW               @"ID_CELL_TEXT_VIEW"

@interface zt_TextViewCellView : zt_OptionCellView <UITextViewDelegate>
{
    UITextView *m_TextView;
    UILabel *m_lblInfoNotice;
    BOOL m_AutoLayoutIsPerformed;
    NSLayoutConstraint *m_TextViewHeightConstraint;
}

- (void)configureAppearance;
- (void)setData:(NSString*)data;
- (NSString*)getCellData;
- (void)setInfoNotice:(NSString*)notice;
- (void)setTextViewDelegate:(id<UITextViewDelegate>)delegate;
- (void)willMoveToWindow:(UIWindow *)newWindow;
-(void)darkModeCheck:(UITraitCollection *)traitCollection;

@end
