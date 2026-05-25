//
//  ScanandPairVC.m
//  RFIDDemoApp
//
//  Created by Symbol on 23/12/20.
//  Copyright © 2020 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "ScanandPairVC.h"
#import "ui_config.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"
#import "RFIDReadersListCell.h"
#import "HelpViewController.h"

#define ZD_CELL_READER_LIST                    @"ID_CELL_READER_LIST"
#define ZT_CELL_HEIGHT_READER_LIST             50
typedef enum {
    
    READER_LIST_ITEM_NO_READER = 0,
    READER_LIST_ITEM_NOT_CONNECTED,
    READER_LIST_ITEM_CONNECTED,
    READER_LIST_ITEM_BATCH,
    READER_LIST_ITEM_TOTAL_STATES

} READER_LIST_ITEM_STATE;

/// Created the new scan and pair viewcontroller to have the internal scan direcly we can access settings screen from the app and pair it.
@interface zt_ScanandPairVC ()
@property (retain, nonatomic) IBOutlet UIButton *btn_pair_unpair;

@end

@implementation zt_ScanandPairVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ReaderList = [[NSMutableArray alloc] init];
        m_ActiveReaderIndexValue = -1;
        m_ActiveReaderId = -1;
        m_EmptyDevList = YES;
        
        m_btnHelp = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(barButtonHelpAction)];
        [m_btnHelp setImage:[UIImage imageNamed:HELP_ICON]];
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
    
    [paired_list_table release];
    [_btn_pair_unpair release];
    [paired_readers_label release];
    [super dealloc];
}

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [paired_list_table setDelegate:self];
    [paired_list_table setDataSource:self];
    [self setTitle:SCAN_PAIR_TITLE];
    [self setUpView];
}

/// Using this method to setup the ui text and the placeholders to the textfields and labels in the view controller.
- (void)setUpView {
    
    [paired_readers_label setText:SCAN_PAIRED_READERS];
    [_btn_pair_unpair setTitle:SCAN_PAIR_UNPAIR_TEXT forState:UIControlStateNormal];
    
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    /* just to reload data from app engine */
    
    [self deviceListHasBeenUpdated];
    
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:m_btnHelp];
    
    self.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
}

/// Using the button action to navigate the current view controller to helpviewcontroller when the user requires help on the bluetooth pairing.
- (void)barButtonHelpAction
{
    zt_HelpViewController * help_vc = (zt_HelpViewController*)[[UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:HELP_STORY_BOARD_ID];
    [self.navigationController pushViewController:help_vc animated:YES];
}

/// This button action will help user to navigate to the settings screen from the application direcly to pair the reader manually.
/// @param sender Sending the object to utilize the object details like id and the name etc.
- (IBAction)pairConnection:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:OPEN_SETTINGS_STRING] options:@{} completionHandler:NULL];
}

/* ###################################################################### */
/* ########## zt_IRfidAppEngineDevListDelegate Protocol implementation ## */
/* ###################################################################### */

/// This method will help us to updated the device status at any time if the status changes.
- (BOOL)deviceListHasBeenUpdated
{
    /* TBD: check whether we still have reader that was active */

    if ([[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count] > 0)
    {
        /* determine actual status of previously active scanner */
        NSArray *list_readers = [[zt_RfidAppEngine sharedAppEngine] getActualDeviceList];
        BOOL found = NO;
        
        srfidReaderInfo *readerInformation = nil;
        for (int index = 0; index < [list_readers count]; index++)
        {
            readerInformation = (srfidReaderInfo*)[list_readers objectAtIndex:index];
            if (m_ActiveReaderId != -1)
            {
                if ([readerInformation getReaderID] == m_ActiveReaderId)
                {
                    m_ActiveReaderIndexValue = index;
                    found = YES;
                    break;
                }
            }
            else
            {
                if (YES == [readerInformation isActive])
                {
                    m_ActiveReaderId = [readerInformation getReaderID];
                    m_ActiveReaderIndexValue = index;
                    found = YES;
                    break;
                }
            }
        }
        
        if (NO == found)
        {
            m_ActiveReaderId = -1;
            m_ActiveReaderIndexValue = -1;
        }
    }
    
    [paired_list_table reloadData];    
    return YES;
}


/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

/// To set the number of sections in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/// To set the number of rows in sections in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param section Here we will get the current section of the tableview to update the value in every sections.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count];
    if (0 == count)
    {
        m_ActiveReaderIndexValue = -1;
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

/// To set the cell for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to show the proper values in the cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexValueOfTheReader = (int)[indexPath row];
    READER_LIST_ITEM_STATE state = [self getReaderListItemState:indexValueOfTheReader];
    zt_RFIDReadersListCell * readerList_Cell = [paired_list_table dequeueReusableCellWithIdentifier:ZD_CELL_READER_LIST];
    if (state != READER_LIST_ITEM_NO_READER)
    {
        srfidReaderInfo *info = (srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:indexValueOfTheReader];
        
        [readerList_Cell setDeviceInformation:[info getReaderName]];
        
    }else
    {
        [readerList_Cell setDeviceInformation:@""];
    }
    readerList_Cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return readerList_Cell;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

/// To set the height for row at indexpath in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item to set proper height to the cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ZT_CELL_HEIGHT_READER_LIST;
}

/// To select the required cell and get the index of selected cell in the tableview which is using to show the available readers in the scan and pair screen.
/// @param tableView This tableview is used to show the available readers list in the scan and pair screen.
/// @param indexPath Here we are getting the current indexpath of the item which is user selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// This method is used to fetch the reader list and its status if the reader to pair and unpair.
/// @param index This object is used to fetch the status of the device.
- (READER_LIST_ITEM_STATE) getReaderListItemState : (int) index
{
    READER_LIST_ITEM_STATE itemState = READER_LIST_ITEM_NOT_CONNECTED;
    
    if (m_EmptyDevList)
    {
        itemState = READER_LIST_ITEM_NO_READER;
    }
    else if (index == m_ActiveReaderIndexValue)
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
        }
    }

    return itemState;
}
@end
