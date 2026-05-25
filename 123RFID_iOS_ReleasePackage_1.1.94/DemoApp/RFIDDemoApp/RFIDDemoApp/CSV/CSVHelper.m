//
//  CSVHelper.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-11-15.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "CSVHelper.h"
#import "InventoryData.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "HexToAscii.h"

@implementation CSVHelper

/// Get csv format list from array
/// @param list tags list
+(NSString *)getAllTagListAsStringForCSV:(NSArray *)list{
    NSMutableArray * taglistArray = [[NSMutableArray alloc] init];
    
    for(zt_InventoryItem *inventoryItem in list) {
        NSString *tagIdWithHexOrAscii = [NSString stringWithFormat:ZT_EXPORTDATA_ASCII_FORMAT,[inventoryItem getTagId]];
        
        if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode]){
            NSString * asciiTagData = [HexToAscii stringFromHexString:tagIdWithHexOrAscii];
            tagIdWithHexOrAscii = asciiTagData;
        }
        
//      NSString *tagRowData = [NSString stringWithFormat:ZT_EXPORTDATA_TAG_ROWS,tagIdWithHexOrAscii,[inventoryItem getCount],[inventoryItem getRSSI]];
        NSString *tagRowData = [NSString stringWithFormat:@"\"%@\",\"%d\",\"%d\"", tagIdWithHexOrAscii, [inventoryItem getCount], [inventoryItem getRSSI]];

        [taglistArray addObject:tagRowData];
    }
    NSString *rowsForTags = [taglistArray componentsJoinedByString: ZT_EXPORTDATA_TAG_ROW_LINE_BREAK];
    return rowsForTags;
}

/// Create a file name
+(NSString *)generateFileName{
    NSDate *date = [NSDate date];
    int unixtime = [date timeIntervalSince1970];
    NSString * fileName = [NSString stringWithFormat:ZT_EXPORTDATA_FILE_NAME_FORMAT,ZT_EXPORTDATA_FILENAME,unixtime,ZT_EXPORTDATA_FILENAME_CONVENTION];
    return fileName;
}

/// Create tags heading
+(NSString *)tagListHeading{
    //NSString *tagRowData = [NSString stringWithFormat:ZT_EXPORTDATA_TAGS_HEADING,ZT_EXPORTDATA_TAG_ID,ZT_EXPORTDATA_COUNT,ZT_EXPORTDATA_RSSI];
    NSString *tagRowData = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\"", @"TAG ID", @"COUNT", @"RSSI"];

    return tagRowData;
}

/// Get time string value
/// @param timeValue time value float
+(NSString *)getTimeToString:(CGFloat) timeValue{
    int _time = timeValue;
    int min = _time / ZT_EXPORTDATA_TIME_60;
    int sec = _time % ZT_EXPORTDATA_TIME_60;
    NSString *minAndSec = [NSString stringWithFormat:ZT_EXPORTDATA_TIME_FORMAT,min,sec];
    //NSString *readTime = [NSString stringWithFormat:ZT_EXPORTDATA_CSV_TIME_FORMAT,ZT_EXPORTDATA_READ_TIME,minAndSec];
    NSString *readTime = [NSString stringWithFormat:@"\"%@\",\"%@\"", @"READ TIME:", minAndSec];

    return readTime;
}


@end
