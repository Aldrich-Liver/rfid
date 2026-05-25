//
//  HelpViewController.h
//  RFIDDemoApp
//
//  Created by Symbol on 31/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Added new helpview to describe how to pair and unpair the readers manually.
@interface zt_HelpViewController : UIViewController
{
    IBOutlet UILabel * lable_help_description;
}
@end

