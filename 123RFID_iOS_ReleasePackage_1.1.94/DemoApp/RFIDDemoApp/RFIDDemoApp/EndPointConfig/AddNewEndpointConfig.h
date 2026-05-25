//
//  AddNewEndpointConfig.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2024-09-26.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

@protocol AddNewEndpointConfigDelegate <NSObject>

@required
- (void)reloadTableData;

@end

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "LabelInputFieldCellView.h"
#import "SwitchCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "EnumMapper.h"
NS_ASSUME_NONNULL_BEGIN

@interface AddNewEndpointConfig : UIViewController<UITableViewDataSource, UITableViewDelegate,UIDocumentPickerDelegate,zt_IOptionCellDelegate>
{
    IBOutlet UITableView *addNewEndpoint_table;
    IBOutlet UIButton * addButton;
    int m_PickerCellIdx;
    
    /* cells */
    zt_InfoCellView *cellType;
    zt_InfoCellView *cellProtocol;
    zt_InfoCellView *cellHostVerify;
    
    zt_LabelInputFieldCellView *cellName;
    zt_LabelInputFieldCellView *cellUrl;
    zt_LabelInputFieldCellView *cellPort;
    zt_LabelInputFieldCellView *cellKeepAlive;
    zt_LabelInputFieldCellView *cellTenantID;
    zt_LabelInputFieldCellView *cellMinRconnectDelay;
    zt_LabelInputFieldCellView *cellMaxReconnectDelay;
    zt_LabelInputFieldCellView *cellUserName;
    zt_LabelInputFieldCellView *cellPassword;
    // MDM Support
    zt_LabelInputFieldCellView *cellCommandTopic;
    zt_LabelInputFieldCellView *cellResponseTopic;
    zt_LabelInputFieldCellView *cellEventTopic;
    zt_InfoCellView *cellCACertificate;
    zt_InfoCellView *cellClientCertificate;
    zt_InfoCellView *cellPrivateKey;
    
    zt_SwitchCellView *cellCleanSession;
    zt_SwitchCellView *cellActivate;
    zt_PickerCellView *m_cellPicker;
    zt_EnumMapper *m_MapperEndpointConfigType;
    zt_EnumMapper *m_MapperEndpointConfigProtocol;
    zt_EnumMapper *m_MapperEndpointConfigHostverify;
    UITapGestureRecognizer *m_GestureRecognizer;
    srfidGetActiveEnpoints *activeEndPoints;
    NSMutableArray * certificates_list;
}
@property (retain, nonatomic) NSString * endPointName;
@property (retain, nonatomic) NSString * operation;
- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;
- (int)recalcCellIndex:(int)cell_index;

@end

NS_ASSUME_NONNULL_END
