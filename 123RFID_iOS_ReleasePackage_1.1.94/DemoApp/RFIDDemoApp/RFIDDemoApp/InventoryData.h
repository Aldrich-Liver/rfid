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
 *  Description:  InventoryData.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "InventoryItem.h"
#import <ZebraRfidSdkFramework/RfidTagReportConfig.h>

@interface zt_InventoryData : NSObject

- (NSArray*) getInventoryList:(BOOL)search;
- (void)addInventoryItem:(srfidTagData *)item;
- (void)clearInventoryItemList;

+ (unsigned long)getUniqueCount:(NSArray*)tags;
+ (int)getTotalCount:(NSArray*)tags;

- (NSArray*)getDumpedInventoryList;


@end
