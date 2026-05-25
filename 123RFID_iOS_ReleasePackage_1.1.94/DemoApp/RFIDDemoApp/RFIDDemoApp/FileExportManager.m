/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  FileExportManager.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "FileExportManager.h"

@implementation zt_FileExportManager

+ (NSString *)getHeaderWithCount:(int)unique withTotalCount:(int)total withReadTime:(NSTimeInterval)readTime
{
    NSString *result = @"INVENTORY SUMMARY";
    result = [NSString stringWithFormat:@"%@\rUNIQUE COUNT:,%d",result,unique];
    result = [NSString stringWithFormat:@"%@\rTOTAL COUNT:,%d",result,total];
    result = [NSString stringWithFormat:@"%@\rREAD TIME:, %@ (HH:MM:SS)",result,[self stringFromTimeInterval:readTime]];
    result = [NSString stringWithFormat:@"%@\r\r",result];
    return result;
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

+ (NSString *)getData:(NSArray *)tags
{
    NSString *result = @"TAG ID, COUNT";
    for (zt_InventoryItem *tag in tags) {
        result = [NSString stringWithFormat:@"%@\r%@,%d",result,[tag getTagId],[tag getCount]];
    }
    return result;
}

@end
