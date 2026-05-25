//
//  CSVHelper.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-11-15.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///Export csv helper file.
@interface CSVHelper : NSObject

+(NSString *)getAllTagListAsStringForCSV:(NSArray *)list;
+(NSString *)generateFileName;
+(NSString *)tagListHeading;
+(NSString *)getTimeToString:(CGFloat) timeValue;

@end

NS_ASSUME_NONNULL_END
