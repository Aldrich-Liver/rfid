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
 *  Description:  ReaderListVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ReaderListVC.h"
#import "ui_config.h"
#import "RfidAppKeys.h"
#import "AppConfiguration.h"
#import "RFIDDeviceCellView.h"
#import "BaseDpoVC.h"
#import "ScanandPairVC.h"
#import "PairByScanViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <AVFoundation/AVFoundation.h>
#import "NFC/NFCReader.h"
#import "UIViewController+ZT_ResponseHandler.h"
#import "ScannerEngine.h"


#define ZT_CELL_ID_NO_READER                      @"NO_READER"
#define ZT_CELL_ID_READER_INFO_NOT_CONNECTED      @"ID_CELL_READER_INFO_NOT_CONNECTED"
#define ZT_CELL_ID_READER_INFO_CONNECTED          @"ID_CELL_READER_INFO_CONNECTED"
#define ZT_CELL_ID_READER_INFO_BATCH              @"ID_CELL_READER_INFO_BATCH"
#define MESSAGE_OK @"OK"
#define MESSAGE_TITLE @"Error"
#define RFID8500_FORMAT @"RFD8500%@"
#define RFID4031_FORMAT @"RFD4031%@"
#define PREDICATE_FORMAT @"SELF like %@"


#define ZT_CELL_HEIGHT_NO_READER                  50
#define ZT_CELL_HEIGHT_NOT_CONNECTED              50
#define ZT_CELL_HEIGHT_CONNECTED                  90
#define ZT_CELL_HEIGHT_BATCH                      70

#define EMPTY_VALUE @""
#define PAIR_BY_SCAN_STORY_BOARD_NAME @"PairByScan"
#define STORY_BOARD_ID @"ID_PAIR_BY_SCAN_VIEW_CONTROLLER"

#define MESSAGE @"Message"
#define CAMERA_PERMISSION_MESSAGE @"123RFID Mobile app doesn't have permission to use camera, please change privacy settings. (Settings->Privacy->Camera)"
#define CANCEL @"Cancel"
#define OK @"OK"

typedef enum {
    
    READER_LIST_ITEM_NO_READER = 0,
    READER_LIST_ITEM_NOT_CONNECTED,
    READER_LIST_ITEM_CONNECTED,
    READER_LIST_ITEM_BATCH,
    READER_LIST_ITEM_TOTAL_STATES

} READER_LIST_ITEM_STATE;

@interface zt_ReaderListVC ()

@property (retain, nonatomic) IBOutlet UIButton *locateReaderButton;
@property (retain, nonatomic) IBOutlet UIView *locatingIndicator;
@property (retain, nonatomic) IBOutlet UIView *locatingHeader;
@property (retain, nonatomic) CABasicAnimation *pulsateAnimation;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *heightContraint;
@end

@implementation zt_ReaderListVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ReaderList = [[NSMutableArray alloc] init];
        m_btnScanandPair = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(barButtonScanAction)];
        [m_btnScanandPair setImage:[UIImage imageNamed:SCAN_PAIR_ICON]];
        nfcScanPair = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(barButtonNFCReadAction)];
        [nfcScanPair setImage:[UIImage imageNamed:NFC_PAIR_ICON]];
        m_ActiveReaderIdx = -1;
        m_ActiveReaderId = -1;
        m_EmptyDevList = YES;
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_ReaderList)
    {
        [m_ReaderList removeAllObjects];
        [m_ReaderList release];
    }
    
    [m_tblReaderList release];
    [_locateReaderButton release];
    [_locatingIndicator release];
    [_locatingHeader release];
    [_pulsateAnimation release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_tblReaderList setDelegate:self];
    [m_tblReaderList setDataSource:self];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblReaderList setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* setup locating indicator animation */
    self.pulsateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.pulsateAnimation.fromValue = @1.0;
    self.pulsateAnimation.toValue = @1.35;
    self.pulsateAnimation.autoreverses = YES;
    self.pulsateAnimation.duration = 0.15;
    self.pulsateAnimation.removedOnCompletion = NO;
    self.pulsateAnimation.repeatCount = HUGE_VALF;
    
    /* set title */
    [self setTitle:@"Readers List"];
    self.locatingIndicator.layer.cornerRadius = self.locatingIndicator.frame.size.height / 2.0;
    self.locatingIndicator.backgroundColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    
    self.heightContraint.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    /* just to reload data from app engine */
    
    [self deviceListHasBeenUpdated];
    
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:m_btnScanandPair];
    [right_items addObject:nfcScanPair];
    
    self.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
}

