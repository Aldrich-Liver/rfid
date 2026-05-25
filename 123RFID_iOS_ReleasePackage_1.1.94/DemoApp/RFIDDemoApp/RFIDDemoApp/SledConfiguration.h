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
 *  Description:  SledConfiguration.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidAntennaConfiguration.h>
#import <ZebraRfidSdkFramework/RfidSingulationConfig.h>
#import <ZebraRfidSdkFramework/RfidReportConfig.h>
#import <ZebraRfidSdkFramework/RfidTagReportConfig.h>
#import <ZebraRfidSdkFramework/RfidLinkProfile.h>
#import <ZebraRfidSdkFramework/RfidStartTriggerConfig.h>
#import <ZebraRfidSdkFramework/RfidStopTriggerConfig.h>
#import <ZebraRfidSdkFramework/RfidRegulatoryConfig.h>
#import <ZebraRfidSdkFramework/RfidReaderCapabilitiesInfo.h>
#import <ZebraRfidSdkFramework/RfidReaderVersionInfo.h>
#import <ZebraRfidSdkFramework/RfidPreFilter.h>
#import <ZebraRfidSdkFramework/RfidDynamicPowerConfig.h>
#import <ZebraRfidSdkFramework/RfidUniqueTagsReport.h>
#import "RegionData.h"
#import "EnumMapper.h"

/* battery event causes */
#define ZT_BATTERY_EVENT_CAUSE_LOW                             @"Battery level low"
#define ZT_BATTERY_EVENT_CAUSE_CRITICAL                        @"Battery level critical"

/* antennat settings */
#define ZT_SLED_ANTENNA_LINK_PROFILE_PREFIX                    @"RF mode "
#define ZT_SLED_ANTENNA_POWER_LEVEL_FORMAT                     @"%1.1f"

/* singulation settings */
#define ZT_SLED_SINGULATION_TAG_POPULATION_MIN                 1
#define ZT_SLED_SINGULATION_TAG_POPULATION_MAX                 2000

/* tag report settings */
#define ZT_SLED_TAG_REPORT_PROPERTY_NUMBER                     2

/* singulation settings */
#define ZT_SLED_CFG_NAME_SINGULATION_TAG_POPULATION_MIN       0
#define ZT_SLED_CFG_NAME_SINGULATION_TAG_POPULATION_MAX       32768
#define ZT_SLED_CFG_NAME_SINGULATION_TAG_POPULATION_STEP      10

#define ZT_SLED_CFG_SINGULATION_SESSION_S0                     0
#define ZT_SLED_CFG_SINGULATION_SESSION_S1                     1
#define ZT_SLED_CFG_SINGULATION_SESSION_S2                     2
#define ZT_SLED_CFG_SINGULATION_SESSION_S3                     3
#define ZT_SLED_CFG_SINGULATION_SESSION_COUNT                  4

#define ZT_SLED_CFG_SINGULATION_INVENTORY_STATE_A              0
#define ZT_SLED_CFG_SINGULATION_INVENTORY_STATE_B              1
#define ZT_SLED_CFG_SINGULATION_INVENTORY_STATE_COUNT          2

#define ZT_SLED_CFG_SINGULATION_SLFLAG_ASSERTED                0
#define ZT_SLED_CFG_SINGULATION_SLFLAG_DEASSERTED              1
#define ZT_SLED_CFG_SINGULATION_SLFLAG_COUNT                   2

/* tag report settings */
#define ZT_SLED_CFG_TAG_REPORT_FIRST_SEEN_TIME                 0
#define ZT_SLED_CFG_TAG_REPORT_LAST_SEEN_TIME                  1
#define ZT_SLED_CFG_TAG_REPORT_PC                              2
#define ZT_SLED_CFG_TAG_REPORT_RSSI                            3
#define ZT_SLED_CFG_TAG_REPORT_PHASE                           4
#define ZT_SLED_CFG_TAG_REPORT_CHANNEL_INDEX                   5
#define ZT_SLED_CFG_TAG_REPORT_TAG_SEEN_COUNT                  6
#define ZT_SLED_CFG_TAG_REPORT_UNIQUE_TAG 7
#define ZT_SLED_CFG_TAG_REPORT_COUNT                           8

