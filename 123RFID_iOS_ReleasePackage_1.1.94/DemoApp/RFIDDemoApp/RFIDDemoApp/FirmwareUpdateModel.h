//
//  FWUpdateModel.h
//  ScannerSDKApp
//
//  Created by pqj647 on 10/9/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirmwareUpdateModel : NSObject

@property (nonnull, retain) NSString *modelTitle;
@property (nonnull, retain) NSString *datFileName;
@property (nonnull, retain) NSString *releasedDate;
@property (nonnull, retain) NSString *releaseNotes;
@property (nonnull, retain) NSArray * supportedModels;
@property (nonnull, retain) NSString *plugInRev;
@property (nonnull, retain) NSString *plugFamily;//family+name
@property (nonnull, retain) NSMutableArray *firmwareNameArray;
@property (nonnull, retain) NSData *imgData;

@end
