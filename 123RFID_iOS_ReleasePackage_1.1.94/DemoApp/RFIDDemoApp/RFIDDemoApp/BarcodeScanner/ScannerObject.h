//
//  ScannerObject.h
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-09-07.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZebraScannerFramework/SbtSdkFactory.h>

NS_ASSUME_NONNULL_BEGIN


/// The scanner object class to store the connected scanner data.
@interface ScannerObject : NSObject{
      SbtScannerInfo *scannerInfo;
}

@property(strong, nonatomic, readwrite) SbtScannerInfo *scannerInfo;
+ (ScannerObject *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
