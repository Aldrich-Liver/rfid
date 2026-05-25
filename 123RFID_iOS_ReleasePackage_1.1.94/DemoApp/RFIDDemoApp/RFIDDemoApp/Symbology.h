//
//  Symbology.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-10-25.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Symbology : NSObject{
    NSString *symbologyName;
    int rmdAttributeID;
    BOOL enabled;
    BOOL supported;
}

- (id)init:(NSString*)name aRMDAttr:(int)attr_id;
- (void)dealloc;

- (int)getRMDAttributeID;
- (BOOL)isEnabled;
- (NSString*)getSymbologyName;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isSupported;
- (void)setSupported:(BOOL)supported;


@end

NS_ASSUME_NONNULL_END
