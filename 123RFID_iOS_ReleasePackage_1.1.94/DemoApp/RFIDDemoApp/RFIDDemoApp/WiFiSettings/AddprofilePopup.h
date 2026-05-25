//
//  AddprofilePopup.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 29/02/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

@protocol AddprofilePopupDelegate <NSObject>

@required
- (void)reloadTableData;

@end

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "WiFiSettingsViewControler.h"
#import "SwitchCellView.h"
NS_ASSUME_NONNULL_BEGIN

@interface AddprofilePopup : UIViewController<UITableViewDataSource, UITableViewDelegate,zt_IOptionCellDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView *addProfile_table;
    int m_PickerCellIdx;
    
    /* cells */
    zt_InfoCellView *cellProtocol;
    zt_InfoCellView *cellEAP;
    zt_InfoCellView *cellCACertificates;
    zt_InfoCellView *cellClientCertificates;
    zt_InfoCellView *cellPrivateKey;
    zt_LabelInputFieldCellView *cellIdentity;
    zt_LabelInputFieldCellView *cellAnnonymousIdentity;
    zt_LabelInputFieldCellView *cellPassword;
    zt_LabelInputFieldCellView *cellPrivatePassword;
    zt_PickerCellView *m_cellPicker;
    zt_SwitchCellView *cellHiddenSSID;
    zt_SwitchCellView *cellPreferredWIFI;
    UITapGestureRecognizer *m_GestureRecognizer;
    IBOutlet UIView * addProfileView;
    IBOutlet UILabel * profileName;
    IBOutlet UITextField * profileName_Field;
    IBOutlet UILabel * lineLabel;
    NSMutableArray * certificates_list;
    IBOutlet NSLayoutConstraint * heightConstraint;
    IBOutlet NSLayoutConstraint * profileNameLabelHC;
    IBOutlet NSLayoutConstraint * profileNameFieldHC;
}
@property (nonatomic, retain) NSString * popup_type;
@property (nonatomic, assign) srfidWlanScanList * profile_listObject;
@property (nonatomic, retain) id<AddprofilePopupDelegate> popupDelegate;
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;
@end

NS_ASSUME_NONNULL_END
