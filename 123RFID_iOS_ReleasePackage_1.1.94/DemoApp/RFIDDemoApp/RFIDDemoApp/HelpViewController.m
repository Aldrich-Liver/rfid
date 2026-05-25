//
//  HelpViewController.m
//  RFIDDemoApp
//
//  Created by Symbol on 31/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "HelpViewController.h"
#import "ui_config.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"
@interface zt_HelpViewController ()

@end

/// Added new helpview to describe how to pair and unpair the readers manually.
@implementation zt_HelpViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:HELP_TITLE];
    [lable_help_description setText:HELP_DESCRIPTION_TITLE];
}


@end
