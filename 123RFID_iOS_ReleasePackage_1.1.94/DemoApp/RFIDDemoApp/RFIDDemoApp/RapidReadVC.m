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
 *  Description:  RapidReadVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RapidReadVC.h"
#import "ui_config.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"
#import <AudioToolbox/AudioServices.h>
#import "ScannerEngine.h"
#import "CSVHelper.h"
#import "RFIDDemoApp-Swift.h"

#define ZT_RR_TIMER_INTERVAL               0.2

@interface zt_RapidReadVC ()
{
    NSTimer *m_ViewUpdateTimer;
    
    IBOutlet UIView *m_viewUniqueTagCountBackground;
    IBOutlet UILabel *m_lblUniqueTagCountNotice;
    IBOutlet UILabel *m_lblUniqueTagCountData;
    IBOutlet UILabel *m_lblTotalTagCountNotice;
    IBOutlet UILabel *m_lblTotalTagCountData;
    IBOutlet UILabel *m_lblReadRateNotice;
    IBOutlet UILabel *m_lblReadRateData;
    IBOutlet UILabel *m_lblReadTimeNotice;
    IBOutlet UILabel *m_lblReadTimeData;
    IBOutlet UILabel *m_lblTagsSecond;
    IBOutlet UIButton *m_btnStartStop;
    
    // Taglist Matchmode
    IBOutlet UIView  *tagListBackgroundView;
    IBOutlet UILabel *matchingTagsNotice;
    IBOutlet UILabel *matchingTagsData;
    IBOutlet UILabel *missingTagsNotice;
    IBOutlet UILabel *missingTagsData;
    
    CGFloat m_fszTotalTags;
    CGFloat m_fszReadTime;
    CGFloat m_fszReadRate;
    CGFloat m_fszUniqueTags;
    int m_TotalTags;
    int m_ReadTime;
    int m_ReadRate;
    int m_UniqueTags;
    IBOutlet UILabel *batchModeLabel;
    zt_SledConfiguration *sledConfig;
    
    //Export CSV
    CGFloat readTimeValue;
    bool isRapidReadStarted;
    bool isCreateCSVFileMethodExcute;
    BOOL inventoryTriggered;

}
@property(nonatomic)IBOutlet UIProgressView * progressBarView;

@end

@implementation zt_RapidReadVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ViewUpdateTimer = nil;
        m_fszReadRate = - 1.0;
        m_fszReadTime = -1.0;
        m_fszTotalTags = - 1.0;
        m_fszUniqueTags = -1.0;
        m_ReadRate = -1;
        m_ReadTime = -1;
        m_TotalTags = -1;
        m_UniqueTags = -1;
        isRapidReadStarted = FALSE;
        isCreateCSVFileMethodExcute = FALSE;
    }
    return self;
}

