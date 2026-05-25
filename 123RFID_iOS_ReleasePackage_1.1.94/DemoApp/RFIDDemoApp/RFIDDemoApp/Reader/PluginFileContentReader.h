//
//  PluginFileContentReader.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-16.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFirmwareModelContentReader.h"

@interface PluginFileContentReader : NSObject<PluginFirmwareModelContentReader, NSXMLParserDelegate> {
    NSString *plugFamily;//family+name
    NSString *plugName;
    NSString *plugInRev;//revision
    NSString *plugInDate;//release-date
    NSString *matchingPlugInFirmwareName;//TBD
    NSString *pngFileName;
    NSString *releaseNotes;
    
    NSString *releaseNotesFilePath;
    NSString *metadataFilePath;
    NSString *xmlContent;
    
    NSMutableArray *modelList;
    
    //for nsxmlparser sml parsing
    // an ad hoc string to hold element value
    NSMutableString *currentElementValue;
    FirmwareUpdateModel *firmwareModel;
}

@property(nonatomic, retain)NSString *pluginFilePath;

@end
