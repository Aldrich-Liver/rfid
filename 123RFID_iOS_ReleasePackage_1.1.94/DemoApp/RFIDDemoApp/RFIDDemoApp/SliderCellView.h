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
 *  Description:  SliderCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

#define ZT_CELL_ID_SLIDER                    @"ID_CELL_SLIDER"

@interface zt_SliderCellView : zt_OptionCellView
{
    UISlider *m_sldOption;
    float m_SliderValue;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)configureAppearance;
- (void)setCellData:(float)data;
- (float)getCellData;
- (void)setMinimumValue:(float)value;
- (void)setMaximumValue:(float)value;
- (void)sliderDidChangeValue;

@end
