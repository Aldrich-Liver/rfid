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
 *  Description:  LabelInputFieldCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LabelInputFieldCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_LabelInputFieldCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self darkModeCheck:self.traitCollection];
    if (self)
    {
        m_txtDataField = [[UITextField alloc] init];
        [m_txtDataField setDelegate:self];
        m_lblInfoNotice = [[UILabel alloc] init];
        m_InputFieldWidthConstraint = nil;
        
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_txtDataField)
    {
        [m_txtDataField release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        if (nil == m_InputFieldWidthConstraint)
        {
            m_InputFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:(float)m_InputFieldWidth / 100.0 constant:0.0];
        }
        [self.contentView addConstraint:m_InputFieldWidthConstraint];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c70];

        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    m_InputFieldWidth = 40;
    
    [m_txtDataField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_txtDataField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_txtDataField setKeyboardType:UIKeyboardTypeDefault];
    [m_txtDataField setReturnKeyType:UIReturnKeyDone];
    [m_txtDataField setClearButtonMode:UITextFieldViewModeAlways];
    [m_txtDataField setBorderStyle:UITextBorderStyleRoundedRect];
    [m_txtDataField setBackgroundColor:[UIColor whiteColor]];
    [m_txtDataField setText:@""];
    
    
    [m_txtDataField setTextColor:[UIColor blackColor]];
    [m_txtDataField setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_TEXT_FIELD]];
    
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblInfoNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblInfoNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoNotice setText:@""];
    
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [m_txtDataField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [m_lblInfoNotice setNumberOfLines:0];
    [m_lblInfoNotice setLineBreakMode:NSLineBreakByWordWrapping];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_txtDataField];
}

- (void)setData:(NSString*)data
{
    [m_txtDataField setText:[NSString stringWithFormat:@"%@", data]];
}

- (NSString*)getCellData
{
    return [m_txtDataField text];
}

- (void)setPlaceHolder:(NSString*)data
{
    [m_txtDataField setPlaceholder:[NSString stringWithFormat:@"%@", data]];
}
- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:[NSString stringWithFormat:@"%@", notice]];
}

- (void)disableLbl
{
    m_lblInfoNotice.textColor = [UIColor lightGrayColor];
}

- (void)setDataFieldWidth:(int)width
{
    m_InputFieldWidth = width;
    if (m_InputFieldWidthConstraint != nil)
    {
        [self.contentView removeConstraint:m_InputFieldWidthConstraint];
    }
    
    m_InputFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:(float)m_InputFieldWidth / 100.0 constant:0.0];
    [self.contentView addConstraint:m_InputFieldWidthConstraint];
}

- (void)setKeyboardType:(UIKeyboardType)type
{
    [m_txtDataField setKeyboardType:type];
}

- (UITextField *)getTextField
{
    return m_txtDataField;
}

/* ###################################################################### */
/* ########## Text Field Delegate Protocol implementation ############### */
/* ###################################################################### */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* just to hide keyboard */
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (nil != m_Delegate)
    {
        [m_Delegate didBeginEditing:self];
    }
}

/// Asks the delegate whether to change the specified text.
/// @param textField The text field containing the text.
/// @param range The range of characters to be replaced.
/// @param string The replacement string for the specified range.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL checkBrandID = [[NSUserDefaults standardUserDefaults] boolForKey:BRANDIDCHECK_KEY_DEFAULTS];
    
    if (checkBrandID) {
        if (textField.text.length >= NXP_BRANDID_MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
    }else
    {
        return YES;
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_txtDataField.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_txtDataField.backgroundColor = [UIColor clearColor];
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
