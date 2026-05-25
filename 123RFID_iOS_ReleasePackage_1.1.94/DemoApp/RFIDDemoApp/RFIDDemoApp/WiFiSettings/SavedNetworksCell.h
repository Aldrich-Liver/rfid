//
//  SavedNetworksCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 05/07/23.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SavedNetworksCell : UITableViewCell
{
    
}
@property(nonatomic,retain)NSString * cellType;
@property(nonnull,retain)IBOutlet UILabel *labelTitle;
@property(nonnull,retain)IBOutlet UILabel *labelDetail;
@property(nonnull,retain)IBOutlet UIImageView *imageWifi;
@property(nonnull,retain)IBOutlet UIImageView *lockIcon;
@property(nonnull,retain)IBOutlet UIView *bgView;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