/* regulatory settings (preconfigured channels) */
#define ZT_SLED_CFG_REGULATORY_CHANNEL_4                       0
#define ZT_SLED_CFG_REGULATORY_CHANNEL_7                       1
#define ZT_SLED_CFG_REGULATORY_CHANNEL_10                      2
#define ZT_SLED_CFG_REGULATORY_CHANNEL_13                      3
#define ZT_SLED_CFG_REGULATORY_CHANNEL_COUNT                   4

/* trigger settings  */
#define ZT_TRIGGER_MIN                                      0
#define ZT_TRIGGER_MAX                                      4294967295
#define ZT_TRIGGER_EMPTY_FIELD                              -1

#define ZT_START_TRIGGER_PERIODIC_DEFAULT                   10000
#define ZT_START_TRIGGER_HANDHELD_DEFAULT                   SRFID_TRIGGERTYPE_PRESS
#define ZT_STOP_TRIGGER_DURATION_DEFAULT                    10000
#define ZT_STOP_TRIGGER_TAG_OBSERVATION_DEFAULT             100
#define ZT_STOP_TRIGGER_ATTEMPTS_DEFAULT                    10
#define ZT_STOP_TRIGGER_TIMEOUT_DEFAULT                     10000
#define ZT_STOP_TRIGGER_HADHELD_DEFAULT                     SRFID_TRIGGERTYPE_RELEASE

#define ZT_SLED_CFG_TRIGGER_START_IMMEDIATE                    0
#define ZT_SLED_CFG_TRIGGER_START_HANDHELD                     1
#define ZT_SLED_CFG_TRIGGER_START_PERIODIC                     2
#define ZT_SLED_CFG_TRIGGER_START_COUNT                        3

#define ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE                     0
#define ZT_SLED_CFG_TRIGGER_STOP_HANDHELD                      1
#define ZT_SLED_CFG_TRIGGER_STOP_DURATION                      2
#define ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION               3
#define ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS                    4
#define ZT_SLED_CFG_TRIGGER_STOP_COUNT                         5

/* prefilters */
#define ZT_PREFILTERS_OFFSET_MIN                                0
#define ZT_PREFILTERS_OFFSET_MAX                                1024
#define ZT_PREFILTERS_OFFSET_DEFAULT                            0

@interface zt_SledConfiguration : NSObject
{
    /* tag report settings */
    
    /* available tag report options (option name for each tag report field) */
    NSMutableArray *m_ConfigTagReportOptions;
    /* Batch Mode Settings */
    
    float m_ConfigBatchMode;
}

#pragma mark - antenna

@property (readonly) NSMutableArray *antennaPowerLevelsArray;
@property (readonly) NSMutableDictionary *antennaOptionsLinkProfile;
@property (readonly) NSMutableDictionary *antennaOptionsTari;
@property (readonly) NSMutableDictionary *antennaOptionsPie;
@property (readonly) NSMutableDictionary *antennaOptionsDoSelect;
@property (readonly) NSMutableArray *antennaAllLinkProfiles;
@property (readonly) NSMutableArray *sampleLinkProfiles;
@property (readonly) NSMutableArray *linkProfilesArray;
@property (readonly) NSMutableArray *backUpLinkProfile;

@property float currentAntennaPowerLevel;
@property int currentAntennaLinkProfile;
@property int currentAntennaTari;
@property int currentAntennaPie;
@property BOOL currentAntennaDoSelect;
@property BOOL minTari_12500;
@property BOOL stepTari_non_0;
@property BOOL stepTari_6300;
@property BOOL pie_1500;


