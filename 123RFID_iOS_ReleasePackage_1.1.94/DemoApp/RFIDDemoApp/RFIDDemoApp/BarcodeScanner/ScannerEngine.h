//
//  ScannerEngine.h
//  SampleApp iOS SP
//
//  Created by Nilusha Wimalasena on 2021-09-07.
//

#import <Foundation/Foundation.h>
#import <ZebraScannerFramework/SbtSdkFactory.h>
#import "ScannerObject.h"
#import "BarcodeList.h"


NS_ASSUME_NONNULL_BEGIN

/*
 Scanner app engine class will handle all communications with scanner SDK
 */
@class ScannerEngine;

/*
 Scanner App engin scanner events delegate protocol
 */
@protocol ScannerEngineConnectionsDelegate <NSObject>
- (BOOL)scannerHasAppeared:(int)scannerID;
- (BOOL)scannerHasDisappeared:(int)scannerID;
- (BOOL)scannerHasConnected:(int)scannerID;
- (BOOL)scannerHasDisconnected:(int)scannerID;
@end

@protocol ScannerEngineDelegate <NSObject>

-(void)barcodeDataList:(NSData*)barcodeData barcodeType:(int)barcodeType;

@end

/// Delegate for update events
@protocol ScannerAppEngineFirmwareUpdateEventsDelegate <NSObject>
- (void)updateUI:(FirmwareUpdateEvent*)event;
@end

@interface ScannerEngine : NSObject<ISbtSdkApiDelegate>{
    id <ISbtSdkApi>     sdkApi;
    NSMutableArray *scannerList;
    NSLock *scannerInfoListGuard;
    ScannerObject * conectedScannerInfoObject;
    NSMutableArray *scannerBarcodeList;
    BOOL isBarcodePageAppear;
    BarcodeData *selectedBarcodeData;
    NSMutableArray *deviceConnectionsDelegates;
    //Firmware update
    BOOL didFirmwareUpdate;
    int previousScanner;
    NSMutableArray *firmwareUpdateProgressDelegateList;
    int zebraScannerId;
    
    BOOL isScanSymbologyChanged;
    BOOL isScanBeeperChanged;

}

@property (strong,nonatomic) id<ScannerEngineDelegate> delegate;

- (void)addDeviceEventsDelegate:(id<ScannerEngineConnectionsDelegate>)delegate;
- (void)removeDeviceEventsDelegate:(id<ScannerEngineConnectionsDelegate>)delegate;

- (void)addFirmwareUpdateEventsDelegate:(id<ScannerAppEngineFirmwareUpdateEventsDelegate>)delegate;
- (void)removeFirmwareUpdateEventsDelegate:(id<ScannerAppEngineFirmwareUpdateEventsDelegate>)delegate;

-(id)init;
+(ScannerEngine *) sharedScannerEngine;
-(void)initializationSDK;
-(NSString *)getSDKVersion;
-(NSMutableArray *)getDeviceList;
-(void)connectScanner:(NSString*)scannerName;
-(SbtScannerInfo *)getConnectedScannerInfo;

-(void)disableScanner;
-(void)enableScanner;
-(void)setDelegateForScannerObject:(id)viewController;
- (NSArray*)getScannerBarcodes;
-(void)clearBarcodeData;
-(void)removeBarcodeData;
-(void)disconnect:(int)scannerId;
-(void)setBarcodePageAppear:(BOOL)appeared;
-(void)setSelectedBarcodeValue:(BarcodeData *) barcodeData;
-(BarcodeData *)getSelectedBarcodeValue;
-(void)removeSelectedBarcodeValue;
-(SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML;
-(SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString*)outXML forScanner:(int)scannerID;
-(SBT_RESULT)pullTiggerStart;
-(SBT_RESULT)releaseTiggerStart;
- (void)blinkLEDFastON;
- (void)blinkLEDFastOFF;
- (void)setPreviousScanner:(int)scannerIdStatus;
- (int)getPreviousScannerId;

- (BOOL)firmwareDidUpdate;
- (void)setFirmwareDidUpdate:(BOOL)updateStatus;
- (int)getZebraConnectedScannerID;

//Scan batch request
-(SBT_RESULT)scanBatchRequest;

// Scanner symbology settings changes
-(void)setConfigScannerSymbologySettings:(BOOL)symbology;
-(BOOL)getConfigScannerSymbologySettings;

// Scanner beeper settings changes
-(void)setConfigScannerBeeperSettings:(BOOL)beeper;
-(BOOL)getConfigScannerBeeperSettings;

- (BOOL)checkIsThisSecureFirmwareFile:(NSString*)firmwarePath;
- (BOOL)unzippedTheSecureFirmwareFile:(NSString*)password firmwarePath:(NSString*)firmwarePath;

NS_ASSUME_NONNULL_END

@end


