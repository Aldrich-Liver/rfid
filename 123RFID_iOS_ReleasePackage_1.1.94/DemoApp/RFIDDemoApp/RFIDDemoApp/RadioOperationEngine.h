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
 *  Description:  InventoryEngine.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidReportConfig.h>
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import <ZebraRfidSdkFramework/RfidTagData.h>
#import "InventoryData.h"

#define ZT_RADIO_OPERATION_NONE                 0
#define ZT_RADIO_OPERATION_INVENTORY            1
#define ZT_RADIO_OPERATION_LOCATIONING          2
#define ZT_RADIO_OPERATION_MULTI_TAG_LOCATIONING   3

@protocol zt_IRadioOperationEngineListener <NSObject>
- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type;
- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type;
@end

@interface zt_RadioOperationEngine : NSObject
{
    NSMutableArray *m_ListenersList;
    
/* operation params */
    NSLock *m_OperationParamGuard;
    /* fields configured to be reported during inventory operation */
    srfidReportConfig *m_TagReportConfig;
    /* memory bank for inventory operation */
    SRFID_MEMORYBANK m_InventoryMemoryBank;
    /* tag pattern for locationing operation */
    NSMutableString *m_LocationingTagId;
    
/* operation status */
    NSLock *m_OperationStatusGuard;
    int m_OperationType;
    BOOL m_OperationInProgress;
    BOOL m_AbortRequested;
    BOOL m_InventoryIsRequested;
    BOOL m_LocationingIsRequested;
    BOOL m_GetTagsIsRequested;
    BOOL m_RetriveReaderConfigAfterBatch;
    BOOL multiTagLocationingIsRequested;
    
    /* from first start notification to last stop notification */
    NSTimeInterval m_SessionTime;
    /* real operation time between start & stop notification */
    NSTimeInterval m_RadioOperationTime;
    /* time of last started operation cycle */
    NSDate *m_LastStartOperationTime;
    /* time of first started operation cycle */
    NSDate *m_FirstStartOperationTime;
    
/* operation data */
    
    /* inventory data: array of tags */
    zt_InventoryData *m_InventoryData;
    /* proximity persent */
    int m_ProximityPercent;
    srfidTagData *tagDataObjectForMultiTag;
    
/* tag exporting */
    BOOL m_TagExportCompleted;
    BOOL m_TagExportDumped;
    /* serial dispatch queue to synchronize export-to-file action */
    dispatch_queue_t m_TagExportQueue;
    /* serial queue for non-blocking processing of sdk notifications */
    dispatch_queue_t m_RadioEngineQueue;
    
    int m_batchModeEvent;
    BOOL m_readerTerminated;
}

- (void)addOperationListener:(id<zt_IRadioOperationEngineListener>)delegate;
- (void)removeOperationListener:(id<zt_IRadioOperationEngineListener>)delegate;

- (void) eventRadioOperation:(BOOL)started;
- (void) eventTagData:(srfidTagData*)data;
- (void) eventProximityData:(int)percent;
- (void) eventSessionTerminated;

- (SRFID_RESULT)startInventory:(BOOL)isReportOptions aMemoryBank:(SRFID_MEMORYBANK)mem_bank message:(NSString **)statusMessage;

- (SRFID_RESULT)performBrandCheckInventory:(BOOL)isReportOptions aMemoryBank:(SRFID_MEMORYBANK)mem_bank message:(NSString **)statusMessage  brandId:(NSString*)brandId epcLenth:(int)epcLenth;

- (SRFID_RESULT)stopInventory:(NSString **)statusMessage;

- (SRFID_RESULT)startTagLocationing:(NSString*)tagEpcID message:(NSString **)statusMessage;
- (SRFID_RESULT)stopTagLocationing:(NSString **)statusMessage;
- (void)clearLocationingStatistics;

- (void)logInventoryToFile:(NSString*)readerName;

/* operation status */
- (int)getStateOperationType;
- (BOOL)getStateInventoryRequested;
- (BOOL)getStateLocationingRequested;
- (BOOL)getStateOperationInProgress;
- (BOOL)getStateGetTagsOperationInProgress;
- (zt_InventoryData*)inventoryData;
- (NSTimeInterval)getRadioOperationTime;
- (NSDate*)getLastStartOperationTime;
- (int)getProximityPercent;
- (void) setCurrentBatchModeStatus:(int)event;
- (void)setRadioOperationTime:(NSTimeInterval)time;

/* operation parameters */
- (srfidReportConfig*)getInventoryReportConfig;
- (SRFID_MEMORYBANK)getInventoryMemoryBank;
- (void)setInventoryMemoryBank:(SRFID_MEMORYBANK)val;
- (NSString*)getLocationingTagId;

/* notifications */
- (void)notifyOperationRequested;
- (void)notifyOperationInProgress;

- (SRFID_RESULT)getTags:(NSString **)statusMessage;
- (SRFID_RESULT)purgeTags:(NSString **)statusMessage;

- (dispatch_queue_t)getQueue;


- (SRFID_RESULT)startMultiTagLocationing:(srfidReportConfig*)reportConfig message:(NSString **)statusMessage;
- (void) eventMultiTagProximityData:(srfidTagData *)tagData;
- (SRFID_RESULT)stopMultiTagLocationing:(NSString **)statusMessage;

@end
