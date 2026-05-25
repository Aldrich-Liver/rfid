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
 *  Description:  InfoCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_INFO                    @"ID_CELL_INFO"

#define ZT_CELL_INFO_STYLE_BLUE                                1
#define ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR           2
#define ZT_CELL_INFO_STYLE_GRAY                                3

@interface zt_InfoCellView : zt_OptionCellView
{
    UILabel *m_lblInfoData;
    UILabel *m_lblInfoNotice;
    BOOL m_AutoLayoutIsPerformed;
    int m_CellStyle;
}

- (void)configureAppearance;
- (void)setData:(NSString*)data;
- (NSString*)getCellData;
- (void)setInfoNotice:(NSString*)notice;
- (void)setStyle:(int)style;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
- (void)setCellActive;
- (void)setCellInActive;

@end
