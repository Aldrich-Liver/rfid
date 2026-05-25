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
 *  Description:  RegionData.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RegionData.h"

@implementation zt_RegionData

-(id)init
{
    self = [super init];
    if (self != nil)
    {
    
    }
    return self;
}

- (void)dealloc
{
    if (nil != _regionCode)
    {
        [_regionCode release];
    }
    
    if (nil != _regionName)
    {
        [_regionName release];
    }
    
    if (nil != _supporteChannels) {
        [_supporteChannels release];
    }
    
    [super dealloc];
}

- (void)setRegionFromRegionInfo:(srfidRegionInfo *)info
{
    NSString *oldCode = _regionCode;
    NSString *oldName = _regionCode;
    _regionCode = [[info getRegionCode] copy];
    _regionName = [[info getRegionName] copy];
    [oldCode release];
    [oldName release];
}

- (void)setSupportedChannels:(NSMutableArray *)channels
{
    if (nil == _supporteChannels)
    {
        _supporteChannels = [[NSMutableArray alloc] init];
    }
    [_supporteChannels removeAllObjects];
    [_supporteChannels addObjectsFromArray:channels];
}
@end
