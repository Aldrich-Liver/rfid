//
//  AssetDetailsVC.h
//  RFIDDemoApp
//
//  Created by Kasun Adhikari on 2021-11-17.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.


#import <UIKit/UIKit.h>
#import <ZebraScannerFramework/SbtScannerInfo.h>
#import "ScannerDetailsVC.h"

///Responsible for AssetDetails page.
@interface AssetDetailsVC : ScannerDetailsVC
@property (nonatomic, retain) NSMutableDictionary *resultDictioanry;

@end
