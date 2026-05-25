//
//  ImpingTagProtectViewController.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-07-30.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#ifndef ImpingTagProtectViewController_h
#define ImpingTagProtectViewController_h


#endif /* ImpingTagProtectViewController_h */

#import <UIKit/UIKit.h>
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "LabelInputFieldCellView.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "SwitchCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImpingTagProtectViewController :UIViewController <UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource>
{
    IBOutlet UIPickerView *m_PickerTagProtectMode;
    IBOutlet UITextField *m_TagPatternTxtField;
    
    IBOutlet UITextField *m_TagPasswordTxtField;
    
    IBOutlet UIButton *m_BtnPerformOperation;
    NSString *selectedOption ;
    BOOL isSelected_EnableVisibilityBtn;
    BOOL isSelected_DisableVisibilityBtn;
    
    
}

@end

NS_ASSUME_NONNULL_END
