/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ActiveReader.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface zt_ActiveReader : NSObject

- (void)setIsActive:(BOOL)isActive withID:(NSNumber *)identiefier;
- (BOOL)isActive;
- (int)getReaderID;
- (void)setBatchModeStatus:(BOOL)status;
- (BOOL)getBatchModeStatus;
- (void)setBatchModeRepeat:(BOOL)status;
- (BOOL)getBatchModeRepeat;

@end
