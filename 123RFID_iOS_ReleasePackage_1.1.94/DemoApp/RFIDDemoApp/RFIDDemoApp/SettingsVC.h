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
 *  Description:  SettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "ImageLabelCellView.h"
#import "UIViewController+ZT_ResponseHandler.h"

@interface zt_SettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IRfidAppEngineDevListDelegate,UIDocumentPickerDelegate,AuthorisationPopupDelegate>
{
    NSMutableArray *m_SettingsOptionsHeaders;
    NSMutableArray *m_SettingsOptionsImages;
    IBOutlet UITableView *m_tblSettingsOptions;
    zt_ImageLabelCellView *m_OffscreenImageLabelCell;
    BOOL inventoryRequested;
    BOOL isScannerSupport;
    UIAlertController *alertController;
    
}
@property (nonatomic, retain) NSMutableDictionary *resultDictioanry;
- (void)configureImageLabelCell:(zt_ImageLabelCellView*)cell forRow:(int)row;
@end
