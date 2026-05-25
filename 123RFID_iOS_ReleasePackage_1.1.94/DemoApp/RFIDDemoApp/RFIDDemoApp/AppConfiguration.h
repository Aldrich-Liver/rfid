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
 *  Description:  AppConfiguration.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "InventoryItem.h"
#import "TaglistDataObject.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

#define ZT_APP_CFG_CONNECTION_AUTO_DETECTION           @"MotRfidAppConnectionAutoDetection"
#define ZT_APP_CFG_CONNECTION_AUTO_RECONNECTION        @"MotRfidAppConnectionAutoReconnection"
#define ZT_APP_CFG_NOTIFICATION_AVAILABLE              @"MotRfidAppNotificationAvailable"
#define ZT_APP_CFG_NOTIFICATION_CONNECTION             @"MotRfidAppNotificationConnection"
#define ZT_APP_CFG_NOTIFICATION_BATTERY                @"MotRfidAppNotificationBattery"
#define ZT_APP_CFG_HOST_BEEPER_ENABLED                 @"MotRfidAppHostBeeperEnabled"
#define ZT_APP_CFG_APP_INSTALLED                       @"MotRfidAppInstalled"
#define ZT_APP_CFG_APP_DATA_EXPORT                     @"ZTRfidAppDataExport"
#define ZT_APP_CFG_APP_MATCH_MODE                      @"ZTRfidAppMatchMode"
#define ZT_APP_CFG_APP_FRIENDLY_NAMES                  @"ZTRfidAppFriendlyNames"
#define ZT_APP_CFG_APP_ASCII_MODE                      @"ZTRfidAppASCIIMode"
#define ZT_APP_CFG_READER_ASCII_PASSWORD               @"ZTRfidAppReaderAsciiPassword"
#define ZT_APP_CFG_APP_SGTIN96                         @"ZTRfidAppSgtin96"

@interface zt_AppConfiguration : NSObject
{
    BOOL m_ConfigConnectionAutoDetection;
    BOOL m_ConfigConnectionAutoReconnection;
    BOOL m_ConfigNotificationAvailable;
    BOOL m_ConfigNotificationConnection;
    BOOL m_ConfigNotificationBattery;
    BOOL m_ConfigHostBeeperEnabled;
    BOOL m_ConfigDataExport;
    // Changes made on 22-Dec-2020
    BOOL m_ConfigMatchMode;
    BOOL m_ConfigFriendlyNames;
    BOOL m_ConfigASCIIMode;
    
    // Changes made on 21-Mar-2023
    BOOL m_ConfigSgtin96;

    /* temporary UI settings */
    
    /* search criteria from inventory screen */
    NSMutableString *m_SearchCriteria;
    
    /* selected item on inventory screen */
    zt_InventoryItem *m_SelectedInventoryItem;
    int m_SelectedInventoryIdx;
    
    NSMutableString *m_TagIdLocationing;
    NSMutableArray *currentlySelectedTagIdArray;
    NSMutableString *m_TagIdAccess;
    NSArray* tagListArray;
    NSArray* multiTagArray;
    /* selected memory bank on inventory operations screen (UI only) */
    SRFID_MEMORYBANK m_SelectedInventoryMemoryBankUI;
    NSMutableArray *currentlySelectedTagIdObjectArray;
    
    // Selected taglist filter
    int selectedTagListFilter;
    
    // Multitag Locate
    BOOL isMultitagLocated;
    BOOL isMultitagLocationing;
    
    NSMutableArray *tagListPredicateArray;
    NSMutableArray *multiTagPredicateArray;
    
    BOOL isScanSupport;
    
    NSMutableArray *batteryStatusArray;
    NSMutableArray *wifiListArray;
    AVAudioPlayer *player;
}
- (void)loadAppConfiguration;
- (BOOL)getConfigConnectionAutoDetection;
- (BOOL)getConfigConnectionAutoReconnection;
- (void)setConfigConnectionAutoReconnection:(BOOL)option;
- (BOOL)getConfigNotificationAvailable;
- (void)setConfigNotificationAvailable:(BOOL)option;
- (BOOL)getConfigNotificationConnection;
- (void)setConfigNotificationConnection:(BOOL)option;
- (BOOL)getConfigNotificationBattery;
- (void)setConfigNotificationBattery:(BOOL)option;
- (BOOL)getConfigHostBeeperEnabled;
- (void)setConfigHostBeeperEnabled:(BOOL)option;
- (BOOL)getConfigDataExport;
- (void)setConfigDataExport:(BOOL)option;
// Changes made on 22-Dec-2020
- (BOOL)getConfigMatchMode;
- (void)setConfigMatchMode:(BOOL)option;
- (BOOL)getConfigFriendlyNames;
- (void)setConfigFriendlyNames:(BOOL)option;
- (BOOL)getConfigASCIIMode;
- (void)setConfigASCIIMode:(BOOL)option;
- (NSString*)getConfigAsciiPassword:(int)reader_id;
- (void)setConfigAsciiPassword:(NSString*)password forReader:(int)reader_id;