/// Notifies the view controller that its view was removed from a view hierarchy.
/// @param animated If YES, the disappearance of the view was animated.
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

/// Button action which will navigate user to Scan and Pair view controller.
- (void)barButtonScanAction
{
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
           if (granted)
           {
               // Granted access to mediaType
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self navigateToPairByScanScreen];
               });
           }
           else
           {
               //Not granted access to mediaType
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self showCameraPermission];
               });
           }
       }];

}

/// Button action pop-up NFC reader view.
- (void)barButtonNFCReadAction{
    NFCReader *nfcReader = [[NFCReader alloc] init];
    [nfcReader startNFCReading];
}

- (void) startLocatorAnimation {

    self.locatingHeader.hidden = NO;
    
    [self.locatingIndicator.layer addAnimation:self.pulsateAnimation forKey:nil];
    
}

- (void) stopLocatorAnimation {
    
    [self.locatingIndicator.layer removeAllAnimations];
    self.locatingHeader.hidden = YES;
    
}

- (void) setLocateReaderButtonState{
    if (m_ActiveReaderIdx == -1) {
        self.locateReaderButton.hidden = YES;
        self.locatingHeader.hidden = YES;
    }
    else{
        self.locateReaderButton.hidden = NO;
        if ([zt_RfidAppEngine sharedAppEngine].isLocatingDevice) {
            [self.locateReaderButton setTitle:@"STOP LOCATING" forState:UIControlStateNormal];
            [self startLocatorAnimation];
        }
        else{
            [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
            [self stopLocatorAnimation];
            [self getConnectionInterfaceStatus];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];
    [self stopLocatingReaderIfAny];
    
}
- (void)stopLocatingReaderIfAny{
    SRFID_RESULT conn_result = SRFID_RESULT_FAILURE;
    if (-1 != m_ActiveReaderId)
    {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:NO message:nil];
            self.heightContraint.constant = 0;
        }
    }

    if (conn_result == SRFID_RESULT_SUCCESS) {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            {
                [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
                [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
                [self stopLocatorAnimation];
            }
        }
    }
}

/* ###################################################################### */
/* ########## zt_IRfidAppEngineDevListDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)deviceListHasBeenUpdated
{
    /* TBD: check whether we still have reader that was active */

    if ([[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count] > 0)
    {
        /* determine actual status of previously active scanner */
        NSArray *lst = [[zt_RfidAppEngine sharedAppEngine] getActualDeviceList];
        BOOL found = NO;
        
        srfidReaderInfo *info = nil;
        for (int i = 0; i < [lst count]; i++)
        {
            info = (srfidReaderInfo*)[lst objectAtIndex:i];
            if (m_ActiveReaderId != -1)
            {
                if ([info getReaderID] == m_ActiveReaderId)
                {
                    m_ActiveReaderIdx = i;
                    found = YES;
                    break;
                }
            }
            else
            {
                if (YES == [info isActive])
                {
                    m_ActiveReaderId = [info getReaderID];
                    m_ActiveReaderIdx = i;
                    found = YES;
                    break;
                }
            }
        }
        
        if (NO == found)
        {
            m_ActiveReaderId = -1;
            m_ActiveReaderIdx = -1;
        }
    }
    
    [m_tblReaderList reloadData];
    [self setLocateReaderButtonState];
    
    return YES;
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
    int count = (int)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count];
    if (0 == count)
    {
        m_ActiveReaderIdx = -1;
        m_ActiveReaderId = -1;
        m_EmptyDevList = YES;
        count = 1;
    }
    else
    {
        m_EmptyDevList = NO;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellForIndexPath:indexPath];
}

