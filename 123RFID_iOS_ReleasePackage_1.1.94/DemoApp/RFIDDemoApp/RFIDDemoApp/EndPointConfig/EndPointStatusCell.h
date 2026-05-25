//
//  EndPointStatusCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 02/05/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EndPointStatusCell : UITableViewCell
{
    
}
@property(nonnull,retain)IBOutlet UILabel * labelEPType;
@property(nonnull,retain)IBOutlet UILabel * labelEPName;
@property(nonnull,retain)IBOutlet UILabel * labelStatus;
@property(nonnull,retain)IBOutlet UILabel * labelReason;
@property(nonnull,retain)IBOutlet UILabel * labelCause;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end

NS_ASSUME_NONNULL_END