- (BOOL)setAntennaOptionsWithConfig:(srfidAntennaConfiguration *)config;
- (srfidAntennaConfiguration *)getAntennaConfig;
- (void)setLinkProfileOptions:(NSArray *)linkProfiles;
- (BOOL)isAntennaConfigEqual:(zt_SledConfiguration *)sled;
- (NSArray *)getLinkProfileArray;
- (BOOL)isMinTari_12500;
- (BOOL)isStepTari_non_0;
- (BOOL)isStepTari_6300;
- (BOOL)ispie_1500;

#pragma mark - dynamic power optimization settings
@property (atomic, strong) NSNumber * currentDpoEnable;
- (void)setDpoOptionsWithConfig:(srfidDynamicPowerConfig *)config;
- (srfidDynamicPowerConfig *)getDpoConfig;
- (BOOL)isDpoConfigEqual:(zt_SledConfiguration *)sled;

#pragma mark - singulation

@property (readonly) zt_EnumMapper *mapperSLFlag;
@property (readonly) zt_EnumMapper *mapperSession;
@property (readonly) zt_EnumMapper *mapperInventoryState;
@property (readonly) zt_EnumMapper *mapperTagPopulation;

@property SRFID_SLFLAG currentSLFLag;
@property SRFID_SESSION currentSession;
@property SRFID_INVENTORYSTATE currentInventoryState;
@property int currentTagPopulation;

- (BOOL)setSingulationOptionsWithConfig:(srfidSingulationConfig *)config;
- (srfidSingulationConfig *)getSingulationConfig;
- (BOOL)isSingulationConfigEqual:(zt_SledConfiguration *)sled;
- (BOOL)isSingulationConfigValid;

#pragma mark - tag report

@property BOOL tagReportFirstSeenTime;
@property BOOL tagReportLastSeenTime;
@property BOOL tagReportPC;
@property BOOL tagReportRSSI;
@property BOOL tagReportPhase;
@property BOOL tagReportChannelIdx;
@property BOOL tagCheckBrandIdx;
@property BOOL tagReportSeenCount;

- (void)setTagReportOptionsWithConfig:(srfidTagReportConfig *)config;
- (srfidTagReportConfig *)getTagReportConfig;
- (srfidReportConfig *)getReportConfig;
- (srfidReportConfig *)getReportConfigAllOff;
- (BOOL)isTagReporConfigEqual:(zt_SledConfiguration *)sled;

#pragma mark - beeper
@property (nonatomic, readonly) zt_EnumMapper *mapperBeeper;
@property (nonatomic) BOOL currentBeeperEnable;
@property (nonatomic) BOOL hostBeeperEnable;
@property (nonatomic) SRFID_BEEPERCONFIG currentBeeperLevel;
@property (nonatomic) SRFID_BEEPERCONFIG hostBeeperLevel;

- (void)setBeeperOptionsWithConfig:(SRFID_BEEPERCONFIG)config;
- (SRFID_BEEPERCONFIG)getBeeperConfig;
- (BOOL)isBeeperConfigEqual:(zt_SledConfiguration *)sled;
- (BOOL)isHostBeeperConfigEqual:(zt_SledConfiguration *)sled;

#pragma mark - triggers
@property (nonatomic, readonly) zt_EnumMapper *mapperTriggerType;
@property (nonatomic, readonly) NSMutableArray *triggerStartOptions;
@property (nonatomic, readonly) NSMutableArray *triggerStopOptions;

@property (nonatomic) int currentStartTriggerOption;
@property (nonatomic) SRFID_TRIGGERTYPE currentStartTriggerType;
@property (nonatomic) long long currentStartDelay;

@property (nonatomic) int currentStopTriggerOption;
@property (nonatomic) SRFID_TRIGGERTYPE currentStopTriggerType;
@property (nonatomic) long long currentStopTagCount;
@property (nonatomic) long long currentStopInventoryCount;
@property (nonatomic) long long currentStopAccessCount;
@property (nonatomic) long long currentStopTimeout;
@property (nonatomic) BOOL currentStopOnAccessCount;

