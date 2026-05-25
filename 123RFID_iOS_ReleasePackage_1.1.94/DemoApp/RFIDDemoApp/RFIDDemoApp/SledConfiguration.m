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
 *  Description:  SledConfiguration.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SledConfiguration.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "LinkProfileObject.h"

/* Antenna */
#define ZT_SLED_ANTENNA_POWER_MEASUREMENT_MULT                10
#define ZT_SLED_ANTENNA_POWER_MIN                             120
#define ZT_SLED_ANTENNA_POWER_MAX                             300
#define ZT_SLED_ANTENNA_POWER_STEP                            30

#define ZT_SLED_CFG_NAME_ANTENNA_TARI_MIN                     0
#define ZT_SLED_CFG_NAME_ANTENNA_TARI_MAX                     7
#define ZT_SLED_CFG_NAME_ANTENNA_TARI_STEP                    1

/* tag report */
#define ZT_SLED_CFG_NAME_TAG_REPORT_FIRST_SEEN_TIME            @"First Seen Time"
#define ZT_SLED_CFG_NAME_TAG_REPORT_LAST_SEEN_TIME             @"Last Seen Time"
#define ZT_SLED_CFG_NAME_TAG_REPORT_PC                         @"PC"
#define ZT_SLED_CFG_NAME_TAG_REPORT_RSSI                       @"RSSI"
#define ZT_SLED_CFG_NAME_TAG_REPORT_PHASE                      @"Phase"
#define ZT_SLED_CFG_NAME_TAG_REPORT_CHANNEL_IDX                @"Channel Index"
#define ZT_SLED_CFG_NAME_TAG_REPORT_TAG_SEEN_COUNT             @"Tag Seen Count"
#define ZT_SLED_CFG_NAME_TAG_REPORT_UNIQUE_TAG             @"Report Unique tags"


/* regulatory */
#define ZT_SLED_CFG_NAME_REGULATORY_CHANNEL_4                  @"Channel 4 (865.70 MHz)"
#define ZT_SLED_CFG_NAME_REGULATORY_CHANNEL_7                  @"Channel 7 (866.30 MHz)"
#define ZT_SLED_CFG_NAME_REGULATORY_CHANNEL_10                 @"Channel 10 (866.90 MHz)"
#define ZT_SLED_CFG_NAME_REGULATORY_CHANNEL_13                 @"Channel 13 (867.50 MHz)"


/* trigger */
#define ZT_SLED_CFG_NAME_TRIGGER_START_IMMEDIATE               @"Immediate"
#define ZT_SLED_CFG_NAME_TRIGGER_START_PERIODIC                @"Periodic"
#define ZT_SLED_CFG_NAME_TRIGGER_START_HANDHELD                @"Handheld"

#define ZT_SLED_CFG_NAME_TRIGGER_STOP_IMMEDIATE                @"Immediate"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_DURATION                 @"Duration"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_TAG_OBSERVATION          @"Tag Observation"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_N_ATTEMPTS               @"N Attempts"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_HANDHELD                 @"Handheld"

@implementation zt_SledConfiguration

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _antennaPowerLevelsArray = [[NSMutableArray alloc] init];
        _antennaOptionsLinkProfile = [[NSMutableDictionary alloc] init];
        _antennaOptionsTari= [[NSMutableDictionary alloc] init];
        _antennaOptionsPie= [[NSMutableDictionary alloc] init];
        _antennaOptionsDoSelect= [[NSMutableDictionary alloc] init];
        _antennaAllLinkProfiles = [[NSMutableArray alloc] init];
        _sampleLinkProfiles = [[NSMutableArray alloc] init];
        _linkProfilesArray = [[NSMutableArray alloc] init];
        _backUpLinkProfile = [[NSMutableArray alloc] init];
        
        _mapperSLFlag =[[zt_EnumMapper alloc] initWithSLFLAGMapper];
        _mapperSession = [[zt_EnumMapper alloc] initWithSESSIONMapper];

        _mapperInventoryState = [[zt_EnumMapper alloc] initWithINVENTORYSTATEMapper];
        _mapperTagPopulation = [[zt_EnumMapper alloc] initWithTAGPPOPULATIONMapper];
        
        _mapperBeeper = [[zt_EnumMapper alloc] initWithBEEPERCONFIGMapper];
        _mapperTargetOption = [[zt_EnumMapper alloc] initWithSELECTTARGETMapperForPrefilters];
        
        _triggerStartOptions = [[NSMutableArray alloc] init];
        _triggerStopOptions = [[NSMutableArray alloc] init];
        _mapperTriggerType = [[zt_EnumMapper alloc] initWithTRIGGERTYPEMapper];
        
        _regionOptions = [[NSMutableArray alloc] init];
        _currentRegionChannelList = [[NSMutableArray alloc] init];
        
        _currentPrefilters = [[NSMutableArray alloc] init];
        _mapperAction = [[zt_EnumMapper alloc] initWithSELECTACTIONMapper];
        _mapperBankPrefilters = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForPrefilters];
        
        m_ConfigTagReportOptions = [[NSMutableArray alloc] init];
        _batchModeOptions = [[NSMutableArray alloc] init];
        _usbBatchModeOptions = [[NSMutableArray alloc] init];
        
        _currentDpoEnable = 0;
        
    }
    return self;
}

- (void)dealloc
{
    // Antenna dealloc
    if (nil != _antennaPowerLevelsArray)
    {
        [_antennaPowerLevelsArray release];
    }
    if (nil != _antennaOptionsLinkProfile)
    {
        [_antennaOptionsLinkProfile removeAllObjects];
        [_antennaOptionsLinkProfile release];
    }
    
    if (nil != _sampleLinkProfiles)
    {
        [_sampleLinkProfiles removeAllObjects];
        [_sampleLinkProfiles release];
    }
    
    if (nil != _antennaOptionsTari)
    {
        [_antennaOptionsTari removeAllObjects];
        [_antennaOptionsTari release];
    }
    if (nil != _antennaOptionsPie)
    {
        [_antennaOptionsPie removeAllObjects];
        [_antennaOptionsPie release];
    }
    if (nil != _antennaOptionsDoSelect)
    {
        [_antennaOptionsDoSelect removeAllObjects];
        [_antennaOptionsDoSelect release];
    }
    
    if (nil != _antennaAllLinkProfiles)
    {
        [_antennaAllLinkProfiles removeAllObjects];
        [_antennaAllLinkProfiles release];
    }
    
    if (nil != _backUpLinkProfile)
    {
        [_backUpLinkProfile removeAllObjects];
        [_backUpLinkProfile release];
    }

    // Singulation dealloc
    if (nil != _mapperSLFlag)
    {
        [_mapperSLFlag release];
    }
    
    if (nil != _mapperSession)
    {
        [_mapperSession release];
    }
    
    if (nil != _mapperInventoryState)
    {
        [_mapperInventoryState release];
    }
    
    if (nil != _mapperTagPopulation)
    {
        [_mapperTagPopulation release];
    }
    
    // beeper
    if (nil != _mapperBeeper) {
        [_mapperBeeper release];
    }
    
    // trigger options
    if (nil != _mapperTriggerType)
    {
        [_mapperTriggerType release];
    }
    
    if (nil != _triggerStopOptions) {
        [_triggerStopOptions release];
    }
    
    if (nil != _triggerStartOptions)
    {
        [_triggerStartOptions release];
    }
    
    if(nil != _regionOptions)
    {
        [_regionOptions release];
    }
    if(nil != _currentRegionCode)
    {
        [_currentRegionCode release];
    }
    if(nil != _currentRegionChannelList)
    {
        [_currentRegionChannelList release];
    }
    
    if (nil !=_currentPrefilters)
    {
        [_currentPrefilters release];
    }
    if (nil !=_mapperTargetOption)
    {
        [_mapperTargetOption release];
    }
    if (nil !=_mapperAction)
    {
        [_mapperAction release];
    }
    if (nil !=_mapperBankPrefilters)
    {
        [_mapperBankPrefilters release];
    }
    
    // toDo delete later
    
    if (nil != m_ConfigTagReportOptions)
    {
        [m_ConfigTagReportOptions removeAllObjects];
        [m_ConfigTagReportOptions release];
    }
    
    //batch mode
    if(nil != _batchModeOptions)
    {
        [_batchModeOptions release];
    }
    if(nil != _usbBatchModeOptions)
    {
        [_usbBatchModeOptions release];
    }


    [super dealloc];
}

