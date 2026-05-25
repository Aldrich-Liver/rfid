//
//  EndPointConfigViewController.m
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 13/09/24.
//  Copyright © 2024 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import "EndPointConfigViewController.h"
#import "ui_config.h"
#import "RfidAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "EndpointsListCell.h"
#import "AlertView.h"
#import <ZebraRfidSdkFramework/RfidGetEndPointList.h>
#import <ZebraRfidSdkFramework/RfidSetEndPointConfig.h>
#import "AddNewEndpointConfig.h"
#define ZT_CELL_ENDPOINT_HEIGHT         65
#define ZT_CELL_ID_ENDPOINT            @"ID_ENDPOINTS_CELL"
@interface EndPointConfigViewController ()
{
    NSMutableArray *endpoint_list;
    IBOutlet UIButton * buttonAddNew;
    IBOutlet UILabel * label_no_endpoints;
    BOOL multiTagLocated;
    BOOL tagLocated;
    BOOL inventoryRequested;
    zt_AlertView *activityView;
    NSString * operationString;
    BOOL isLocalCall;
}
@property (retain, nonatomic) IBOutlet UITableView * endpoints_table;
@end

@implementation EndPointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:ENDPOINTS_TITLE];
    endpoint_list = [[NSMutableArray alloc] init];
    tagLocated = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    multiTagLocated = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] isMultiTagLocated];
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    activityView = [[zt_AlertView alloc] init];
    operationString = [NSString stringWithFormat:@""];
    isLocalCall = YES;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"GetList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    [super viewWillAppear:animated];
}

/// Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self darkModeCheck:self.view.traitCollection];
    
    BOOL reload = [[NSUserDefaults standardUserDefaults] boolForKey:@"GetList"];
    
    if (reload) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self getEndpointsListApiCall];
        });
        if (!isLocalCall) {
            [self showpopup];
        }
    }
}

- (void)showpopup
{
    NSString * message = [NSString stringWithFormat:@""];
    if ([operationString isEqualToString:@"New"]) {
        message = [NSString stringWithFormat:@"Endpoint added successfully"];
    }else
    {
        message = [NSString stringWithFormat:@"Endpoint updated successfully"];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [self showSuccessPopup:message];
    });
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GetList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Get wlan profile list api call
-(void)getEndpointsListApiCall
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [activityView showActivity:self.view];
        });
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        NSMutableArray* listEndPoint = [[NSMutableArray alloc]init];
            
        result = [[zt_RfidAppEngine sharedAppEngine] getEndPointList:readerId endPointList:&listEndPoint status:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            
            if (listEndPoint.count != 0) {
                NSMutableArray * filesArray = [[NSMutableArray alloc] init];
                for (RfidGetEndPointList * endpoint_info in listEndPoint) {
                    [filesArray addObject:[endpoint_info getEndPointName]];
                }
                [endpoint_list removeAllObjects];
                endpoint_list = [filesArray mutableCopy];
                if (listEndPoint.count != 0) {
                    _endpoints_table.hidden = false;
                    label_no_endpoints.hidden = true;
                }
            }else
            {
                if (listEndPoint.count != 0) {
                    _endpoints_table.hidden = false;
                    label_no_endpoints.hidden = true;
                }else
                {
                    _endpoints_table.hidden = true;
                    label_no_endpoints.hidden = false;
                }
            }
                                
            dispatch_async(dispatch_get_main_queue(),^{
                [activityView hideActivity];
                [self.endpoints_table reloadData];
            });
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
                [self showFailurePopup:status];
            });
        }
    }else
    {
        [self.navigationController.navigationBar setUserInteractionEnabled:true];
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (IBAction)addNewEndPoint:(id)sender
{
    AddNewEndpointConfig * add_endpoint_vc = (AddNewEndpointConfig*)[[UIStoryboard storyboardWithName:ENDPOINT_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADD_NEW_ENDPOINT_BOARD_ID];
    add_endpoint_vc.operation = @"New";
    isLocalCall = NO;
    operationString = [NSString stringWithFormat:@"New"];
    [self.navigationController pushViewController:add_endpoint_vc animated:YES];
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

-(void)showSuccessPopup:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success"
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
    
    return endpoint_list.count;
}

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ZT_CELL_ENDPOINT_HEIGHT;
}

/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EndpointsListCell *endpoints_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_ENDPOINT forIndexPath:indexPath];
    
    if (endpoints_cell == nil)
    {
        endpoints_cell = [[EndpointsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_ENDPOINT];
    }
    endpoints_cell.labelEndpointName.text = [NSString stringWithString:[endpoint_list objectAtIndex:indexPath.row]];
    [endpoints_cell.buttonDelete setTag:indexPath.row];
    [endpoints_cell.buttonEdit setTag:indexPath.row];
    [endpoints_cell.buttonEdit addTarget:self
                                       action:@selector(editEndpointAction:)
                                       forControlEvents:UIControlEventTouchUpInside];
    [endpoints_cell.buttonDelete addTarget:self
                                       action:@selector(removeEndpointAction:)
                                       forControlEvents:UIControlEventTouchUpInside];
    
    endpoints_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return endpoints_cell;
}

