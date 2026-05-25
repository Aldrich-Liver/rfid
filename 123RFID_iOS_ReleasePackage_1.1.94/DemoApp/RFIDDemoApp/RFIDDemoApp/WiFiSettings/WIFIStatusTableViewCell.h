//
//  WIFIStatusTableViewCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 01/06/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIFIStatusTableViewCell : UITableViewCell
@property(nonnull,retain)IBOutlet UILabel *labelKey;
@property(nonnull,retain)IBOutlet UILabel *labelValue;
@end

NS_ASSUME_NONNULL_END
