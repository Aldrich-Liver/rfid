//
//  HexToAscii.h
//  RFIDDemoApp
//
//  Created by Nilusha Wimalasena on 2021-09-27.
//  Copyright © 2021 Zebra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Convert string to hex string
@interface HexToAscii : NSObject

+ (NSString *)stringFromHexString:(NSString *)hexString;
+ (int)hexToInteger:(char)characterValue;

@end

NS_ASSUME_NONNULL_END