- (void)setupInitialConfiguration
{
    /* antenna settings */
    for (int value = ZT_SLED_CFG_NAME_ANTENNA_TARI_MIN; value <= ZT_SLED_CFG_NAME_ANTENNA_TARI_MAX ; value += ZT_SLED_CFG_NAME_ANTENNA_TARI_STEP) {
        [_antennaOptionsTari setObject:[NSString stringWithFormat:@"%d tari level", value] forKey:[NSNumber numberWithInt:value]];
    }
    
    [_antennaOptionsDoSelect setObject:@"Select" forKey:[NSNumber numberWithBool:YES]];
    [_antennaOptionsDoSelect setObject:@"Not Select" forKey:[NSNumber numberWithBool:NO]];

    /* tag report settings */
    
    _tagReportFirstSeenTime = NO;
    _tagReportLastSeenTime = NO;
    _tagReportPC = NO;
    _tagReportRSSI = NO;
    _tagReportPhase = NO;
    _tagReportChannelIdx = NO;
    _tagReportSeenCount = NO;
    _isUniqueTagsReport = [NSNumber numberWithBool:NO];
    _factoryResetFlag = NO;
    
    /* power management settings */
    
    self.currentDpoEnable =  [NSNumber numberWithBool:FALSE]; /* enable DPO by default */
    /* beeper settings */
    
    _currentBeeperLevel = SRFID_BEEPERCONFIG_MEDIUM;
    
    /* prefilters settings */
    [self addEmptyPrefilterToArray:_currentPrefilters];
    [self addEmptyPrefilterToArray:_currentPrefilters];
    [self setPrefiltersFromConfig:_currentPrefilters];
    
    // Calling this method to disable automatically enabled prefilters (enabled by setPrefiltersFromConfig method
    [self temporarilyDisablePrefilters];
    
    // delete above lines
    
    /* tag report settings */
    
    for (int i = 0; i < ZT_SLED_CFG_TAG_REPORT_COUNT; i++)
    {
        [m_ConfigTagReportOptions addObject:@""];
    }
    
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_CHANNEL_INDEX withObject:ZT_SLED_CFG_NAME_TAG_REPORT_CHANNEL_IDX];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_FIRST_SEEN_TIME withObject:ZT_SLED_CFG_NAME_TAG_REPORT_FIRST_SEEN_TIME];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_LAST_SEEN_TIME withObject:ZT_SLED_CFG_NAME_TAG_REPORT_LAST_SEEN_TIME];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_PC withObject:ZT_SLED_CFG_NAME_TAG_REPORT_PC];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_PHASE withObject:ZT_SLED_CFG_NAME_TAG_REPORT_PHASE];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_RSSI withObject:ZT_SLED_CFG_NAME_TAG_REPORT_RSSI];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_TAG_SEEN_COUNT withObject:ZT_SLED_CFG_NAME_TAG_REPORT_TAG_SEEN_COUNT];
    [m_ConfigTagReportOptions replaceObjectAtIndex:ZT_SLED_CFG_TAG_REPORT_UNIQUE_TAG withObject:ZT_SLED_CFG_NAME_TAG_REPORT_UNIQUE_TAG];
    
    /* trigger settings */
    for (int i = 0; i < ZT_SLED_CFG_TRIGGER_START_COUNT; i++)
    {
        [_triggerStartOptions addObject:@""];
    }
    
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_HANDHELD withObject:ZT_SLED_CFG_NAME_TRIGGER_START_HANDHELD];
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_IMMEDIATE withObject:ZT_SLED_CFG_NAME_TRIGGER_START_IMMEDIATE];
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_PERIODIC withObject:ZT_SLED_CFG_NAME_TRIGGER_START_PERIODIC];
    
    for (int i = 0; i < ZT_SLED_CFG_TRIGGER_STOP_COUNT; i++)
    {
        [_triggerStopOptions addObject:@""];
    }
    
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_DURATION withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_DURATION];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_HANDHELD withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_HANDHELD];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_IMMEDIATE];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_N_ATTEMPTS];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_TAG_OBSERVATION];
    
    /* Batch Mode */
    
    [_batchModeOptions addObject:@""];
    [_batchModeOptions addObject:@""];
    [_batchModeOptions addObject:@""];
    [_batchModeOptions replaceObjectAtIndex:SRFID_BATCHMODECONFIG_DISABLE withObject:@"Disable"];
    [_batchModeOptions replaceObjectAtIndex:SRFID_BATCHMODECONFIG_AUTO withObject:@"Auto"];
    [_batchModeOptions replaceObjectAtIndex:SRFID_BATCHMODECONFIG_ENABLE withObject:@"Enable"];
    [_usbBatchModeOptions addObjectsFromArray:_batchModeOptions];
        
    _currentBatchMode = 1;
    _currentUSBBatchMode = 1;
    
 }

+ (NSNumber *)getKeyFromDictionary:(NSDictionary *)dictionary withValue:(NSString *)value
{
    NSDictionary *dic = [dictionary copy];
    NSArray *array = [dic allKeysForObject:value];
    [dic release];
    if([array count] == 1)
    {
        return array[0];
    }
    return nil;
}

#pragma mark - antenna
- (BOOL)setAntennaOptionsWithConfig:(srfidAntennaConfiguration *)config
{
    zt_SledConfiguration *localSledConfiguration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    _currentAntennaLinkProfile = [config getLinkProfileIdx];
    _currentAntennaTari = [config getTari];
    _currentAntennaPie = localSledConfiguration.currentAntennaPie;
    _currentAntennaDoSelect = [config getDoSelect];
    float inputPowerLevel = [config getPower];
    _currentAntennaPowerLevel = inputPowerLevel;
    
    return YES;
}


/// Fetch the pie value using the selected link profile index.
/// @param linkProfileIndex The link profile index from the selected link profile object.
/// @param linkProfilesArray The link profiles array to fetch matching index.
-(int)getPieValueByLinkProfileIndex:(int)linkProfileIndex linkProfileArray:(NSMutableArray*) linkProfilesArray{
    int pieValue = 0;
    for (zt_LinkProfileObject *linkProfileObject in linkProfilesArray) {
        if ([linkProfileObject.modeTableEntry getRFModeIndex] == linkProfileIndex){
            pieValue =  [linkProfileObject.modeTableEntry getPIE];
            break;
        }
    }
    return pieValue;
}

- (srfidAntennaConfiguration *)getAntennaConfig
{
    srfidAntennaConfiguration *config = [[[srfidAntennaConfiguration alloc] init] autorelease];
    [config setPower:_currentAntennaPowerLevel];
    [config setLinkProfileIdx:_currentAntennaLinkProfile];
    [config setTari:_currentAntennaTari];
    [config setDoSelect:_currentAntennaDoSelect];
    return config;
}

