//
//  LinkProfileObject.m
//  RFIDDemoApp
//
//  Created by Symbol on 08/03/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "LinkProfileObject.h"
#import "RfidAppEngine.h"

/// LinkProfileObject model is created to save the filtered linkeprofile values into the model locally.
@implementation zt_LinkProfileObject

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        _indexVal = 0;
        _profileName = @"";
        _modeTableEntry = nil;
    }
    return self;
}

- (void)dealloc
{
    
    if (nil != _profileName)
    {
        [_profileName release];
    }
    
    if (nil != _modeTableEntry) {
        [_modeTableEntry release];
    }
    
    [super dealloc];
}

/// LinkProfileObject initialize method which will help to initialize all the variables.
/// @param index The selected index value of the selected link profile.
/// @param profile The selected profile name of the link profile.
/// @param tableEntry The selected link profile overall values passing through the table entry.
- (void)initWithIndex:(int)index profileName:(NSString *)profileName modeTable:(srfidLinkProfile *)tableEntry legacyProfileName:(NSString *)legacyProfileName
{
    _indexVal = index;
    _profileName = profileName;
    _modeTableEntry = tableEntry;
    _legacyProfileName = legacyProfileName;
}

/// Get the current index of the selected link profile.
- (int)getIndex
{
    return _indexVal;
}

/// Get the current name of the selected link profile.
- (NSString*)getProfile
{
    return _profileName;
}

/// Get the overall details of the selected link profile.
- (srfidLinkProfile*) getModeTableEntry
{
    return _modeTableEntry;
}

@end