- (void)setStartTriggerOptionWithConfig:(srfidStartTriggerConfig *)config;
- (void)setStopTriggerOptionWithConfig:(srfidStopTriggerConfig *)config;
- (srfidStartTriggerConfig *)getStartTriggerConfig;
- (srfidStopTriggerConfig *)getStopTriggerConfig;
- (BOOL)isStartTriggerConfigEqual:(zt_SledConfiguration *)sled;
- (BOOL)isStopTriggerConfigEqual:(zt_SledConfiguration *)sled;
- (BOOL)isStartTriggerConfigValid;
- (BOOL)isStopTriggerConfigValid;
- (BOOL)isStartTriggerRepeatMonitoring;
- (BOOL)isStartTriggerPeriodic;
- (BOOL)isStartTriggerImmediate;
- (BOOL)isStartTriggerHandheld;
- (BOOL)isStopTriggerHandheld;
- (BOOL)isStopTriggerImmediate;

#pragma mark - regualatory
@property (nonatomic, retain, setter=setRegionOptions:) NSMutableArray *regionOptions;
@property (nonatomic, retain, setter=setSupportedRegions:) NSMutableArray *supportedRegions;
@property (nonatomic, copy) NSString *currentRegionCode;
@property (nonatomic, copy) NSMutableArray *currentRegionChannelList;
@property (nonatomic) BOOL currentRegionHoppingEnabled;

- (void)setRegulatoryOptionsWithConfig:(srfidRegulatoryConfig *)config;
- (srfidRegulatoryConfig *)getRegulatoryConfig;
- (BOOL)isRegulatoryConfigEqual:(zt_SledConfiguration *)sled;
- (int)indexOfCurrentRegion;
- (int)indexOfRegionWithName:(NSString *)name;
- (BOOL)isChannelEnabled:(NSString*)channel  forRegion:(NSString*)region_code;
- (void)fillCurrentRegionChannelsListDefault;
- (void)enableCurrentRegionChannel:(NSString*)channel;
- (void)disableCurrentRegionChannel:(NSString*)channel;

#pragma mark - capabilities
@property(nonatomic, retain) NSString *readerSerialNumber;
@property(nonatomic, retain) NSString *readerModel;
@property(nonatomic, retain) NSString *readerManufacturer;
@property(nonatomic, retain) NSString *readerManufacturingDate;
@property(nonatomic, retain) NSString *readerScannerName;
@property(nonatomic, retain) NSString *readerAsciiVersion;
@property(nonatomic) int readerSelectFilterNum;
@property(nonatomic) int readerMinPower;
@property(nonatomic) int readerMaxPower;
@property(nonatomic) int readerPowerStep;
@property(nonatomic, retain) NSString *readerAirProtocolVersion;
@property(nonatomic, retain) NSString *readerBTAddress;
@property(nonatomic) int readerMaxAccessSequence;

- (void)setCapabilityOptionWithInfo:(srfidReaderCapabilitiesInfo *)info;

/* Reader Version Info */
@property(nonatomic, retain) NSString *readerDeviceVersion;
@property(nonatomic, retain) NSString *readerBluetoothVersion;
@property(nonatomic, retain) NSString *readerNGEVersion;
@property(nonatomic, retain) NSString *readerPL33;

- (void)setReaderVersionWithInfo:(srfidReaderVersionInfo *)info;

#pragma mark - prefilters
@property(nonatomic, readonly) zt_EnumMapper *mapperTargetOption;
@property(nonatomic, readonly) zt_EnumMapper *mapperAction;
@property(nonatomic, readonly) zt_EnumMapper *mapperBankPrefilters;

@property(nonatomic, retain) NSMutableArray *currentPrefilters;
@property(nonatomic) int currentPrefilterIndex;
@property(nonatomic) BOOL applyFirstFilter;
@property(nonatomic) BOOL applySecondFilter;

