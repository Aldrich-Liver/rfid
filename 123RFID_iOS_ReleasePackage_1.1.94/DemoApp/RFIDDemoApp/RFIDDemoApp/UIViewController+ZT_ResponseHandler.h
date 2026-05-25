//
//  UIViewController+ZT_ResponseHandler.h
//  RFIDDemoApp
//
//  Created by SST on 04/06/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "AlertView.h"

@interface UIViewController (ZT_ResponseHandler)
- (void)handleCommandResult:(SRFID_RESULT)result withStatusMessage:(NSString *)message;
- (void)showSucces;
- (void)showFailure:(NSString *)message;
- (void)showTimeout;
@end
