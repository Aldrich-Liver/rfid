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
 *  Description:  SelectionTableVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@protocol zt_ISelectionTableVCDelegate <NSObject>
- (void)didChangeSelectedOption:(NSString *)value;
@end

@interface zt_SelectionTableVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *m_tblOptions;
    NSString *m_Caption;
    NSMutableArray* m_Options;
    //NSString *m_SelectedValue;
    int m_SelectedOption;
    id<zt_ISelectionTableVCDelegate> m_Delegate;
    
    UIBarButtonItem *m_btnSave;
    BOOL m_ModalMode;
}

- (void)setModalMode:(BOOL)enabled;
- (void)btnSavePressed;
- (void)setDelegate:(id<zt_ISelectionTableVCDelegate>)delegate;
- (void)setCaption:(NSString*)caption;

- (void)setOptionsWithDictionary:(NSDictionary*)options withStringPrefix:(NSString *)dataPrefix;
- (void)setOptionsWithFloatArray:(NSArray *)options withStringFormat:(NSString *) format;
- (void)setOptionsWithStringArray:(NSArray*)options;

- (void)setSelectedOptionInt:(int)option;
- (void)setSelectedValue:(NSString *)value;

@end
