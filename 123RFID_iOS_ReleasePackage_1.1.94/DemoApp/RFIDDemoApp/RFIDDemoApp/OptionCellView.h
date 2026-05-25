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
 *  Description:  OptionCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@protocol zt_IOptionCellDelegate <NSObject>
- (void)didChangeValue:(id)option_cell;
- (void)didBeginEditing:(id)option_cell;
@end

@interface zt_OptionCellView : UITableViewCell
{
    int m_CellTag;
    id <zt_IOptionCellDelegate> m_Delegate;
}

- (void)setDelegate:(id<zt_IOptionCellDelegate>)delegate;
- (void)setCellTag:(int)tag;
- (int)getCellTag;

@end