-(void)setPrefiltersFromConfig:(NSMutableArray *)prefilters;
+ (NSMutableArray*)getPrefiltersArrayCopy:(NSMutableArray *)array;

-(BOOL)prefilterEnabled;
-(NSString *)prefilterTagPattern;
-(NSString *)prefilterTagert;
-(NSString *)prefilterAction;
-(NSString *)prefilterMemoryBank;
-(NSNumber *)prefilterOffset;
-(NSNumber *)prefilterLength;

-(NSString *)returnEPCMemoryBankForNonMatch;
-(NSString *)returnPreFilterTargetforNonMatch;
-(NSString *)returnPreFilterActionforNonMatch;

- (void)setPrefilterEnabled:(BOOL)value;
- (void)setPrefilterTagPattern:(NSString *)value;
- (void)setPrefilterTarget:(NSString *)value;
- (void)setPrefilterAction:(NSString *)value;
- (void)setPrefilterMemoryBank:(NSString *)value;
- (void)setPrefilterOffset:(NSNumber *)value;
- (void)setPrefilterLength:(NSNumber *)value;

- (void)copyFirstFilerConfig:(srfidPreFilter*)prefilter;
- (void)copySecondFilterConfig:(srfidPreFilter*)prefilter;

- (BOOL)isPrefilterValid:(srfidPreFilter *)prefilter;
+ (BOOL)isPrefilterEqual:(srfidPreFilter*)prefilterOne withPrefilter:(srfidPreFilter*)prefilterTwo;

#pragma marka - others
- (void)setupInitialConfiguration;
+ (NSNumber *)getKeyFromDictionary:(NSDictionary *)dictionary withValue:(NSString *)value;


- (NSArray*)getConfigTagReportOptions;

#pragma mark - Batch Mode

@property (nonatomic) int currentBatchMode;
@property (nonatomic) int currentUSBBatchMode;


@property (nonatomic, readonly) NSMutableArray *batchModeOptions;
-(void) setBatchModeOptionsWithConfig : (SRFID_BATCHMODECONFIG)config;
-(SRFID_BATCHMODECONFIG) getBatchModeConfig;
- (BOOL) isBatchModeConfigEqual: (zt_SledConfiguration *)sled;

@property (nonatomic, readonly) NSMutableArray *usbBatchModeOptions;
-(void) setUSBBatchModeOptionsWithConfig : (SRFID_BATCHMODECONFIG)config;
-(SRFID_BATCHMODECONFIG) getUSBBatchModeConfig;
- (BOOL) isUSBBatchModeConfigEqual: (zt_SledConfiguration *)sled;

#pragma mark --- UniqueTags Report
@property (atomic, strong) NSNumber * isUniqueTagsReport;
-(void) setUniqueTagsReport : (srfidUniqueTagsReport *)config;
-(srfidUniqueTagsReport *) getUniqueTagsReport;
- (BOOL) isUniqueTagsReportEqual: (zt_SledConfiguration *)sled;

#pragma mark --- Trigger Configuration
@property (nonatomic) SRFID_NEW_ENUM_KEYLAYOUT_TYPE currentSelectedUpperTrigger;
@property (nonatomic) SRFID_NEW_ENUM_KEYLAYOUT_TYPE currentSelectedLowerTrigger;
-(void) setSelectedTriggerConfigurationUpperTrigger : (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)upper lowerTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)lower;
- (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)getSelectedUpperTriggerConfiguration;
- (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)getSelectedLowerTriggerConfiguration;
- (NSString*)getReaderMaxPowerLevel;

#pragma mark  --- FactoryReset
@property (nonatomic) BOOL factoryResetFlag;
- (void)SetTheDeviceIsFactoryReseted:(BOOL)option;
- (BOOL)GetTheDeviceIsFactoryReseted;
@end
