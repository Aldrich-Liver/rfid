//
//  FactoryResetViewController.h
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2022-04-27.
//  Copyright © 2022 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

/// Responsible for Reset and reboot the device
@interface FactoryResetViewController : UIViewController
{
    IBOutlet UIButton *buttonResetReboot;
    IBOutlet UIButton *radioButtonReset;
    IBOutlet UIButton *radioButtonReboot;
    
    IBOutlet UIImageView *imgesetReboot;
    IBOutlet UIImageView *imageReset;
    

    IBOutlet UILabel *labelTitle;
    IBOutlet UILabel *labelDescription;
    IBOutlet UILabel *labelFactoryReset;
    IBOutlet UILabel *labelReboot;
    IBOutlet UIView *viewRebootFactoryResetPopup;
    IBOutlet UILabel *labelRebootPopup;
    
    UIImage *selectedImage;
    UIImage *unselectedImage;
    zt_ActiveReader *activeReader;
}

@end

NS_ASSUME_NONNULL_END
