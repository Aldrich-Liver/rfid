//
//  DebugVC.h
//  RFIDDemoApp
//
//  Created by Vincent Daempfle on 4/27/16.
//  Copyright © 2016 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectionTableVC.h"
#import "SwitchCellView.h"
#import "LabelInputFieldCellView.h"

@interface zt_DebugVC : UIViewController <UITableViewDataSource, UITableViewDelegate,zt_IOptionCellDelegate>
{
    UITapGestureRecognizer *m_GestureRecognizer;
    
    IBOutlet UITableView *m_tblOptions;
    
    zt_SwitchCellView *m_cellInventoryDelay;
    zt_LabelInputFieldCellView *m_cellInventoryDelayMs;
    
}

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;

@end
