//
//  TaglistDataObject.m
//  RFIDDemoApp
//
//  Created by Venkatraman, Madesan on 22/02/22.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//


#import "TaglistDataObject.h"

#define kTagID        @"tagID"
#define kItemName      @"itemName"
#define ZT_EMPTY_STRING                          @""

@implementation TaglistDataObject
@synthesize tagID;
@synthesize itemName;


/// To intialize the model.
-(id)init
{
    self = [super init];
    if (self != nil)
    {
        tagID = ZT_EMPTY_STRING;
        itemName = ZT_EMPTY_STRING;
    }
    return self;
}


/// Deallocates all the momery.
- (void)dealloc
{
    
    if (nil != tagID)
    {
        [tagID release];
    }
    
    if (nil != itemName) {
        [itemName release];
    }
    
    [super dealloc];
}

/// Ti intialize with tagid and itemname.
/// @param tagID Tagid from the csv file.
/// @param itemName Item name from the csv file.
- (void)initWithTagIDFromCSVFile:(NSString *)tagID itemName:(NSString *)itemName
{
    self.tagID = tagID;
    self.itemName = itemName;
}

/// To get the tagid.
- (NSString*)getTagId
{
    return self.tagID;
}

/// To get the friendly name.
- (NSString*)getTagFriendlyName
{
    return self.itemName;
}

/// To support encoding and decoding of instances
/// @param encoder Nscoder to encode the data.
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:tagID forKey:kTagID];
    [encoder encodeObject:itemName forKey:kItemName];
}

/// Initialize object using nscoder.
/// @param decoder Nscoder to decode the data.
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.tagID = [decoder decodeObjectForKey:kTagID];
        self.itemName = [decoder decodeObjectForKey:kItemName];
    }
    
    return self;
}

@end
