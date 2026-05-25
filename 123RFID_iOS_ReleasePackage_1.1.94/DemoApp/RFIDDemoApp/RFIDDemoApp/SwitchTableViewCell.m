//
//  SwitchTableViewCell.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell


/// Init cell with style
/// @param style Cell style
/// @param reuseIdentifier Identifier
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        // Initialization code
        m_Index = 0;
    }
    return self;
}


/// Deallocates the memory occupied by the receiver.
- (void)dealloc{
    [_cellTitle release];
    [_cellSwitch release];
    [super dealloc];
}


/// Sets the selected state of the cell, optionally animating the transition between states.
/// @param selected YES to set the cell as selected, NO to set it as unselected. The default is NO.
/// @param animated YES to animate the transition between selected states, NO to make the transition immediate.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

/// Get index
- (int)getIndex{
    return m_Index;
}

/// Set index
/// @param index index value
- (void)setIndex:(int)index{
    m_Index = index;
}


/// Set switch delegate
/// @param delegate delegate referance
- (void)setDelegate:(id <ISwitchTableViewCellProtocol>)delegate{
    m_Delegate = delegate;
}


/// Switch symbologoy value change
/// @param sender reference
- (IBAction)switchSymbologyValueChanged:(id)sender{
    if (m_Delegate != nil){
        [m_Delegate switchValueChanged:[_cellSwitch isOn] aIndex:m_Index];
    }
}


/// Set switch value
/// @param on On status
- (void)setSwitchOn:(BOOL)on{
    [_cellSwitch setOn:on animated:NO];
}

@end
