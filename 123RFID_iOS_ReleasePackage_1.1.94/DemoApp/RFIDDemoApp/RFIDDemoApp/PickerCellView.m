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
 *  Description:  PickerCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "PickerCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"
@implementation zt_PickerCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_PickerView = [[UIPickerView alloc] init];
        m_Choices = [[NSMutableArray alloc] init];
        m_SelectedChoice = 0;
        m_AutoLayoutIsPerformed = NO;
        
        [m_PickerView setDelegate:self];
        [m_PickerView setDataSource:self];
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_PickerView)
    {
        [m_PickerView release];
    }
    if (nil != m_Choices)
    {
        [m_Choices removeAllObjects];
        [m_Choices release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    [m_PickerView setShowsSelectionIndicator:YES];
    
    [m_PickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_PickerView];
}

- (void)setChoices:(NSArray*)choices
{
    [m_Choices removeAllObjects];
    [m_Choices addObjectsFromArray:choices];
    [m_PickerView reloadAllComponents];
}

- (int)getSelectedChoice
{
    return m_SelectedChoice;
}

- (void)setSelectedChoice:(int)choice
{
    m_SelectedChoice = choice;
    [m_PickerView selectRow:m_SelectedChoice inComponent:0 animated:YES];
    [m_PickerView reloadAllComponents];
}

/* ###################################################################### */
/* ########## UIPickerViewDataSource Protocol implementation ############ */
/* ###################################################################### */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [m_Choices count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;

    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];

        pickerLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold"                size:16];

        pickerLabel.textAlignment=NSTextAlignmentCenter;
    }
    [pickerLabel setText:[m_Choices objectAtIndex:row]];

    return pickerLabel;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return (NSString*)[m_Choices objectAtIndex:row];
}

/* ###################################################################### */
/* ########## UIPickerViewDelegate Protocol implementation ############## */
/* ###################################################################### */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    m_SelectedChoice = (int)row;
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
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
