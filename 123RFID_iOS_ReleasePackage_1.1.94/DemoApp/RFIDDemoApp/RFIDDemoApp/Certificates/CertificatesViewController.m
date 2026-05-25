//
//  CertificatesViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/07/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "CertificatesViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "CertificatesListCell.h"
#import "AlertView.h"
#import <ZebraRfidSdkFramework/RfidCertificatesList.h>
#import "AddCertificatePopup.h"
#define ZT_CELL_CERTIFICATES_HEIGHT         65
#define ZT_CELL_ID_CERTIFICATES            @"ID_CERTIFICATES_CELL"

@interface CertificatesViewController ()
{
    NSMutableArray *certificates_list;
    IBOutlet UIButton * buttonAddNew;
    IBOutlet UIButton * buttonRemoveAll;
    IBOutlet UILabel * label_no_certificates;
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    BOOL activeLoader;
    zt_AlertView *activityView;
}

@property (retain, nonatomic) IBOutlet UITableView * certificates_table;
@end

@implementation CertificatesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CERTIFICATES_TITLE];
    certificates_list = [[NSMutableArray alloc] init];
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    activityView = [[zt_AlertView alloc] init];
    activeLoader = NO;
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    
    [self getCertificatesListApiCall];
}


/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != self.certificates_table)
    {
        [self.certificates_table release];
    }
    if (nil != certificates_list)
    {
        [certificates_list release];
    }
  
    [super dealloc];
}

/// Get wlan profile list api call
-(void)getCertificatesListApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        if (activeLoader == NO) {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView showActivity:self.view];
            });
        }
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        NSMutableArray * certListArray = [[NSMutableArray alloc] init];
            
        result = [[zt_RfidAppEngine sharedAppEngine] getCertificatesList:readerId certificatesList:&certListArray status:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                activeLoader = NO;
                [activityView hideActivity];
            });
            if (certListArray.count != 0) {
                NSMutableArray * filesArray = [[NSMutableArray alloc] init];
                for (id item in certListArray) {
                    if ([item isKindOfClass:[srfidCertificatesList class]]) {
                        srfidCertificatesList *certificates_info = (srfidCertificatesList *)item;
                        [filesArray addObject:[certificates_info getCertName]];
                    } else {
                        NSLog(@"Unexpected object type in certificates_list: %@", [item class]);
                    }
                }
                [certificates_list removeAllObjects];
                certificates_list = [filesArray mutableCopy];
                
                if (certificates_list.count != 0) {
                    _certificates_table.hidden = false;
                    label_no_certificates.hidden = true;
                }else
                {
                    _certificates_table.hidden = true;
                    label_no_certificates.hidden = false;
                }
            }else
            {
                [certificates_list removeAllObjects];
                if (certificates_list.count != 0) {
                    _certificates_table.hidden = false;
                    label_no_certificates.hidden = true;
                }else
                {
                    _certificates_table.hidden = true;
                    label_no_certificates.hidden = false;
                }
            }
            
            [self.certificates_table reloadData];
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                activeLoader = NO;
                [activityView hideActivity];
                [self showFailurePopup:@"Get certificates list failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)addNewCertificates:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        AddCertificatePopup * addcert_popup_vc = (AddCertificatePopup*)[[UIStoryboard storyboardWithName:CERTIFICATES_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADDCERTIFICATE_POPUP_BOARD_ID];
        addcert_popup_vc.popupDelegate = self;
        [addcert_popup_vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:addcert_popup_vc
                           animated:YES
                         completion:nil];
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)removeAllCertificates:(id)sender
{
    if (certificates_list.count != 0) {
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Do you want to remove all the certificates?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeAllCertificateAPICall];
                    }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
        [confirmAlert addAction:cancel];
        [confirmAlert addAction:ok];
        [self presentViewController:confirmAlert animated:YES completion:nil];
    }else
    {
        [self showFailurePopup:@"No certificates available"];
    }
}

-(void)removeCertificateAction:(UIButton*)sender
{
    NSString * fileName = [NSString stringWithFormat:@"%@",[certificates_list objectAtIndex:sender.tag]];
    
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Do you want to remove this certificate?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeCertificateAPICall:fileName];
                }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:cancel];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}
-(void)removeCertificateAPICall:(NSString*)fileName
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
                
        result = [[zt_RfidAppEngine sharedAppEngine] removeCertificate:readerId fileName:fileName aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            if (activeLoader == NO) {
                activeLoader = YES;
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView showActivity:self.view];
                });
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.certificates_table reloadData];
                [self saveCertificate];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Remove certificate failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

-(void)removeAllCertificateAPICall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
                
        result = [[zt_RfidAppEngine sharedAppEngine] removeAllCertificate:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [certificates_list removeAllObjects];
                [self.certificates_table reloadData];
                
                if (activeLoader == NO) {
                    activeLoader = YES;
                    dispatch_async(dispatch_get_main_queue(),^{
                        [activityView showActivity:self.view];
                    });
                }
                
                [self saveCertificate];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Remove certificates failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)saveCertificates:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveCertificate:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Certificates Saved Successfully"];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Save Certificate Failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)saveCertificate
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveCertificate:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getCertificatesListApiCall];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    activeLoader = NO;
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                activeLoader = NO;
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}
#pragma mark - Event AddCertificatePopupDelegate

-(void)reloadTableData
{
    if (activeLoader == NO) {
        activeLoader = YES;
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //[self getCertificatesListApiCall];
        [self saveCertificate];
    });
    
}


-(void)showFailurePopup:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                        delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

/// Returns the number of rows (table cells) in a specified section.
/// @param tableView An object representing the table view requesting this information.
/// @param section An index number that identifies a section of the table. Table views in a plain style have a section index of zero.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return certificates_list.count;
}

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ZT_CELL_CERTIFICATES_HEIGHT;
}

/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CertificatesListCell *certificates_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_CERTIFICATES forIndexPath:indexPath];
    
    if (certificates_cell == nil)
    {
        certificates_cell = [[CertificatesListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_CERTIFICATES];
    }
    NSString * fileName = [NSString stringWithFormat:@"%@",[certificates_list objectAtIndex:indexPath.row]];
    certificates_cell.labelCertificateName.text = fileName;
    [certificates_cell.buttonRemove setTag:indexPath.row];
    [certificates_cell.buttonRemove addTarget:self
                                       action:@selector(removeCertificateAction:)
                                       forControlEvents:UIControlEventTouchUpInside];
    
    certificates_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return certificates_cell;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.certificates_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    label_no_certificates.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self.certificates_table reloadData];
}

@end
