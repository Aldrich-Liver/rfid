//
//  ScannerObject.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-09-07.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "ScannerObject.h"

@implementation ScannerObject
@synthesize scannerInfo = _scannerInfoObject;

+ (ScannerObject *)sharedInstance {
    static dispatch_once_t onceToken;
    static ScannerObject *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ScannerObject alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _scannerInfoObject = [[SbtScannerInfo alloc] init];
    
    }
    return self;
}


@end
