//
//  AdminLoginVC.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 29/07/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdminLoginVC : UIViewController
{
    IBOutlet UITextField * passwordField;
    IBOutlet UIButton * button_Login;
    IBOutlet UIButton * button_Change_pw;
    UITapGestureRecognizer *m_GestureRecognizer;
    
}
@property (nonatomic,assign) BOOL fromRootView;
@end

NS_ASSUME_NONNULL_END