- (void)dealloc
{
    [m_viewUniqueTagCountBackground release];
    [m_lblUniqueTagCountData release];
    [m_lblUniqueTagCountNotice release];
    [m_lblTotalTagCountNotice release];
    [m_lblTotalTagCountData release];
    [m_lblReadRateNotice release];
    [m_lblReadRateData release];
    
    [m_lblReadTimeNotice release];
    [m_lblReadTimeData release];
    [m_btnStartStop release];
    
    [tagListBackgroundView release];
    [matchingTagsNotice release];
    [matchingTagsData release];
    [missingTagsNotice release];
    [missingTagsData release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cycleCountArray = [[NSMutableArray alloc] init];
    inventoryTriggered = FALSE;
    [self configureAppearance];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];
    sledConfig = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    inventoryTriggered = FALSE;
    /* set title */
    [self.tabBarController setTitle:ZT_STR_BUTTON_RAPID_READ];
    
    // get active profile
    activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];
    
    BOOL is_inventory = (ZT_RADIO_OPERATION_INVENTORY == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    if (NO == is_inventory)
    {
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_INVENTORY];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        if (YES == requested)
        {
            /* simple logic of radioStateChangedOperationRequested w/o cleaning of selected inventory item */
            if (@available(iOS 11.0, *)) {
                [m_btnStartStop setTintColor:[UIColor colorNamed:THEME_COLOR]];
            } else {
                // Fallback on earlier versions
            }
            [UIView performWithoutAnimation:^
             {
                [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
                 [m_btnStartStop layoutIfNeeded];
                [m_btnStartStop setSelected:YES];
             }];
            
            [self updateOperationDataUI];
            
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
            
            if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
            {
                batchModeLabel.hidden = NO;
                [self.view bringSubviewToFront:batchModeLabel];
                
                if (![activeProfile  isEqual: CYCLE_COUNT_INDEX])
                {
                    [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setReadRate:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setReadTime:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setUniqueTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [matchingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [missingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                }
            }
            
        }
        else
        {
            [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_INVENTORY];
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
        }
    }
    NSString * activeProfile;
    activeProfile = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY];
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX] ) {
        m_buttonCycleCount.hidden=NO;
    }else
    {
        m_buttonCycleCount.hidden=YES;
      
    }
    /* add dpo button to the titlebar */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
    [self darkModeCheck:self.view.traitCollection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
    
    if (tagListOption) {
        [self->tagListBackgroundView setHidden:FALSE];
        [self.view bringSubviewToFront:tagListBackgroundView];
    }else
    {
        [self->tagListBackgroundView setHidden:TRUE];
        [self.view sendSubviewToBack:tagListBackgroundView];
    }
    [self darkModeCheck:self.view.traitCollection];
    
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if ([local prefilterEnabled])
    {
        labelPrefilterEnabled.hidden = NO;
        prefilterLabelHeightConstraint.constant = 15;
    }else
    {
        labelPrefilterEnabled.hidden = YES;
        prefilterLabelHeightConstraint.constant = 0;
    }
    
    if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        batchModeLabel.hidden = NO;
        [self.view bringSubviewToFront:batchModeLabel];
        
        if (![activeProfile  isEqual: CYCLE_COUNT_INDEX])
        {
            [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            [self setReadRate:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            [self setReadTime:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            [self setUniqueTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            [matchingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            [missingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
    
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
}

- (void)updateOperationDataUI
{
    /* unique tags */
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
    int tag_count = (int)[zt_InventoryData getUniqueCount:_tags];
    
    /* total tags */
    int total_tag_count = [zt_InventoryData getTotalCount:_tags];

    NSTimeInterval read_time = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getRadioOperationTime];
    BOOL in_progress = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress];
    if (YES == in_progress)
    {
        NSDate *last_start = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLastStartOperationTime];
        if (nil != last_start)
        {
            read_time += [[NSDate date] timeIntervalSinceDate:last_start];
            [last_start release];
        }
    }
    
    int read_rate = 0;
    if (read_time >= 1)
    {
        read_rate = total_tag_count / read_time;
    }
    if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        batchModeLabel.hidden = YES;
        m_lblUniqueTagCountData.hidden = NO;
        if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
        {
            
            if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
            {
                [NSThread sleepForTimeInterval:0.1];
                int totalReadsCount = [[[NSUserDefaults standardUserDefaults] objectForKey:ZT_TOTALREADS_DEFAULTS_KEY] intValue];
                int uniqueTagsCount = [[[NSUserDefaults standardUserDefaults] objectForKey:ZT_UNIQUETAGS_DEFAULTS_KEY] intValue];
                [self setUniqueTagCount:uniqueTagsCount];
                [self setTotalTagCount:totalReadsCount];
            }else
            {
                [NSThread sleepForTimeInterval:0.1];
                if (batchModeLabel.isHidden == YES) {
                    [self setUniqueTagCount:tag_count];
                    [self setTotalTagCount:total_tag_count];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:total_tag_count] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tag_count] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else
                {
                    [self setUniqueTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
            
        }else
        {
            [self setUniqueTagCount:tag_count];
            [self setTotalTagCount:total_tag_count];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:total_tag_count] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tag_count] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
        if (tagListOption) {
            [self getMatchingTagList];
        }
        dispatch_async(dispatch_get_main_queue(),^{
            if (SRFID_BATCHMODECONFIG_ENABLE != [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getBatchModeConfig])
            {
                [self setReadRate:read_rate];
            }
            else
            {
                [self setReadRate:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            }
            [self setReadTime:read_time];
        });
        //[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] playHostBeeper];
    }
    
    if (nil != _tags)
    {
        [_tags release];
    }

}
- (void)showWarning:(NSString *)message
{
    [self showLoadingBarWithDurationWithMessage:message time:3];
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
}

- (IBAction)btnStartStopPressed:(id)sender
{
    BOOL locationingRequested = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getIsMultiTagLocationing];
    
    if (!locationingRequested) {
        /// Clearing selected barcode value
        [[ScannerEngine sharedScannerEngine] removeSelectedBarcodeValue];
        if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
        {
            [self showWarning:INVENTORY_TAG_READING_INPROGRESS];
            return;
        }
        inventoryTriggered = TRUE;
        BOOL inventory_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
        NSString *statusMsg = nil;
        if (NO == inventory_requested)
        {
            if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES])
            {
                rfid_res = [[zt_RfidAppEngine sharedAppEngine] purgeTags:&statusMsg];
            }
            
            NSString * brandID = [[NSUserDefaults standardUserDefaults] objectForKey:BRANDID_KEY_DEFAULTS];
            NSString * epcLength = [[NSUserDefaults standardUserDefaults] objectForKey:EPCLENGTH_KEY_DEFAULTS];
            
            BOOL checkBrandID = [[NSUserDefaults standardUserDefaults] boolForKey:BRANDIDCHECK_KEY_DEFAULTS];
            
            if (checkBrandID) {
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] performBrandCheckInventory:YES aMemoryBank:SRFID_MEMORYBANK_NONE message:&statusMsg brandId:brandID epcLenth:[epcLength intValue]];
            }else
            {
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:SRFID_MEMORYBANK_NONE message:&statusMsg];
            }
            
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setSelectedInventoryMemoryBankUI:SRFID_MEMORYBANK_NONE];
            if([statusMsg  isEqualToString:INVENTORY_IN_BATCH_MODE])
            {
                batchModeLabel.hidden = NO;
                [self.view bringSubviewToFront:batchModeLabel];
                [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
                [m_btnStartStop setSelected:YES];
                m_lblUniqueTagCountData.hidden = YES;
                
                if (![activeProfile  isEqual: CYCLE_COUNT_INDEX])
                {
                    [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setReadRate:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [self setReadTime:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [matchingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    [missingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    
                    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigMatchMode];
                    
                    if (tagListOption) {
                        batchModeLabel.hidden = NO;
                        [self.view bringSubviewToFront:batchModeLabel];
                        [matchingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                        [missingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                    }
                }
            }
        }
        else
        {
            rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
        }
        
        if (m_btnStartStop.selected == YES) {
            [m_btnStartStop setSelected:NO];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] stopHostBeeper];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
                
                if ([activeProfile  isEqual: CYCLE_COUNT_INDEX] || [[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
                {
                    [self getTotalTagsCountInCycleCount];
                }
                zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
                long long timeoutStop = [sled currentStopTimeout];
                
                if (!(timeoutStop > 0)) {
                    [self createCSVFileUsingInventoryData];
                }
            });
        }else{
            [m_btnStartStop setSelected:YES];
            [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] playHostBeeper];
        }
    }else
    {
        [self showWarning:ZT_MULTITAG_ERROR_MESSAGE];
    }
    
    // request battery status so we know how much battery is left
    [[zt_RfidAppEngine sharedAppEngine] requestBatteryStatus:nil];
    
    // refresh dpo bar button item to show battery status
    [self refreshDpoButton];
}

/// To get the total reads tags count when cyclecount is enabled
-(void)getTotalTagsCountInCycleCount
{
    [NSThread sleepForTimeInterval:ZT_CYCLECOUNT_THREAD_SLEEP];
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
    int totalTagCount = [zt_InventoryData getTotalCount:_tags];
        
    if ([activeProfile  isEqual: CYCLE_COUNT_INDEX])
    {
        [NSThread sleepForTimeInterval:0.1];
        totalTagsCountForCycleCount += totalTagCount;
        [self addingArrayforCycleCount:_tags];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalTagsCountForCycleCount] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(),^{
        if (totalTagsCountForCycleCount != ZT_TAG_LIST_COUNT_ZERO){
            [self setTotalTagCount:totalTagsCountForCycleCount];
        }
    });
}


/// Adding array to get the proper tags count when cyclecount is enabled.
/// @param tagsArray Tags array for the cyclecount operation.
-(void)addingArrayforCycleCount:(NSArray *) tagsArray
{
    for (zt_InventoryItem * tag in tagsArray) {
        BOOL isMatch = NO;
        for (zt_InventoryItem * cycleCountTag in cycleCountArray) {
            if ([[cycleCountTag getTagId] isEqual:[tag getTagId]]) {
                isMatch = YES;
                [cycleCountTag addCount:[tag getCount]];
            }
        }
        if (!isMatch) {
            [cycleCountArray addObject:tag];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        int totalUniqueTagCount = (int)[cycleCountArray count];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalUniqueTagCount] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setUniqueTagCount:totalUniqueTagCount];
    });

}

