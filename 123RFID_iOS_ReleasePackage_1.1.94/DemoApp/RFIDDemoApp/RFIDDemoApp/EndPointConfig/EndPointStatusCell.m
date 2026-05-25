//
//  EndPointStatusCell.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 02/05/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "EndPointStatusCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"
@implementation EndPointStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self darkModeCheck:self.traitCollection];
}

- (void)dealloc
{
    if (nil != _labelEPType) {
        [_labelEPType release];
    }
    if (nil != _labelEPName) {
        [_labelEPName release];
    }
    if (nil != _labelStatus) {
        [_labelStatus release];
    }
    if (nil != _labelReason) {
        [_labelReason release];
    }
    if (nil != _labelCause) {
        [_labelCause release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelEPType.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelEPName.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelStatus.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelReason.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelCause.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
