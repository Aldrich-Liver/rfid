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
 *  Description:  AsciiProtocolHandler.m
 *
 *  Notes:
 *
 ******************************************************************************/


#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>

@interface zt_EnumMapper : NSObject

#pragma mark - Inventory
- (id)initWithMEMORYBANKMapperForInventory;
#pragma mark - Access
- (id)initWithMEMORYBANKMapperAccess;
- (id)initWithMEMORYBANKMapperAccessLock;
- (id)initWithACCESSPERMISSIONMapper;
#pragma mark - Link Profiles
- (id)initWithDIVIDERATIOMapper;
- (id)initWithMODULATIONMapper;
- (id)initWithFORWARDLINKMODULATIONMapper;
- (id)initWithSPECTRALMASKINDICATORMapper;
#pragma mark - Singulation
- (id)initWithSLFLAGMapper;
- (id)initWithSESSIONMapper;
- (id)initWithINVENTORYSTATEMapper;
- (id)initWithTAGPPOPULATIONMapper;
#pragma mark - Triggers
- (id)initWithTRIGGERTYPEMapper;
#pragma mark - Pre Filters
- (id)initWithMEMORYBANKMapperForPrefilters;
- (id)initWithSELECTTARGETMapperForPrefilters;
- (id)initWithSELECTACTIONMapper;
- (id)initWithBEEPERCONFIGMapper;

#pragma mark - common methods
- (NSMutableArray *)getStringArray;
- (NSMutableDictionary *)getDictionary;
- (int)getIndxByEnum:(int)enumVal;
- (int)getEnumByIndx:(int)indx;
- (NSString *)getStringByEnum:(int)enumVal;
- (int)getEnumByString:(NSString *)val;
- (void)printDebug;
- (int)getEnumForReservedMemoryBank;

#pragma mark - Endpoint Config
- (id)initWithENDPOINTCONFIGType;
- (id)initWithENDPOINTCONFIGProtocol;
- (id)initWithENDPOINTCONFIGHostVerify;

@end
