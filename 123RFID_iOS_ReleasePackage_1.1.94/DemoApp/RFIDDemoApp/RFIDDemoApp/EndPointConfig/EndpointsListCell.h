//
//  EndpointsListCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 13/09/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EndpointsListCell : UITableViewCell
{
    
}
@property(nonnull,retain)IBOutlet UIButton * buttonDelete;
@property(nonnull,retain)IBOutlet UIButton * buttonEdit;
@property(nonnull,retain)IBOutlet UILabel * labelEndpointName;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end

NS_ASSUME_NONNULL_END
