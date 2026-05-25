//
//  SavedNetworksCell.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 05/07/23.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "SavedNetworksCell.h"
#import "ui_config.h"
#import <ZebraRfidSdkFramework/RfidSdkDefs.h>
#import "UIColor+DarkModeExtension.h"

@interface SavedNetworksCell()
{
    
}

@end

/// A UITableViewCell object is a specialized type of view that manages the content of a single table row.
@implementation SavedNetworksCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self darkModeCheck:self.traitCollection];
}

- (void)dealloc
{
    if (nil != _labelTitle) {
        [_labelTitle release];
    }
    if (nil != _labelDetail) {
        [_labelDetail release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    if ([_cellType isEqualToString:@"available"]) {
        self.bgView.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    }
    _imageWifi.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
