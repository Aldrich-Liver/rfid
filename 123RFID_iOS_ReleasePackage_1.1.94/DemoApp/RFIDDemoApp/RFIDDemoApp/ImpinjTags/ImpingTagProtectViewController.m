//
//  ImpingTagProtectViewController.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-07-30.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImpingTagProtectViewController.h"
#import "config.h"
#import "ui_config.h"
#import "AsciiToHex.h"
#import "UIColor+DarkModeExtension.h"

#define CHECK_IMAGE_NAME @"check_box_48dp"
#define UN_CHECK_IMAGE_NAME @"un_check_box_48dp"


@interface ImpingTagProtectViewController()

@property (strong, nonatomic) NSArray *pickerData;

@end



@implementation ImpingTagProtectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSelected_EnableVisibilityBtn = NO;
    isSelected_DisableVisibilityBtn = NO;
    
    m_TagPasswordTxtField.delegate = self;
    m_TagPatternTxtField.delegate = self;
    
    [self setTitle:@"Impinj Tag Protect"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Initialize the data source
    self.pickerData = @[@"Protect", @"Unprotect", @"Enable Visibility", @"Disable Visibility"];
    
    // Set the delegate and data source
    self->m_PickerTagProtectMode.delegate = self;
    self->m_PickerTagProtectMode.dataSource = self;
    
    [self setTagIdToText];
    [self pickerSelectValueWhenLoadTheScreen];
    
    // Create the gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // Add the gesture to the main view
    [self.view addGestureRecognizer:tapGesture];
}



-(void)viewDidAppear:(BOOL)animated
{
    [self darkModeCheck:self.view.traitCollection];

}


- (void)dealloc {
    [m_PickerTagProtectMode release];
    [m_TagPatternTxtField release];
    [m_TagPasswordTxtField release];
    [m_BtnPerformOperation release];
    [super dealloc];
}


-(void)pickerSelectValueWhenLoadTheScreen
{
    
    NSInteger selectedRow = [m_PickerTagProtectMode selectedRowInComponent:0];
    selectedOption = self.pickerData[selectedRow];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // This check applies the validation only to m_TagPasswordTxtField
       if (textField == m_TagPasswordTxtField) {
           // Convert the replacement string to uppercase
           NSString *uppercaseString = [string uppercaseString];
           
           // Define the set of allowed uppercase hexadecimal characters.
           NSCharacterSet *hexCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
           
           // Check if all characters in the converted string are part of the hex set.
           for (int i = 0; i < [uppercaseString length]; i++) {
               unichar c = [uppercaseString characterAtIndex:i];
               if (![hexCharSet characterIsMember:c]) {
                   return NO; // Reject the change if a character is not in the set.
               }
           }

           // If validation passes, replace the text field's content with the uppercase version
           textField.text = [textField.text stringByReplacingCharactersInRange:range withString:uppercaseString];
           return NO; // Return NO because we've manually updated the text field.
       }
       
       return YES; // Allow the change for this or any other text fields.
}

#pragma mark - IBAction
- (IBAction)protectTag:(UIButton *)sender{
    
    [self tagProtectImpinjin];
    
}

//-(void)EnableVisibilityBtnChecked {
//    if ( m_TagPasswordTxtField.text.length == 8) {
//        [self enableTagVisibilityApi];
//        
//       
//    }
//    else
//    {
//         [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"The password length should be 8 characters.."];
//    }
//}
//
//-(void)DisableVisibilityBtnChecked
//{
//    if ( m_TagPasswordTxtField.text.length == 8) {
//        
//        [self disableTagVisibilityApi];
//        
//    }
//    else
//    {
//        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"The password length should be 8 characters.."];
//    }
//    
//}

#pragma mark - UIPickerViewDataSource

// Number of components (columns) in the picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // Assuming a single column picker
}

// Number of rows in each component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

// Title for each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

// Optional: Handle selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedOption = self.pickerData[row];
    NSLog(@"Selected: %@", selectedOption);
    // Perform actions based on the selected option
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];


}


/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}
-(void)setTagIdToText{
    NSString * tagID;
    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
    {
        tagID = [AsciiToHex stringFromAsciiString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess]];
    }
    else
    {
        tagID = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess];
    }
    
    m_TagPatternTxtField.text = tagID;
    
}


#pragma mark - API call

