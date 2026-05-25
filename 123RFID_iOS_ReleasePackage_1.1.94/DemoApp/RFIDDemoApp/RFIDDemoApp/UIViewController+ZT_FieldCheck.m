//
//  UIViewController+ZT_FieldCheck.m
//  RFIDDemoApp
//
//  Created by SST on 18/06/15.
//  Copyright (c) 2015 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UIViewController+ZT_FieldCheck.h"

@implementation UIViewController (ZT_FieldCheck)

- (BOOL)isEmptyField:(NSString *)input
{
    if ([input length] == 0) {
        return YES;
    }
    else
        return NO;
}

- (BOOL)checkForMinLL:(long long)min forMax:(long long)max withValue:(long long)value
{
    if (value < min || value > max) {
        return NO;
    }
    return YES;
}

- (BOOL)checkForMin:(int)min forMax:(int)max withValue:(int)value
{
    if (value < min || value > max) {
        return NO;
    }
    return YES;
}

- (void)showInvalidParamsWarning
{
    NSString *message = @"Invalid Parameters";
    NSString *err = [NSString stringWithFormat:@"%@", message];
    
    NSString *failure_message = @"Failed to apply settings";
    
    failure_message = [failure_message stringByAppendingFormat:@":\r\n%@", err];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:NO aSuccessMessage:@"Settings applied successfully" aFailureMessage:failure_message];
    });
}


- (BOOL)checkDataLength:(int)validLength withData:(NSString *)data
{
    if ([data length] > validLength || [data length] == 0) {
        return NO;
    }
    return YES;
}

// length <= 128 and only HEX
- (BOOL)checkHexPattern:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    if ([address length] > 128) {
        return NO;
    }
    
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* 0 .. 9, A .. F */
        if ((_ch < 48) || ((_ch > 57) && (_ch < 65)) || (_ch > 70))
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
    
}

- (BOOL)checkNumInput:(NSString*)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* :, 0 .. 9, A .. F */
        if ((_ch < 48) || (_ch > 57) )
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

// length <= 8 and only HEX
- (BOOL)checkPasswordInput:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    if ([address length] > 8) {
        return NO;
    }
    
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        if ((_ch < 48) || ((_ch > 57) && (_ch < 65)) || (_ch > 70))
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

/// Check hex tag pattern leangth.
/// - Parameter address: The address of the tag.
- (BOOL)checkHexPatternForLengthyTags:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
//    if ([address length] > 128) {
//        return NO;
//    }
    
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* 0 .. 9, A .. F */
        if ((_ch < 48) || ((_ch > 57) && (_ch < 65)) || (_ch > 70))
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
    
}


@end
