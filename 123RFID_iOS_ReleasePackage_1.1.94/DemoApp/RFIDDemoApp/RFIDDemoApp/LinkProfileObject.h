//
//  LinkProfileObject.h
//  RFIDDemoApp
//
//  Created by Symbol on 08/03/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RfidAppEngine.h"

/// LinkProfileObject model is created to save the filtered linkeprofile values into the model locally.
@interface zt_LinkProfileObject : NSObject

@property (atomic) int indexVal;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) srfidLinkProfile * modeTableEntry;
@property (nonatomic, retain) NSString * legacyProfileName;


- (void)initWithIndex:(int)index profileName:(NSString *)profileName modeTable:(srfidLinkProfile *)tableEntry legacyProfileName:(NSString *)legacyProfileName;
- (int)getIndex;
- (NSString*)getProfile;
- (srfidLinkProfile*)getModeTableEntry;

@end