-(void)editEndpointAction:(UIButton*)sender
{
    AddNewEndpointConfig * add_endpoint_vc = (AddNewEndpointConfig*)[[UIStoryboard storyboardWithName:ENDPOINT_STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ADD_NEW_ENDPOINT_BOARD_ID];
    add_endpoint_vc.operation = @"Update";
    operationString = [NSString stringWithFormat:@"Update"];
    isLocalCall = NO;
    add_endpoint_vc.endPointName = [NSString stringWithFormat:@"%@",[endpoint_list objectAtIndex:[sender tag]]];
    [self.navigationController pushViewController:add_endpoint_vc animated:YES];
}

-(void)removeEndpointAction:(UIButton*)sender
{
    NSString * fileName = [NSString stringWithFormat:@"%@",[endpoint_list objectAtIndex:sender.tag]];
    
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Do you want to delete this endpoint?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeEndPointConfigAPICall:fileName];
                }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [confirmAlert addAction:cancel];
    [confirmAlert addAction:ok];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

- (void)removeEndPointConfigAPICall:(NSString *)endPointName
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
                
        result = [[zt_RfidAppEngine sharedAppEngine] removeEndPointConfig:readerId endPointName:endPointName aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getEndpointsListApiCall];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Remove Endpoint failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

- (void)saveEndPointConfig
{
    if (inventoryRequested == NO && tagLocated == NO && multiTagLocated == NO)
    {
        int readerId =  [[[zt_RfidAppEngine sharedAppEngine] activeReader] getReaderID];
        SRFID_RESULT result = SRFID_RESULT_FAILURE;
        NSString *status = [[NSString alloc] init];
        
        result = [[zt_RfidAppEngine sharedAppEngine] saveEndPointConfig:readerId aStatusMessage:&status];
        
        if (result == SRFID_RESULT_SUCCESS)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getEndpointsListApiCall];
            });
            
        }else if (result == SRFID_RESULT_RESPONSE_ERROR)
        {
            if ([status isEqualToString:ZT_DEVICE_AUTH_MESSAGE])
            {
                [[zt_RfidAppEngine sharedAppEngine] showAuthorizationPopup:self andaMessage:status];
            }else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self showFailurePopup:status];
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showFailurePopup:@"Delete EndPoint Failed"];
            });
        }
    }else
    {
        [self showFailurePopup:ZT_GENERAL_ERROR_MESSAGE];
    }
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != self.endpoints_table)
    {
        [self.endpoints_table release];
    }
    if (nil != endpoint_list)
    {
        [endpoint_list release];
    }
  
    [super dealloc];
}


#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.endpoints_table.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
    label_no_endpoints.tintColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    [self.endpoints_table reloadData];
}


@end
