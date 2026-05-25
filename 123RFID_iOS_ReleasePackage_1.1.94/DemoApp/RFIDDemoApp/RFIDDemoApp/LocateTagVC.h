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
 *  Description:  LocateTagVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "AlertView.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "ui_config.h"
#import "config.h"
#import "BaseDpoVC.h"

@interface zt_LocateTagVC : BaseDpoVC <UITextFieldDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener,UITableViewDataSource, UITableViewDelegate,UIDocumentPickerDelegate>
{
    IBOutlet UITextField *m_txtTagIdInput;
    IBOutlet UITextField *txtMultiTagIdInput;
    IBOutlet UILabel *m_lblDistanceData;
    IBOutlet UIButton *m_btnStartStop;
    IBOutlet UIView *m_indicatorBackground;
    IBOutlet UIView *m_indicatorValue;
    UITapGestureRecognizer *m_GestureRecognizer;
    IBOutlet NSLayoutConstraint *m_IndicatorHeightConstraint;
    
    NSMutableString *m_strTagInput;
    int currentOperation;
    NSTimer *m_ViewUpdateTimer;
    IBOutlet UISegmentedControl *segmentedControlOperations;
    IBOutlet UIView *singleTagView;
    IBOutlet UIView *multiTagView;
    IBOutlet UITableView *multiTagsTableView;
    IBOutlet UIButton *btnLocateMultiTag;
    IBOutlet UIButton *btnAddTag;
    IBOutlet UIButton *btnRemoveTag;
    IBOutlet UIButton *btnReload;
    IBOutlet UIButton *btnBrowseFiles;
    
    
    IBOutlet UITableView *tableView;
    NSString  *selectedTag;
    NSMutableArray *temporaryTagSelectedArray;
    srfidReportConfig *multipleTagsReportConfig;
    NSMutableArray *multiTagEventList;
    NSMutableArray *filterArray;
    BOOL theStatusOfMultiTagLocationingStartStop;
    NSMutableDictionary *multiTagDataDictionary;
    BOOL inventoryRequested;
    NSMutableArray *multiTagSeenCountArray;
    
    // MultiTag Locationing
    NSMutableArray *currentlySelectedTagIdArray;
    BOOL multiTagLocated;
    BOOL refereshPressed;
    
}

- (IBAction)btnStartStopPressed:(id)sender;
- (void)configureAppearance;
- (void)setRelativeDistance:(int)distance;
- (void)dismissKeyboard;
- (BOOL)onNewProximityEvent:(int)value;
- (void)showWarning:(NSString *)message;
- (void)updateOperationDataUI;

@end
