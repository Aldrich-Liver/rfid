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
 *  Description:  FileExportManager.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "RfidAppEngine.h"

@interface zt_FileExportManager : NSObject

+ (NSString *)getHeaderWithCount:(int)unique withTotalCount:(int)total withReadTime:(NSTimeInterval)readTime;
+ (NSString *)getData:(NSArray*)tags;
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)readTime;
@end
