/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ReaderListVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "BaseDpoVC.h"
#import "PairByScanViewController.h"

@interface zt_ReaderListVC : BaseDpoVC <UITableViewDataSource, UITableViewDelegate, zt_IRfidAppEngineDevListDelegate,PairByScanDelegate>
{
    /* TBD: m_ReaderList SHALL containt smth like DcsScannerInfo objects;
     thus active reader idx shall be removed as DcsScannerInfo contains
     information about active/available status */
    NSMutableArray *m_ReaderList;
    int m_ActiveReaderIdx;
    int m_ActiveReaderId;
    
    IBOutlet UITableView *m_tblReaderList;
    UIBarButtonItem *m_btnScanandPair;
    UIBarButtonItem *nfcScanPair;
    BOOL m_EmptyDevList;
}

@end
