//
//  BarcodeData.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-08-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Barcode data object
@interface BarcodeData : NSObject
{
    NSData *decodeData;
    int decodeType;
}

- (id)initWithData:(NSData*)barcode_data ofType:(int)barcodeType;
- (void)dealloc;

- (int)getDecodeType;
- (NSData*)getDecodeData;
- (NSString *)getDecodeDataAsStringUsingEncoding:(NSStringEncoding)encoding;


@end


NS_ASSUME_NONNULL_END
