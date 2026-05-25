//
//  UIViewController+ZT_ResponseHandler.m
//  RFIDDemoApp
//
//  Created by SST on 04/06/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//


#import "UIViewController+ZT_ResponseHandler.h"

@implementation UIViewController (ZT_ResponseHandler)

- (void)handleCommandResult:(SRFID_RESULT)result withStatusMessage:(NSString *)message
{
    switch (result) {
        case SRFID_RESULT_SUCCESS:
            [self showSucces];
            break;
            
        case SRFID_RESULT_FAILURE:
            [self showFailure:@""];
            break;
            
        case SRFID_RESULT_RESPONSE_ERROR:
            [self showFailure:message];
            break;
            
        case SRFID_RESULT_RESPONSE_TIMEOUT:
            [self showTimeout];
            break;
            
        default:
            break;
    }
}

- (void)showSucces
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:YES aSuccessMessage:@"Settings applied successfully" aFailureMessage:@"Failed to apply settings"];
    });
    
}

- (void)showFailure:(NSString *)message
{
    NSString *err = [NSString stringWithFormat:@"%@", message];
    
    NSString *failure_message = @"Failed to apply settings";
    
    failure_message = [failure_message stringByAppendingFormat:@":\r\n%@", err];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:NO aSuccessMessage:@"Settings applied successfully" aFailureMessage:failure_message];
    });
}

- (void)showTimeout
{
    NSString *failure_message = @"Failed to apply settings";
    
    failure_message = [failure_message stringByAppendingFormat:@":\r\n%@", @"Timeout"];
}


@end
