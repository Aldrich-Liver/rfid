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
 *  Description:  RegionData.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidRegionInfo.h>

@interface zt_RegionData : NSObject

@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, copy) NSString *regionName;
@property (nonatomic, retain,setter=setSupportedChannels:) NSMutableArray *supporteChannels;
@property (nonatomic) BOOL hoppingConfigurable;

- (void)setRegionFromRegionInfo:(srfidRegionInfo *)info;
- (void)setSupportedChannels:(NSMutableArray *)channels;

@end
