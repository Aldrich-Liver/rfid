//
//  AddCertificatePopup.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 26/08/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

@protocol AddCertificatePopupDelegate <NSObject>

@required
- (void)reloadTableData;

@end

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
NS_ASSUME_NONNULL_BEGIN

@interface AddCertificatePopup : UIViewController<UITableViewDataSource, UITableViewDelegate,zt_IOptionCellDelegate,UIDocumentPickerDelegate>
{
    IBOutlet UITableView *addCertificate_table;
    int m_PickerCellIdx;
    
    /* cells */
    zt_InfoCellView *cellInterface;
    zt_InfoCellView *cellCertType;
    zt_PickerCellView *m_cellPicker;
    IBOutlet UIView * addCertificateView;
    IBOutlet NSLayoutConstraint * heightConstraint;
}
@property (nonatomic, retain) id<AddCertificatePopupDelegate> popupDelegate;
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;
@end

NS_ASSUME_NONNULL_END