- (void)setUniqueTagCount:(int)count
{
    if (count == m_UniqueTags)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_UniqueTags / 10) == (count / 10))
    {
        upd = NO;
    }
    
    m_UniqueTags = count;
    
    [m_lblUniqueTagCountData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, count]];
    
    if ((YES == upd) || (m_fszUniqueTags < 0.0))
    {
        m_fszUniqueTags = [self fontSizeToFit:[m_lblUniqueTagCountData text] forLabel:m_lblUniqueTagCountData aMaxSize:200.0];
        [m_lblUniqueTagCountData setFont:[UIFont boldSystemFontOfSize:m_fszUniqueTags]];

    }
}

- (void)setTotalTagCount:(int)count;
{
    if (count == m_TotalTags)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_TotalTags / 10) == (count / 10))
    {
        upd = NO;
    }
    
    m_TotalTags = count;
    
    [m_lblTotalTagCountData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, count]];
    if ((YES == upd) || (m_fszTotalTags < 0.0))
    {
        m_fszTotalTags = [self fontSizeToFit:[m_lblTotalTagCountData text] forLabel:m_lblTotalTagCountData aMaxSize:50.0];
        [m_lblTotalTagCountData setFont:[UIFont boldSystemFontOfSize:m_fszTotalTags]];
    }
}

