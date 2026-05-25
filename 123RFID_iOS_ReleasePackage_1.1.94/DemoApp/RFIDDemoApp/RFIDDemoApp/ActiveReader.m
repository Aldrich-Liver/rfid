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
 *  Description:  ActiveReader.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveReader.h"

@interface zt_ActiveReader()

@property (nonatomic) BOOL isActiveStatus;
@property (nonatomic) int readerID;
@property (nonatomic) BOOL batchEventStatus;
@property(nonatomic)BOOL batchEventRepeat;

@end

@implementation zt_ActiveReader

- (void)setIsActive:(BOOL)isActive withID:(NSNumber *)identiefier
{
    @synchronized(self)
    {
        _isActiveStatus = isActive;
        _readerID = [identiefier intValue];
    }
}

-(BOOL)isActive
{
    @synchronized(self)
    {
        return _isActiveStatus;
    }
}

-(int)getReaderID
{
    @synchronized(self)
    {
        return _readerID;
    }
}

- (void) setBatchModeStatus:(BOOL)status
{
    @synchronized(self)
    {
        _batchEventStatus = status;
    }
}

- (BOOL) getBatchModeStatus
{
    @synchronized(self)
    {
        return _batchEventStatus;
    }
}

- (void)setBatchModeRepeat:(BOOL)status{
    @synchronized(self)
    {
        _batchEventRepeat = status;
    }
}
- (BOOL)getBatchModeRepeat{
    @synchronized(self)
    {
        return _batchEventRepeat;
    }
}

@end
