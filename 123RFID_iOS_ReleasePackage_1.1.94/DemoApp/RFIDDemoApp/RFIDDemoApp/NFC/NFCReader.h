//
//  NFCReader.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2022-03-18.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>

NS_ASSUME_NONNULL_BEGIN

/// NFC read helper class.
@interface NFCReader : NSObject<NFCNDEFReaderSessionDelegate>{
    NFCNDEFReaderSession *session;
}

-(void)startNFCReading;


@end

NS_ASSUME_NONNULL_END
