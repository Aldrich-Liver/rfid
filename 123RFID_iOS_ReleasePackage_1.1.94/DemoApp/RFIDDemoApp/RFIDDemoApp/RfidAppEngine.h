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
 *  Description:  RfidAppEngine.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "SledConfiguration.h"
#import "AppConfiguration.h"
#import <ZebraRfidSdkFramework/RfidSdkApi.h>
#import "ActiveReader.h"
#import "InventoryItem.h"
#import "InventoryData.h"
#import "RegionData.h"
#import "RadioOperationEngine.h"
#import <ZebraRfidSdkFramework/RfidBatteryStatusInformation.h>
#import "RegulatorySettingsVC.h"


// This is the protocol that defines the methods our delegate can implement.
@protocol zt_IRfidAppEngineTagDataEventForImpingTag <NSObject>
// This method is optional. The delegate can choose whether to implement it.
- (void)impingTagDataEvent:(srfidTagData*)tagData;
@end


@protocol zt_IRfidAppEngineDevListDelegate <NSObject>
- (BOOL)deviceListHasBeenUpdated;
@end

@protocol zt_IRfidAppEngineTriggerEventDelegate <NSObject>
- (BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID;
@end

@protocol zt_IRfidAppEngineBatteryEventDelegate <NSObject>
- (BOOL)onNewBatteryEvent;
@end

@protocol zt_IRfidAppEngineMultiTagEventDelegate <NSObject>
- (void)onNewMultiTagEvent:(srfidTagData*)tagdata;
@end

@protocol zt_IRfidAppEngineWlanScanEventDelegate <NSObject>
- (BOOL)onNewWlanScanEvent:(NSString*)scanEvent;
@end

@protocol zt_IRfidAppEngineWlanConnectEventDelegate <NSObject>
- (BOOL)onNewWlanConnectEvent:(NSString*)connectEvent;
@end

@protocol zt_IRfidAppEngineWlanDisConnectEventDelegate <NSObject>
- (BOOL)onNewWlanDisConnectEvent:(NSString*)disconnectEvent;
@end

@protocol zt_IRfidAppEngineWlanOperationFailedEventDelegate <NSObject>
- (BOOL)onNewWlanOperationFailedEvent:(NSString*)operationFailedEvent;
@end

@protocol zt_IRfidAppEngineIOTStatusEventDelegate <NSObject>
- (void)onNewIOTStatusEvent:(srfidIOTStatusEvent*)iotStatusEvent;
@end

@protocol AuthorisationPopupDelegate <NSObject>
@required
-(void)showAuthorisation:(NSString*)status;
@end

@interface zt_RfidAppEngine : NSObject <srfidISdkApiDelegate,RegulatorySettingsVCDelegate>

+ (zt_RfidAppEngine *) sharedAppEngine;
+ (id)alloc;
+ (void)destroy;
- (id)init;
- (void)dealloc;

@property (nonatomic) BOOL isLocatingDevice;
@property (nonatomic) BOOL statusOfChargeTerminal;
@property (nonatomic) SRFID_CONNECTED_INTERFACE_TYPE connectedUserInterfaceType;

#pragma mark - data
- (zt_ActiveReader *)activeReader;
- (zt_SledConfiguration *)sledConfiguration;
- (zt_AppConfiguration *)appConfiguration;
- (zt_SledConfiguration *)temporarySledConfigurationCopy;
- (zt_RadioOperationEngine *)operationEngine;

- (void) reconnectAfterBatchMode;
- (void) establishAsciiConnection;
- (void) postAsciiConnectionActions;

/* interface for UI */

- (NSString *)getSDKVersion;
- (srfidBatteryEvent*)getBatteryInfo;
- (NSString*)getBatteryStatusString;
- (void)resetBatteryStatusString;
- (SRFID_RESULT)fetchAllRegionData:(NSString**)statusMessage;
- (void)loadRegionsInfoIfRequired;
- (void)setConnectedReaderName:(NSString *)readerName;
- (NSString*)getConnectedReaderName;

#pragma mark - observers management
- (void)addDeviceListDelegate:(id<zt_IRfidAppEngineDevListDelegate>)delegate;
- (void)removeDeviceListDelegate:(id<zt_IRfidAppEngineDevListDelegate>)delegate;

- (void)addTriggerEventDelegate:(id<zt_IRfidAppEngineTriggerEventDelegate>)delegate;
- (void)removeTriggerEventDelegate:(id<zt_IRfidAppEngineTriggerEventDelegate>)delegate;

- (void)addBatteryEventDelegate:(id<zt_IRfidAppEngineBatteryEventDelegate>)delegate;
- (void)removeBatteryEventDelegate:(id<zt_IRfidAppEngineBatteryEventDelegate>)delegate;

- (void)multiTagEventDelegate:(id<zt_IRfidAppEngineMultiTagEventDelegate>)delegate;

- (void)addWlanScanEventDelegate:(id<zt_IRfidAppEngineWlanScanEventDelegate>)delegate;

- (void)removeWlanScanEventDelegate:(id<zt_IRfidAppEngineWlanScanEventDelegate>)delegate;

- (void)addWlanConnectEventDelegate:(id<zt_IRfidAppEngineWlanConnectEventDelegate>)delegate;

- (void)removeWlanConnectEventDelegate:(id<zt_IRfidAppEngineWlanConnectEventDelegate>)delegate;

- (void)addWlanDisConnectEventDelegate:(id<zt_IRfidAppEngineWlanDisConnectEventDelegate>)delegate;

- (void)removeWlanDisConnectEventDelegate:(id<zt_IRfidAppEngineWlanDisConnectEventDelegate>)delegate;

- (void)addWlanOperationFailedEventDelegate:(id<zt_IRfidAppEngineWlanOperationFailedEventDelegate>)delegate;

- (void)removeWlanOperationFailedEventDelegate:(id<zt_IRfidAppEngineWlanOperationFailedEventDelegate>)delegate;

- (void)addIOTStatusEventDelegate:(id<zt_IRfidAppEngineIOTStatusEventDelegate>)delegate;
- (void)removeIOTStatusEventDelegate:(id<zt_IRfidAppEngineIOTStatusEventDelegate>)delegate;


- (void)impingTagDataEventDelegate:(id<zt_IRfidAppEngineTagDataEventForImpingTag>)delegate;




#pragma mark - device management
- (NSArray*)getActualDeviceList;
- (void)updateDeviceList;

- (void)connect:(int)reader_id;
- (void)disconnect:(int)reader_id;
- (void)sendCommand:(NSString*)cmd forReader:(int)reader_id;

- (void)setPairByScanConnectReaderName:(NSString*)readerName;

- (SRFID_RESULT)locateReader:(BOOL)doEnabled message:(NSString **)statusMessage;
-(void)showAuthorizationPopup:(UIViewController*)viewcontroller andaMessage:(NSString *)message;
@property (nonatomic, retain) id<AuthorisationPopupDelegate> popupAuthDelegate;

#pragma mark - reading command
- (SRFID_RESULT) sdkStartInventory:(int)readerID aMemoryBank:(SRFID_MEMORYBANK)memoryBankId aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT) sdkStopInventory:(int)readerID aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT) sdkPerformBrandCheckInventory:(int)readerID aMemoryBank:(SRFID_MEMORYBANK)memoryBankId aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage  brandId:(NSString*)brandId epcLenth:(int)epcLenth;

