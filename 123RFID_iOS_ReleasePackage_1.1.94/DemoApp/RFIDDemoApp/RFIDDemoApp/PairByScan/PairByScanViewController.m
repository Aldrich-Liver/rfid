//
//  PairByScanViewController.m
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-08-27.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//


#import "PairByScanViewController.h"
#import <AVFoundation/AVFoundation.h>

#define VERBOSE             1
#define ST_CODE_128         0x03
#define BUTTON_TITLE_CLOSE @"Close"
#define EMPTY_VALUE @""
#define MULTIPLIER_FOR_CLOSE_BUTTON 1
#define RIGHT_BUTTON_SPACE 0
#define TOP_BUTTON_SPACE 2
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 80

#define QUEUE "com.zebra.RFIDDemoApp.avCaptureQueue"
#define SYSTEM_SOUND_ID 1204
#define PINCH_ZOOM_FACTOR 2.0
#define VIDEO_ZOOM_FACTOR 1.0



/// Responsible for scan the barcode by using inbuilt camera
@interface PairByScanViewController() <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *session;
}

@property (nonatomic, strong) NSString *decodeData;
@end

@implementation PairByScanViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    self.decodeData = EMPTY_VALUE;
    
    
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If YES, the view was added to the window using an animation.
-(void)viewDidAppear:(BOOL)animated{
    
    [self createCloseButton];
    
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If YES, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self startScanningBarcode];
}

/// Cancel the camera view
- (void)cancelCameraView
{
    [session stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/// Create close button
-(void)createCloseButton {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self
               action:@selector(cancelCameraView)
     forControlEvents:UIControlEventTouchUpInside];
    cancelButton.translatesAutoresizingMaskIntoConstraints = false;
    [cancelButton setTitle:BUTTON_TITLE_CLOSE forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:MULTIPLIER_FOR_CLOSE_BUTTON constant:RIGHT_BUTTON_SPACE];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:MULTIPLIER_FOR_CLOSE_BUTTON constant:TOP_BUTTON_SPACE];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:MULTIPLIER_FOR_CLOSE_BUTTON constant:BUTTON_HEIGHT];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:MULTIPLIER_FOR_CLOSE_BUTTON constant:BUTTON_WIDTH];

    [self.view addConstraints:@[right, top]];
    [cancelButton addConstraints:@[height, width]];

}

/// Start  the scaning barcode
- (void) startScanningBarcode {
    
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error ;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:captureMetadataOutput];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(QUEUE, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeCode128Code]];
    
    if ( nil != captureDevice )
    {
        // Capture device must be locked to change settings
        if ( [captureDevice lockForConfiguration:nil] )
        {
            if ( [captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] )
            {
                captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            if ( [captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] )
            {
                captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            if ( [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] )
            {
                captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            [captureDevice unlockForConfiguration];
        }
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    [session startRunning];
    
    [self enableTheZoomingCapabilityOnCameraView];
    
}

#pragma mark CameraViewZooming

/// Enable the zooming capability on camera view
-(void)enableTheZoomingCapabilityOnCameraView {
    UIPinchGestureRecognizer *pinchForZoom = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    [self.view addGestureRecognizer:pinchForZoom];
}


/// Handle the pinch to zoom recognizer in cameraview
/// @param pinchRecognizer A discrete gesture recognizer that interprets pinching gestures involving two touches.
-(void) handlePinchToZoomRecognizer:(UIPinchGestureRecognizer*)pinchRecognizer {
   
    const CGFloat pinchZoomScaleFactor = PINCH_ZOOM_FACTOR;

    if (pinchRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
        NSError *error = nil;
        if ([captureDevice lockForConfiguration:&error])
        {
            captureDevice.videoZoomFactor = VIDEO_ZOOM_FACTOR + pinchRecognizer.scale * pinchZoomScaleFactor;
            [captureDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"error: %@", error);
        }
    }
}

#pragma mark CameraCaptureDelegate

/// Informs the delegate that the capture output object emitted new metadata objects.
/// @param captureOutput The AVCaptureMetadataOutput object that captured and emitted the metadata objects
/// @param metadataObjects An array of AVMetadataObject instances representing the newly emitted metadata. Because AVMetadataObject is an abstract class, the objects in this array are always instances of a concrete subclass.
/// @param connection The capture connection through which the objects were emitted.
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataMachineReadableCodeObject = [metadataObjects objectAtIndex:0];
        if ([[metadataMachineReadableCodeObject type] isEqualToString:AVMetadataObjectTypeCode128Code]) {
            
            if  (!([self.decodeData isEqual:[metadataMachineReadableCodeObject stringValue]])){
                NSLog (@"Decode Data:%@",[metadataMachineReadableCodeObject stringValue]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    AudioServicesPlaySystemSound(SYSTEM_SOUND_ID);
                    self.decodeData = [metadataMachineReadableCodeObject stringValue];
                    if ([self.pairByScanDelegate respondsToSelector:@selector(didDetectReaderBarcode:)]) {
                        
                        [self performSelector:@selector(processDecode:) withObject:self.decodeData afterDelay:0.0];
                        
                    }
                });
              
            }
            
        }
    }
}

/// Process decode data
/// @param decodeData decode data
- (void) processDecode : (NSString *) decodeData {
 
    [self.pairByScanDelegate didDetectReaderBarcode:decodeData];
    [self dismissViewControllerAnimated:NO completion:^ {[self.pairByScanDelegate didDetectReaderBarcode:decodeData];}];

}

@end