- (void)setLinkProfileOptions:(NSArray *)linkProfiles
{
    [_antennaAllLinkProfiles removeAllObjects];
    [_antennaAllLinkProfiles addObjectsFromArray:linkProfiles];
    [_linkProfilesArray removeAllObjects];
    [_antennaOptionsLinkProfile removeAllObjects];
    
    [_backUpLinkProfile removeAllObjects];
    [_backUpLinkProfile addObjectsFromArray:linkProfiles];
    
    for (int i=0; i < [linkProfiles count]; ++i) {
        
        srfidLinkProfile *profile = linkProfiles[i];
        
        int backscatter = profile.getBDR;
        int miller = LINK_PROFILE_MILLER_1;
        NSString * modulationString = [self getModulationString:profile.getModulation];
        int modulation = [[modulationString substringFromIndex: [modulationString length] - 1] intValue];
        NSString * profileString = nil;
        switch (modulation)
        {
            case LINK_PROFILE_MODULATION_2:
                miller = LINK_PROFILE_MILLER_2;
                break;
            case LINK_PROFILE_MODULATION_4:
                miller = LINK_PROFILE_MILLER_4;
                break;
            case LINK_PROFILE_MODULATION_8:
                miller = LINK_PROFILE_MILLER_8;
                break;
        }
    
        if (miller == LINK_PROFILE_MILLER_1) {
            if (profile.getMaxTari == LINK_PROFILE_TARI_668) {
                profileString = [NSString stringWithFormat:@"%@ %d", LINK_PROFILE_AUTOMAC,profile.getMaxTari];
            }else
            {
                profileString = [NSString stringWithFormat:@"%@ %d%@",LINK_PROFILE_FM0,backscatter * miller/1000,LINK_PROFILE_K];
            }
        }else
        {
            profileString = [NSString stringWithFormat:@"%@%d %d%@",LINK_PROFILE_M,miller,backscatter * miller/1000,LINK_PROFILE_K];
        }
        
        if (![_sampleLinkProfiles containsObject:profileString]) {
            
            [_sampleLinkProfiles addObject:profileString];
            [_antennaOptionsLinkProfile setObject:profileString forKey:[NSNumber numberWithInt: [profile getRFModeIndex]]];
            _antennaAllLinkProfiles = _sampleLinkProfiles;
            
            
            if (profile.getMinTari == MIN_TARI_12500) {
                _minTari_12500 = TRUE;
            }
            if (profile.getStepTari != 0 && profile.getStepTari != LINK_PROFILE_TARI_668) {
                _stepTari_non_0 = TRUE;
            }
            if (profile.getStepTari == STEP_TARI_6300) {
                _stepTari_6300 = TRUE;
            }
            
            if (profile.getPIE == ANTENNA_PAI_1500) {
                _pie_1500 = TRUE;
            }
            
            NSString * legacyName = [NSString stringWithFormat:@"%d %@ %d %d %d %d",
                                       profile.getBDR,
                                       [self getModulationString:profile.getModulation],
                                       profile.getPIE,
                                       profile.getMinTari,
                                       profile.getMaxTari,
                                       profile.getStepTari];
            
            zt_LinkProfileObject* linkProfileObject  = [[zt_LinkProfileObject alloc] init];
            linkProfileObject.profileName = profileString;
            linkProfileObject.legacyProfileName = legacyName;
            linkProfileObject.modeTableEntry = profile;
            linkProfileObject.indexVal = i;
            
            [_linkProfilesArray addObject:linkProfileObject];
        }
    }

}

- (NSArray *)getLinkProfileArray
{
    NSMutableArray *keys = [[[NSMutableArray alloc] initWithArray:[_antennaOptionsLinkProfile allKeys]] autorelease];
    [keys sortUsingSelector:@selector(compare:)];
    NSArray *linkProfiles = [_antennaOptionsLinkProfile objectsForKeys:keys notFoundMarker:[NSNull null]];
    return linkProfiles;
}

- (NSString *)getForwardLinkModulation:(SRFID_FORWARDLINKMODULATION)forward
{
    zt_EnumMapper *mapper = [[zt_EnumMapper alloc] initWithFORWARDLINKMODULATIONMapper];
    NSString *result = [mapper getStringByEnum:forward];
    [mapper release];
    return result;
}

- (NSString *)getModulationString:(SRFID_MODULATION)mod
{
    zt_EnumMapper *mapper = [[zt_EnumMapper alloc] initWithMODULATIONMapper];
    NSString *result = [mapper getStringByEnum:mod];
    [mapper release];
    return result;
}

- (BOOL)isAntennaConfigEqual:(zt_SledConfiguration *)sled
{
    if(_currentAntennaDoSelect != sled.currentAntennaDoSelect)
       return NO;
    if(_currentAntennaLinkProfile != sled.currentAntennaLinkProfile)
        return NO;
    if(_currentAntennaPowerLevel != sled.currentAntennaPowerLevel)
        return NO;
    if(_currentAntennaTari != sled.currentAntennaTari)
        return NO;
    if(_currentAntennaPie != sled.currentAntennaPie)
        return NO;
    
    return YES;
}

- (BOOL)isMinTari_12500
{
    return  _minTari_12500;
}
- (BOOL)isStepTari_non_0
{
    return _stepTari_non_0;
}
- (BOOL)isStepTari_6300
{
    return _stepTari_6300;
}
- (BOOL)ispie_1500
{
    return _pie_1500;
}

#pragma mark - dynamic power optimization settings

