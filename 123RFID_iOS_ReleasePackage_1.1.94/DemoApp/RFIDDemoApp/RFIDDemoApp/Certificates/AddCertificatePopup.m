//
//  AddCertificatePopup.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 26/08/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "AddCertificatePopup.h"
#import "UIColor+DarkModeExtension.h"
#import "config.h"
#import "AlertView.h"

#define ZT_VC_ADDCERT_CELL_IDX_INTERFACE              0
#define ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE              1

@interface AddCertificatePopup ()
{
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
}
@property (nonatomic) NSArray *interfaceChoices;
@property (nonatomic) NSArray *certTypeChoices;
@end

@implementation AddCertificatePopup

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [addCertificate_table release];
    
    if (nil != cellInterface)
    {
        [cellInterface release];
    }
    if (nil != cellCertType)
    {
        [cellCertType release];
    }
    
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    /* configure table view */
    [addCertificate_table registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [addCertificate_table registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    activityView = [[zt_AlertView alloc] init];
    
    [cellInterface setDelegate:self];
    [cellCertType setDelegate:self];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [addCertificate_table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    addCertificateView.layer.cornerRadius = 20;
    addCertificateView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self setupConfigurationInitial];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [addCertificate_table setDelegate:self];
    [addCertificate_table setDataSource:self];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [addCertificate_table setDelegate:nil];
    [addCertificate_table setDataSource:nil];
}
- (void)createPreconfiguredOptionCells
{
    cellInterface = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    cellCertType = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    [cellInterface setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellInterface setInfoNotice:@"Interface"];
    [cellCertType setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [cellCertType setInfoNotice:@"Certificate Type"];
}

- (void)setupConfigurationInitial
{
    heightConstraint.constant = 270;
    
    self.interfaceChoices = [[NSArray alloc] initWithObjects:@"wifi",@"mqtt",@"filestore", nil];
    [cellInterface setData:[self.interfaceChoices firstObject]];
    
    self.certTypeChoices = [[NSArray alloc] initWithObjects:@"ca_cert",@"client_cert",@"client_key", nil];
    [cellCertType setData:[self.certTypeChoices firstObject]];
}

-(void)addCertificateAPICall:(NSString*)fileName fileSize:(NSNumber*)fileSize andFilePath:(NSURL*)filePath
{
    dispatch_async(dispatch_get_main_queue(),^{
        [activityView showActivity:self.view];
    });
    int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    if ([fileSize compare:@4063] == NSOrderedDescending) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView hideActivity];
            [self showFailurePopup:@"File size exceeds maximum limit of 4063 bytes"];
        });
        
        return;
    }
    NSString * size = [NSString stringWithFormat:@"%@",fileSize];

    result = [[zt_RfidAppEngine sharedAppEngine] addCertificate:readerId fileName:fileName fileSize:size andFilePath:filePath aStatusMessage:&status];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.popupDelegate reloadTableData];
        }];
    }
    else if (result == SRFID_RESULT_RESPONSE_ERROR)
    {
        if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                });
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }
        
    }
    else
    {
        if (status != nil) {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:status];
            });
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Add certificate failed"];
            });
        }
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
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
            });
            [self dismissViewControllerAnimated:YES completion:^{
                [self.popupDelegate reloadTableData];
            }];
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
                    });
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [activityView hideActivity];
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self showFailurePopup:@"Add Certificate Failed"];
            });
        }
    }else{
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)addNewCertificates:(id)sender
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        [self openSharedFiles];
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)closeAddcertView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showFailurePopup:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (int)recalcCellIndex:(int)cell_index
{
    if (-1 == m_PickerCellIdx)
    {
        return cell_index;
    }
    else
    {
        if (cell_index < m_PickerCellIdx)
        {
            return cell_index;
        }
        else
        {
            return (cell_index + 1);
        }
    }
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 + ((m_PickerCellIdx != -1) ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        cell = m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_INTERFACE] == cell_idx)
    {
        cell = cellInterface;
    }
    else if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE] == cell_idx)
    {
        cell = cellCertType;
    }
    
    if (nil != cell)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        
        height += 1.0;
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        return m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_INTERFACE] == cell_idx)
    {
        [cellInterface darkModeCheck:self.view.traitCollection];
        return cellInterface;
    }
    else if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE] == cell_idx)
    {
        [cellCertType darkModeCheck:self.view.traitCollection];
        return cellCertType;
    }
    return nil;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    int row_to_hide = -1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int main_cell_idx = -1;
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_INTERFACE] == cell_idx)
    {
        heightConstraint.constant = 486;
        [m_cellPicker setChoices:_interfaceChoices];
        main_cell_idx = ZT_VC_ADDCERT_CELL_IDX_INTERFACE;
    }
    else if ([self recalcCellIndex:ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE] == cell_idx)
    {
        heightConstraint.constant = 486;
        [m_cellPicker setChoices:_certTypeChoices];
        main_cell_idx = ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE;
    }
    
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        
        if (-1 != row_to_hide)
        {
            heightConstraint.constant = 270;
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ((main_cell_idx + 1) != _picker_cell_idx)
        {
            m_PickerCellIdx = main_cell_idx + 1;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)option_cell getSelectedChoice];
        
        if (ZT_VC_ADDCERT_CELL_IDX_INTERFACE == (m_PickerCellIdx - 1))
        {
            NSString *value = _interfaceChoices[choice];
            [cellInterface setData:value];
        }
        else if (ZT_VC_ADDCERT_CELL_IDX_CERT_TYPE == (m_PickerCellIdx - 1))
        {
            NSString *value = _certTypeChoices[choice];
            [cellCertType setData:value];
        }
    }
}
/// To open shared files from the phone.
- (void)openSharedFiles{
    if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested] && ![[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing] && ![[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested])
    {
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[ZT_MULTI_TAGDATA_DOCUMENT_TYPE_TEXT,ZT_MULTI_TAGDATA_DOCUMENT_TYPE_DATA]
                                                                                                                    inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:documentPicker animated:YES completion:nil];
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

///MARK:- Document picker delegate
/// Tells the delegate that the user has selected a document or a destination.
/// @param controller The document picker that called this method.
/// @param url The URL of the selected document or destination.
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        // Condition called when user download the file
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [NSString stringWithFormat:@"%@_%@",[cellInterface getCellData],[cellCertType getCellData]];
        
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&error];
        NSNumber *fileSize = 0;
        if (fileAttributes) {
            // Retrieve the file size
            fileSize = fileAttributes[NSFileSize];
            NSLog(@"File size: %@", fileSize);
        } else {
            NSLog(@"Error getting file attributes: %@", error.localizedDescription);
        }
        
        if (fileData != nil && fileName != nil) {
            [self addCertificateAPICall:fileName fileSize:fileSize andFilePath:url];
        }
    }
}

/// Tells the delegate that the user canceled the document picker.
/// @param controller The document picker that called this method.
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    NSLog(@"Document picker was cancelled");
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    addCertificate_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [addCertificate_table reloadData];
}

@end
