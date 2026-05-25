//
//  TriggerTableViewController.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-12-13.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface TriggerTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray *triggersConfig;
}


@property (retain, nonatomic) IBOutlet UIPickerView *upperPickerView;
@property (retain, nonatomic) IBOutlet UIPickerView *lowerPickerView;


@end

NS_ASSUME_NONNULL_END