- (void)setReadRate:(int)rate
{
    if (rate == m_ReadRate)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_ReadRate / 10) == (rate / 10))
    {
        upd = NO;
    }
    
    m_ReadRate = rate;
    
    [m_lblReadRateData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_INT_FORMAT, rate]];
    
    if ((YES == upd) || (m_fszReadRate < 0.0))
    {
        m_fszReadRate = [self fontSizeToFit:[m_lblReadRateData text] forLabel:m_lblReadRateData aMaxSize:50.0];
        [m_lblReadRateData setFont:[UIFont boldSystemFontOfSize:m_fszReadRate]];
    }
}

- (void)setReadTime:(int)time
{
    int _time = time;
    int min = _time / 60;
    int sec = _time % 60;
    [m_lblReadTimeData setText:[NSString stringWithFormat:@"%02d:%02d ",min,sec]];
    readTimeValue = time;
    if (m_fszReadTime < 0.0)
    {
        m_fszReadTime = [self fontSizeToFit:[m_lblReadTimeData text] forLabel:m_lblReadTimeData aMaxSize:50.0];
        [m_lblReadTimeData setFont:[UIFont boldSystemFontOfSize:m_fszReadTime]];
    }
}


- (CGFloat)fontSizeToFit:(NSString*)text forLabel:(UILabel*)ui_label aMaxSize:(CGFloat)max_size;
{
    float lbl_height = ui_label.frame.size.height;
    float lbl_width = ui_label.frame.size.width;
    
    CGFloat font_size = max_size;
    CGSize text_size;
    
    do
    {
        font_size--;
        text_size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:font_size]}];
        
    } while ((text_size.height > lbl_height) || (text_size.width > lbl_width));
    
    return font_size - 5.0;
}

