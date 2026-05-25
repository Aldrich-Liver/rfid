//
//  ImpinjInventoryVC.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-08-01.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#ifndef ImpinjInventoryVC_h
#define ImpinjInventoryVC_h


#endif /* ImpinjInventoryVC_h */

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "SwitchCellView.h"
#import <ZebraRfidSdkFramework/RfidSdkApi.h>
#import <ZebraRfidSdkFramework/RfidSdkFactory.h>
#import <ZebraRfidSdkFramework/RfidTagData.h>
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>
#import <ZebraRfidSdkFramework/RfidOperEndSummaryEvent.h>
#import <ZebraRfidSdkFramework/RfidDatabaseEvent.h>
#import <ZebraRfidSdkFramework/RfidTemperatureEvent.h>
#import <ZebraRfidSdkFramework/RfidPowerEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImpinjInventoryVC :UIViewController <zt_IRfidAppEngineTagDataEventForImpingTag>
{
    IBOutlet UIButton *m_BtnFocus;
    IBOutlet UIButton *m_BtnQuite;
    IBOutlet UIButton *m_BtnUnquite;
    
    IBOutlet UITableView *m_TblImpinjInventory;
    
    IBOutlet UILabel *m_LblTagQuietStatus;
    
    IBOutlet UIButton *m_BtnImpinjInvStart;
    IBOutlet UIButton *m_BtnClearSes;
    
    NSMutableArray *m_Tags;
        
    id <srfidISdkApi> m_RfidSdkApi;
    
    //NSMutableArray *currentlySelectedTagIdObjectArray;
    

}

@property (nonatomic, strong) NSMutableArray *tagDataInventory;
@property (nonatomic, strong) NSMutableArray *currentlySelectedTagIdObjectArray;
@property (nonatomic, strong) NSMutableArray *selectedRows;

@end

NS_ASSUME_NONNULL_END
