//
//  BarcodeList.h
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-09-08.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarcodeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BarcodeList : NSObject
{
    int m_MotoScannerID;
    NSString *m_ScannerName;
    NSMutableArray *m_BarcodeList;
}

- (id)initWithMotoID:(int)moto_id andName:(NSString *)scannerName;
- (void)dealloc;

- (int)getScannerID;
- (NSArray*)getBarcodeList;
- (NSString *)getScannerName;
- (void) clearBarcodeList;
- (void)addBarcodeData:(BarcodeData*)decode_data;


@end

NS_ASSUME_NONNULL_END