- (void)configureAppearance
{
    /* rounded elements */
    [[m_viewUniqueTagCountBackground layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_BIG];
    [[m_lblReadRateData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
    [[m_lblTotalTagCountData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
    [[m_lblReadTimeData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
}

- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        isRapidReadStarted = TRUE;
        
        [UIView performWithoutAnimation:^
         {
            [m_btnStartStop setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
             [m_btnStartStop layoutIfNeeded];
            [m_btnStartStop setSelected:YES];
         }];
        
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
        if(batchModeLabel.hidden)
        {
            m_lblUniqueTagCountData.hidden = YES;
            batchModeLabel.hidden = NO;
            [self.view bringSubviewToFront:batchModeLabel];
            if (![activeProfile  isEqual: CYCLE_COUNT_INDEX])
            {
                [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [self setReadRate:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [self setReadTime:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [matchingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
                [missingTagsData setText:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
            }
        }
        
        [self updateOperationDataUI];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setImage:[UIImage imageNamed:START_SCAN_ICON] forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
            [m_btnStartStop setSelected:NO];
        }];
       
       [self createCSVForStopTriggerDelayTime];
        isRapidReadStarted = FALSE;
       
        
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        if(!batchModeLabel.hidden)
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getTags:&statusMsg];
            batchModeLabel.hidden=YES;
            m_lblUniqueTagCountData.hidden = NO;
        }
        else if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] purgeTags:&statusMsg];
            if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
                [[zt_RfidAppEngine sharedAppEngine] reconnectAfterBatchMode];
        }
        /* update statictics */
        [self updateOperationDataUI];
    }
}

- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == in_progress)
    {
        /* start timer */
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_RR_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
    }
    else
    {
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        /* update statistics */
        [self updateOperationDataUI];
    }
}

-(BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID{
    if (!isRFID){
        return YES;
    }
    __block zt_RapidReadVC *__weak_self = self;
    
    BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    if (YES == pressed)
    {
        /* trigger press -> start operation if start trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerImmediate])
        {
            /* immediate start trigger */
            if (NO == requested)
            {
                /* operation is not in progress / requested */
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    else
    {
        /* trigger release -> stop operation if stop trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerImmediate])
        {
            /* immediate stop trigger */
            
            BOOL batchmodeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:ZT_BATCHMODE_ENABLED_KEY];
            
            if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus] != YES && batchmodeEnabled == YES)
            {
                SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
                rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
            }else
            {
                if (YES == requested)
                {
                    /* operation is already in progress or has been requested (case of periodic start trigger */
                    
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       [__weak_self btnStartStopPressed:nil];
                                   });
                }
            }
        }
    }
    return YES;
//    /* nrv364: process only on trigger press
//     root cause:
//     - suppose that start trigger is HH press and stop is immediate
//     - command issued
//     - trigger pressed
//     - trigger PRESS notification from RFID
//     - operation START notification from RFID
//     - trigger released
//     - trigger RELEASE notification from RFID
//     - we abort ongoing operation */
//    if (YES == pressed)
//    {
//        /* nrv364:
//         with periodic start trigger operation start/stop notifications indicate
//         inventory "loops" and abort cmd is required to stop the on going operation */
//        if ((YES == [[zt_RfidAppEngine sharedAppEngine] isRadioOperationInProgress]) ||
//            ((YES == m_OperationRequested) && (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerPeriodic])))
//        {
//            /* op in progress -> shall stop */
//
//            if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerHandheld])
//            {
//                /* if stop trigger is HH than we have no reason to perform a stop action manually */
//                dispatch_async(dispatch_get_main_queue(),
//                               ^{
//                                   [__weak_self btnStartStopPressed:nil];
//                               });
//            }
//        }
//        else
//        {
//            /* op not in progress -> shall start */
//            if (NO == m_OperationRequested)
//            {
//                if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerHandheld])
//                {
//                    /* if start trigger is HH than we have no reason to perform a start action manually */
//                    dispatch_async(dispatch_get_main_queue(),
//                                   ^{
//                                       [__weak_self btnStartStopPressed:nil];
//                                   });
//                }
//            }
//        }
//
//    }
//    return YES;
}


