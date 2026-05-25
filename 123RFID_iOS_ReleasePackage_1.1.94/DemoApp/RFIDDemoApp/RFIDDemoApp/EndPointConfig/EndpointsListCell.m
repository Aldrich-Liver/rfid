//
//  EndpointsListCell.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 13/09/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "EndpointsListCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"
@implementation EndpointsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self darkModeCheck:self.traitCollection];
    [_buttonDelete setTitle:@"" forState:UIControlStateNormal];
    [_buttonEdit setTitle:@"" forState:UIControlStateNormal];
}

- (void)dealloc
{
    if (nil != _buttonDelete) {
        [_buttonDelete release];
    }
    if (nil != _buttonEdit) {
        [_buttonEdit release];
    }
    if (nil != _labelEndpointName) {
        [_labelEndpointName release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _buttonDelete.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _buttonEdit.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    _labelEndpointName.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
