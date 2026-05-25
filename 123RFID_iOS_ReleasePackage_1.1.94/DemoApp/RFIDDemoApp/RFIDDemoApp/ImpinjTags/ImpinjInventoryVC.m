//
//  ImpinjInventoryVC.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2025-08-01.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImpinjInventoryVC.h"
#import "ImpinjCustomTableViewCell.h"
#import "UIColor+DarkModeExtension.h"
#import "RFIDDemoApp-Swift.h"

#define CHECK_IMAGE_NAME @"check_box_48dp"
#define UN_CHECK_IMAGE_NAME @"un_check_box_48dp"


@interface ImpinjInventoryVC() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSMutableArray *selectedStates;  // Track selection states for each cell

@end

@implementation ImpinjInventoryVC



- (void)dealloc {
    [m_BtnFocus release];
    [m_BtnQuite release];
    [m_BtnUnquite release];
    [m_TblImpinjInventory release];
    [m_LblTagQuietStatus release];
    [m_BtnImpinjInvStart release];
    [m_BtnClearSes release];
    
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self inventoryStop];
    [[zt_RfidAppEngine sharedAppEngine] srfidSetReaderDefaultConfiguration];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Impinj Inventory"];
    
    _currentlySelectedTagIdObjectArray = [[NSMutableArray alloc] init];
    self.selectedRows = [NSMutableArray array];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    
    
    
    m_TblImpinjInventory.delegate = self;
    m_TblImpinjInventory.dataSource = self;
    
    // Use _tagDataInventory
    //
    
    // Example data initialization
    self.tableData = @[
        @{@"tagID": @"Tag 1", @"tagReadCount": @"5", @"readCount": @"100", @"readRate": @"10"},
        @{@"tagID": @"Tag 2", @"tagReadCount": @"3", @"readCount": @"200", @"readRate": @"20"}
        // Add more dictionaries for additional cells
    ];
    
    // Initialize selected states for each cell
    self.selectedStates = [NSMutableArray arrayWithCapacity:self.tableData.count];
    for (NSUInteger i = 0; i < self.tableData.count; i++)
    {
        [self.selectedStates addObject:@(NO)];  // Initially, no cell is selected
    }
    
    [self setupInventoryObject];
    
}




-(void)setupInventoryObject {
   
    [[zt_RfidAppEngine sharedAppEngine] impingTagDataEventDelegate:self];
  
    _tagDataInventory = [[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self darkModeCheck:self.view.traitCollection];
}

- (void)clearAllSelections {
    // 1. Clear the array that stores the selected index paths.
    [self.selectedRows removeAllObjects];

    // 2. Clear the array that stores your selected tag data objects.
    [_currentlySelectedTagIdObjectArray removeAllObjects];


    NSLog(@"All selections have been cleared.");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagDataInventory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImpinjCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    NSString *tagId = [_tagDataInventory[indexPath.row] getTagId];
    NSString *tagIdString = [NSString stringWithFormat:@"%@", tagId];
    cell.textLabel.text = tagIdString;
    
    if ([self.selectedRows containsObject:indexPath]) {
            // If selected, set the background color to green
            cell.backgroundColor = [UIColor greenColor];
        } else {
            // If not selected, set it back to the default color (e.g., clear or white)
            // This is crucial for recycled cells
            cell.backgroundColor = [UIColor whiteColor]; // Or [UIColor clearColor] depending on your design
        }
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // We will manage the selection state manually
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSString *selectedTagID = [[self.tagDataInventory objectAtIndex:indexPath.row] getTagId];
        NSLog(@"Adrian Selected Tag ID: %@", selectedTagID);

        id selectedObject = [self.tagDataInventory objectAtIndex:indexPath.row];

        // If the row is already selected, deselect it
        if ([self.selectedRows containsObject:indexPath]) {
            [self.selectedRows removeObject:indexPath];
            [_currentlySelectedTagIdObjectArray removeObject:selectedObject];
        }
        // If the row is not selected, select it
        else {
            [self.selectedRows addObject:indexPath];
            [_currentlySelectedTagIdObjectArray addObject:selectedObject];
            if ([_currentlySelectedTagIdObjectArray count] > 2) {
                [_currentlySelectedTagIdObjectArray removeObject:selectedObject];
                [self showAlertMessageWithTitle:@"Alert" withMessage:@"Tag Quiet can quiet a maximum of two tags at once. After that, it only supports one tag at a time"];
            }
        }

        NSLog(@"Adrian currentlySelectedTagIdObjectArray Count: %lu", (unsigned long)[_currentlySelectedTagIdObjectArray count]);

        // Reload the row to update its appearance (to show/hide the checkmark)
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self updateTableViewAppearance];
    }
}

