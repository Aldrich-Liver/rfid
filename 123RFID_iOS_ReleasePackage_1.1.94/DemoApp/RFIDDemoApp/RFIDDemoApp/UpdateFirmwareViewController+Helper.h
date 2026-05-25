//
//  UpdateFirmwareViewController+Helper.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-22.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UpdateFirmwareViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpdateFirmwareViewController (Helper)

-(NSString*)processReleasedDateLableString:(NSString*)revision withDate:(NSString*)date withFirmwareName:(NSMutableArray*)firmwareNameArray;
- (NSString*)getCorrectFirmwareName:(NSMutableArray*)firmwareNameArray;
- (NSString*)getAvailableFirmwareFile;
- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path;
- (NSMutableAttributedString*)getPluginMismatchString;
- (NSMutableAttributedString*)getFirmwareUpdateHelpString;
- (NSString *)findFilesEdatName:(NSString *)extension fromPath:(NSString*)path;
- (NSString *)findFilesEDATtName:(NSString *)extension fromPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