- (zt_RFIDDeviceCellView *) getCellForIndexPath : (NSIndexPath *) indexPath
{
    BOOL isBatchEnabled = NO;
    BOOL isConnected = NO;
    
    int idx = (int)[indexPath row];
    
    NSArray * cellIdentifiers = [[NSArray alloc] initWithObjects:ZT_CELL_ID_NO_READER, ZT_CELL_ID_READER_INFO_NOT_CONNECTED, ZT_CELL_ID_READER_INFO_CONNECTED, ZT_CELL_ID_READER_INFO_BATCH, nil];
    
    READER_LIST_ITEM_STATE state = [self getReaderListItemState:idx];
    
    if (state != READER_LIST_ITEM_NO_READER)
    {
        srfidReaderInfo *info = (srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:idx];
        zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        
        if (state == READER_LIST_ITEM_CONNECTED) {
            isConnected = YES;
            [[zt_RfidAppEngine sharedAppEngine] setConnectedReaderName:[info getReaderName]];
        }
        
        if (state == READER_LIST_ITEM_BATCH) {
            isBatchEnabled = YES;
        }
        
        zt_RFIDDeviceCellView *cell = [m_tblReaderList dequeueReusableCellWithIdentifier:cellIdentifiers[state] forIndexPath:indexPath];
        
        [cell setDeviceInformation:[info getReaderName] withModel:[sled readerModel] withSerial:[sled readerSerialNumber] withBTAddress:[sled readerBTAddress] isActive:isConnected isBatch:isBatchEnabled];
        [cellIdentifiers release];
        
        return cell;
    } else {
        
        zt_RFIDDeviceCellView * cell = [m_tblReaderList dequeueReusableCellWithIdentifier:ZT_CELL_ID_NO_READER forIndexPath:indexPath];
        [cell.textLabel setText:@"NO available readers"];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
        
        [cellIdentifiers release];
        
        return cell;
    }
    
    //return cell;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self getCellHeightAtIndexPath:indexPath];
    
}

- (CGFloat) getCellHeightAtIndexPath : (NSIndexPath *) indexPath
{
    CGFloat height = 0.0;

    int idx = (int)[indexPath row];
    
    READER_LIST_ITEM_STATE state = [self getReaderListItemState:idx];
    
    switch (state) {
        case READER_LIST_ITEM_NO_READER:
            
            height = ZT_CELL_HEIGHT_NO_READER;
            break;
            
        case READER_LIST_ITEM_NOT_CONNECTED:
            height = ZT_CELL_HEIGHT_NOT_CONNECTED;
            break;
            
        case READER_LIST_ITEM_CONNECTED:
            height = ZT_CELL_HEIGHT_CONNECTED;
            break;
            
        case READER_LIST_ITEM_BATCH:
            height = ZT_CELL_HEIGHT_BATCH;
            break;
            
        default:
            break;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (NO == m_EmptyDevList)
    {
        int idx = (int)[indexPath row];
        
        NSMutableArray *index_paths = [[NSMutableArray alloc] init];
        
        if (-1 != m_ActiveReaderIdx)
        {
            [index_paths addObject:[NSIndexPath indexPathForRow:m_ActiveReaderIdx inSection:0]];
        }
        
        if (idx == m_ActiveReaderIdx)
        {
            m_ActiveReaderIdx = -1; /* emulate disconnection */
            int _id = m_ActiveReaderId;
            m_ActiveReaderId = -1;
            [[zt_RfidAppEngine sharedAppEngine] disconnect:_id];
            [[ScannerEngine sharedScannerEngine] disconnect:_id];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_BATCHMODE_ENABLED_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else
        {
            if (-1 != m_ActiveReaderId)
            {
                int _id = m_ActiveReaderId;
                m_ActiveReaderIdx = -1;
                m_ActiveReaderId = -1;
                [[zt_RfidAppEngine sharedAppEngine] disconnect:_id];
                [[ScannerEngine sharedScannerEngine] disconnect:_id];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_BATCHMODE_ENABLED_KEY];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            
            [[zt_RfidAppEngine sharedAppEngine] connect:[(srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:idx] getReaderID]];
            [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZT_ACTIVE_READER_KEY];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DeviceAuthorised"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationFade];
        
        [index_paths removeAllObjects];
        [index_paths release];
    }

}

- (IBAction)locateReaderAction:(id)sender {
    SRFID_RESULT conn_result = SRFID_RESULT_FAILURE;
    
    if (-1 != m_ActiveReaderId)
    {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"LOCATE READER"]) {
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:YES message:nil];
            self.heightContraint.constant = 30;
        }
        else if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:NO message:nil];
            self.heightContraint.constant = 0;
        }
    }

    if (conn_result == SRFID_RESULT_SUCCESS) {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"LOCATE READER"])
        {
            [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = YES;
            [self.locateReaderButton setTitle:@"STOP LOCATING" forState:UIControlStateNormal];
            [self startLocatorAnimation];
        }
        else if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            {
                [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
                [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
                [self stopLocatorAnimation];

            }
        }
    }
}

