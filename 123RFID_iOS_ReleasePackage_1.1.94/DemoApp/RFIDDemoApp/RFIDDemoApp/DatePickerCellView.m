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
 *  Description:  DatePickerCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "DatePickerCellView.h"
#import "ui_config.h"

@implementation zt_DatePickerCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_DatePickerView = [[UIDatePicker alloc] init];
        m_SelectedDate = [NSDate date];
        m_AutoLayoutIsPerformed = NO;
        
        [m_DatePickerView addTarget:self action:@selector(datePickerDidChangeValue) forControlEvents:UIControlEventValueChanged];
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_DatePickerView)
    {
        [m_DatePickerView release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_DatePickerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_DatePickerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_DatePickerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_DatePickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    [m_DatePickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [m_DatePickerView setDatePickerMode:UIDatePickerModeDateAndTime];
    
    /* TBD: shall we set locale ? */
    [m_DatePickerView setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    [[self contentView] addSubview:m_DatePickerView];
}

- (void)setMinimumDate:(NSDate*)min_date
{
    [m_DatePickerView setMinimumDate:min_date];
}

- (void)setMaximumDate:(NSDate*)max_date
{
    [m_DatePickerView setMaximumDate:max_date];
}

- (NSDate*)getSelectedDate
{
    return m_SelectedDate;
}

- (void)setSelectedDate:(NSDate*)date
{
    m_SelectedDate = date;
    [m_DatePickerView setDate:m_SelectedDate];
}

- (void)datePickerDidChangeValue
{
    m_SelectedDate = m_DatePickerView.date;
    
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}

@end
