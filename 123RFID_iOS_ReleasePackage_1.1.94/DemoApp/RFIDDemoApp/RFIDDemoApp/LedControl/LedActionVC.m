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
 *  Description:  LedActionVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LedActionVC.h"
#import <ZebraScannerFramework/RMDAttributes.h>
#import <ZebraScannerFramework/SbtSdkDefs.h>
#import "ScannerEngine.h"
#import "config.h"
#import "ui_config.h"

// Defining the following flag will remove the Red and Yellow LED
// options for the RFD8500 device. The Red and Yellow LED's are currently
// unsupported, but will be re-enabled in the future
#define LOCAL_CONFIG_RFD8500_HIDE_RED_YELLOW_LED
#define SST_SCANNER_MODEL_UNKNOWN           @"Unknown"

@interface LedActionViewController ()

@end

@implementation LedActionViewController

/* default cstr for storyboard */
/// Returns an object initialized from data in a given unarchiver.
/// @param aDecoder An unarchiver object.
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        ledValues = [[NSMutableArray alloc] init];
        ledNames = [[NSMutableArray alloc] init];
        scannerID = SBT_SCANNER_ID_INVALID;
        scannerModel = SST_SCANNER_MODEL_UNKNOWN;
        requiredLedAction = YES;
       
    }
    return self;
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (ledNames != nil)
    {
        [ledNames removeAllObjects];
        [ledNames release];
    }
    if (ledValues != nil)
    {
        [ledValues removeAllObjects];
        [ledValues release];
    }
      
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [super dealloc];
}
/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:SCANNER_LEDCONTROLL_PAGE_TITLE];
    
    activityView = [[zt_AlertView alloc]init];
}
/// Notifies the view controller that its view was removed from a view hierarchy.
/// @param animated If YES, the disappearance of the view was animated.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
////Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

/// Set scanner id from previous page
/// @param scanner_id connected reader id
- (void)setScannerID:(int)scanner_id
{

    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    scannerModel = [scannerInfo getScannerName];
    scannerID = [scannerInfo getScannerID];
    
        [ledNames addObject:SCANNER_LEDCONTROLL_GREEN_LED_ON];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_GREEN_ON]];
        [ledNames addObject:SCANNER_LEDCONTROLL_GREEN_LED_OFF];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_GREEN_OFF]];
        [ledNames addObject:SCANNER_LEDCONTROLL_RED_LED_ON];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_RED_ON]];
        [ledNames addObject:SCANNER_LEDCONTROLL_RED_LED_OFF];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_RED_OFF]];
        [ledNames addObject:SCANNER_LEDCONTROLL_YELLOW_LED_ON];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_YELLOW_ON]];
        [ledNames addObject:SCANNER_LEDCONTROLL_YELLOW_LED_OFF];
        [ledValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_YELLOW_OFF]];
    
    
}
/// This method is to send the relavent attributes to perform led elumination
/// @param in_xml  xml to send attributes
- (void)performLedAction:(NSString*)in_xml
{
    SBT_RESULT res = [[ScannerEngine sharedScannerEngine] executeCommand:SBT_SET_ACTION aInXML:in_xml];
    
    if (res != SBT_RESULT_SUCCESS)
    {
         [self showAlertForLedAction];
    }
}
/// This method is to show alert after performing the led action
- (void)showAlertForLedAction
{
    
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_RFID_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_LED_ACTION
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [ledNames count] / SCANNER_LEDCONTROLL_ROWS_IN_SECTION;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return SCANNER_LEDCONTROLL_ROWS_IN_SECTION;
}

/// Asks the data source for a cell to insert in a particular location of the table view. Required.
/// @param tableView A table-view object requesting the cell.
/// @param indexPath An index path locating a row in tableView.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *LedActionCellIdentifier = SCANNER_LEDCONTROLL_CEL;
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:LedActionCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LedActionCellIdentifier];
    }
    cell.textLabel.text = [ledNames objectAtIndex:[indexPath row] + ([indexPath section] * SCANNER_LEDCONTROLL_ROWS_IN_SECTION)];
    
    return cell;
}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

/// Tells the delegate a row is selected.
/// @param tableView A table view informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL led_enable = ([indexPath row] == 0);
    
    requiredLedAction = led_enable;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    NSString *in_xml = [NSString stringWithFormat:SCANNER_LEDCONTROLL_INXML, scannerID, [[ledValues objectAtIndex:[indexPath row] + ([indexPath section] * SCANNER_LEDCONTROLL_ROWS_IN_SECTION)] intValue]];
    activityView = [[zt_AlertView alloc] init];
    [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performLedAction:) withObject:in_xml withString:nil];

}

@end
