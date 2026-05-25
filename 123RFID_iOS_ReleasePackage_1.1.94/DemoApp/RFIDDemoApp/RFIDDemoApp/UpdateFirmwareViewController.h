//
//  UpdateFirmwareViewController.h
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-14.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ui_config.h"
#import "ScannerEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpdateFirmwareViewController : UIViewController<UITextViewDelegate,ScannerAppEngineFirmwareUpdateEventsDelegate> {
    /// Firmware details view
    IBOutlet UILabel *headerLabel;
    IBOutlet UILabel *firmwareNameLabel;
    IBOutlet UILabel *releasedDateLabel;
    IBOutlet UITextView *releaseNotesTextView;
    IBOutlet UIButton *updateButton;
    IBOutlet UILabel *releaseNotesLabel;
    IBOutlet UIView *releaseNotesSuperView;
    IBOutlet UIImageView *scannerImage;
    IBOutlet UIScrollView *superScrollView;
    
    ///Plugins mismatch view
    IBOutlet UIButton *pluginMismatchButton;
    IBOutlet UIView *pluginMismatchView;
    IBOutlet UILabel *pluginMismatchLabel;
    IBOutlet UITextView *pluginsMismatchTextView;
    
    ///Firmware help view
    IBOutlet UIView *helpView;
    IBOutlet UITextView *helpTextView;
    IBOutlet UIButton *helpViewCloseButton;
    
    ///Content
    IBOutlet UIView *contentView;
    
    /// Firmware update
    NSString *selectedFirmwareFilePath;
    ZT_INFO_UPDATE_FIRMWARE commandType;
    NSString *modelNumber;
    NSString *firmwareVersion;
    IBOutlet UIButton *closePopup;
    BOOL fromSuccess;
    BOOL authorisationRequired;
    BOOL deviceAuthorised;
    
    /// Firmware update progres process
    BOOL firmwareUpdateDidAbort;
    BOOL firmwareUpdateDidStop;
    float progressCurrent;
    IBOutlet UIView *progressView;
    IBOutlet UILabel *firmwareProgressLabel;
    UIView *temporaryView;
    IBOutlet UILabel *progressValueLabel;
    IBOutlet UIProgressView *progressBarView;
    UIAlertController *cancelAlert;
    IBOutlet UIButton *cancelFirmwareUpdateButton;
    
    /// Activity indicator
    UIActivityIndicatorView *spinner;
    BOOL inventoryRequested;
}

/// Actions
- (IBAction)updateFirmwareButtonAction:(id)sender;
- (IBAction)pluginMisMatchOkClicked:(id)sender;
- (IBAction)closeHelpView:(id)sender;
- (void)setupCloseButton:(BOOL)isFromSuccess;

///Constraints
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *deviceImageViewHeightConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *updateButtonHeightConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *firmwareDetailsViewHeightConstraint;
- (IBAction)closePopupAction:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *helpViewHeightConstraint;

@end
   

NS_ASSUME_NONNULL_END
