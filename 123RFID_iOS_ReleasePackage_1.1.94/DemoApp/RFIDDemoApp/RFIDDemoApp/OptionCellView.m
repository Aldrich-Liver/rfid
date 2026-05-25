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
 *  Description:  OptionCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/


#import "OptionCellView.h"

#define ZT_CELL_OPTION_TAG_NOT_A_TAG           -1

@implementation zt_OptionCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_CellTag = ZT_CELL_OPTION_TAG_NOT_A_TAG;
        m_Delegate = nil;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDelegate:(id<zt_IOptionCellDelegate>)delegate;
{
    m_Delegate = delegate;
}

- (void)setCellTag:(int)tag
{
    m_CellTag = tag;
}

- (int)getCellTag
{
    return m_CellTag;
}

@end