- (void)updateTableViewAppearance {
    for (NSIndexPath *indexPath in [m_TblImpinjInventory indexPathsForVisibleRows]) {
        ImpinjCustomTableViewCell *cell = [m_TblImpinjInventory cellForRowAtIndexPath:indexPath];
        BOOL isSelected = [self.selectedStates[indexPath.row] boolValue];
        
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            cell.backgroundColor = isSelected ? [UIColor darkGrayColor] : [UIColor blackColor];
        } else {
            cell.backgroundColor = isSelected ? [UIColor lightGrayColor] : [UIColor whiteColor];
        }
    }
}


- (void)tagSelectButtonTapped:(UIButton *)sender {
    
}

- (IBAction)tagQuietButtonPressed:(UIButton *)sender {
    m_LblTagQuietStatus.text = @"Enabled";
    [self enableTagQuiet];
}

- (IBAction)tagUnQuietButtonPressed:(UIButton *)sender {
    m_LblTagQuietStatus.text = @"Disabled";
    [self disableTagQuiet];
}


- (void)enableTagQuiet
{
    NSString *response = @"";
    //[[zt_RfidAppEngine sharedAppEngine]deleteAllPrefilter:&response];
    [[zt_RfidAppEngine sharedAppEngine]restorePrefiltersForTagQuet];
    [self setTagQuetPrilterArray];
}

-(void)setTagQuetPrilterArray {
    
    NSString * temp = @"";
    NSMutableArray *prefilterArrayForQuite = [[NSMutableArray alloc]init];
   // int reader_id = [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
 
    // Get the currently selected tags from inventory and assign those to this selected tag array
    NSMutableArray* selectedTag = _currentlySelectedTagIdObjectArray;
    NSInteger arrayCount = [selectedTag count];
 
    for (int i = 0; i < arrayCount; i++) {
        
        srfidTagData *itemTag = [selectedTag objectAtIndex:i];
        NSString * tagID = [itemTag getTagId];
        
        if([temp isEqual:tagID]){
            
        }
        else
        {
             temp = tagID;
        
            if (itemTag != nil && [itemTag getTagId] != nil) {
                // Create a new instance of tagFocusFilter for each iteration
                srfidPreFilter *tagFocusFilter = [[srfidPreFilter alloc] init];
                
                // Set properties for tagFocusFilter
                [tagFocusFilter setMaskStartPos:32];
                [tagFocusFilter setMatchLength:96];
                [tagFocusFilter setMatchPattern:tagID];
                [tagFocusFilter setMemoryBank:SRFID_MEMORYBANK_EPC];
                [tagFocusFilter setAction:SRFID_SELECTACTION_INV_B__OR__DSRT_SL];
                [tagFocusFilter setTarget:SRFID_SELECTTARGET_S3];
                
                [prefilterArrayForQuite addObject:tagFocusFilter];
                //            // Add tagFocusFilter to prefilterArrayForQuiet
            }
        }
    }
    
    NSString *response = @"";
     if([prefilterArrayForQuite count] > 0){
         SRFID_RESULT resTagQuiteSetrefilter  = SRFID_RESULT_FAILURE;
        
        resTagQuiteSetrefilter  =   [[zt_RfidAppEngine sharedAppEngine]setPreFilterForTagQuiet:prefilterArrayForQuite status:&response];
                                    
        
        if(resTagQuiteSetrefilter == SRFID_RESULT_SUCCESS){
            NSLog(@">>Adrian Sucess srfidSetPreFilters");
            [self showWarning:@"Impinj Tag Queit Enabled"];
          
        }else{
            NSLog(@">>Adrian Failed srfidSetPreFilters");
            [self showWarning:@"Impinj Tag Queit Enable Failed"];
        }
         
         
         
         SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:YES meesage:&response];
         
         if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
             NSLog(@">>Adrian Sucess resTagQuiteFinal");
             
         }else{
             NSLog(@">>Adrian Fail resTagQuiteFinal");
         }
         
   }
    
}

