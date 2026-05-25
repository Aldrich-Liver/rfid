//
//  BarcodeData.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-08-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "BarcodeData.h"
#import "ui_config.h"

/// Barcode data object
@implementation BarcodeData

/// init barcode object
/// @param barcode_data data value
/// @param barcode_type barcode type
- (id)initWithData:(NSData*)barcode_data ofType:(int)barcodeType
{
    self = [super init];
    if (self != nil)
    {
        decodeType = barcodeType;
        decodeData = [[NSData alloc] initWithData:barcode_data];
    }
    return self;
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (decodeData != nil)
    {
        [decodeData release];
    }
    [super dealloc];
}

/// Get decoded type
- (int)getDecodeType
{
    return decodeType;
}

/// Get decode data
- (NSData*)getDecodeData
{
    return decodeData;
}


/// Get decode data string
/// @param enc encoding type
- (NSString *)getDecodeDataAsStringUsingEncoding:(NSStringEncoding)enc
{
    NSString *decodeDataString = [[NSString alloc] initWithBytes:((unsigned char*)[decodeData bytes]) length:([decodeData length]) encoding:enc];
    
    // If nil data is returned, display data bytes as string.
    if (decodeDataString == nil)
    {
        [decodeDataString release];
        
        unsigned char *bytes = (unsigned char*)[decodeData bytes];
        
        NSMutableString *decodeDataBytesString = [[NSMutableString alloc] initWithString:BARCODE_DATA_VIEW_DATA_CANNOT_DISPLAY_AS_STRING];
        
        for (int i = 0; i < [decodeData length]; i++)
        {
            [decodeDataBytesString appendFormat:BARCODE_DATA_VIEW_DECODE_DATA_FORMATER,bytes[i]];
        }
        
        decodeDataString = [[NSString alloc] initWithString:decodeDataBytesString];
        [decodeDataBytesString release];
    }
    
    return [decodeDataString autorelease];
}

@end
