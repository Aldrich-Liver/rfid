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
 *  Description:  SwitchCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_SWITCH                    @"ID_CELL_SWITCH"

@interface zt_SwitchCellView : zt_OptionCellView
{
    UILabel *m_lblInfoNotice;
    UISwitch *m_swtOption;
    BOOL m_AutoLayoutIsPerformed;
    BOOL switch_operated;
}

- (void)configureAppearance;
- (void)setOption:(BOOL)on;
- (BOOL)getOption;
- (void)setInfoNotice:(NSString*)notice;
- (void)switchDidChangeValue;
- (void)setEnabled:(BOOL)enabled;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
- (void)setUserInteraction:(BOOL)enabled;
- (void)setSwitchOperated:(BOOL)value;
- (BOOL)getSwitchOperated;

@end
