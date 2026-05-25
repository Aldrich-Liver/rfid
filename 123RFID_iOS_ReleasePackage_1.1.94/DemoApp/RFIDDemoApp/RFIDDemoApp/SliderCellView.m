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
 *  Description:  SliderCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SliderCellView.h"
#import "ui_config.h"

@implementation zt_SliderCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_sldOption = [[UISlider alloc] init];
        
        [m_sldOption addTarget:self action:@selector(sliderDidChangeValue) forControlEvents:UIControlEventValueChanged];
        
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_sldOption)
    {
        [m_sldOption release];
    }
    [super dealloc];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* workaround: in some cases the super implementation does NOT call layoutSubviews
     on the content view of UITableViewCell*/
    
    [self.contentView layoutSubviews];
}


- (void)updateConstraints
{
    [super updateConstraints];
    if (NO == m_AutoLayoutIsPerformed)
    {
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_sldOption attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_sldOption attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_sldOption attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_sldOption attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    [m_sldOption setMinimumValue:0.0];
    [m_sldOption setMaximumValue:1.0];
    [m_sldOption setValue:0.1];
    
    [m_sldOption setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_sldOption];
}

- (void)setCellData:(float)data
{
    [m_sldOption setValue:data];
}

- (float)getCellData
{
    return m_sldOption.value;
}

- (void)setMinimumValue:(float)value
{
    [m_sldOption setMinimumValue:value];
}

- (void)setMaximumValue:(float)value
{
    [m_sldOption setMaximumValue:value];
}

- (void)sliderDidChangeValue
{
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}

@end
