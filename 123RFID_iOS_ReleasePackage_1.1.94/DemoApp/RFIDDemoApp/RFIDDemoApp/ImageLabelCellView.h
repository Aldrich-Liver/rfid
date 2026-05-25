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
 *  Description:  ImageLabelCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_IMAGE_LABEL                    @"ID_CELL_IMAGE_LABEL"

@interface zt_ImageLabelCellView : zt_OptionCellView
{
    UIImageView *m_imgCellImage;
    UILabel *m_lblInfoNotice;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)setDisableStyle;
- (void)configureAppearance;
- (void)setInfoNotice:(NSString*)notice;
- (void)setCellImage:(NSString*)image_name;
-(void)darkModeCheck:(UITraitCollection *)traitCollection;


@end
