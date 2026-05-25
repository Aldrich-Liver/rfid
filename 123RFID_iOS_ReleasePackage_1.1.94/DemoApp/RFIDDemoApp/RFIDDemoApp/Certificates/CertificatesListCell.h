//
//  CertificatesListCell.h
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/07/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CertificatesListCell : UITableViewCell
{
    
}
@property(nonnull,retain)IBOutlet UIButton * buttonRemove;
@property(nonnull,retain)IBOutlet UILabel * labelCertificateName;
- (void)darkModeCheck:(UITraitCollection *)traitCollection;
@end

NS_ASSUME_NONNULL_END
