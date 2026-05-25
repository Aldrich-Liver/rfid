//
//  UIViewController+ZT_FieldCheck.h
//  RFIDDemoApp
//
//  Created by SST on 18/06/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"

#define ZT_VC_EMPTY_FIELD              -1

@interface UIViewController (ZT_FieldCheck)

- (BOOL)isEmptyField:(NSString *)input;

- (BOOL)checkForMinLL:(long long)min forMax:(long long)max withValue:(long long)value;
- (BOOL)checkForMin:(int)min forMax:(int)max withValue:(int)value;

- (void)showInvalidParamsWarning;
- (BOOL)checkDataLength:(int)validLength withData:(NSString *)data;

- (BOOL)checkHexPattern:(NSString *)address;
- (BOOL)checkNumInput:(NSString*)address;
- (BOOL)checkPasswordInput:(NSString *)address;
- (BOOL)checkHexPatternForLengthyTags:(NSString *)address;

@end
