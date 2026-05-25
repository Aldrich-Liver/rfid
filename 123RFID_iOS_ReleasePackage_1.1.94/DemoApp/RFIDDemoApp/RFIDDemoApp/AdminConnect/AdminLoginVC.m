//
//  AdminLoginVC.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 29/07/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "AdminLoginVC.h"
#import "ChangePasswordVC.h"
#import "SettingsVC.h"
#import "AlertView.h"
#define ADMIN_LOGIN_TITLE @"Admin Login"
@interface AdminLoginVC ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
}
@end

@implementation AdminLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ADMIN_LOGIN_TITLE];
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    activityView = [[zt_AlertView alloc] init];
    
    if (!self.fromRootView)
    {
        [self createCustomBack];
    }
    [self passwordFieldUI];
    
}

- (void)passwordFieldUI
{
    passwordField.secureTextEntry = YES;
    UIButton *toggleVisibilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleVisibilityButton.frame = CGRectMake(0, 0, 30, 30); // Adjust size as needed
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_off_icon"] forState:UIControlStateNormal]; // Set initial icon (e.g., eye with a slash)
        [toggleVisibilityButton setImage:[UIImage imageNamed:@"eye_on_icon"] forState:UIControlStateSelected]; // Set icon for selected state (e.g., open eye)
        [toggleVisibilityButton addTarget:self action:@selector(togglePasswordVisibility:) forControlEvents:UIControlEventTouchUpInside];
        
        // Assign the button as the right view of the text field
    passwordField.rightView = toggleVisibilityButton;
    passwordField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)createCustomBack
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];

    // Create and configure the UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_icon"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(-5, 0, 30, 30); // Adjust the frame as needed
    [customView addSubview:imageView];

    // Create and configure the UILabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(28, 0, 45, 30)]; // Adjust the frame as needed
    label.text = @"Back";
    label.font = [UIFont systemFontOfSize:18.0]; // Adjust the font size as needed
    label.textColor = [UIColor whiteColor]; // Adjust the text color as needed
    [customView addSubview:label];

    
    // Add a tap gesture recognizer to the custom view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCustomBack:)];
    [customView addGestureRecognizer:tapGestureRecognizer];
    
    // Create the UIBarButtonItem with the custom view
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    self.navigationItem.leftBarButtonItem = customBackButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)handleCustomBack:(id)sender {
    [self popBackToSettings];
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

- (IBAction)loginButtonAction:(id)sender
{
    if ([passwordField.text isEqual: @""]) {
        [self showFailurePopup:@"Password field is empty"];
        return;
    }
    
    if ([passwordField.text containsString:@" "]) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self showFailurePopup:@"Password cannot contain empty space"];
        });
        return;
    }
    
    passwordField.text = [passwordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        [activityView showActivity:self.view];
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] adminLogin:readerId password:passwordField.text aStatusMessage:&status];
        [NSThread sleepForTimeInterval:0.3];
        if (result == SRFID_RESULT_SUCCESS)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DeviceAuthorised"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            dispatch_async(dispatch_get_main_queue(),^{
                [self showSuccessPopup:@"Connection Successful"];
            });

        }else if(result == SRFID_RESULT_RESPONSE_ERROR)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DeviceAuthorised"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
        else if(result == SRFID_RESULT_RESPONSE_TIMEOUT)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DeviceAuthorised"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DeviceAuthorised"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
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
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent leading spaces
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    
    // Allow only one space between words
    if ([string isEqualToString:@" "]) {
        NSRange previousCharacterRange = NSMakeRange(range.location - 1, 1);
        NSString *previousCharacter = [textField.text substringWithRange:previousCharacterRange];
        if ([previousCharacter isEqualToString:@" "]) {
            return NO;
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            passwordField.textColor = [UIColor systemRedColor];
            textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self showFailurePopup:@"Password cannot contain empty space"];
        });
    }else
    {
        passwordField.textColor = [UIColor labelColor];
    }

    return YES;
}*/

- (IBAction)changePWButtonAction:(id)sender
{
    ChangePasswordVC *changepw_vc = nil;
    changepw_vc = (ChangePasswordVC*)[[UIStoryboard storyboardWithName:LOGIN_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:CHANGEPW_BOARD_ID];
    [self.navigationController pushViewController:changepw_vc animated:YES];
}

-(void)showSuccessPopup:(NSString *)message
{
    passwordField.text = @"";
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithString:message] message:@"" preferredStyle:UIAlertControllerStyleAlert];
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

@end
