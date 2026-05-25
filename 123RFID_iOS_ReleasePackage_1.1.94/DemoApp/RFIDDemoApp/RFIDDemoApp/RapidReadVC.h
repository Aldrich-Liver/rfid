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
 *  Description:  RapidReadVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "AlertView.h"
#import "BaseDpoVC.h"

@interface zt_RapidReadVC : BaseDpoVC <zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener>{
    
    IBOutlet UIButton *m_buttonCycleCount;
    
    // CycleCount
    NSString * activeProfile;
    int totalTagsCountForCycleCount;
    NSMutableArray * cycleCountArray;
    IBOutlet UILabel *labelPrefilterEnabled;
    IBOutlet NSLayoutConstraint * prefilterLabelHeightConstraint;
}


- (void)updateOperationDataUI;
- (void)setUniqueTagCount:(int) count;
- (void)setTotalTagCount:(int)count;
- (void)setReadRate:(int)rate;
- (CGFloat)fontSizeToFit:(NSString*)text forLabel:(UILabel*)ui_label aMaxSize:(CGFloat)max_size;
- (void)configureAppearance;
- (IBAction)btnStartStopPressed:(id)sender;
- (void)showWarning:(NSString *)message;
- (IBAction)btnCycleCountPressed:(id)sender;

@end