#pragma mark - tag locationing commands
- (SRFID_RESULT)sdkStartTagLocationing:(int)readerID aEpcId:(NSString*)tagEpcID aStatusMessage:(NSString **)statusMessage;
- (SRFID_RESULT)sdkStopTagLocationing:(int)readerID aStatusMessage:(NSString **)statusMessage;

#pragma mark - access command
- (SRFID_RESULT)readTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)writeTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)killTag:(NSString *)tagID withTagData:(srfidTagData **)tagData withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)lockTag:(NSString *)tagID withTagData:(srfidTagData **)tagData memoryBank:(SRFID_MEMORYBANK)memoryBank accessPermissions:(SRFID_ACCESSPERMISSION)accessPermissions withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

#pragma mark - settings request
- (SRFID_RESULT)getSupportedLinkProfiles:(NSString **)responsMessage;
- (SRFID_RESULT)getAntennaConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)setAntennaConfigurationFromLocal:(NSString **)responsMessage;
- (SRFID_RESULT)getDpoConfiguration:(NSString **)responseMessage;
- (SRFID_RESULT)setDpoConfigurationFromLocal:(NSString **)responseMessage;
- (SRFID_RESULT)getSingulationConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)setSingulationConfigurationFromLocal:(NSString **)responsMessage;
- (SRFID_RESULT)getTagReportConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)setTagReportConfigurationFromLocal:(NSString **)responsMessage;
- (SRFID_RESULT)getStartTriggerConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)setStartTriggerConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)getStopTriggerConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)setStopTriggerConfiguration:(NSString **)responsMessage;
- (SRFID_RESULT)getSupportedRegions:(NSString **)responsMessage;
- (SRFID_RESULT)getRegionInfo:(zt_RegionData**)region_data message:(NSString **)responsMessage;
- (SRFID_RESULT)getRegulatoryConfig:(NSString **)responsMessage;
- (SRFID_RESULT)setRegulatoryConfig:(NSString **)responsMessage;
- (SRFID_RESULT)getBeeperConfig:(NSString **)responsMessage;
- (SRFID_RESULT)setBeeperConfig:(NSString **)responsMessage;
- (SRFID_RESULT)getReaderCapabilitiesInfo:(NSString **)responsMessage;
- (SRFID_RESULT)getReaderVersionInfo:(NSString **)responsMessage;
- (SRFID_RESULT)getPrefilters:(NSString **)responsMessage;
- (SRFID_RESULT)setPrefilters:(NSString **)responsMessage;
- (void)restorePrefilters;
- (SRFID_RESULT)saveReaderConfig:(NSString **)responsMessage;
- (SRFID_RESULT)requestBatteryStatus:(NSString **)responsMessage;
- (SRFID_RESULT)setBatchModeConfig:(NSString **)statusMessage;
- (SRFID_RESULT)setUSBBatchModeConfig:(NSString **)statusMessage;
- (SRFID_RESULT)requestIOTStatus:(NSString **)responsMessage;
- (void)restorePrefiltersForTagQuet;
#pragma mark - getTags in batch mode