/// Cycle count button action.
/// @param sender Button reference.
- (IBAction)btnCycleCountPressed:(id)sender
{
    BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    if (YES == requested)
    {
        [self showWarning:INVENTORY_TAG_READING_INPROGRESS];
    }
    else
    {
        /* clear inventory data*/
        [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] clearInventoryItemList];
        /* stop timer */
        [[[zt_RfidAppEngine sharedAppEngine] operationEngine] setRadioOperationTime:0.0];
        /* update UI */
        [self updateOperationDataUI];
        
        [self setUniqueTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
        [self setTotalTagCount:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_TOTALREADS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO] forKey:ZT_UNIQUETAGS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// Taglist Matchmode feature.

/// To get the matching tags from the inventory data.
- (void)getMatchingTagList
{
    NSArray *inventoryArray = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    NSArray * tagListArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvTagListArray];
    NSMutableArray * tagIDArray = [[NSMutableArray alloc] init];
    
    for (TaglistDataObject * tagListObject in tagListArray) {
        [tagIDArray addObject:[tagListObject getTagId]];
    }
    
    NSMutableArray * matchingArray = [[NSMutableArray alloc] init];
    
    for (zt_InventoryItem * inventoryData in inventoryArray) {
        if ([tagIDArray containsObject:[inventoryData getTagId]]) {
            [matchingArray addObject:[inventoryData getTagId]];
        }
    }
        
    int matchingArrayCount = (int)[matchingArray count];
    int tagListArrayCount = (int)[tagIDArray count];
    
    [matchingTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)matchingArrayCount]];
    BOOL in_progress = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress];
    
    if (YES == in_progress)
    {
        [missingTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)tagListArrayCount - matchingArrayCount]];
    }else
    {
        [missingTagsData setText:[NSString stringWithFormat:ZT_CYCLECOUNT_LONG_FORMAT,(unsigned long)tagListArrayCount - matchingArrayCount]];
    }
    [self showProgress:matchingArrayCount];
    if (tagListArrayCount >= ZT_FRIENDLYNAME_ARRAY_COUNT) {
        if (matchingArrayCount == tagListArrayCount) {
            SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
            rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
            [zt_AlertView showInfoMessage:self.view withHeader:ZT_TAGLIST_FILE_CONTENT_EMPTY_STRING withDetails:ZT_TAGLIST_ALERT_MESSAGE_STRING withDuration:1];
            
            [self createCSVFileUsingInventoryData];
        }
    }
}

/// To show the progress for matching the tagscount.
/// @param tagsCount Tagscount from the .csv file.
- (void)showProgress:(int)tagsCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray * tagListArray = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getCsvTagListArray];
        NSMutableArray * tagIDArray = [[NSMutableArray alloc] init];
        
        for (TaglistDataObject * tagListObject in tagListArray) {
            [tagIDArray addObject:[tagListObject getTagId]];
        }
        int tagListArrayCount = (int)[tagIDArray count];
        int currentProgress = (int)((float)tagsCount/tagListArrayCount*ZT_FW_UPDATE_PROGRESS_100_PERCENT);
        [_progressBarView setProgress:(currentProgress / ZT_FW_UPDATE_PROGRESS_UI_100_PERCENT)];
    });
}

