//
//  BaseImpinjTagConfigViewController.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-07-29.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#ifndef BaseImpinjTagConfigViewController_h
#define BaseImpinjTagConfigViewController_h


#endif /* BaseImpinjTagConfigViewController_h */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseImpinjTagConfigViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    BOOL inventoryRequested;
    IBOutlet UITableView *tableView;
    
}
@property (nonatomic, strong) NSArray *dataArray;

@end

NS_ASSUME_NONNULL_END