- (void)setDpoOptionsWithConfig:(srfidDynamicPowerConfig *)config
{
    self.currentDpoEnable = [NSNumber numberWithBool:[config getDynamicPowerOptimizationEnabled]];
    [[NSUserDefaults standardUserDefaults] setValue:self.currentDpoEnable forKey:DPO_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (srfidDynamicPowerConfig *)getDpoConfig
{
    srfidDynamicPowerConfig *config = [[[srfidDynamicPowerConfig alloc] init] autorelease];
    
    if (self.currentDpoEnable == nil) {
        
        self.currentDpoEnable = [[NSUserDefaults standardUserDefaults] valueForKey:DPO_DEFAULTS_KEY];
    }
    [config setDynamicPowerOptimizationEnabled:[self.currentDpoEnable boolValue]];

    return config;
}

- (BOOL)isDpoConfigEqual:(zt_SledConfiguration *)sled
{
    if([self.currentDpoEnable boolValue] != [sled.currentDpoEnable boolValue])
        return NO;
    
    return YES;
}

#pragma mark - singulation settings

- (BOOL)setSingulationOptionsWithConfig:(srfidSingulationConfig *)config
{
    _currentSLFLag = [config getSLFlag];
    _currentSession = [config getSession];
    _currentInventoryState = [config getInventoryState];
    _currentTagPopulation = [config getTagPopulation];
    if (NSNotFound == [_mapperTagPopulation getIndxByEnum:_currentTagPopulation])
    {
        /* one of not-supported by app values retrieved from reader */
        _currentTagPopulation = [_mapperTagPopulation getEnumByIndx:0];
        return NO;
    }
    return YES;
}

- (srfidSingulationConfig *)getSingulationConfig
{
    srfidSingulationConfig *config = [[[srfidSingulationConfig alloc] init] autorelease];
    [config setSlFlag:_currentSLFLag];
    [config setSession:_currentSession];
    [config setInventoryState:_currentInventoryState];
    [config setTagPopulation:_currentTagPopulation];
    return config;
}

- (BOOL)isSingulationConfigEqual:(zt_SledConfiguration *)sled
{
    if(_currentSession != sled.currentSession)
        return NO;
    if(_currentInventoryState != sled.currentInventoryState)
        return NO;
    if(_currentSLFLag != sled.currentSLFLag)
        return NO;
    if(_currentTagPopulation != sled.currentTagPopulation)
        return NO;
    return YES;
}

- (BOOL)isSingulationConfigValid
{
    if ([self checkForMin:ZT_SLED_CFG_NAME_SINGULATION_TAG_POPULATION_MIN forMax:ZT_SLED_CFG_NAME_SINGULATION_TAG_POPULATION_MAX withValue:_currentTagPopulation])
        return YES;
    else
        return NO;
}

/* Tag Report */

- (void)setTagReportOptionsWithConfig:(srfidTagReportConfig *)config
{
    _tagReportChannelIdx = [config getIncChannelIdx];
    _tagReportFirstSeenTime = [config getIncFirstSeenTime];
    _tagReportLastSeenTime = [config getIncLastSeenTime];
    _tagReportPC = [config getIncPC];
    _tagReportPhase = [config getIncPhase];
    _tagReportRSSI = [config getIncRSSI];
    _tagReportSeenCount = [config getIncTagSeenCount];
    /* nrv364: disable not used fields */
    _tagReportFirstSeenTime = NO;
    _tagReportLastSeenTime = NO;
   // _tagReportSeenCount = NO;
}

- (srfidTagReportConfig *)getTagReportConfig
{
    srfidTagReportConfig *config = [[[srfidTagReportConfig alloc] init] autorelease];
    [config setIncChannelIdx:_tagReportChannelIdx];
    [config setIncFirstSeenTime:_tagReportFirstSeenTime];
    [config setIncLastSeenTime:_tagReportLastSeenTime];
    [config setIncPC:_tagReportPC];
    [config setIncPhase:_tagReportPhase];
    [config setIncRSSI:_tagReportRSSI];
    [config setIncTagSeenCount:_tagReportSeenCount];
    return config;
}

- (srfidReportConfig *)getReportConfig
{
    srfidReportConfig *config = [[[srfidReportConfig alloc] init] autorelease];
    [config setIncChannelIndex:_tagReportChannelIdx];
    [config setIncFirstSeenTime:_tagReportFirstSeenTime];
    [config setIncLastSeenTime:_tagReportLastSeenTime];
    [config setIncPC:_tagReportPC];
    [config setIncPhase:_tagReportPhase];
    [config setIncRSSI:_tagReportRSSI];
    [config setIncTagSeenCount:_tagReportSeenCount];
    return config;
}

- (srfidReportConfig *)getReportConfigAllOff
{
    srfidReportConfig *config = [[[srfidReportConfig alloc] init] autorelease];
    [config setIncChannelIndex:NO];
    [config setIncFirstSeenTime:NO];
    [config setIncLastSeenTime:NO];
    [config setIncPC:NO];
    [config setIncPhase:NO];
    [config setIncRSSI:NO];
    [config setIncTagSeenCount:NO];
    return config;

}

- (BOOL)isTagReporConfigEqual:(zt_SledConfiguration *)sled
{
    if(_tagReportChannelIdx != sled.tagReportChannelIdx)
        return NO;
    if(_tagReportFirstSeenTime != sled.tagReportFirstSeenTime)
        return NO;
    if(_tagReportLastSeenTime != sled.tagReportLastSeenTime)
        return NO;
    if(_tagReportPC != sled.tagReportPC)
        return NO;
    if(_tagReportPhase != sled.tagReportPhase)
        return NO;
    if(_tagReportRSSI != sled.tagReportRSSI)
        return NO;
    if(_tagReportSeenCount != sled.tagReportSeenCount)
       return NO;
    if(_currentBatchMode != sled.currentBatchMode)
        return NO;
    if(_currentUSBBatchMode != sled.currentUSBBatchMode)
        return NO;
    
    return YES;
}

/* beeper */

- (void)setBeeperOptionsWithConfig:(SRFID_BEEPERCONFIG)config
{
    BOOL hostBeeper = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_APP_CFG_HOST_BEEPER_ENABLED];
    if (SRFID_BEEPERCONFIG_HIGH == config)
    {
        _currentBeeperEnable = YES;
        _hostBeeperEnable = hostBeeper;
        _currentBeeperLevel = SRFID_BEEPERCONFIG_HIGH;
    }
    else if (SRFID_BEEPERCONFIG_MEDIUM == config)
    {
        _currentBeeperEnable = YES;
        _hostBeeperEnable = hostBeeper;
        _currentBeeperLevel = SRFID_BEEPERCONFIG_MEDIUM;
    }
    else if (SRFID_BEEPERCONFIG_LOW == config)
    {
        _currentBeeperEnable = YES;
        _hostBeeperEnable = hostBeeper;
        _currentBeeperLevel = SRFID_BEEPERCONFIG_LOW;
    }
    else if (SRFID_BEEPERCONFIG_QUIET == config)
    {
        _currentBeeperEnable = NO;
        _hostBeeperEnable = hostBeeper;
        /* don't override UI level for disabled beeper */
        //_currentBeeperLevel = SRFID_BEEPERCONFIG_MEDIUM;
    }
}

- (SRFID_BEEPERCONFIG)getBeeperConfig
{
    SRFID_BEEPERCONFIG beeper = SRFID_BEEPERCONFIG_QUIET;
    
    if (YES == _currentBeeperEnable)
    {
        switch (_currentBeeperLevel) {
            case SRFID_BEEPERCONFIG_HIGH:
                beeper = SRFID_BEEPERCONFIG_HIGH;
                break;
            case SRFID_BEEPERCONFIG_MEDIUM:
                beeper = SRFID_BEEPERCONFIG_MEDIUM;
                break;
            case SRFID_BEEPERCONFIG_LOW:
                beeper = SRFID_BEEPERCONFIG_LOW;
                break;
            case SRFID_BEEPERCONFIG_QUIET:
                beeper = SRFID_BEEPERCONFIG_QUIET;
                break;
        }
    }
    
    return beeper;
}

- (BOOL)isBeeperConfigEqual:(zt_SledConfiguration *)sled
{
    
    if (_currentBeeperEnable != sled.currentBeeperEnable)
    {
        return NO;
    }
    
    if (YES == sled.currentBeeperEnable)
    {
        if (_currentBeeperLevel != sled.currentBeeperLevel)
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isHostBeeperConfigEqual:(zt_SledConfiguration *)sled
{

    if (_hostBeeperEnable != sled.hostBeeperEnable)
    {
        return NO;
    }

    if (YES == sled.hostBeeperEnable) {
        if (_hostBeeperLevel != sled.hostBeeperLevel) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - trigger settings
- (void)setStartTriggerOptionWithConfig:(srfidStartTriggerConfig *)config
{
    BOOL onHandheldTrigger = [config getStartOnHandheldTrigger];
    _currentStartTriggerType = [config getTriggerType];
    BOOL repeat = [config getRepeatMonitoring];
    
    if (onHandheldTrigger)
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_HANDHELD;
        _currentStartDelay = 0;
    }
    else if (repeat)
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_PERIODIC;
        _currentStartDelay = [config getStartDelay];
    }
    else
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_IMMEDIATE;
        _currentStartDelay = 0;
        
    }
}

- (void)setStopTriggerOptionWithConfig:(srfidStopTriggerConfig *)config
{
    BOOL onHanheldTrigger = [config getStopOnHandheldTrigger];
    _currentStopTriggerType = [config getTriggerType];
    BOOL onTagCount = [config getStopOnTagCount];
    BOOL onTimeout = [config getStopOnTimeout];
    BOOL onInventoryCount = [config getStopOnInventoryCount];
    _currentStopInventoryCount =[config getStopInventoryCount];
    //    _currentStopOnAccessCount  = [config getStopOnAccessCount];
    //    _currentStopAccessCount = [NSNumber numberWithInt:[config getStopAccessCount]];
    
    int timeout = 0;
    if (YES == onTimeout)
    {
        timeout = [config getStopTimeout];
    }
    
    if (YES == onHanheldTrigger)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_HANDHELD;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else if (YES == onTagCount)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION;
        _currentStopTagCount = [config getStopTagCount];
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else if (YES == onInventoryCount)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount =[config getStopInventoryCount];
    }
    else if (YES == onTimeout)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_DURATION;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_START_IMMEDIATE;
        _currentStopTagCount = 0;
        _currentStopTimeout = 0;
        _currentStopInventoryCount = 0;
    }
}

