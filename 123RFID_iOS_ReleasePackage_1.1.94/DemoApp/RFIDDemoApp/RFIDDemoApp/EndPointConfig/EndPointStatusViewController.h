//
//  EndPointStatusViewController.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/04/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
NS_ASSUME_NONNULL_BEGIN

@interface EndPointStatusViewController : UIViewController<zt_IRfidAppEngineIOTStatusEventDelegate>
{
    IBOutlet UILabel * endPointStatus_label;
}
@property (retain, nonatomic) IBOutlet UITableView * endPointStatus_table;
@end

NS_ASSUME_NONNULL_END
