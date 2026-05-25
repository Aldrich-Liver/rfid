//
//  BaseImpinjTagConfigViewController.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-07-29.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "BaseImpinjTagConfigViewController.h"
#import "ImpingTagProtectViewController.h"
#import "ImpinjInventoryVC.h"
#import "RFIDDemoApp-Swift.h"

@interface BaseImpinjTagConfigViewController ()

@end

@implementation BaseImpinjTagConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the data array
    self.dataArray = @[@"Tag Protect",@"Tag Focus Enable",@"Tag Focus Disable", @"Tag Quiet Inventory"];
    
    // Initialize the table view
    self->tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // Set the delegate and data source
    self->tableView.delegate = self;
    self->tableView.dataSource = self;
    
    // Register a basic UITableViewCell class
    //[self->tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell123"];
    // Load the nib file and register it with the identifier "Cell123"
      //[self->tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell123"];
    
    // Add the table view to the view hierarchy
    [self.view addSubview:self->tableView];
}

#pragma mark - UITableViewDataSource

// Number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Single section
}

// Number of rows in the section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count; // Number of items in the array
}

// Configure and return each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellID";
      
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
     cellIdentifier];
     
     if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
     }

    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

// Handle row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row with animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ImpingTagProtectViewController *impinjTagProtectVC = nil;
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    if (inventoryRequested == YES) {
        [self showWarning:@"Impinj Tag Functions are not allowed while main inventory is running"];
    }else {
        
        if(indexPath.row == 0){
            impinjTagProtectVC = (ImpingTagProtectViewController*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_TAG_PROTECT_BOARD_ID];
        
            [self.navigationController pushViewController:impinjTagProtectVC animated:YES];
            
        }
        else  if(indexPath.row == 1) {
            
            //[self enableTagFocusImpinj:YES];
            
            SRFID_RESULT result = SRFID_RESULT_FAILURE;
            NSString *status = [[NSString alloc] init];
            
            result = [[zt_RfidAppEngine sharedAppEngine]enableTagFocus:YES
                                                             aStatusMessage:&status];
            
            if (result == SRFID_RESULT_SUCCESS)
            {
                SRFID_RESULT result1 = SRFID_RESULT_FAILURE;
                NSString *status1 = [[NSString alloc] init];
                
                result1 = [[zt_RfidAppEngine sharedAppEngine]getPrefilters :&status1];
                
                if (result1 == SRFID_RESULT_SUCCESS)
                {
                    NSLog(@"SRFID_RESULT_SUCCESS");
                    
                    NSNumber *sessionIndex = @1;
                    [[NSUserDefaults standardUserDefaults] setObject:sessionIndex forKey:@"SavedSessionIndex"];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TagFocusEnabled"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }else{
                    NSLog(@"SRFID_RESULT_Fail");
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TagFocusEnabled"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                
          
                [self showWarning:@"Impinj Enable Tag Focus Success!"];
            }else{
       
                [self showWarning:@"Impinj Enable Tag Focus Fail !"];
            }
            
            
            
            
  
        }
        else  if(indexPath.row == 2) {
            
            SRFID_RESULT result = SRFID_RESULT_FAILURE;
            NSString *status = [[NSString alloc] init];
            
            result = [[zt_RfidAppEngine sharedAppEngine]enableTagFocus:NO
                                                             aStatusMessage:&status];
            
            if (result == SRFID_RESULT_SUCCESS)
            {
                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
                [local setPrefilterEnabled:0];
                [self showWarning:@"Impinj Disable Tag Focus Success!"];
            }else{
                [self showWarning:@"Impinj Disable Tag Focus Failed!"];
            }
        }
//        else  if(indexPath.row == 3) {
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TagQueitEnabled"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//         
//            NSString *status = [[NSString alloc] init];
//            SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:YES meesage:&status];
//            
//            if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
//                [self showWarning:@"Impinj Tag Queit Enabled !"];
//                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//                [local setPrefilterEnabled:1];
//                
//            }else{
//                [self showWarning:@"Impinj Tag Queit Enabled Failed !"];
//            }
//            
//            
//            
//           
//        
//        }else  if(indexPath.row == 4) {
//            
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TagQueitEnabled"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//            NSString *status = [[NSString alloc] init];
//            [[zt_RfidAppEngine sharedAppEngine]deleteAllPrefilter:&status];
//          //  [self showWarning:@"Impinj Tag Queit Disable !"];
//           
//            
//        
//            SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:NO meesage:&status];
//            
//            if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
//                [self showWarning:@"Impinj Tag Queit Disable !"];
//                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//                [local setPrefilterEnabled:0];
//                
//            }else{
//                [self showWarning:@"Impinj Tag Queit Disable !Failed !"];
//            }
//            
//            
//            
//            
//            zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//            [local setPrefilterEnabled:0];
//            
//        }
        
        else  if(indexPath.row == 3) {
            ImpinjInventoryVC *impinjInventoryVC = nil;
            impinjInventoryVC = (ImpinjInventoryVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IMPINJ_INVENTORY_BOARD_ID"];
            [self.navigationController pushViewController:impinjInventoryVC animated:YES];
                    
        }
       
    }
   
}

-(void)enableTagFocusImpinj:(BOOL)enable {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    result = [[zt_RfidAppEngine sharedAppEngine]enableTagFocus:enable
                                                     aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        if(enable){
            SRFID_RESULT result1 = SRFID_RESULT_FAILURE;
            NSString *status1 = [[NSString alloc] init];
            
            result1 = [[zt_RfidAppEngine sharedAppEngine]getPrefilters :&status1];
            
            if (result1 == SRFID_RESULT_SUCCESS)
            {
                NSLog(@"SRFID_RESULT_SUCCESS");
            }else{
                NSLog(@"SRFID_RESULT_Fail");
            }
           
        }else{
            zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
            [local setPrefilterEnabled:1];
        }
        NSLog(@"SRFID_RESULT_SUCCESS");
    }else{
        NSLog(@"SRFID_RESULT_Fail");
    }
    
    
    
}

- (void)showWarning:(NSString *)message
{
    [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];

}





@end