- (srfidStartTriggerConfig *)getStartTriggerConfig
{
    srfidStartTriggerConfig *config = [[[srfidStartTriggerConfig alloc] init] autorelease];
    [config setTriggerType:_currentStartTriggerType];
    
    switch (_currentStartTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_START_IMMEDIATE:
            [config setStartOnHandheldTrigger:NO];
            [config setRepeatMonitoring:NO];
            [config setStartDelay:0];
            break;
        
        case ZT_SLED_CFG_TRIGGER_START_PERIODIC:
            [config setStartOnHandheldTrigger:NO];
            [config setRepeatMonitoring:YES];
            [config setStartDelay:(unsigned int)_currentStartDelay];
            break;
        
        case ZT_SLED_CFG_TRIGGER_START_HANDHELD:
            [config setStartOnHandheldTrigger:YES];
            [config setRepeatMonitoring:YES]; /* nrv364 */
            [config setStartDelay:0];
            break;
        default:
            break;
    }
    return config;
}

- (srfidStopTriggerConfig *)getStopTriggerConfig
{
    srfidStopTriggerConfig *config = [[[srfidStopTriggerConfig alloc] init] autorelease];
    [config setTriggerType:_currentStopTriggerType];
    
    
    // onAccessCount is not used now, so it is not changed
    //[config setStopOnAccessCount:_currentStopOnAccessCount];
    //[config setStopAccessCount:[_currentStopAccessCount intValue]];
    
    
    switch (_currentStopTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:NO];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:0];
            [config setStopInventoryCount:0];
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_HANDHELD:
            [config setStopOnHandheldTrigger:YES];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];

            break;
        case ZT_SLED_CFG_TRIGGER_STOP_DURATION:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];

            break;
        case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:YES];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:(unsigned int)_currentStopTagCount];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:YES];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:(unsigned int)_currentStopInventoryCount];
            break;
            
        default:
            break;
    }
    return config;
}

- (BOOL)isStartTriggerConfigEqual:(zt_SledConfiguration *)sled
{
    if (_currentStartTriggerOption != sled.currentStartTriggerOption)
        return NO;
    
    switch (_currentStartTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_START_HANDHELD:
            if (_currentStartTriggerType != sled.currentStartTriggerType)
                return NO;
            break;
        
        case ZT_SLED_CFG_TRIGGER_START_PERIODIC:
            if (_currentStartDelay != sled.currentStartDelay)
                return NO;
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)isStartTriggerConfigValid
{
       switch (_currentStartTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_START_PERIODIC:
            return [self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStartDelay];
            break;
            
        default:
            break;
    }
    
    return YES;
}
- (BOOL)isStopTriggerConfigEqual:(zt_SledConfiguration *)sled
{
    if (_currentStopTriggerOption != sled.currentStopTriggerOption)
        return NO;
    
    switch (_currentStopTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_STOP_HANDHELD:
            if (_currentStopTriggerType != sled.currentStopTriggerType)
                return NO;
            if (_currentStopTimeout != sled.currentStopTimeout)
                return NO;
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_DURATION:
            if (_currentStopTimeout != sled.currentStopTimeout)
                return NO;
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
            if (_currentStopTagCount != sled.currentStopTagCount)
                return NO;
            if (_currentStopTimeout != sled.currentStopTimeout)
                return NO;
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
            if (_currentStopInventoryCount != sled.currentStopInventoryCount)
                return NO;
            if (_currentStopTimeout != sled.currentStopTimeout)
                return NO;
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)isStopTriggerConfigValid
{
    switch (_currentStopTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_STOP_HANDHELD:
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopTimeout])
                return NO;
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_DURATION:
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopTimeout])
                return NO;
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopTagCount])
                return NO;
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopTimeout])
                return NO;
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopInventoryCount])
                return NO;
            if (![self checkForMinLL:ZT_TRIGGER_MIN forMax:ZT_TRIGGER_MAX withValue:_currentStopTimeout])
                return NO;
            break;
            
        default:
            break;
    }
    
    return YES;
}


- (BOOL)isStartTriggerRepeatMonitoring;
{
    return (ZT_SLED_CFG_TRIGGER_START_IMMEDIATE != _currentStartTriggerOption);
}

- (BOOL)isStartTriggerPeriodic
{
    return (ZT_SLED_CFG_TRIGGER_START_PERIODIC == _currentStartTriggerOption);
}

- (BOOL)isStartTriggerImmediate
{
    return (ZT_SLED_CFG_TRIGGER_START_IMMEDIATE == _currentStartTriggerOption);
}

- (BOOL)isStartTriggerHandheld
{
    return (ZT_SLED_CFG_TRIGGER_START_HANDHELD == _currentStartTriggerOption);
}

- (BOOL)isStopTriggerHandheld
{
    return (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == _currentStopTriggerOption);
}

- (BOOL)isStopTriggerImmediate
{
    return (ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE == _currentStopTriggerOption);
}


#pragma mark - regulatory settings
-(void)setRegions:(NSMutableArray *)regionOptions
{
    if (_regionOptions == regionOptions) {
        return;
    }
    
    NSMutableArray *oldValue = _regionOptions;
    
    if (regionOptions != nil)
    {
        _regionOptions = [regionOptions copy];
    }
    else
    {
        _regionOptions = nil;
    }
    
    if (oldValue != nil)
    {
        [oldValue release];
    }
}

-(void)setSupportedRegions:(NSMutableArray *)supportedRegions
{
    if (_supportedRegions == supportedRegions) {
        return;
    }
    NSMutableArray *oldValue = _supportedRegions;
    if (supportedRegions != nil)
    {
        _supportedRegions = [supportedRegions copy];
    }
    else
    {
        _supportedRegions = nil;
    }
    if (oldValue != nil)
    {
        [oldValue release];
    }
}

- (void)setRegulatoryOptionsWithConfig:(srfidRegulatoryConfig *)config
{
    NSMutableArray *oldValue = _currentRegionChannelList;
    _currentRegionChannelList = [[config getEnabledChannelsList] mutableCopy];
    [oldValue release];
    
    NSString * oldCode = _currentRegionCode;
    _currentRegionCode = [[config getRegionCode] copy];
    [oldCode release];
    
    /* nrv364: app is not aware of hopping configuration */
    _currentRegionHoppingEnabled = (SRFID_HOPPINGCONFIG_ENABLED == [config getHoppingConfig]);
}

- (srfidRegulatoryConfig *)getRegulatoryConfig
{
    srfidRegulatoryConfig *config = [[[srfidRegulatoryConfig alloc] init] autorelease];
    
    [config setRegionCode:_currentRegionCode];
   
    /* nrv364: does NOT change hopping configuration from app */
    /* otherwise update & use _currentRegionHoppingEnabled */
    [config setHoppingConfig:SRFID_HOPPINGCONFIG_DEFAULT];
    
    /* nrv364: reader responds with "Hopping configuration is not supported" if we send
     setregulatory ASCII with enabled channels list for regions w/o hopping
     configuration enabled */
    
    if (NSOrderedSame != [_currentRegionCode caseInsensitiveCompare:@"NA"])
    {
        int idx = [self indexOfCurrentRegion];
        if (idx >= 0)
        {
            zt_RegionData *rdata = (zt_RegionData*)[_regionOptions objectAtIndex:idx];
            if (YES == rdata.hoppingConfigurable)
            {
                [config setEnabledChannelsList:_currentRegionChannelList];
            }
        }
    }
    
    return config;
}

