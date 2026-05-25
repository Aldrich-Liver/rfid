//
//  AssetDetailsVC.m
//  RFIDDemoApp
//
//  Created by Kasun Adhikari on 2021-11-17.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.

//
#import "AssetDetailsVC.h"
#import "SbtScannerInfo+AssetsTblRepresentation.h"
#import "ScannerEngine.h"
#import "ui_config.h"
#import "config.h"
#import "RfidAppEngine.h"

@interface AssetDetailsVC ()

@end
/// Asset details  table view controller
@implementation AssetDetailsVC

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:SCANNER_ASSET_INFORMATION_TITLE];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getTableData) withObject:nil withString:nil];
    
    
}


/// This method is to set the asset information in to the table
- (void)getTableData {
    didStartDataRetrieving = YES;
    SbtScannerInfo *scannerInfo = [[ScannerEngine sharedScannerEngine] getConnectedScannerInfo];
    
    NSMutableDictionary *savedResultDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:ZT_DEVICEINFO_DEFAULTS_KEY];
    
    
    if (savedResultDictionary == nil && [self checkResultDictionaryValues:savedResultDictionary] == FALSE)
    {
        [[NSUserDefaults standardUserDefaults] setValue:ZT_DEVICEINFO_API_CALL_VALUE1 forKey:ZT_DEVICEINFO_API_CALL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.resultDictioanry = [scannerInfo getAssetsTableRepresentation:^(NSMutableDictionary *dictionary) {
        
            [self operationComplete];
            self.resultDictioanry = dictionary;
            [self.tableView reloadData];
            self->didStartDataRetrieving = NO;
            [[NSUserDefaults standardUserDefaults] setValue:self.resultDictioanry forKey:ZT_DEVICEINFO_DEFAULTS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }else
    {
        [self operationComplete];
        self.resultDictioanry = savedResultDictionary;

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      }
    );
    
    
}


/// Check the dictionary values are true.
/// - Parameter valuesDictionary: Result dictionary.
- (BOOL)checkResultDictionaryValues:(NSMutableDictionary*)valuesDictionary
{
    BOOL isValid = FALSE;
    for(int i = 0; i < [valuesDictionary[SCANNER_ASSET_INFORMATION_TABLE_VALUES] count]; i++)
    {
        if (![valuesDictionary[SCANNER_ASSET_INFORMATION_TABLE_VALUES][i]  isEqual: @""])
        {
            isValid = TRUE;
        }else
        {
            isValid = FALSE;
        }
    }
    
    return isValid;
}

// Method to check the model number contains the value rfd8500
- (BOOL)containsRfd8500:(NSString *)modelName
{
    if (modelName == nil)
    {
            return NO;  // Return NO if the modelName is nil to avoid potential crashes
    }
        
    NSRange range = [modelName rangeOfString:@"RFD8500"];
    return range.location != NSNotFound;
}

////Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SCANNER_ASSET_INFORMATION_SECTION_COUNT;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.resultDictioanry[SCANNER_ASSET_INFORMATION_TABLE_VALUES] isKindOfClass:[NSMutableArray class]]) {
        return ((NSMutableArray*)self.resultDictioanry[SCANNER_ASSET_INFORMATION_TABLE_VALUES]).count;
    } else {
        
        zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        
        if ([sled.readerPL33 isEqualToString:EMPTY_STRING]) {
            return SCANNER_ASSET_INFORMATION_TABLE_ROW_COUNT_PL500;
        }else
        {
            return SCANNER_ASSET_INFORMATION_TABLE_ROW_COUNT;
        }
    }
}

/// Asks the data source for a cell to insert in a particular location of the table view. Required.
/// @param tableView A table-view object requesting the cell.
/// @param indexPath An index path locating a row in tableView.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = SCANNER_ASSET_INFORMATION_TABLE_CELL;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if(indexPath.row == SCANNER_ASSET_INFORMATION_TABLE_DOM_ROW){
    cell.detailTextLabel.text = self.resultDictioanry[SCANNER_ASSET_INFORMATION_TABLE_VALUES][indexPath.row];
        cell.textLabel.text = SCANNER_ASSET_INFORMATION_DOM;
    }else{
        cell.detailTextLabel.text = self.resultDictioanry[SCANNER_ASSET_INFORMATION_TABLE_VALUES][indexPath.row];
    cell.textLabel.text = self.resultDictioanry[SCANNER_ASSET_INFORMATION_TABLE_TITLES][indexPath.row];
    }
    
    return cell;
}

@end
