//
//  WiFiSettingsViewControler.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2023-06-30.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import <ZebraRfidSdkFramework/RfidWlanScanList.h>
#import <ZebraRfidSdkFramework/RfidWlanProfile.h>
#import "AddprofilePopup.h"
#import "ShareProfilePopup.h"

/// WiFi Settings view controller
@interface WiFiSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,zt_IRfidAppEngineWlanScanEventDelegate,AddprofilePopupDelegate,ShareprofilePopupDelegate,zt_IRfidAppEngineWlanDisConnectEventDelegate>
{
    NSMutableArray *connected_networks_list;
    NSMutableArray *saved_networks_list;
    NSMutableArray *available_networks_list;
    UIButton * buttonScanWifi;
    srfidWlanScanList * availableNetworks_listObject;
}
@property (retain, nonatomic) IBOutlet UITableView * available_networks_table;
@end