- (BOOL)isRegulatoryConfigEqual:(zt_SledConfiguration *)sled
{
    if (![_currentRegionCode isEqualToString:sled.currentRegionCode]) {
            return NO;
        }
        /* nrv364 compare enabled channels */
        
        /* count */
        if ([_currentRegionChannelList count] != [sled.currentRegionChannelList count])
        {
            return NO;
        }
        
        /* 2nd contains each elem from 1st */
        
        BOOL found = NO;
        for (NSString *_ch1 in _currentRegionChannelList)
        {
            found = NO;
            for (NSString *_ch2 in sled.currentRegionChannelList)
            {
                if (YES == [_ch1 isEqualToString:_ch2])
                {
                    found = YES;
                    break;
                }
            }
            if (NO == found)
            {
                return NO;
            }
        }
        return YES;
    }

- (int)indexOfCurrentRegion
{
    for (int i = 0; i < [_regionOptions count]; i++)
    {
        zt_RegionData *region = [_regionOptions objectAtIndex:i];
                    
        if ([_currentRegionCode isEqualToString:region.regionCode])
        {
            return i;
        }
    }
    
    return -1;
}

- (int)indexOfRegionWithName:(NSString *)name
{
    for (int i = 0; i < [_regionOptions count]; i++)
    {
        zt_RegionData *region = [_regionOptions objectAtIndex:i];
        
        if ([name isEqualToString:region.regionName])
        {
            return i;
        }
    }
    
    return -1;
}

- (BOOL)isChannelEnabled:(NSString*)channel forRegion:(NSString*)region_code;
{
    
    zt_RegionData *rdata = (zt_RegionData*)[_regionOptions objectAtIndex:[self indexOfCurrentRegion]];
    
    if (YES == [[rdata regionCode] isEqualToString:region_code])
    {
        for (NSString *enabled_channel in _currentRegionChannelList)
        {
            if (YES == [enabled_channel isEqualToString:channel])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)fillCurrentRegionChannelsListDefault
{
    zt_RegionData *rdata = (zt_RegionData*)[_regionOptions objectAtIndex:[self indexOfCurrentRegion]];
    [_currentRegionChannelList removeAllObjects];
    /* nrb364:
      - enable all supported channels for regions w/o hopping configuration enabled
      - disable all supported channels to allow user selection for regions w/ hopping configuration enabled */
    if (NO == rdata.hoppingConfigurable)
    {
        [_currentRegionChannelList addObjectsFromArray:[rdata supporteChannels]];
    }
}

- (void)enableCurrentRegionChannel:(NSString*)channel
{
    BOOL already_enabled = NO;
    
    for (NSString *_ch in _currentRegionChannelList)
    {
        if (YES == [channel isEqualToString:_ch])
        {
            already_enabled = YES;
            break;
        }
    }
    
    if (NO == already_enabled)
    {
        [_currentRegionChannelList addObject:channel];
    }
}

- (void)disableCurrentRegionChannel:(NSString*)channel
{
    int idx_to_remove = -1;
    int i = 0;
    for (NSString *_ch in _currentRegionChannelList)
    {
        if (YES == [channel isEqualToString:_ch])
        {
            idx_to_remove = i;
            break;
        }
        i++;
    }
    
    if (-1 != idx_to_remove)
    {
        [_currentRegionChannelList removeObjectAtIndex:idx_to_remove];
    }
}

#pragma mark - capabilities
- (void)setCapabilityOptionWithInfo:(srfidReaderCapabilitiesInfo *)info
{
    if (_readerSerialNumber != nil) {
        [_readerSerialNumber release];
        [_readerModel release];
        [_readerManufacturer release];
        [_readerManufacturingDate release];
        [_readerScannerName release];
        [_readerAsciiVersion release];
        [_readerAirProtocolVersion release];
        [_readerBTAddress release];
    }
    
    _readerSerialNumber = [[info getSerialNumber] retain];
    _readerModel = [[info getModel] retain];
    _readerManufacturer = [[info getManufacturer] retain];
    _readerManufacturingDate = [[info getManufacturingDate] retain];
    _readerScannerName = [[info getScannerName] retain];
    _readerAsciiVersion = [[info getAsciiVersion] retain];
    _readerSelectFilterNum = [info getSelectFilterNum];
    _readerMinPower = [info getMinPower] ;
    _readerMaxPower = [info getMaxPower];
    _readerPowerStep = [info getPowerStep];
    _readerAirProtocolVersion = [[info getAirProtocolVersion] retain];
    _readerBTAddress = [[info getBDAddress] retain];
    _readerMaxAccessSequence = [info getMaxAccessSequence];
    
    
    if (0 == _readerMinPower)
    {
        _readerMinPower = ZT_SLED_ANTENNA_POWER_MIN;
    }
    
    if (0 == _readerMaxPower)
    {
        _readerMaxPower = ZT_SLED_ANTENNA_POWER_MAX;
    }
    
    // options for antenna
    [_antennaPowerLevelsArray removeAllObjects];
    for (float value = _readerMinPower; value <= _readerMaxPower ; value += ZT_SLED_ANTENNA_POWER_STEP) {
        [_antennaPowerLevelsArray addObject:[NSNumber numberWithFloat:(value / ZT_SLED_ANTENNA_POWER_MEASUREMENT_MULT)]];
    }
}

#pragma mark - version
- (void)setReaderVersionWithInfo:(srfidReaderVersionInfo *)info
{
    if(_readerBluetoothVersion != nil)
    {
        [_readerDeviceVersion release];
        [_readerBluetoothVersion release];
        [_readerNGEVersion release];
        [_readerPL33 release];
    }
    
    _readerDeviceVersion = [[info getDeviceVersion] retain];
    _readerBluetoothVersion = [[info getBluetoothVersion] retain];
    _readerNGEVersion = [[info getNGEVersion] retain];
    _readerPL33 = [[info getPL33] retain];
}

#pragma mark - prefilters
// Tempoarily disable the prefilters
-(void)temporarilyDisablePrefilters {
    _applyFirstFilter = NO;
    _applySecondFilter = NO;
}

-(void)setPrefiltersFromConfig:(NSMutableArray *)prefiltersFromReader
{
    NSMutableArray *prefilters = [zt_SledConfiguration getPrefiltersArrayCopy:prefiltersFromReader];
//    NSMutableArray *prefilters = prefiltersFromReader;
    int size = (int)[prefilters count];
    if (size > 2)
    {
        for (int i = 2; i < size ; i++)
        {
            [prefilters removeObjectAtIndex:i];
        }
    }
    
    if (size == 0) {
        // keep default option
        _applyFirstFilter = NO;
        _applySecondFilter = NO;
    }
    else if ([prefilters count] == 1)
    {
        // check is it first or second filter in UI
        if ([zt_SledConfiguration isPrefilterEqual:prefilters[0] withPrefilter:_currentPrefilters[0]])
        {
            [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:0]];
            _applyFirstFilter = YES;
            _applySecondFilter = NO;
        }
        else if([zt_SledConfiguration isPrefilterEqual:prefilters[0] withPrefilter:_currentPrefilters[1]])
        {
            [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:0]];
            _applyFirstFilter = NO;
            _applySecondFilter = YES;
        }
        else
        {
            [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:0]];
            _applyFirstFilter = YES;
            _applySecondFilter = NO;
        }
        
    }
    else if([prefilters count] == 2)
    {
        int pref1idx = -1;
        if ([zt_SledConfiguration isPrefilterEqual:prefilters[0] withPrefilter:_currentPrefilters[0]])
        {
            [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:0]];
            pref1idx = 0;
        }
        else if([zt_SledConfiguration isPrefilterEqual:prefilters[0] withPrefilter:_currentPrefilters[1]])
        {
            [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:0]];
            pref1idx = 1;
        }
        
        if (pref1idx != -1) {
            if (pref1idx == 0)
            {
                [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:1]];
            }
            else if(pref1idx == 1)
            {
                [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:1]];
            }
            _applyFirstFilter = YES;
            _applySecondFilter = YES;
        }
        else
        {
            int pref2idx = -1;
            if ([zt_SledConfiguration isPrefilterEqual:prefilters[1] withPrefilter:_currentPrefilters[0]])
            {
                [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:1]];
                pref2idx = 0;
            }
            else if ([zt_SledConfiguration isPrefilterEqual:prefilters[1] withPrefilter:_currentPrefilters[1]])
            {
                [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:1]];
                pref2idx = 1;
            }
            
            if (pref2idx != -1) {
                if (pref2idx == 0) {
                    [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:0]];
                }
                if (pref2idx == 1) {
                    [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:0]];
                }
                _applyFirstFilter = YES;
                _applySecondFilter = YES;
            }
            else
            {
                [_currentPrefilters replaceObjectAtIndex:0 withObject:[prefilters objectAtIndex:0]];
                [_currentPrefilters replaceObjectAtIndex:1 withObject:[prefilters objectAtIndex:1]];
                _applyFirstFilter = YES;
                _applySecondFilter = YES;
            }
        }
    }
    
    //[prefilters release];
}