// Addd invetory tag object into multi tag array
/// @param tagItemObject The tag id object
-(void)addInvetoryTagObjectIntoMultiTagArray:tagItemObject
{
    [_currentlySelectedTagIdObjectArray addObject:tagItemObject];
    NSLog(@"Adrian currentlySelectedTagIdObjectArray Count: %lu", (unsigned long)[_currentlySelectedTagIdObjectArray count]);
    
//    if (![currentlySelectedTagIdObjectArray containsObject:tagItemObject])
//    {
//        [currentlySelectedTagIdObjectArray addObject:tagItemObject];
//    }
}

- (void)disableTagQuiet{
    
    if ([_currentlySelectedTagIdObjectArray count] > 0)
    {
        [_currentlySelectedTagIdObjectArray removeAllObjects];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TagQueitEnabled"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSString *status = [[NSString alloc] init];
    //  [self showWarning:@"Impinj Tag Queit Disable !"];
    
    
    [[zt_RfidAppEngine sharedAppEngine]restorePrefiltersForTagQuet];
    
    SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:NO meesage:&status];
    
    if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
        [self showWarning:@"Impinj Tag Queit Disable"];
        //                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        //                [local setPrefilterEnabled:0];
        //
    }else{
        [self showWarning:@"Impinj Tag Queit Disable Failed"];
    }
    //[[zt_RfidAppEngine sharedAppEngine]deleteAllPrefilter:&status];
    //[[zt_RfidAppEngine sharedAppEngine]restorePrefiltersForTagQuet];

}

-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae{
    UIAlertController * alert = [UIAlertController
                    alertControllerWithTitle:title
                                     message:messgae
                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                        actionWithTitle:@"Ok"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle ok action
                                }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showWarning:(NSString *)message
{
    [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
    
}

- (IBAction)FocusCheckBoxTapped:(UIButton *)sender {
    
    if (sender.selected) {
        NSLog(@"Checkbox is checked");
        
        
        [UIView performWithoutAnimation:^{
            [self->m_BtnFocus setImage:[UIImage imageNamed:CHECK_IMAGE_NAME] forState:UIControlStateNormal];
            [self->m_BtnFocus layoutIfNeeded];
        }];
        [self->m_BtnFocus  setSelected:NO];
        
        
        
        
    } else {
        NSLog(@"Checkbox is unchecked");
        [UIView performWithoutAnimation:^{
            [self->m_BtnFocus setImage:[UIImage imageNamed:UN_CHECK_IMAGE_NAME] forState:UIControlStateNormal];
            [self->m_BtnFocus layoutIfNeeded];
        }];
        [self->m_BtnFocus setSelected:YES];
    }
    
}

// Tag Quiet
- (IBAction)tagQuiteBtnChecked:(UIButton *)sender {
    
    if (m_BtnUnquite.selected == YES) {
        
        [UIView performWithoutAnimation:^{
            [m_BtnUnquite setImage:[UIImage imageNamed:UN_CHECK_IMAGE_NAME] forState:UIControlStateNormal];
            [m_BtnUnquite layoutIfNeeded];
            [m_BtnUnquite setSelected:NO];
            
        }];
        //[self inventoryStop];
        [self disableTagQuiet];
    }else{
        
        [UIView performWithoutAnimation:^{
            [m_BtnUnquite setImage:[UIImage imageNamed:CHECK_IMAGE_NAME] forState:UIControlStateNormal];
            [m_BtnUnquite layoutIfNeeded];
            [m_BtnUnquite setSelected:YES];
            
        }];
        //[self inventoryStart];
        [self enableTagQuiet];
    }
}
#pragma mark - Tag Quiet Inventory
-(void)inventoryStart {
    BOOL hasTagQueitEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"TagQueitEnabled"];
    
    if (hasTagQueitEnabled) {
        [self enableTagQuiet];
    }

    
    [_tagDataInventory removeAllObjects];
    [self clearAllSelections];
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:SRFID_MEMORYBANK_TID message:&status];
   
}

-(void)inventoryStop {
    
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_TblImpinjInventory reloadData];
    });
    
}




