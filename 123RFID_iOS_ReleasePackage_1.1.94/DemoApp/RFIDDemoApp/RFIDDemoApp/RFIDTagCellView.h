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
 *  Description:  RFIDTagCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/


#import <UIKit/UIKit.h>

#define ZT_CELL_ID_TAG_DATA                 @"ID_CELL_TAG_DATA"

/*
 TBD:
 - inventory operation shall be performed in accordance with selected bank and show
 details on cell selection
 - if user select "none as option" => no expended view for bank details (???)
 */

@interface zt_RFIDTagCellView : UITableViewCell
{
    IBOutlet UIView  *m_viewSummary;
    IBOutlet UIView  *m_viewBankData;
    IBOutlet UIView  *m_viewDetails;
    IBOutlet UILabel *m_lblTagData;
    IBOutlet UILabel *m_lblTagCount;
    IBOutlet UILabel *m_lblBankId;
    IBOutlet UILabel *m_lblBankData;
    IBOutlet UILabel *m_lblPCData;
    IBOutlet UILabel *m_lblRSSIData;
    IBOutlet UILabel *m_lblPhaseData;
    IBOutlet UILabel *m_lblChannelData;
    IBOutlet UIStackView *m_stackView;
    
    BOOL m_IsExpanded;
}

- (void)configureViewMode:(BOOL)is_expanded;
- (void)setTagData:(NSString*)tag_data;
- (void)setNxpBrandIdStatusWithColorOnTag:(BOOL)brandIdStatus;
- (void)setTagCount:(NSString*)tag_count;
- (void)setBankIdentifier:(NSString*)bank_identifier;
- (void)setBankData:(NSString*)bank_data;
- (void)setPCData:(NSString*)pc_data;
- (void)setRSSIData:(int)rssi_data;
- (void)setPhaseData:(int)phase_data;
- (void)setChannelData:(int)channel_data;
- (void)setTagDataTextColorForMatchedTags;
- (void)setTagDataTextColorForMissingTags;
- (void)setDefaultTextColorForRemainingTags;
- (void)setTagDataASCIIMode:(NSString*)tag_data;
- (void) setTagDataTextColorForASCIIMode;
- (void) setTagDataTextColorForTamperTags;
- (void)setDefaultTextColor;

- (void)setUnperfomPCData;
- (void)setUnperfomRSSIData;
- (void)setUnperfomPhaseData;
- (void)setUnperfomChannelData;
- (void)setUnperfomTagSeenCount;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;

- (NSString*)getTagId;
@end
