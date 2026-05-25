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
 *  Description:  AboutVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"

@interface zt_AboutVC : UIViewController <zt_IRfidAppEngineDevListDelegate>
{
    
    IBOutlet UILabel *m_lblOrganization;
    IBOutlet UILabel *m_lblApplicationCaption;
    IBOutlet UILabel *m_lblApplicationVersionNotice;
    IBOutlet UILabel *m_lblApplicationVersionData;
    IBOutlet UILabel *m_lblCopyright;
    IBOutlet UILabel *lableSdkVersionTitle;
    IBOutlet UILabel *lableSdkVersionNumber;
    IBOutlet UILabel *lableBarcodeSdkVersionTitle;
    IBOutlet UILabel *lableBarcodeSdkVersionNumber;

}

- (void)configureAppearance;

@end
