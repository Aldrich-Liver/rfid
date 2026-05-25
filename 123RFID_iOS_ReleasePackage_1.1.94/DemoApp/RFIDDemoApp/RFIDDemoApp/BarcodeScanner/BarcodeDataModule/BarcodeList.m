//
//  BarcodeList.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-09-08.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "BarcodeList.h"


/// Barcode data list object
@implementation BarcodeList


/// Init barcode  list object
/// @param moto_id The Scanner id
/// @param scannerName The scanner name
- (id)initWithMotoID:(int)moto_id andName:(NSString *)scannerName
{
    self = [super init];
    if (self != nil)
    {
        m_MotoScannerID = moto_id;
        m_BarcodeList = [[NSMutableArray alloc] init];
        m_ScannerName = [[NSString alloc] initWithString:scannerName];
    }
    return self;
}


/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (m_BarcodeList != nil)
    {
        [m_BarcodeList removeAllObjects];
        [m_BarcodeList release];
        [m_ScannerName release];
    }
    [super dealloc];
}


///  Get scanner id
- (int)getScannerID
{
    return m_MotoScannerID;
}


/// Get barcode list
- (NSArray*)getBarcodeList
{
    return m_BarcodeList;
}


/// get scanner name
- (NSString *) getScannerName
{
    return m_ScannerName;
}


/// Clear barcode data
- (void) clearBarcodeList
{
    [m_BarcodeList removeAllObjects];
}


/// Add barcode data
/// @param decode_data The decode data
- (void)addBarcodeData:(BarcodeData*)decode_data
{
    if (m_BarcodeList != nil)
    {
        [m_BarcodeList addObject:decode_data];
    }
}

@end
