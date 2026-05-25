//
//  UIColor+DarkModeExtension.m
//  RFIDDemoApp
//
//  Created by Adrian Danushka on 9/18/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UIColor+DarkModeExtension.h"
#import "ui_config.h"

@implementation UIColor (DarkModeExtension)

+(UIColor*)getDarkModeLabelTextColor:(UITraitCollection *)traitCollection
{
    if (@available(iOS 12.0, *)) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return UIColor.whiteColor;
        }
    }
    return UIColor.blackColor;
}

+(UIColor*)getDarkModeLabelTextColorForAbout:(UITraitCollection *)traitCollection
{
    if (@available(iOS 12.0, *)) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return UIColor.whiteColor;
        }
    }
    return UIColor.grayColor;
}

+(UIColor*)getDarkModeLabelTextColorForRapidRead:(UITraitCollection *)traitCollection
{
    if (@available(iOS 12.0, *)) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return UIColor.whiteColor;
        }
    }
    return THEME_BLUE_COLOR
}

+(UIColor*)getDarkModeViewBackgroundColor:(UITraitCollection *)traitCollection
{
    if (@available(iOS 12.0, *)) {
      if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
          return UIColor.blackColor;
      }
    }
    return UIColor.whiteColor;
}


/// Get dark mode inventory cell backgroundColor
/// @param traitCollection  The traits, such as the size class and scale factor.
+(UIColor*)getDarkModeInventoryCellBackgroundColor:(UITraitCollection *)traitCollection{
    if (@available(iOS 12.0, *)) {
      if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
          return UIColor.blackColor;
      }
    }
    return UIColor.whiteColor;
}

@end
