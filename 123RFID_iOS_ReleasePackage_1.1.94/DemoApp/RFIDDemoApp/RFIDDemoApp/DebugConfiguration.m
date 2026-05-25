//
//  DebugConfiguration.m
//  RFIDDemoApp
//
//  Created by Vincent Daempfle on 4/27/16.
//  Copyright © 2016 Motorola Solutions. All rights reserved.
//

#import "DebugConfiguration.h"
#import "RfidAppEngine.h"

@interface zt_DebugConfiguration () {
    BOOL inventoryDelayState;
    NSUInteger inventoryDelayMs;
}

@end

@implementation zt_DebugConfiguration

- (void) initializeDebugConfiguration
{
    inventoryDelayState = NO;
    inventoryDelayMs = 500; //ms
}

- (BOOL)getInventoryDelayState
{
    return inventoryDelayState;
}

- (void)setInventoryDelayState:(BOOL)option
{
    if (inventoryDelayState != option)
    {
        inventoryDelayState = option;
    }
}

- (NSUInteger) getInventoryDelay
{
    return inventoryDelayMs;
}

- (void) setInventoryDelay:(NSUInteger)delay
{
    if (inventoryDelayMs != delay)
    {
        inventoryDelayMs = delay;
    }
    
}

@end
