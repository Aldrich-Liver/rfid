//
//  PairByScanViewController.h
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2021-08-27.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN



/// Responsible for scan the barcode by using inbuilt camera
@protocol PairByScanDelegate <NSObject>

@required

- (void)didDetectReaderBarcode:(NSString *)decodeData;

@end

@interface PairByScanViewController : UIViewController {
    NSString *serialNumber;
    AVCaptureDevice *captureDevice;
}

@property (nonatomic, retain) id<PairByScanDelegate>pairByScanDelegate;

@end

NS_ASSUME_NONNULL_END
