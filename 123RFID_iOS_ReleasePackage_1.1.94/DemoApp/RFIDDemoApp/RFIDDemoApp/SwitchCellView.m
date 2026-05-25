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
 *  Description:  SwitchCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SwitchCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_SwitchCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_lblInfoNotice = [[UILabel alloc] init];
        m_swtOption = [[UISwitch alloc] init];
        m_AutoLayoutIsPerformed = NO;
        switch_operated = NO;
        [m_swtOption addTarget:self action:@selector(switchDidChangeValue) forControlEvents: UIControlEventValueChanged];
        m_swtOption.onTintColor = THEME_BLUE_COLOR;

        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_swtOption)
    {
        [m_swtOption release];
    }
    if (nil != m_lblInfoNotice)
    {
        [m_lblInfoNotice release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_swtOption attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_swtOption attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        //NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_swtOption attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0];
        //[self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_swtOption attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_swtOption attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_swtOption attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c70];
        
        NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_swtOption attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c80];
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblInfoNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblInfoNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoNotice setText:@""];
    
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_swtOption setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_swtOption];
}

- (void)setOption:(BOOL)on
{
    [m_swtOption setOn:on];
}

- (BOOL)getOption
{
    return [m_swtOption isOn];
}

- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:[NSString stringWithFormat:@"%@", notice]];
}

- (void)switchDidChangeValue
{
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
    [self setSwitchOperated:true];
}

- (void)setSwitchOperated:(BOOL)value
{
    switch_operated = value;
}
- (BOOL)getSwitchOperated
{
    return switch_operated;
}

- (void)setEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
    m_lblInfoNotice.userInteractionEnabled = enabled;
    m_swtOption.userInteractionEnabled = enabled;
    if (YES == enabled)
    {
        [m_lblInfoNotice setTextColor:[UIColor blackColor]];
        [m_swtOption setEnabled:YES];
    }
    else
    {
        [m_lblInfoNotice setTextColor:[UIColor grayColor]];
        [m_swtOption setEnabled:NO];
    }
}

/// To set the user interaction for friendlynames switch.
/// @param enabled To get the bool value enabled or disabled.
- (void)setUserInteraction:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
    m_lblInfoNotice.userInteractionEnabled = enabled;
    m_swtOption.userInteractionEnabled = enabled;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_lblInfoNotice.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection]; ;
    m_lblInfoNotice.backgroundColor = [UIColor clearColor];
    
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}


@end
