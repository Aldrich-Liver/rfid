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
 *  Description:  ImageLabelCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ImageLabelCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_ImageLabelCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_imgCellImage = [[UIImageView alloc] init];
        m_lblInfoNotice = [[UILabel alloc] init];
        
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        
        /* increase default cell size unless new size will not be provided
         from table view data source */
        //self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self darkModeCheck:self.traitCollection];
    
    return self;
}

- (void)dealloc
{
    if (nil != m_imgCellImage)
    {
        [m_imgCellImage release];
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
        
       
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        /*
		without DefaultHight priority there is a conflict with
		constraints on iOS 8.0
         */
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_IMAGE_SZ];
        c40.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:c40];

        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_IMAGE_SZ];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_imgCellImage attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c70];
        
//        NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        //[self.contentView addConstraint:c80];
        
//        NSLayoutConstraint *c90 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        //[self.contentView addConstraint:c90];
        
        NSLayoutConstraint *c100 = [NSLayoutConstraint constraintWithItem:m_imgCellImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblInfoNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c100];
        
        NSLayoutConstraint *c110 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_imgCellImage attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c110];
        
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
    
    [m_imgCellImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_imgCellImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_imgCellImage];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:[NSString stringWithFormat:@"%@", notice]];
}

- (void)setCellImage:(NSString*)image_name
{
    UIImage *img = [UIImage imageNamed:image_name];
    
    [m_imgCellImage setImage:img];
}

- (void)setDisableStyle
{
    [m_lblInfoNotice setTextColor:[UIColor grayColor]];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_lblInfoNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblInfoNotice.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
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
