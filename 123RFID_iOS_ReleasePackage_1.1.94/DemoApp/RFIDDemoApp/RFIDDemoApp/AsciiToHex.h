//
//  AsciiToHex.h
//  RFIDDemoApp
//
//  Created by Nilusha Wimalasena on 2021-10-07.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AsciiToHex : NSObject

+ (NSString *)stringFromAsciiString:(NSString *)asciiString;

@end

NS_ASSUME_NONNULL_END
