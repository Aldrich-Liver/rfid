//
//  ShareProfilePopup.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 13/03/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

@protocol ShareprofilePopupDelegate <NSObject>

@required
- (void)reloadTableDataAfterDelete;

@end


#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>
NS_ASSUME_NONNULL_BEGIN

@interface ShareProfilePopup : UIViewController<zt_IRfidAppEngineWlanConnectEventDelegate,zt_IRfidAppEngineWlanOperationFailedEventDelegate>
{
    IBOutlet UIView * shareProfileView;
    IBOutlet UILabel * descriptionLabel;
    srfidReaderInfo *m_LastReaderInfo;
}
@property (nonatomic, retain) id<ShareprofilePopupDelegate> sharePopupDelegate;
@property (nonatomic, assign) NSString * profileName;
@property (nonatomic, retain) NSMutableDictionary *resultDictioanry;
@end

NS_ASSUME_NONNULL_END