- (IBAction)btnStartStopPressed:(id)sender
{
    if (m_BtnImpinjInvStart.selected == YES) {
        
        [UIView performWithoutAnimation:^{
            [m_BtnImpinjInvStart setImage:[UIImage imageNamed:START_SCAN_ICON] forState:UIControlStateNormal];
            [m_BtnImpinjInvStart layoutIfNeeded];
            [m_BtnImpinjInvStart setSelected:NO];
            
        }];
        [self inventoryStop];
    }else{
        
        [UIView performWithoutAnimation:^{
            [m_BtnImpinjInvStart setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
            [m_BtnImpinjInvStart layoutIfNeeded];
            [m_BtnImpinjInvStart setSelected:YES];
            
        }];
        [self inventoryStart];
    }
}


#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    //    self->m_TblImpinjInventory.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        // Dark Mode
        [self->m_BtnFocus setBackgroundColor:[UIColor darkGrayColor]];
        [self->m_BtnUnquite setBackgroundColor:[UIColor darkGrayColor]];
        
    } else {
        // Light Mode
        [self->m_BtnFocus setBackgroundColor:[UIColor whiteColor]];
        [self->m_BtnUnquite setBackgroundColor:[UIColor whiteColor]];
        
    }
}


/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self->m_TblImpinjInventory reloadData];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}


- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}





- (void)srfidEventBatteryNotity:(int)readerID aBatteryEvent:(srfidBatteryEvent *)batteryEvent {
    
}

- (void)srfidEventCommunicationSessionEstablished:(srfidReaderInfo *)activeReader {
    
}

- (void)srfidEventCommunicationSessionTerminated:(int)readerID {
    
}

- (void)srfidEventConnectedInterfaceNotity:(int)readerID aConnectedInterfaceEvent:(sfidConnectedInterfaceEvent *)connectedInterfaceEvent {
    
}

- (void)srfidEventIOTSatusNotity:(int)readerID aIOTStatusEvent:(srfidIOTStatusEvent *)iotStatusEvent {
    
}

- (void)srfidEventMultiProximityNotify:(int)readerID aTagData:(srfidTagData *)tagData {
    
}

- (void)srfidEventProximityNotify:(int)readerID aProximityPercent:(int)proximityPercent {
    
}

#pragma mark - Read Notify
- (void)srfidEventReadNotify:(int)readerID aTagData:(srfidTagData *)tagData {
    NSLog(@"Adrian Tag %@", [tagData getTagId]);
    
    if (!_tagDataInventory) {
        _tagDataInventory = [NSMutableArray array];
    }
    
    BOOL isDuplicate = NO;
    NSString *newTagId = [tagData getTagId];
    
    for (srfidTagData *existingTag in _tagDataInventory) {
        if ([[existingTag getTagId] isEqualToString:newTagId]) {
            isDuplicate = YES;
            break;
        }
    }
    
    if (!isDuplicate) {
        [_tagDataInventory addObject:tagData];
    }
    
    NSLog(@"Adrian Tag Count %lu", (unsigned long)[_tagDataInventory count]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->m_TblImpinjInventory reloadData];
    });
}

- (void)srfidEventReaderAppeared:(srfidReaderInfo *)availableReader {
    
}

- (void)srfidEventReaderDisappeared:(int)readerID {
    
}

- (void)srfidEventStatusNotify:(int)readerID aEvent:(SRFID_EVENT_STATUS)event aNotification:(id)notificationData {
    
}

- (void)srfidEventTriggerNotify:(int)readerID aTriggerEvent:(SRFID_TRIGGEREVENT)triggerEvent {
    
}

- (void)srfidEventWifiScan:(int)readerID wlanSCanObject:(srfidWlanScanList *)wlanScanObject {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}


- (void)impingTagDataEvent:(srfidTagData *)tagData { 
    NSLog(@" Impinj Quiet Tag impingTagDataEvent");
  
    NSLog(@" Tag Quiet %@", [tagData getTagId]);
    
    if (!_tagDataInventory) {
        _tagDataInventory = [NSMutableArray array];
    }
    
    BOOL isDuplicate = NO;
    NSString *newTagId = [tagData getTagId];
    
    for (srfidTagData *existingTag in _tagDataInventory) {
        if ([[existingTag getTagId] isEqualToString:newTagId]) {
            isDuplicate = YES;
            break;
        }
    }
    
    if (!isDuplicate) {
        [_tagDataInventory addObject:tagData];
    }
    
    NSLog(@"Tag Quiet Count %lu", (unsigned long)[_tagDataInventory count]);
  // [NSThread sleepForTimeInterval:1.0];
    if([_tagDataInventory count] >0){

        dispatch_async(dispatch_get_main_queue(), ^{

            [self->m_TblImpinjInventory reloadData];
        });
    }
}

@end
