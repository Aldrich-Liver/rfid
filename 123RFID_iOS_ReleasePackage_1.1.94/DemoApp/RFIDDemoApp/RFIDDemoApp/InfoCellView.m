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
 *  Description:  InfoCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "InfoCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_InfoCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_lblInfoData = [[UILabel alloc] init];
        m_lblInfoNotice = [[UILabel alloc] init];
        
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    [self darkModeCheck:self.traitCollection];
    return self;
}

- (void)dealloc
{
    if (nil != m_lblInfoData)
    {
        [m_lblInfoData release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblInfoData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblInfoData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        /* nrv364: don't add width constraint to allow flexible label width */
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblInfoData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.55 constant:0.0];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblInfoData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:m_lblInfoData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblInfoData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c70];
        
        NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblInfoData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
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
    
    UIView *tmp = [[UIView alloc] init];
    [m_lblInfoData setTextColor:[UIColor getDarkModeLabelTextColor:self.traitCollection]]; // system blue "action" color
    [tmp release];
    [m_lblInfoData setBackgroundColor:[UIColor getDarkModeViewBackgroundColor:self.traitCollection]];
    [m_lblInfoData setTextAlignment:NSTextAlignmentRight];
    [m_lblInfoData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoData setText:@""];
    [m_lblInfoData setNumberOfLines:0];
    
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblInfoData setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_lblInfoData];
}

- (void)setData:(NSString*)data
{
    [m_lblInfoData setText:[NSString stringWithFormat:@"%@", data]];
    [m_lblInfoData setAdjustsFontSizeToFitWidth:YES];
    m_lblInfoData.backgroundColor = [UIColor clearColor];
    m_lblInfoData.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
}


- (NSString*)getCellData
{
    return [m_lblInfoData text];
}

- (void)setInfoNotice:(NSString*)notice
{
    m_lblInfoNotice.backgroundColor = [UIColor getDarkModeViewBackgroundColor:self.traitCollection];
    m_lblInfoNotice.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
    [m_lblInfoNotice setText:[NSString stringWithFormat:@"%@", notice]];
}

- (void)setStyle:(int)style
{
    m_CellStyle = style;
    
    if (ZT_CELL_INFO_STYLE_BLUE == m_CellStyle)
    {
        [self setAccessoryType:UITableViewCellAccessoryNone];
        UIView *tmp = [[UIView alloc] init];
        [m_lblInfoData setTextColor:[UIColor getDarkModeLabelTextColor:self.traitCollection]];
        [tmp release];
    }
    else if (ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR == m_CellStyle)
    {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [m_lblInfoData setTextColor:[UIColor getDarkModeLabelTextColor:self.traitCollection]];
    }
    else if (ZT_CELL_INFO_STYLE_GRAY == m_CellStyle)
    {
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [m_lblInfoData setTextColor:[UIColor getDarkModeLabelTextColor:self.traitCollection]];
    }
}

/// Set cell active.
- (void)setCellActive
{
    [m_lblInfoData setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
}

/// Set cell inactive.
- (void)setCellInActive
{
    [m_lblInfoData setTextColor:[UIColor systemGrayColor]];
    [m_lblInfoNotice setTextColor:[UIColor systemGrayColor]];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_lblInfoData.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblInfoData.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    m_lblInfoNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
