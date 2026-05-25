//
//  UIColor+DarkModeExtension.h
//  RFIDDemoApp
//
//  Created by Adrian Danushka on 9/18/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DarkModeExtension)

+(UIColor*)getDarkModeLabelTextColor:(UITraitCollection *)traitCollection;
+(UIColor*)getDarkModeLabelTextColorForAbout:(UITraitCollection *)traitCollection;
+(UIColor*)getDarkModeLabelTextColorForRapidRead:(UITraitCollection *)traitCollection;
+(UIColor*)getDarkModeViewBackgroundColor:(UITraitCollection *)traitCollection;
+(UIColor*)getDarkModeInventoryCellBackgroundColor:(UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
