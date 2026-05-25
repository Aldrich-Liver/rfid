//
//  ConnectedNetworkCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 27/03/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectedNetworkCell : UITableViewCell
@property(nonnull,retain)IBOutlet UILabel *labelTitle;
@property(nonnull,retain)IBOutlet UILabel *labelDetail;
@property(nonnull,retain)IBOutlet UIImageView *imageWifi;
@property(nonnull,retain)IBOutlet UIImageView *lockIcon;
@property(nonnull,retain)IBOutlet UIButton *moreOption;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end

NS_ASSUME_NONNULL_END
