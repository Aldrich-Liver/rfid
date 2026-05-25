//
//  EndPointStatusViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 30/04/25.
//  Copyright © 2025 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "EndPointStatusViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "EndPointStatusCell.h"
#import "RFIDDemoApp-Swift.h"


#define ZT_CELL_ID_EP_STATUS             @"ID_EP_STATUS_CELL"
@interface EndPointStatusViewController ()
{
    NSMutableArray * endPointStatusArray;
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    srfidIOTStatusEvent *iotEvent;
}
@end

@implementation EndPointStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:EP_STATUS_TITLE];
    endPointStatusArray = [[NSMutableArray alloc] init];
    iotEvent = [[srfidIOTStatusEvent alloc] init];
    [endPointStatus_label setHidden:YES];
    [_endPointStatus_table setHidden:NO];
    [self getIOTStatusApiCall];
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != _endPointStatus_table)
    {
        [_endPointStatus_table release];
    }
  
    [super dealloc];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Register for battery event
    [[zt_RfidAppEngine sharedAppEngine] addIOTStatusEventDelegate:self];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
}

-(void)getIOTStatusApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
            
        result = [[zt_RfidAppEngine sharedAppEngine] requestIOTStatus:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                //[activityView hideActivity];
                [self showFailurePopup:@"Get IOT status failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)onNewIOTStatusEvent:(srfidIOTStatusEvent *)iotStatusEvent {
    
    [endPointStatusArray addObject:iotStatusEvent];
    
    if (endPointStatusArray != nil) {
        [endPointStatus_label setHidden:YES];
        [_endPointStatus_table setHidden:NO];
        [self.endPointStatus_table reloadData];
    }else
    {
        [endPointStatus_label setHidden:NO];
        [_endPointStatus_table setHidden:YES];
    }
}

#pragma mark - Method
/// Show alert view with given message
/// @param message The message
- (void)showPopup:(NSString *)message
{
    [self showOnlyMessageWithDurationWithMessage:message time:ZT_MULTITAG_ALERTVIEW_WAITING_TIME];
}

-(void)showFailurePopup:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
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
    
    return endPointStatusArray.count;
 
}

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
}
/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EndPointStatusCell *status_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_EP_STATUS forIndexPath:indexPath];
    
    if (status_cell == nil)
    {
        status_cell = [[EndPointStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_EP_STATUS];
    }
    
    iotEvent = [endPointStatusArray objectAtIndex:indexPath.row];
        
    if ([[iotEvent getEpType] isEqualToString:@"mgmt"]) {
        [status_cell.labelEPType setText:@"Management"];
    }
    else if ([[iotEvent getEpType] isEqualToString:@"mgmt event"]) {
        [status_cell.labelEPType setText:@"Management Event"];
    }
    else
    {
        [status_cell.labelEPType setText:[[iotEvent getEpType] capitalizedString]];
    }
    
    [status_cell.labelEPName setText:[[iotEvent getEpName] capitalizedString]];
    [status_cell.labelStatus setText:[[iotEvent getStatus] capitalizedString]];
    [status_cell.labelReason setText:[[iotEvent getReason] capitalizedString]];
    [status_cell.labelCause setText:[[iotEvent getCause] capitalizedString]];

    status_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //[status_cell darkModeCheck:self.view.traitCollection];
    return status_cell;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.endPointStatus_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self.endPointStatus_table reloadData];
}

@end