-(void)enableTagVisibilityApi {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    NSString * pin = m_TagPasswordTxtField.text;
    
    result = [[zt_RfidAppEngine sharedAppEngine]enableVisibilityTag:pin
                                                     aStatusMessage:&status];
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success enable visibility"];
        zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        [local setPrefilterEnabled:1];
        //[self setLoadingImageForTagVisibilty:YES];

    }
    else
    {
       
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed enable visibility"];
        //[self setLoadingImageForTagVisibilty:NO];

    }
}
    
//-(void)setLoadingImageForTagVisibilty:(BOOL)enable {
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    if (enable) {
//        [defaults setBool:YES forKey:@"enableVisibilty"];
//        [defaults setBool:NO forKey:@"disableVisibilty"];
//    }else{
//        [defaults setBool:NO forKey:@"enableVisibilty"];
//    }
//   
//    [defaults synchronize];
//
//}
//
//-(void)setLoadingImageForTagDisableVisibilty:(BOOL)disable {
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    if (disable) {
//        [defaults setBool:YES forKey:@"disableVisibilty"];
//        [defaults setBool:NO forKey:@"enableVisibilty"];
//    }else{
//        [defaults setBool:NO forKey:@"disableVisibilty"];
//    }
//    [defaults synchronize];
//
//}

-(void)disableTagVisibilityApi {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    NSString * pin = m_TagPasswordTxtField.text;
    
    result = [[zt_RfidAppEngine sharedAppEngine]disableVisibilityTag:pin
                                                      aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success disable visibility"];
        zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        [local setPrefilterEnabled:0];
      

    }
    else
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed disable visibility"];
        //[self setLoadingImageForTagDisableVisibilty:NO];

    }
}
-(void)protecTagApi {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    srfidTagData *tagDataObjectTest = [[srfidTagData alloc] init];
    
    NSString * pin = m_TagPasswordTxtField.text;
    
    result = [[zt_RfidAppEngine sharedAppEngine]protectTag:m_TagPatternTxtField.text withTagData:&tagDataObjectTest withPassword:pin aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success Protect Tag"];
    }
    else
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed Protect Tag"];
    }
}

-(void)unprotecTagApi {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    srfidTagData *tagDataObjectTest = [[srfidTagData alloc] init];
    
    NSString * pin = m_TagPasswordTxtField.text;
    
    result = [[zt_RfidAppEngine sharedAppEngine]
              unprotectTag:m_TagPatternTxtField.text withTagData:&tagDataObjectTest withPassword:pin aStatusMessage:&status];
    
    
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success  UnProtect Tag"];
    }
    else
    {
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed  UnProtect Tag"];
    }
}




// tag protect
-(void)tagProtectImpinjin {
    
    if (m_TagPatternTxtField.text.length != 0 &&  m_TagPasswordTxtField.text.length == 8)
    {
        if ([selectedOption isEqualToString:@"Protect"])
        {
            [self protecTagApi];
        }
        else if ([selectedOption isEqualToString:@"Unprotect"])
        {
            [self unprotecTagApi];
        }
        else if ([selectedOption isEqualToString:@"Enable Visibility"])
        {
            [self enableTagVisibilityApi];
        }
        else if ([selectedOption isEqualToString:@"Disable Visibility"])
        {
            [self disableTagVisibilityApi];
        }
    }
    else
    {
        [self textFiledValidation];
    }
    
    
    
}


#pragma mark - Alert
/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:messgae
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:OK
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        //Handle ok action
    }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - TextField Should Return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Dismiss the keyboard
    [textField resignFirstResponder];
    
    if (m_TagPasswordTxtField.text.length == 0) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password cannot be empty."];
        return NO;
    }
    if (m_TagPasswordTxtField.text.length < 6) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password is too short.");
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password is too short."];
        // Prevent the user from proceeding if necessary
        return NO;
    }
    
    if (m_TagPatternTxtField.text.length == 0) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Tag id cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Tag id cannot be empty."];
        return NO;
    }
    
    return YES;
}

-(void)textFiledValidation{
    
    
    if (m_TagPatternTxtField.text.length == 0) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Tag id cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Tag id cannot be empty."];
        
    }
    
    if (m_TagPasswordTxtField.text.length == 0) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password cannot be empty."];
        
    }
    if (m_TagPasswordTxtField.text.length  != 8) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password is too short.");
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"The password length should be 8 characters.."];
        
    }

}

@end