- (void)setTagSearchCriteria:(NSString*)criteria;
- (NSString*)getTagSearchCriteria;

- (zt_InventoryItem *)getSelectedInventoryItem;
- (int)getSelectedInventoryItemIndex;
- (void)setSelectedInventoryItem:(zt_InventoryItem *)item withIdx:(int)index;
- (void)clearSelectedItem;
- (SRFID_MEMORYBANK)getSelectedInventoryMemoryBankUI;
- (void)setSelectedInventoryMemoryBankUI:(SRFID_MEMORYBANK)val;
- (NSString*)getTagIdLocationing;
- (void)setTagIdLocationing:(NSString*)val;
- (void)clearTagIdLocationingGracefully;
- (NSString*)getTagIdAccess;
- (void)setTagIdAccess:(NSString*)val;
- (void)clearTagIdAccessGracefully;


// To handle multiple selection for multi tag feature
- (NSMutableArray*)getMultiTagIdArray;
- (void)removeItemInMultiTagIdLocationingArray:(NSString*)tagId;
- (void)addTagIdIntoMultiTagArray:(NSString*)tagId;
- (void)removeAllMultiTagIds;
-(void)setCurrentlySelectedTagIdArray:(NSMutableArray*)array;

// TaglistMatchMode
- (void)createTagListArrayFromCsvFile:(NSString*)tagList;
- (NSArray*)getCsvTagListArray;

// MultiTagLocate
- (void)createMultiTagArrayFromCsvFile:(NSString*)multiTag;
- (NSArray*)getCsvMultiTagArray;

-(void)addInvetoryTagObjectIntoMultiTagArray:(zt_InventoryItem*)tagItemObject;
-(zt_InventoryItem*)getInvetoryTagObjectByTagId:(NSString*)tagId;

// HostBeeper Settings
- (void)playHostBeeper;
- (void)stopHostBeeper;

// Taglist Matchmode Filter
- (void)setTagListFilter:(int)filter;
- (int)getTagListFilter;

// Multitag Locate
- (void)saveIsMultitagLocated:(BOOL)locate;
- (BOOL)isMultiTagLocated;

- (void)setIsMultitagLocationing:(BOOL)locationing;
- (BOOL)getIsMultiTagLocationing;

// Supports scan or not
- (void)setIsScanFeatureSupporting:(BOOL)supporting;
- (BOOL)getIsScanFeatureSupporting;

//Battery status
-(void)setBatteryStatusArray:(NSMutableArray*)array;
- (NSMutableArray*)getBatteryStatusArray;

// Sgtin96 encoding
-(BOOL)getConfigSgtin96;
-(void)setConfigSgtin96:(BOOL) option;

//Scan WIFI
-(void)setWIFIListArray:(NSMutableArray*)array;
- (NSMutableArray*)getWIFIListArray;

// Userdefined profile
- (NSDictionary *)getUserDefinedProfileFromLocalMemory;
- (void)saveUserDefinedProfileintoLocalMemory:(NSString *)powerLevelKey linkProfileIndex:(NSString *) linkProfileIndexValue sessionIndex:(NSNumber *)sessionIndex dynamicProfile:(NSNumber *) dynamicProfileKey;

- (NSString *)getLinkProfileFromLocalMemory;
- (void)saveLinkProfileintoLocalMemory:(NSString *)linkProfile;
- (int)getMatchingIndexLegacyIndex:(NSString*)profileName linkProfileArray:(NSMutableArray*) linkProfilesArray;

- (int)updateProfilesIndex:(int)index;
- (int)getMatchingIndexFromProfileName:(NSString*)profileName linkProfileArray:(NSArray*) linkProfilesArray;

- (void)saveActiveProfileintoLocalMemory:(NSString *)powerLevelKey linkProfileIndex:(NSString *) linkProfileIndexValue sessionIndex:(NSNumber *)sessionIndex dynamicProfile:(NSNumber *) dynamicProfileKey;
- (NSDictionary *)getActiveProfileFromLocalMemory;
- (NSDictionary *)getFastestReadProfileFromLocalMemory;
-(NSMutableArray*)getSelectedInvetoryTagObjectInInventoryTagArray;
@end