// Export data
/// Create the .csv file using the inventory data
/// @param tagListArray The taglist array from the inventory data.
- (void)createCSVFileUsingInventoryData{
    
    isCreateCSVFileMethodExcute = TRUE;
    BOOL tagListOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigDataExport];
    if (!tagListOption) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:ZT_EXPORTDATA_LOADING withDuration:ZT_EXPORTDATA_THREAD_SLEEP];
    });
    [NSThread sleepForTimeInterval:ZT_EXPORTDATA_THREAD_SLEEP];
    NSArray *inventoryArray = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    if ([inventoryArray count] <= ZT_EXPORTDATA_MIN_CHECK_ZERO) {
        return;
    }
    @try {
        ///Headers
        NSString *uniqueCount = [NSString stringWithFormat:ZT_EXPORTDATA__TOTAL_UNIQUE_COUNT_FORMAT,ZT_EXPORTDATA_UNIQUE_COUNT,m_UniqueTags];
        NSString *totalCount = [NSString stringWithFormat:ZT_EXPORTDATA__TOTAL_UNIQUE_COUNT_FORMAT,ZT_EXPORTDATA_TOTAL_COUNT,m_TotalTags];
        NSString *readTime = [CSVHelper getTimeToString:readTimeValue];
        NSString *tagsRowsHeader = [CSVHelper tagListHeading];
        NSString *tagsRows = [CSVHelper getAllTagListAsStringForCSV:inventoryArray];
        
        NSString *fullFileString = [NSString stringWithFormat:ZT_EXPORTDATA_FULL_FILE_FORMAT,ZT_EXPORTDATA_INVENTORY_SUMMARY,uniqueCount,totalCount,readTime,tagsRowsHeader,tagsRows];
        
        NSMutableString *tagListRowsMutableString = [fullFileString mutableCopy];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:ZT_EXPORTDATA_FILE_INDEX];
        NSString *fileName = [CSVHelper generateFileName];
        NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
        NSError *error;
        [tagListRowsMutableString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding      error:&error];
        NSArray *activityItems = @[[NSURL fileURLWithPath:filePath]];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:NULL];
        dispatch_async(dispatch_get_main_queue(),^{
            [self presentViewController:activityView animated:YES completion:NULL];
        });
        
        // access the completion handler
        activityView.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,
            NSError *error){
                // react to the completion
                if (completed) {
                    [self showSuccess:ZT_EXPORTDATA_SUCCESS_MESSAGE];
                } else {
                    [self showWarning:ZT_EXPORTDATA_CANCELLED_MESSAGE];
                }
                
                if (error) {
                    NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
                }
            };
       
     }
     @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
         dispatch_async(dispatch_get_main_queue(),^{
             
             [zt_AlertView showInfoMessage:self.view withHeader:ZT_TAGLIST_FILE_CONTENT_EMPTY_STRING withDetails:ZT_EXPORTDATA_FAILURE_MESSAGE withDuration:1];
         });
     }
    isRapidReadStarted = FALSE;
    isCreateCSVFileMethodExcute = FALSE;
   
}

- (void)showSuccess:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(),^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:YES aSuccessMessage:message aFailureMessage:EMPTY_STRING];
    });
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    //IBOutlet UIView *m_viewUniqueTagCountBackground;
    
    m_btnStartStop.titleLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_viewUniqueTagCountBackground.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    m_lblUniqueTagCountData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    m_lblTotalTagCountNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblUniqueTagCountNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblTotalTagCountData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    m_lblReadRateNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblReadRateData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    m_lblReadTimeNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    m_lblReadTimeData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    m_lblTagsSecond.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    missingTagsData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    matchingTagsData.textColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    missingTagsNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    matchingTagsNotice.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    _progressBarView.progressTintColor = [UIColor getDarkModeLabelTextColorForRapidRead:traitCollection];
    
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

// Create CSV for Stop TriggerDelayTime
-(void)createCSVForStopTriggerDelayTime {
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    long long timeoutStop = [sled currentStopTimeout];
    
    if (timeoutStop > 0) {
        
        if(isRapidReadStarted && !isCreateCSVFileMethodExcute) {
           
            NSLog(@" Line 1040");
            [self createCSVFileUsingInventoryData];
          
        }
        
    }
     
}

@end
