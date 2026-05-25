//
//  Symbology.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "Symbology.h"
#import "ui_config.h"

@implementation Symbology


/// Init symbology
/// @param name Name of symbology
/// @param attr_id Attribute id
- (id)init:(NSString*)name aRMDAttr:(int)attr_id{
    self = [super init];
    if (self != nil){
        symbologyName = [[NSString alloc] initWithFormat:ZT_SYMBOLOGIES_OBJECT_STRING_FORMAT, name];
        rmdAttributeID = attr_id;
        enabled = NO;
        supported = NO;
    }
    return self;
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc{
    if (symbologyName != nil)
    {
        [symbologyName release];
    }

    [super dealloc];
}

/// Get RMD attribute
- (int)getRMDAttributeID{
    return rmdAttributeID;
}

/// Enable status
- (BOOL)isEnabled{
    return enabled;
}

/// Get symbology name
- (NSString*)getSymbologyName{
    return symbologyName;
}

/// Change enable status
/// @param enabled value
- (void)setEnabled:(BOOL)enabledValue{
    enabled = enabledValue;
}

/// Check support status
- (BOOL)isSupported{
    return supported;
}

/// Set support status
/// @param supported value
- (void)setSupported:(BOOL)supportedValue{
    supported = supportedValue;
}

@end