- (READER_LIST_ITEM_STATE) getReaderListItemState : (int) index
{
    READER_LIST_ITEM_STATE itemState = READER_LIST_ITEM_NOT_CONNECTED;
    
    if (m_EmptyDevList)
    {
        itemState = READER_LIST_ITEM_NO_READER;
    }
    else if (index == m_ActiveReaderIdx)
    {
        if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
        {
            // Reader connected, in batch mode
            itemState = READER_LIST_ITEM_BATCH;
        }
        else if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            // Reader connected
            itemState = READER_LIST_ITEM_CONNECTED;
            
            // Cyclecount clear defaults
            [[NSUserDefaults standardUserDefaults] setObject:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO forKey:ZT_TOTALREADS_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return itemState;
}



#pragma mark PairByScanDelegate

/// Did detect reader barcode while scan from inbuilt camera
/// @param decodeData The decode data received from camera
- (void)didDetectReaderBarcode:(NSString *)decodeData
{
    if ([decodeData isEqualToString:EMPTY_VALUE])
    {
        return;
    }
    
    NSLog(@"didDetectReaderBarcode: %@",decodeData);

    dispatch_async(dispatch_get_main_queue(), ^{
         [self presentPicklistForBluetoothDevice:decodeData];
    });
  
}


/// Get predicate value for device filter
/// @param deviceName The device name
-(NSPredicate*)getPredicateValueForDeviceFilter:(NSString*)deviceName {
    
    NSString *deviceNameRFD8500 = [[NSString alloc] initWithFormat:RFID8500_FORMAT,deviceName];
    NSString *deviceNameRFD4031 = [[NSString alloc] initWithFormat:RFID4031_FORMAT,deviceName];
    NSPredicate *predicateRFD8500 = [NSPredicate predicateWithFormat:PREDICATE_FORMAT, deviceNameRFD8500];
    NSPredicate *predicateRFD4031 = [NSPredicate predicateWithFormat:PREDICATE_FORMAT, deviceNameRFD4031];
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateRFD8500, predicateRFD4031]];

}


/// Displays an alert that allows the user to pair the device with a bluetooth accessory.
/// @param devName The device name
- (void) presentPicklistForBluetoothDevice : (NSString *)deviceName {
    
   
        // Display picker
        [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError *error) {
        // Get a description of the error that occurred (if an error occurred)
        NSString *errorMessage = error.localizedDescription;

        // Check if an error occurred.
        if (error != nil)
        {
            if ([error code] != EABluetoothAccessoryPickerResultCancelled && [error code] != EABluetoothAccessoryPickerAlreadyConnected)
            {
                // A real error occurred. Pairing could not complete.
                // Display an error message to the user
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:MESSAGE_TITLE
                                                      message:errorMessage
                                                      preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:MESSAGE_OK
                                           style:UIAlertActionStyleDefault
                                           handler:nil];

                [alertController addAction:okAction];

                [self presentViewController:alertController animated:YES completion:nil];
            }
            else if ([error code] == EABluetoothAccessoryPickerAlreadyConnected)
            {
                // Error occurred-  Device is already paired!
                NSLog (@"Device is already paired!");
            }

        }
    }];
    
    [[zt_RfidAppEngine sharedAppEngine] setPairByScanConnectReaderName:deviceName];
    
}

/// Show camera permission message
-(void)showCameraPermission {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MESSAGE message:CAMERA_PERMISSION_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            NSLog(@"Cancel");
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:NULL];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated: YES completion: nil];
    
}


/// Navigate to pair by scan screen
-(void)navigateToPairByScanScreen {
    
    PairByScanViewController * pairByScanViewController = (PairByScanViewController*)[[UIStoryboard storyboardWithName:PAIR_BY_SCAN_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:STORY_BOARD_ID];
     pairByScanViewController.pairByScanDelegate = self;
    [self presentViewController:pairByScanViewController animated:YES completion:nil];

}

-(void)getConnectionInterfaceStatus{
       SRFID_RESULT result = SRFID_RESULT_FAILURE;
     
       result = [[zt_RfidAppEngine sharedAppEngine] requestConnectedInterfaceStatus] ;
       
       if (result == SRFID_RESULT_SUCCESS)
       {
           [m_tblReaderList reloadData];
       }
}
@end
