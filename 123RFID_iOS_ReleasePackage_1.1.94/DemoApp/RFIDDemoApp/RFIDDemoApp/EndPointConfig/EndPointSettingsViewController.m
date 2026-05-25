//
//  EndPointSettingsViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/04/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "EndPointSettingsViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "EndPointConfigViewController.h"
#import "EndPointStatusViewController.h"
@interface EndPointSettingsViewController ()

@end

@implementation EndPointSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:EP_SETTINGS_TITLE];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

/// Tells the delegate a row is selected.
/// @param tableView An object representing the table view requesting this information.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *viewController = nil;
    EndPointStatusViewController *endPointStatusVC = nil;
    EndPointConfigViewController *endPointSettingsVC = nil;
    
    switch (indexPath.row) {
           case 0:
            endPointStatusVC = (EndPointStatusViewController*)[[UIStoryboard storyboardWithName:ENDPOINT_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ENDPOINT_STATUS_BOARD_ID];
                  viewController = endPointStatusVC;
            break;
           case 1:
            endPointSettingsVC = (EndPointConfigViewController*)[[UIStoryboard storyboardWithName:ENDPOINT_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ENDPOINT_BOARD_ID];
                  viewController = endPointSettingsVC;
            break;
           default :
               NSLog(@"Invalid row" );
       }
    
        if (nil != viewController)
        {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    
   }
@end
