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
 *  Description:  AlertView.m
 *
 *  Notes:
 *
 ******************************************************************************/
#import "AlertView.h"
#import "MBProgressHUD.h"
#import "ui_config.h"
@interface zt_AlertView () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    int eventEnter;
}

@end

@implementation zt_AlertView

- (void)showAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withString:(NSString *)message
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    HUD.delegate = self;
    HUD.label.text = message;
    HUD.label.numberOfLines = 0;
    HUD.label.lineBreakMode = NSLineBreakByWordWrapping;
    HUD.square = YES;

    [HUD showAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [target performSelector:method withObject:object];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideAnimated:YES];
        });
    });
}

- (void)showDetailedAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withHeader:(NSString *)header withDetails:(NSString*)details
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    HUD.delegate = self;
    HUD.label.text = header;
    HUD.label.numberOfLines = 0;
    HUD.label.lineBreakMode = NSLineBreakByWordWrapping;
    HUD.detailsLabel.text = details;
    HUD.square = YES;

    [HUD showAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [target performSelector:method];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideAnimated:YES];
        });
    });
}

- (void)showSuccessFailure:(UIView *)targetView isSuccess:(BOOL)success {
    
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;

    HUD.delegate = self;
    if(success)
    {
        HUD.label.text = @"Success";
    }
    else
    {
        HUD.label.textColor = [UIColor redColor];
        HUD.label.numberOfLines = 0;
        HUD.label.lineBreakMode = NSLineBreakByWordWrapping;
        HUD.label.text = @"Failure";
    }
    
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
}

- (void)showSuccessFailureWithText:(UIView *)targetView isSuccess:(BOOL)success aSuccessMessage:(NSString*)success_message aFailureMessage:(NSString*)failure_message
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;

    HUD.label.numberOfLines = 0;
    HUD.label.lineBreakMode = NSLineBreakByWordWrapping;
    
    HUD.delegate = self;
    if(success)
    {
        HUD.label.text = success_message;
    }
    else
    {
        HUD.label.textColor = [UIColor redColor];
        HUD.label.text = failure_message;
    }
    
    
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
}

- (void)showWarningText:(UIView *)targetView withString:(NSString *)warning {
    
    HUD = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    // Configure for text only and offset down
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = warning;
    HUD.label.numberOfLines = 0;
    HUD.label.lineBreakMode = NSLineBreakByWordWrapping;
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    
    [HUD hideAnimated:YES afterDelay:4];
}

+ (void)showInfoMessage:(UIView *)targetView withHeader:(NSString *)header withDetails:(NSString*)details withDuration:(int)duration
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = header;
    hud.detailsLabel.text = details;
    hud.label.numberOfLines = 0;
    hud.label.lineBreakMode = NSLineBreakByWordWrapping;
    hud.detailsLabel.numberOfLines = 0;
    hud.detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;

    [hud hideAnimated:YES afterDelay:duration];
}


/// Show activity loader.
/// - Parameter targetView: Target view to show the activity.
- (void)showActivity:(UIView *)targetView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
        eventEnter = 0;
        // Change the background view style and color.
        HUD.label.text = ZT_LOADING_STRING;
        HUD.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        HUD.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
    });
}

- (void)showActivityWithDuration:(UIView *)targetView time:(double)time
{
    HUD = [MBProgressHUD showHUDAddedTo:targetView animated:YES];

    // Change the background view style and color.
    HUD.label.text = ZT_LOADING_STRING;
    HUD.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self doSomeWork];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideAnimated:YES];
        });
    });
}

- (void)doSomeWork {
    // Simulate by just waiting.
    sleep(20.);
}
/// Hide activity loader.
- (void)hideActivity
{
    eventEnter = eventEnter + 1;
    
    if (eventEnter == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideAnimated:YES];
        });
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
    [self release];
}

@end
