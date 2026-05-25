//
//  PFWModelContentReader.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-16.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirmwareUpdateModel.h"

@protocol PluginFirmwareModelContentReader <NSObject>

- (NSString*)readPluginFileData:(void (^)(FirmwareUpdateModel *model))block;

- (FirmwareUpdateModel*)getFirmwareUpdateModel;

- (void)setReleaseNoteFilePath:(NSString*)path;

- (void)setMetaDataFilePath:(NSString*)path;

@end
