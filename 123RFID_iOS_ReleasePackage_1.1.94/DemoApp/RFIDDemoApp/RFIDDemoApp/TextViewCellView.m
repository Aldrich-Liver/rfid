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
 *  Description:  TextViewCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TextViewCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_TextViewCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self darkModeCheck:self.traitCollection];
    if (self)
    {
        m_TextView = [[UITextView alloc] init];
        m_lblInfoNotice = [[UILabel alloc] init];
        m_AutoLayoutIsPerformed = NO;
        m_TextViewHeightConstraint = nil;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_TextView)
    {
        [m_TextView release];
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (!newWindow) {
        [m_TextView resignFirstResponder];
        m_TextView.selectedRange = NSMakeRange(0, 0);
    }
    [super willMoveToWindow:newWindow];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(0, 0);
}

- (BOOL)canBecomeFirstResponder {
    return YES; // Allow the text view to become first responder to enable typing and cursor movement.
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Allow interaction only if the tap is intended for cursor movement
    if ([self.textInputMode.primaryLanguage isEqualToString:@"emoji"]) {
        return NO; // Disable emoji keyboard
    }
    return [super pointInside:point withEvent:event];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    // Disable text selection actions
    if (action == @selector(select:) || action == @selector(selectAll:) || action == @selector(paste:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}


- (void)updateConstraints
{
    [super updateConstraints];
    if (NO == m_AutoLayoutIsPerformed)
    {
        [self.contentView removeConstraints:[self.contentView constraints]];
        
        NSLayoutConstraint *xText = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        NSLayoutConstraint *rText = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
        NSLayoutConstraint *bText = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        
        bText.priority = 999;
        
        [self.contentView addConstraint:xText];
        [self.contentView addConstraint:rText];
        [self.contentView addConstraint:bText];
        
        NSLayoutConstraint *xLabel = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_TextView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *yLabel = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10];
        NSLayoutConstraint *rLabel = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_TextView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        NSLayoutConstraint *bLabel = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_TextView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        [self.contentView addConstraint:xLabel];
        [self.contentView addConstraint:yLabel];
        [self.contentView addConstraint:rLabel];
        [self.contentView addConstraint:bLabel];


        CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];

        m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
        [[self contentView] addConstraint:m_TextViewHeightConstraint];

        m_AutoLayoutIsPerformed = YES;
    }
    else
    {
        [[self contentView] removeConstraint:m_TextViewHeightConstraint];
        CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];
        
        m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
        [[self contentView] addConstraint:m_TextViewHeightConstraint];
    }
}

- (void)configureAppearance
{
    [m_TextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_TextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_TextView setKeyboardType:UIKeyboardTypeDefault];
    [m_TextView setReturnKeyType:UIReturnKeyDone];
    [m_TextView setBackgroundColor:[UIColor whiteColor]];
    [m_TextView setText:@""];
    m_TextView.scrollEnabled = NO;
    
    [m_TextView setTextColor:[UIColor blackColor]];
    [m_TextView setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_TEXT_FIELD]];
    
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblInfoNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblInfoNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoNotice setText:@""];
    
    [m_TextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.contentView addSubview:m_lblInfoNotice];
    [self.contentView addSubview:m_TextView];
}

- (void)setData:(NSString*)data
{
    [m_TextView setText:[NSString stringWithFormat:@"%@", data]];
    CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];
    if (m_TextViewHeightConstraint != nil)
    {
        [[self contentView] removeConstraint:m_TextViewHeightConstraint];
    }
    m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
    [[self contentView] addConstraint:m_TextViewHeightConstraint];

    [self updateConstraints];
}

- (NSString*)getCellData
{
    return [m_TextView text];
}

- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:notice];
}

- (void)setTextViewDelegate:(id<UITextViewDelegate>)delegate
{
    [m_TextView setDelegate:delegate];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_TextView.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_TextView.backgroundColor = [UIColor clearColor];
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