- (SRFID_RESULT)getTags:(NSString **)statusMessage;

#pragma mark - sdk options
- (void)setAutoDetect:(BOOL)option;
- (void)setAutoReconect:(BOOL)option;

- (SRFID_RESULT)purgeTags:(NSString **)statusMessage;

#pragma  mark - UniqueTagsReport
- (SRFID_RESULT)getUniqueTagsReportConfiguration:(NSString **)responseMessage;

- (SRFID_RESULT)setUniqueTagsReportConfigurationFromLocal:(NSString **)responseMessage;

- (SRFID_RESULT)sdkStartMultiTagLocationing:(int)readerID aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT)sdkStopMultiTagLocationing:(int)readerID aStatusMessage:(NSString **)statusMessage;

#pragma  mark - Trigger Mapping
- (SRFID_RESULT)getTriggerConfigurationUpperTrigger;
- (SRFID_RESULT)setTriggerConfigurationUpperTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)upper andLowerTrigger:(SRFID_NEW_ENUM_KEYLAYOUT_TYPE)lower;

- (SRFID_RESULT)setReaderReboot:(int)readerID status:(NSString **)statusMessage;
- (SRFID_RESULT)setReaderFactoryReset:(int)readerID status:(NSString **)statusMessage;


-(SRFID_RESULT)setReaderAttribute:(int)readerID
             attributeInformation:(srfidAttribute*)attributeInfo aStatusMessage:(NSString**)statusMessage;

-(SRFID_RESULT)getReaderAttribute:(int)readerID
                     attributeNum:(int)attrNum
                        aAttrInfo:(srfidAttribute**)attrInfo
                   aStatusMessage:(NSString**)statusMessage ;


-(SRFID_RESULT)getBatteryStatus:(int)readerID aStatusMessage:(NSString**)statusMessage;

#pragma Async access operations
- (SRFID_RESULT)readTagAsync:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT)writeTagAsync:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)lockTagAsync:(NSString *)tagID withTagData:(srfidTagData **)tagData memoryBank:(SRFID_MEMORYBANK)memoryBank accessPermissions:(SRFID_ACCESSPERMISSION)accessPermissions withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)killTagAsync:(NSString *)tagID withTagData:(srfidTagData **)tagData withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)getWifiStatus:(int)readerID wifiStatusInfo:(srfidGetWifiStatusInfo **)wifiStatusInfo status:(NSString **)statusMessage;

