//
//  NFCReader.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2022-03-18.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "NFCReader.h"
#import "config.h"
#import "ui_config.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import  "RfidAppEngine.h"

/// NFC read helper class.
@implementation NFCReader


/// Start NFC read session.
-(void)startNFCReading{
    if (![NFCNDEFReaderSession readingAvailable]) {
        [self showMessageBox:NFC_READ_NON_SUPPORT_MESSAGE withTitle:ZT_RFID_APP_NAME];
        return;
    }
    session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_get_main_queue() invalidateAfterFirstRead:NO];
    [session setAlertMessage:NFC_READ_MESSAGE];
    [session beginSession];
}

/// Tells you when radio-frequency polling is enabled and the reader session has become active and is scanning for tags.
/// @param session The reader session that is active.
-(void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session{
    NSLog(@"readerSessionDidBecomeActive");
}

/// Tells the delegate that the session detected NFC tags with NDEF messages.
/// @param session The reader session calling this method.
/// @param messages An array of the NDEF messages in the order they were discovered on the tag.
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    BOOL isMessageNonSupported = YES; /// Check all message supported or not.
    for(NFCNDEFMessage *message in messages){
        for(NFCNDEFPayload *record in [message records]){
            //Decode type
            NSString *typeValue = [[NSString alloc] initWithData:[record type] encoding:NSUTF8StringEncoding];
            if ([typeValue isEqualToString:NFC_TYPE_STRING]) {
                [session setAlertMessage:NFC_READ_SESSION_FOUND_NDEF];
                [session invalidateSession];
                //Decode Payload message to string
                NSString *decodedData = [[NSString alloc] initWithData:[record payload] encoding:NSASCIIStringEncoding];
                NSArray *payloadStringArrayOfComponents = [decodedData componentsSeparatedByString:NFC_MESSAGE_RFD_TITLE];
                if ([payloadStringArrayOfComponents count] > NFC_MESSAGE_PAYLOAD_INDEX_ONE) {
                    NSString *deviceName = [[NSString alloc] initWithFormat:NFC_MESSAGE_DEVICE_FORMAT,NFC_MESSAGE_RFD_TITLE,payloadStringArrayOfComponents[NFC_MESSAGE_PAYLOAD_INDEX_ONE]];
                    [self presentPicklistForBluetoothDevice:deviceName];
                    isMessageNonSupported = NO;
                }
            }
        }
        ///Display error message for non supported message payload.
        if (isMessageNonSupported) {
            [session setAlertMessage:NFC_MESSAGE_INVALID_PAYLOAD];
            [session invalidateSession];
            [self showMessageBox:NFC_MESSAGE_INVALID_PAYLOAD withTitle:ZT_RFID_APP_NAME];
        }
    }
   
}

/// Tells the delegate the reason for invalidating a reader session.
/// @param session The session that has become invalid. Your app should discard any references it has to this session.
/// @param error The error indicating the reason for invalidation of the session.
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
    NSLog(@"didInvalidateWithError");
    if ([error code] != NFCReaderSessionInvalidationErrorUserCanceled && [error code] != NFCReaderSessionInvalidationErrorFirstNDEFTagRead) {
        [self showMessageBox:[error localizedDescription] withTitle:NFC_READ_SESSION_INVALID];
    }
    session = NULL;
}


/// Displays an alert that allows the user to pair the device with a bluetooth accessory.
/// @param devName The device name
- (void) presentPicklistForBluetoothDevice : (NSString *)deviceName {
    
    
    NSPredicate *predicate = nil ;
    if ([deviceName rangeOfString:RFID40_FORMAT].location != NSNotFound) {
        
      NSLog(@"RFID40 Found");
      predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:NFC_DEVICE_NAME_PREDICATE_BEGIN_WITH_FORMAT, RFID40_FORMAT]];
        
    }
    else if ([deviceName rangeOfString:RFID90_FORMAT].location != NSNotFound) {
        
      NSLog(@"RFID90 Found");
      predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:NFC_DEVICE_NAME_PREDICATE_BEGIN_WITH_FORMAT, RFID90_FORMAT]];
        
    }else {
        NSLog(@"RFID90 or RFD40 Not Found");
       predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:NFC_DEVICE_NAME_PREDICATE_FORMAT, deviceName]];
    }
    
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:NFC_DEVICE_NAME_PREDICATE_FORMAT, deviceName];
        // Display picker
        [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:predicate completion:^(NSError *error) {
        // Get a description of the error that occurred (if an error occurred)
        NSString *errorMessage = error.localizedDescription;

        // Check if an error occurred.
        if (error != nil){
            if ([error code] != EABluetoothAccessoryPickerResultCancelled && [error code] != EABluetoothAccessoryPickerAlreadyConnected){
                // A real error occurred. Pairing could not complete.
                // Display an error message to the user
                [self showMessageBox:errorMessage withTitle:NFC_MESSAGE_TITLE_ERROR];
            }else if ([error code] == EABluetoothAccessoryPickerAlreadyConnected){
                // Error occurred-  Device is already paired!
                [self showMessageBox:errorMessage withTitle:NFC_MESSAGE_TITLE_ERROR];
                NSLog (@"Device is already paired!");
            }
        }
    }];
    
    [[zt_RfidAppEngine sharedAppEngine] setPairByScanConnectReaderName:deviceName];
}

/// Show alert message
/// @param message alert message
/// @param title alert title
- (void)showMessageBox:(NSString*)message withTitle:(NSString*)title{
    dispatch_async(dispatch_get_main_queue(),^{
       UIAlertController * alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction* okButton = [UIAlertAction
                                      actionWithTitle:OK
                                      style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action) {
                                          //Handle cancel button here
                                      }];
       [alert addAction:okButton];
       
       UIViewController * rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
       [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

@end
