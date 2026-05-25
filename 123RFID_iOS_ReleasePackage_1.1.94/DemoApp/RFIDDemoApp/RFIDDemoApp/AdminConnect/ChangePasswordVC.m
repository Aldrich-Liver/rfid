//
//  ChangePasswordVC.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 28/07/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "ChangePasswordVC.h"
#import "SettingsVC.h"
#define CHANGE_PASSWORD_TITLE @"Change Password"
@interface ChangePasswordVC ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
}
@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CHANGE_PASSWORD_TITLE];
    // Do any additional setup after loading the view.
   
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self oldPasswordFieldUI];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self newPasswordFieldUI];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self confirmPasswordFieldUI];
    });
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)oldPasswordFieldUI
{
    oldPasswordField.secureTextEntry = YES;
    UIButton *toggleVisibilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleVisibilityButton.frame = CGRectMake(0, 0, 30, 30); // Adjust size as needed
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_off_icon"] forState:UIControlStateNormal]; // Set initial icon (e.g., eye with a slash)
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_on_icon"] forState:UIControlStateSelected]; // Set icon for selected state (e.g., open eye)
        [toggleVisibilityButton addTarget:self action:@selector(togglePasswordVisibility:) forControlEvents:UIControlEventTouchUpInside];
        
        // Assign the button as the right view of the text field
    oldPasswordField.rightView = toggleVisibilityButton;
    oldPasswordField.rightViewMode = UITextFieldViewModeAlways;
}
- (void)newPasswordFieldUI
{
    newPasswordField.secureTextEntry = YES;
    UIButton *toggleVisibilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleVisibilityButton.frame = CGRectMake(0, 0, 30, 30); // Adjust size as needed
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_off_icon"] forState:UIControlStateNormal]; // Set initial icon (e.g., eye with a slash)
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_on_icon"] forState:UIControlStateSelected]; // Set icon for selected state (e.g., open eye)
        [toggleVisibilityButton addTarget:self action:@selector(togglePasswordVisibility:) forControlEvents:UIControlEventTouchUpInside];
        
        // Assign the button as the right view of the text field
    newPasswordField.rightView = toggleVisibilityButton;
    newPasswordField.rightViewMode = UITextFieldViewModeAlways;
}
- (void)confirmPasswordFieldUI
{
    confirmPasswordField.secureTextEntry = YES;
    UIButton *toggleVisibilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleVisibilityButton.frame = CGRectMake(0, 0, 30, 30); // Adjust size as needed
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_off_icon"] forState:UIControlStateNormal]; // Set initial icon (e.g., eye with a slash)
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_on_icon"] forState:UIControlStateSelected]; // Set icon for selected state (e.g., open eye)
        [toggleVisibilityButton addTarget:self action:@selector(togglePasswordVisibility:) forControlEvents:UIControlEventTouchUpInside];
        
        // Assign the button as the right view of the text field
    confirmPasswordField.rightView = toggleVisibilityButton;
    confirmPasswordField.rightViewMode = UITextFieldViewModeAlways;
}


- (void)togglePasswordVisibility:(UIButton *)sender {
        UITextField *passwordTextField = (UITextField *)sender.superview; // Get the parent text field
        sender.selected = !sender.selected; // Toggle the button's selected state
        passwordTextField.secureTextEntry = !sender.selected; // Toggle secureTextEntry based on button state
        
        // This ensures the cursor and visible text position are maintained after toggling secureTextEntry
        if (!passwordTextField.isSecureTextEntry) {
            UITextRange *textRange = [passwordTextField textRangeFromPosition:passwordTextField.beginningOfDocument toPosition:passwordTextField.endOfDocument];
            [passwordTextField replaceRange:textRange withText:passwordTextField.text];
        }
    }

- (IBAction)submitButtonAction:(id)sender
{
    if ([oldPasswordField.text containsString:@" "] || [newPasswordField.text containsString:@" "] || [confirmPasswordField.text containsString:@" "]) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self showFailurePopup:@"Password cannot contain empty space"];
        });
        return;
    }
    
    if ([oldPasswordField.text isEqual: @""]) {
        [self showFailurePopup:@"Old password field is empty"];
        return;
    }else if ([newPasswordField.text isEqual: @""])
    {
        [self showFailurePopup:@"New password field is empty"];
        return;
    }else if ([confirmPasswordField.text isEqual: @""])
    {
        [self showFailurePopup:@"Confirm password field is empty"];
        return;
    }
    
    oldPasswordField.text = [oldPasswordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    newPasswordField.text = [newPasswordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    confirmPasswordField.text = [confirmPasswordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] changePassword:readerId oldPassword:oldPasswordField.text andNewPassword:newPasswordField.text andreEnterPassword:confirmPasswordField.text aStatusMessage:&status];

        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showSuccessPopup:@"Password Updated Successfully"];
            });
        }else if(result == SRFID_RESULT_RESPONSE_ERROR)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
        else if(result == SRFID_RESULT_RESPONSE_TIMEOUT)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showSuccessPopup:@"Password Update Failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}
- (void)popBackToSettings
{
    NSArray *viewControllers = self.navigationController.viewControllers;
        for (UIViewController *vc in viewControllers) {
            if ([vc isKindOfClass:[zt_SettingsVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                break; // Exit the loop once found and popped
            }
        }
}
-(void)showSuccessPopup:(NSString *)message
{
    oldPasswordField.text = @"";
    newPasswordField.text = @"";
    confirmPasswordField.text = @"";
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        [self popBackToSettings];
                                                          }];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}
-(void)showFailurePopup:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    // Prevent leading spaces
//    if (range.location == 0 && [string isEqualToString:@" "]) {
//        return NO;
//    }
//
//    // Allow only one space between words
//    if ([string isEqualToString:@" "]) {
//        NSRange previousCharacterRange = NSMakeRange(range.location - 1, 1);
//        NSString *previousCharacter = [textField.text substringWithRange:previousCharacterRange];
//        if ([previousCharacter isEqualToString:@" "]) {
//            return NO;
//        }
//    }
//
//    return YES;
//}

@end