- (SRFID_RESULT)setWifiEnable:(int)readerID wifiEnable:(BOOL)wifiEnableStatus status:(NSString **)statusMessage;

-(SRFID_RESULT)addWlanProfile:(int)readerID srfidProfileConfig:(sRfidAddProfileConfig*)profileConfig aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)removeWlanProfile:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage ;
-(SRFID_RESULT)getWlanProfileList:(int)readerID wlanProfileList:(NSMutableArray **)wlanProfileList status:(NSString **)statusMessage;

-(SRFID_RESULT)getWlanScanList:(int)readerID status:(NSString **)statusMessage;
-(SRFID_RESULT)saveWlanProfile:(int)readerID aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)getWlanCertificatesList:(int)readerID wlanCertificatesList:(NSMutableArray **)wlanCertificatesList status:(NSString **)statusMessage;

-(SRFID_RESULT)connectWlanProfile:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)disconnectWlanProfile:(int)readerID aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)setWlanPreferredSSID:(int)readerID ssidWlan:(NSString*)ssidWlan  aStatusMessage:(NSString**)statusMessage;

-(SRFID_RESULT)addCertificate:(int)readerID fileName:(NSString*)fileName fileSize:(NSString*)fileSize andFilePath:(NSURL*)filePath aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)removeCertificate:(int)readerID fileName:(NSString*)fileName  aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)removeAllCertificate:(int)readerID  aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)saveCertificate:(int)readerID aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)getCertificatesList:(int)readerID certificatesList:(NSMutableArray **)certificatesList status:(NSString **)statusMessage;

-(SRFID_RESULT)addEndPointConfig:(int)readerID endPointConfig:(RfidSetEndPointConfig*)endpointConfig aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)getEndPointList:(int)readerID endPointList:(NSMutableArray **)endPointList status:(NSString **)statusMessage;
-(SRFID_RESULT)saveEndPointConfig:(int)readerID aStatusMessage:(NSString**)statusMessage;
-(SRFID_RESULT)removeEndPointConfig:(int)readerID endPointName:(NSString*)endPointName  aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT)getEndpointConfig:(int)readerID endPointName:(NSString*)endPointName endPointConfig:(srfidGetEndPointConfig **)endPointConfig aStatusMessage:(NSString**)astatusMessage;

- (SRFID_RESULT)getActiveEndPoints:(srfidGetActiveEnpoints **)activeEndPoints aStatusMessage:(NSString **)responseMessage;
- (SRFID_RESULT) activateEndPoint:(int)readerID endPointType:(NSString*)endPointType andEndPointName:(NSString*)endPointName aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT)requestConnectedInterfaceStatus;
- (SRFID_RESULT)requestChargeTerminalStatus;
- (SRFID_RESULT)requestChargeTerminalStatusEnable:(BOOL)status;

/// Admin Login
- (SRFID_RESULT) adminLogin:(int)readerID password:(NSString*)password aStatusMessage:(NSString**)statusMessage;
- (SRFID_RESULT) changePassword:(int)readerID oldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword andreEnterPassword:(NSString*)reEnterPassword aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)unprotectTag:(NSString*)tagID
                   withTagData:(srfidTagData **)tagData
                withPassword:(NSString*)password
              aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)protectTag:(NSString*)tagID withTagData:(srfidTagData **)tagData   withPassword:(NSString*)password  aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)enableVisibilityTag:(NSString*)password
                     aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)disableVisibilityTag:(NSString*)password
                      aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)enableTagFocus:(BOOL)enableTagFocus
                aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)setSingulationConfigurationTagFoucus: (srfidSingulationConfig*)singulationConfiguration status:(NSString **)statusMessage;
- (SRFID_RESULT)deleteAllPrefilter:(NSString**)statusMessage;
-(SRFID_RESULT)enableTagQuiet:(BOOL)status meesage:(NSString**)statusMessage;
-(SRFID_RESULT)setPreFilterForTagQuiet:(NSMutableArray *)prefilters status:(NSString **)statusMessage;

- (void)srfidSetReaderDefaultConfiguration;
@end
