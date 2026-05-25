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
 *  Description:  InventoryVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RFIDTagCellView.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

@interface zt_InventoryVC : BaseDpoVC <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener,UIDocumentPickerDelegate>
{
    IBOutlet UITextField *m_txtSearch;
    IBOutlet UILabel *labelUniqueTags;
    IBOutlet UILabel *labelTotalTags;
    IBOutlet UILabel *m_lblUniqueTagsData;
    IBOutlet UILabel *m_lblTotalTagsData;
    IBOutlet UITableView *m_tblTags;
    IBOutlet UIButton *m_btnStartStop;
    IBOutlet UILabel *batchModeLabel;
    IBOutlet UIView *searchBGView;
    IBOutlet UIButton *m_buttonCycleCount;
    IBOutlet UIButton *buttonBrowseFiles;
    IBOutlet NSLayoutConstraint * cycleCountButtonWidthConstraint;
    IBOutlet UILabel *labelPrefilterEnabled;
    IBOutlet NSLayoutConstraint * prefilterLabelHeightConstraint;
    
    NSMutableArray *m_Tags;
    int m_ExpandedCellIdx;
    NSMutableString *m_SearchString;
    
    UIBarButtonItem *m_btnOptions;
    
    zt_EnumMapper *m_Mapper;
    NSMutableArray *m_InventoryOptions;
    SRFID_MEMORYBANK m_SelectedInventoryOption;
    
    NSTimer *m_ViewUpdateTimer;
    
    //To handle cell selection color
    NSMutableArray *selectIndexPathArray;
    NSString* selectedTagId;
    
    NSMutableArray * matchingArray;
    NSMutableArray * missingArray;
    
    //Export csv
    int uniqueTagsCount;
    int totalTagsCount;
    CGFloat readTimeValue;
    
    // TaglistMatchMode
    BOOL tagListOption;
    NSArray * tagListArray;
    
    // TaglistMatchMode Filter
    NSMutableArray * tagListFilterArray;
    int selectedTagListFilter;
    NSMutableArray * filteredArray;
    NSMutableArray * unknownTagsArray;
    
    // CycleCount
    NSString * activeProfile;
    int totalTagsCountForCycleCount;
    NSMutableArray * cycleCountArray;
    bool isInventoryStarted;
    bool isCreateCSVFileMethodExcute;
    
    BOOL inventoryTriggered;

}

- (void)configureTagCell:(zt_RFIDTagCellView*)tag_cell forRow:(int)row isExpanded:(BOOL)expanded;
- (void)setLabelTextToFit:(NSString*)text forLabel:(UILabel*)label withMaxFontSize:(float)max_font_size;
- (void)configureAppearance;
- (void)btnOptionsPressed;
- (IBAction)btnStartStopPressed:(id)sender;
- (void)updateOperationDataUI;
- (IBAction)btnCycleCountPressed:(id)sender;
- (IBAction)buttonBrowseFilesPressed:(id)sender;

@end
