//
//  TaglistDataObject.h
//  RFIDDemoApp
//
//  Created by Venkatraman, Madesan on 22/02/22.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaglistDataObject : NSObject <NSCoding>
{
    NSString * tagID;
    NSString * itemName;
}
@property (nonatomic, copy)NSString * tagID;
@property (nonatomic, copy)NSString * itemName;

- (void)initWithTagIDFromCSVFile:(NSString *)tagID itemName:(NSString *)itemName;
- (NSString*)getTagId;
- (NSString*)getTagFriendlyName;

@end