+ (NSMutableArray*)getPrefiltersArrayCopy:(NSMutableArray *)array
{
    NSMutableArray *newArray = [[[NSMutableArray alloc] initWithCapacity:[array count]] autorelease];
    for (int i=0; i < [array count]; i++)
    {
        srfidPreFilter *emptyPrefilter = [[srfidPreFilter alloc] init];
        [emptyPrefilter setTarget:[array[i] getTarget]];
        [emptyPrefilter setAction:[array[i] getAction]];
        [emptyPrefilter setMemoryBank:[array[i] getMemoryBank]];
        [emptyPrefilter setMaskStartPos:[array[i] getMaskStartPos]];
        [emptyPrefilter setMatchPattern:[[array[i] getMatchPattern] copy]];
        [emptyPrefilter setMatchLength:[array[i] getMatchLength]];
        [newArray addObject:emptyPrefilter];
        [emptyPrefilter release];
    }
    return newArray;
}

- (void)addEmptyPrefilterToArray:(NSMutableArray *)array
{
    srfidPreFilter *emptyPrefilter = [[srfidPreFilter alloc] init];
    [emptyPrefilter setTarget:SRFID_SELECTTARGET_S0];
    [emptyPrefilter setAction:SRFID_SELECTACTION_INV_A__OR__ASRT_SL];
    [emptyPrefilter setMemoryBank:SRFID_MEMORYBANK_USER];
    [emptyPrefilter setMaskStartPos:0];
    [emptyPrefilter setMatchLength:0];
    [emptyPrefilter setMatchPattern:@""];
    [array addObject:emptyPrefilter];
    [emptyPrefilter release];
}

-(BOOL)prefilterEnabled
{
    if (_currentPrefilterIndex == 0)
    {
        return _applyFirstFilter;
    }
    else if (_currentPrefilterIndex == 1)
    {
        return _applySecondFilter;
    }
    return NO;
}

-(NSString *)prefilterTagPattern
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return @"";
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    
    NSString *tagPattern = [prefilter getMatchPattern];
    
    return tagPattern;
}

-(NSString *)prefilterTagert
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return nil;
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    
    SRFID_SELECTTARGET target = [prefilter getTarget];
    
    NSString *targetStr = [[_mapperTargetOption getDictionary] objectForKey:[NSNumber numberWithInt:target]];
    
    return targetStr;
}

-(NSString *)prefilterAction
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return nil;
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    
    SRFID_SELECTACTION action = [prefilter getAction];
    
    NSString *actionStr = [[_mapperAction getDictionary] objectForKey:[NSNumber numberWithInt:action]];
    
    return actionStr;
}

-(NSString *)prefilterMemoryBank
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return nil;
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    SRFID_MEMORYBANK memoryBank = [prefilter getMemoryBank];
    NSString *memoryStr = [[_mapperBankPrefilters getDictionary] objectForKey:[NSNumber numberWithInt:memoryBank]];
    return memoryStr;
}

-(NSNumber *)prefilterOffset
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return nil;
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    NSNumber *offset = [NSNumber numberWithInt:[prefilter getMaskStartPos]];
    return offset;
}


/// Get prefilter length
-(NSNumber *)prefilterLength
{
    if ([_currentPrefilters count] <= _currentPrefilterIndex) {
        return nil;
    }
    
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    NSNumber *length = [NSNumber numberWithInt:[prefilter getMatchLength]];
    return length;
}

- (void)setPrefilterEnabled:(BOOL)value
{
    if(_currentPrefilterIndex == 0)
    {
        _applyFirstFilter = value;
    }
    else if(_currentPrefilterIndex == 1)
    {
        _applySecondFilter = value;
    }
    
}
- (void)setPrefilterTagPattern:(NSString *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    [prefilter setMatchPattern:value];
    
}
- (void)setPrefilterTarget:(NSString *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    SRFID_SELECTTARGET target = [[zt_SledConfiguration getKeyFromDictionary:[_mapperTargetOption getDictionary] withValue:value] intValue];
    [prefilter setTarget:target];
}

- (void)setPrefilterAction:(NSString *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    SRFID_SELECTACTION action = [[zt_SledConfiguration getKeyFromDictionary:[_mapperAction getDictionary] withValue:value] intValue];
    [prefilter setAction:action];
}
- (void)setPrefilterMemoryBank:(NSString *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    SRFID_MEMORYBANK bank = [[zt_SledConfiguration getKeyFromDictionary:[_mapperBankPrefilters getDictionary] withValue:value]intValue];
    [prefilter setMemoryBank:bank];
    
}
- (void)setPrefilterOffset:(NSNumber *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    [prefilter setMaskStartPos:[value intValue]];
}


/// To set the prefilter length.
/// - Parameter value: Prefilter value.
- (void)setPrefilterLength:(NSNumber *)value
{
    srfidPreFilter *prefilter = [_currentPrefilters objectAtIndex:_currentPrefilterIndex];
    [prefilter setMatchLength:[value intValue]];
}

-(NSString *)returnEPCMemoryBankForNonMatch
{
    SRFID_MEMORYBANK memoryBank = SRFID_MEMORYBANK_EPC; // Set to EPC memory bank
    NSString *memoryStr = [[_mapperBankPrefilters getDictionary] objectForKey:[NSNumber numberWithInt:memoryBank]];
    return memoryStr;
}

-(NSString *)returnPreFilterActionforNonMatch
{
    SRFID_SELECTACTION action = SRFID_SELECTACTION_INV_A__OR__ASRT_SL;
    
    NSString *actionStr = [[_mapperAction getDictionary] objectForKey:[NSNumber numberWithInt:action]];
    
    return actionStr;
}

-(NSString *) returnPreFilterTargetforNonMatch
{
    SRFID_SELECTTARGET target = SRFID_SELECTTARGET_SL;
    
    NSString *targetStr = [[_mapperTargetOption getDictionary] objectForKey:[NSNumber numberWithInt:target]];
    
    return targetStr;
}

