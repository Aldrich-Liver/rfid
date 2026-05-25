//
//  ProfilesViewController.h
//  RFIDDemoApp
//
//  Created by Symbol on 05/01/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "BaseDpoVC.h"
#import "ProfileTableViewCell.h"

/// The UIViewController class defines the shared behavior that is common to all view controllers.
@interface zt_ProfilesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * profile_table;
    NSMutableArray *m_profileDetails_list;
    BOOL expanded;
    BOOL enabled;
    BOOL inventoryRequested;
    UIBarButtonItem *btnSave;
    BOOL modalMode;
    BOOL hasAUTOMACSelected;
    NSMutableArray *dummyLinkChoices;
    NSMutableArray *dummySessions;
}
- (void)setModalMode:(BOOL)enabled;
@end

