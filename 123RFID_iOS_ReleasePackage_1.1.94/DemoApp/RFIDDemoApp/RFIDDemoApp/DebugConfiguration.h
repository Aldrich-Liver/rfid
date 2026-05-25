//
//  DebugConfiguration.h
//  RFIDDemoApp
//
//  Created by Vincent Daempfle on 4/27/16.
//  Copyright © 2016 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zt_DebugConfiguration : NSObject

- (void) initializeDebugConfiguration;

// Inventory Delay
//
- (BOOL)getInventoryDelayState;
- (void)setInventoryDelayState:(BOOL)option;
- (NSUInteger) getInventoryDelay;
- (void) setInventoryDelay:(NSUInteger)delay;

@end