- (void)copyFirstFilerConfig:(srfidPreFilter*)prefilter
{
    srfidPreFilter *emptyPrefilter = _currentPrefilters[0];
    [emptyPrefilter setTarget:[prefilter getTarget]];
    [emptyPrefilter setAction:[prefilter getAction]];
    [emptyPrefilter setMemoryBank:[prefilter getMemoryBank]];
    [emptyPrefilter setMaskStartPos:[prefilter getMaskStartPos]];
    [emptyPrefilter setMatchLength:[prefilter getMatchLength]];
    [emptyPrefilter setMatchPattern:[[prefilter getMatchPattern] copy]];
}
- (void)copySecondFilterConfig:(srfidPreFilter*)prefilter;
{
    srfidPreFilter *emptyPrefilter = _currentPrefilters[1];
    [emptyPrefilter setTarget:[prefilter getTarget]];
    [emptyPrefilter setAction:[prefilter getAction]];
    [emptyPrefilter setMemoryBank:[prefilter getMemoryBank]];
    [emptyPrefilter setMaskStartPos:[prefilter getMaskStartPos]];
    [emptyPrefilter setMatchLength:[prefilter getMatchLength]];
    [emptyPrefilter setMatchPattern:[[prefilter getMatchPattern] copy]];
}

+ (BOOL)isPrefilterEqual:(srfidPreFilter*)prefilterOne withPrefilter:(srfidPreFilter*)prefilterTwo
{
    if ([prefilterOne getAction] != [prefilterTwo getAction])
    {
        return NO;
    }
    if ([prefilterOne getMaskStartPos] != [prefilterTwo getMaskStartPos])
    {
        return NO;
    }
    if ([prefilterOne getMatchLength] != [prefilterTwo getMatchLength])
    {
        return NO;
    }
    if (![[prefilterOne getMatchPattern] isEqualToString:[prefilterTwo getMatchPattern]])
    {
        return NO;
    }
    if ([prefilterOne getMemoryBank] != [prefilterTwo getMemoryBank])
    {
        return NO;
    }
    if ([prefilterOne getTarget] != [prefilterTwo getTarget])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)isPrefilterValid:(srfidPreFilter *)prefilter
{
    int offset = [prefilter getMaskStartPos];
    if (offset < ZT_PREFILTERS_OFFSET_MIN || offset > ZT_PREFILTERS_OFFSET_MAX)
    {
        return NO;
    }
    return YES;
}

#pragma mark - old methods

/* tag report settings */

- (NSArray*)getConfigTagReportOptions
{
    return m_ConfigTagReportOptions;
}

#pragma mark - helper methods

- (BOOL)checkForMin:(int)min forMax:(int)max withValue:(int)value
{
    if (value < min || value > max) {
        return NO;
    }
    return YES;
}

- (BOOL)checkForMinLL:(long long)min forMax:(long long)max withValue:(long long)value
{
    if (value < min || value > max) {
        return NO;
    }
    return YES;
}

#pragma mark - Batch Mode Settings

-(void) setBatchModeOptionsWithConfig:(SRFID_BATCHMODECONFIG)config
{
    if (SRFID_BATCHMODECONFIG_ENABLE == config)
    {
        _currentBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
    }
    else if (SRFID_BATCHMODECONFIG_AUTO == config)
    {
        _currentBatchMode = SRFID_BATCHMODECONFIG_AUTO;
    }
    else if (SRFID_BATCHMODECONFIG_DISABLE == config)
    {
        _currentBatchMode = SRFID_BATCHMODECONFIG_DISABLE;
    }
}


-(SRFID_BATCHMODECONFIG) getBatchModeConfig
{
    SRFID_BATCHMODECONFIG batchMode = SRFID_BATCHMODECONFIG_AUTO;
    
    switch (_currentBatchMode) {
        case SRFID_BATCHMODECONFIG_ENABLE:
            batchMode = SRFID_BATCHMODECONFIG_ENABLE;
            break;
        case SRFID_BATCHMODECONFIG_AUTO:
            batchMode = SRFID_BATCHMODECONFIG_AUTO;
            break;
        case SRFID_BATCHMODECONFIG_DISABLE:
            batchMode = SRFID_BATCHMODECONFIG_DISABLE;
            break;
    }
    
    return batchMode;
}


-(BOOL) isBatchModeConfigEqual:(zt_SledConfiguration *)sled
{
    if(_currentBatchMode != sled.currentBatchMode)
    {
        return NO;
    }
    return YES;
}

// USB Batchmode

/// Set usb batchmode configuration options.
/// - Parameter config: The configuration
-(void) setUSBBatchModeOptionsWithConfig : (SRFID_BATCHMODECONFIG)config
{
    if (SRFID_BATCHMODECONFIG_ENABLE == config)
    {
        _currentUSBBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
    }
    else if (SRFID_BATCHMODECONFIG_DISABLE == config)
    {
        _currentUSBBatchMode = SRFID_BATCHMODECONFIG_DISABLE;
    }else
    {
        _currentUSBBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
    }
}


/// Get usb batchmode configuration.
-(SRFID_BATCHMODECONFIG) getUSBBatchModeConfig
{
        SRFID_BATCHMODECONFIG usbBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
        
        switch (_currentUSBBatchMode) {
            case SRFID_BATCHMODECONFIG_AUTO:
                usbBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
            case SRFID_BATCHMODECONFIG_ENABLE:
                usbBatchMode = SRFID_BATCHMODECONFIG_ENABLE;
                break;
            case SRFID_BATCHMODECONFIG_DISABLE:
                usbBatchMode = SRFID_BATCHMODECONFIG_DISABLE;
                break;
        }
        
        return usbBatchMode;
}


/// Comparing the usb batchmode configuration.
/// - Parameter sled: The sled.
- (BOOL) isUSBBatchModeConfigEqual: (zt_SledConfiguration *)sled
{
    if(_currentUSBBatchMode != sled.currentUSBBatchMode)
    {
        return NO;
    }
    return YES;
}

#pragma mark --- UniqueTags Report
-(void) setUniqueTagsReport : (srfidUniqueTagsReport *)config{
  self.isUniqueTagsReport = [NSNumber numberWithBool:[config getUniqueTagsReportEnabled]];
}
-(srfidUniqueTagsReport *) getUniqueTagsReport{
    srfidUniqueTagsReport *config = [[[srfidUniqueTagsReport alloc] init] autorelease];
    [config setUniqueTagsReportEnabled:[self.isUniqueTagsReport boolValue]];
    
    return config;
}
- (BOOL) isUniqueTagsReportEqual: (zt_SledConfiguration *)sled{
    if(_isUniqueTagsReport != sled.isUniqueTagsReport)
        return NO;
    
    return YES;
}

/// To set the selected trigger configuration.
/// @param configuration Configuration from the enum.
-(void) setSelectedTriggerConfigurationUpperTrigger : (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)upper lowerTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)lower{
    [self setCurrentSelectedLowerTrigger:lower];
    [self setCurrentSelectedUpperTrigger:upper];
}

/// To get current upper trigger configuration.
- (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)getSelectedUpperTriggerConfiguration{
    return _currentSelectedUpperTrigger;
}

/// To get current lower trigger configuration.
- (SRFID_NEW_ENUM_KEYLAYOUT_TYPE)getSelectedLowerTriggerConfiguration{
    return _currentSelectedLowerTrigger;
}


/// Get  reader max power level
- (NSString*)getReaderMaxPowerLevel {
    
    return [NSString stringWithFormat:@"%i",  _readerMaxPower];
    
}

- (void)SetTheDeviceIsFactoryReseted:(BOOL)option
{
    _factoryResetFlag = option;
}
- (BOOL)GetTheDeviceIsFactoryReseted
{
    return _factoryResetFlag;
}
@end
