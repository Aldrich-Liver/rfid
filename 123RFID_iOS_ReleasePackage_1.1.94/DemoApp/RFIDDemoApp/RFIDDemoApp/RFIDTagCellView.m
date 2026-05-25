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
 *  Description:  RFIDTagCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RFIDTagCellView.h"
#import "ui_config.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_RFIDTagCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self darkModeCheck:self.traitCollection];
    if (self)
    {
        // Initialization code
        m_IsExpanded = NO;
        m_viewBankData.hidden = YES;
        m_viewDetails.hidden = YES;
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_lblTagData)
    {
        [m_lblTagData release];
    }
    if (nil != m_lblTagCount)
    {
        [m_lblTagCount release];
    }
    if (nil != m_lblBankId)
    {
        [m_lblBankId release];
    }
    if (nil != m_lblBankData)
    {
        [m_lblBankData release];
    }
    if (nil != m_lblPCData)
    {
        [m_lblPCData release];
    }
    if (nil != m_lblRSSIData)
    {
        [m_lblRSSIData release];
    }
    if (nil != m_lblPhaseData)
    {
        [m_lblPhaseData release];
    }
    if (nil != m_lblChannelData)
    {
        [m_lblChannelData release];
    }
    if (nil != m_viewDetails)
    {
        [m_viewDetails release];
    }
    if (nil != m_viewSummary)
    {
        [m_viewSummary release];
    }
    if (nil != m_viewBankData)
    {
        [m_viewBankData release];
    }
    if (nil != m_stackView)
    {
        [m_stackView release];
    }

    [super dealloc];
}

- (void)configureViewMode:(BOOL)is_expanded
{
    m_IsExpanded = is_expanded;
    
    [UIView performWithoutAnimation:^{
    
        m_stackView.distribution = UIStackViewDistributionFillEqually;
        
        if (YES == m_IsExpanded)
        {
            m_viewDetails.hidden = FALSE;
            m_viewBankData.hidden = FALSE;
        }
        else
        {
            m_viewDetails.hidden = TRUE;
            m_viewBankData.hidden = TRUE;
        }
        
        [self layoutIfNeeded];
        
         }];
    
    [UIView performWithoutAnimation:^{
        
        m_stackView.distribution = UIStackViewDistributionFillProportionally;
        
        [self layoutIfNeeded];
    }];
    
}

- (void)setTagData:(NSString*)tag_data
{
    [m_lblTagData setText:tag_data];
}

/// Set nxp brand id status with color on a tag.
/// @param brandIdStatus The status of the brand id of the tag. If that tag is a nxp tag, the status will true, otherwise false.
- (void)setNxpBrandIdStatusWithColorOnTag:(BOOL)brandIdStatus
{
    if (brandIdStatus) {
        m_lblTagData.textColor = THEME_BLUE_COLOR;
    }else
    {
        m_lblTagData.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
    }
}

- (void)setTagCount:(NSString*)tag_count
{
    [m_lblTagCount setText:tag_count];
}


- (void)setBankIdentifier:(NSString*)bank_identifier
{
    if([bank_identifier  isEqual: @"None"])
    {
        [m_lblBankId setText:@""];
        return;
    }
    NSString *identifier = [bank_identifier uppercaseString];
    [m_lblBankId setText:[NSString stringWithFormat:@"%@ MEMORY", identifier]];
}

- (void)setBankData:(NSString*)bank_data
{
    [m_lblBankData setText:bank_data];
    [m_lblBankData sizeToFit];
}

- (void)setPCData:(NSString*)pc_data
{
    [m_lblPCData setText:pc_data];
}

- (void)setRSSIData:(int)rssi_data
{
    [m_lblRSSIData setText:[NSString stringWithFormat:@"%d", rssi_data]];
}

- (void)setPhaseData:(int)phase_data
{
    [m_lblPhaseData setText:[NSString stringWithFormat:@"%d", phase_data]];
}

- (void)setChannelData:(int)channel_data
{
    [m_lblChannelData setText:[NSString stringWithFormat:@"%d", channel_data]];
}

- (void)setUnperfomPCData
{
    [m_lblPCData setText:@"-"];
}
- (void)setUnperfomRSSIData
{
    [m_lblRSSIData setText:@"-"];
}
- (void)setUnperfomPhaseData
{
    [m_lblPhaseData setText:@"-"];
}
- (void)setUnperfomChannelData
{
    [m_lblChannelData setText:@"-"];
}
- (void)setUnperfomTagSeenCount
{
    [m_lblTagCount setText:@"-"];
}

/// Get tag id
- (NSString*)getTagId
{
    return m_lblTagData.text;
}

/// To change the textcolour for matching tags list.
- (void)setTagDataTextColorForMatchedTags
{
    m_lblTagData.textColor = UIColor.greenColor;
}

/// To change the textcolour for missing tags list.
- (void)setTagDataTextColorForMissingTags
{
    m_lblTagData.textColor = UIColor.redColor;
}

/// To change the textcolour for default tags list.
- (void)setDefaultTextColorForRemainingTags
{
    m_lblTagData.textColor = UIColor.grayColor;
}
/// To change the textcolour for tamper tags list.
-(void) setTagDataTextColorForTamperTags
{
    m_lblTagData.textColor = UIColor.redColor;
    m_lblBankData.textColor = UIColor.redColor;
}
/// To change the textcolour for default tags list.
- (void)setDefaultTextColor
{
    m_lblTagData.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
    m_lblBankData.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
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

/// Set tag data in ASCII mode
/// @param tag_data Tag data to be shown in the list.
- (void)setTagDataASCIIMode:(NSString*)tag_data
{
    [m_lblTagData setText:tag_data];
    [self setTagDataTextColorForASCIIMode];
}

/// Color empty spaces in tag data for ASCII mode
-(void) setTagDataTextColorForASCIIMode
{
    int tagDataTextIndex = 0;
    if(m_lblTagData.text != nil && m_lblTagData.text.length >0 ){
        while (tagDataTextIndex<(m_lblTagData.text.length-ZT_TAG_DATA_EMPTY_SPACE.length)) {
            NSRange tagDataTextRange = NSMakeRange(tagDataTextIndex, ZT_TAG_DATA_EMPTY_SPACE.length);
                if ([[m_lblTagData.text substringWithRange:tagDataTextRange] isEqualToString:ZT_TAG_DATA_EMPTY_SPACE]) {
                    NSMutableAttributedString *tempAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:m_lblTagData.attributedText];
                    [tempAttributeText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:tagDataTextRange];
                    m_lblTagData.attributedText = tempAttributeText;
                    tagDataTextIndex += ZT_TAG_DATA_EMPTY_SPACE.length;
                } else {
                    tagDataTextIndex++;
                }
        }
    }
}
@end
