//
//  WIFIStatusTableViewCell.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 01/06/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "WIFIStatusTableViewCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"
@implementation WIFIStatusTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self darkModeCheck:self.traitCollection];
}

- (void)dealloc
{
    if (nil != _labelKey) {
        [_labelKey release];
    }
    if (nil != _labelValue) {
        [_labelValue release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{

}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}


@end
