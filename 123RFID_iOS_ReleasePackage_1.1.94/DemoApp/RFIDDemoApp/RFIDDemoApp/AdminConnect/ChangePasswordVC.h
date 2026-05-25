//
//  ChangePasswordVC.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 28/07/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "EnumMapper.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChangePasswordVC : UIViewController
{
    IBOutlet UITextField * oldPasswordField;
    IBOutlet UITextField * newPasswordField;
    IBOutlet UITextField * confirmPasswordField;
    
    IBOutlet UIButton * button_Submit;
    UITapGestureRecognizer *m_GestureRecognizer;
}
@end

NS_ASSUME_NONNULL_END
