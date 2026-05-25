//
//  ScanandPairVC.h
//  RFIDDemoApp
//
//  Created by Symbol on 23/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "BaseDpoVC.h"

/// Created the new scan and pair viewcontroller header view to declare the needed objects.
@interface zt_ScanandPairVC : UIViewController <UITableViewDelegate, UITableViewDataSource, zt_IRfidAppEngineDevListDelegate>
{
    IBOutlet UITableView * paired_list_table;
    IBOutlet UILabel * paired_readers_label;
    int m_ActiveReaderIndexValue;
    int m_ActiveReaderId;
    BOOL m_EmptyDevList;
    NSMutableArray *m_ReaderList;
    UIBarButtonItem *m_btnHelp;
}

@end

