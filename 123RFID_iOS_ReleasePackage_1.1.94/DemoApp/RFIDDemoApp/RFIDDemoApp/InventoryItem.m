/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  RfidInventoryItem.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "InventoryItem.h"
#import "ui_config.h"
@implementation zt_InventoryItem

- (id)initWithTagData:(srfidTagData*)tagData
{
    self = [super init];
    if (nil != self)
    {
        m_TagData = [[srfidTagData alloc] init];
        [m_TagData setTagId:[tagData getTagId]];
        [m_TagData setBrandIDStatusRfidTagData:[tagData getBrandIDStatusRfidTagData]];
        [m_TagData setFirstSeenTime:[tagData getFirstSeenTime]];
        [m_TagData setLastSeenTime:[tagData getLastSeenTime]];
        [m_TagData setPC:[tagData getPC]];
        [m_TagData setPeakRSSI:[tagData getPeakRSSI]];
        [m_TagData setPhaseInfo:[tagData getPhaseInfo]];
        [m_TagData setChannelIndex:[tagData getChannelIndex]];
        [m_TagData setTagSeenCount:[tagData getTagSeenCount]];
        [m_TagData setOpCode:[tagData getOpCode]];
        [m_TagData setOperationSucceed:[tagData getOperationSucceed]];
        [m_TagData setOperationStatus:[tagData getOperationStatus]];
        [m_TagData setMemoryBank:[tagData getMemoryBank]];
        [m_TagData setMemoryBankData:[tagData getMemoryBankData]];
        [m_TagData setPermaLockData:[tagData getPermaLockData]];
        
        m_Count = 0;
    }
    
    return self;
}

/// Initialising the inventory object class with tagid.
/// @param tagID Tagid to be iniatialise.
- (id)initWithTagID:(NSString*)tagID
{
    self = [super init];
    if (nil != self)
    {
        m_TagData = [[srfidTagData alloc] init];
        [m_TagData setTagId:tagID];
        [m_TagData setBrandIDStatusRfidTagData:0];
        [m_TagData setFirstSeenTime:0];
        [m_TagData setLastSeenTime:0];
        [m_TagData setPC:ZT_TAGLIST_EMPTY_STRING];
        [m_TagData setPeakRSSI:0];
        [m_TagData setPhaseInfo:0];
        [m_TagData setChannelIndex:0];
        [m_TagData setTagSeenCount:0];
        [m_TagData setOpCode:0];
        [m_TagData setOperationSucceed:0];
        [m_TagData setOperationStatus:ZT_TAGLIST_EMPTY_STRING];
        [m_TagData setMemoryBank:0];
        [m_TagData setMemoryBankData:ZT_TAGLIST_EMPTY_STRING];
        [m_TagData setPermaLockData:ZT_TAGLIST_EMPTY_STRING];
        
        m_Count = 0;
    }
    
    return self;
}

- (void)dealloc
{
    if (nil != m_TagData)
    {
        [m_TagData release];
    }
    
    [super dealloc];
}

- (srfidTagData*)getTagData
{
    return m_TagData;
}

- (int)getCount
{
    return m_Count;
}

/// Add the overall count of the total reads.
/// @param count Count passed from the view controller.
- (void)addCount:(int)count
{
    m_Count += count;
}

- (void)incCount
{
    m_Count++;
}

- (void)incCountBySeenCount:(int) tagSeenCount
{
    m_Count += tagSeenCount;
}

- (NSString*)getTagId
{
    return [m_TagData getTagId];
}

- (NSString*)getPC
{
    return [m_TagData getPC];
}

- (short)getRSSI
{
    return [m_TagData getPeakRSSI];
}

- (short)getChannelIndex
{
    return [m_TagData getChannelIndex];
}

- (short)getPhase
{
    return [m_TagData getPhaseInfo];
}

- (SRFID_MEMORYBANK)getMemoryBank
{
    return [m_TagData getMemoryBank];
}

- (NSString*)getMemoryBankData
{
    return [m_TagData getMemoryBankData];
}

/// Get the brand id status true or false from a single rfid tag data.
- (BOOL)getBrandIdStatusFromSingleTagData
{
    return [m_TagData getBrandIDStatusRfidTagData];
}

@end
