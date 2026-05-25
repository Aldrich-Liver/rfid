//
//  SbtScannerInfo+AssetsTblRepresentation.h
//  RFIDDemoApp
//
//  Created by Kasun Adhikari on 2021-11-17.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.


#import <ZebraScannerFramework/SbtScannerInfo.h>

/// Assets information table representation
@interface SbtScannerInfo (AssetsTblRepresentation)
@property (nonatomic, retain) NSMutableDictionary *resultDictionary;

- (NSMutableDictionary*)getAssetsTableRepresentation:(void (^)(NSMutableDictionary *dictionary))competionHnadler;
- (void)setResultDictionary:(NSMutableDictionary *)resultDictionary;
- (NSMutableDictionary*)getResultDictionary;

@end
