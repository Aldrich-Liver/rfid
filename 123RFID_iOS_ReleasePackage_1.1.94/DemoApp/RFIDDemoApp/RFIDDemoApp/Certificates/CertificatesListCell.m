//
//  CertificatesListCell.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/07/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "CertificatesListCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"
@implementation CertificatesListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self darkModeCheck:self.traitCollection];
}

- (void)dealloc
{
    if (nil != _buttonRemove) {
        [_buttonRemove release];
    }
    if (nil != _labelCertificateName) {
        [_labelCertificateName release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _buttonRemove.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelCertificateName.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
