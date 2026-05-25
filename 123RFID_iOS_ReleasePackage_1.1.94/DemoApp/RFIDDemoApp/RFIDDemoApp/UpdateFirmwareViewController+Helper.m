//
//  UpdateFirmwareViewController+Helper.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-22.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UpdateFirmwareViewController+Helper.h"
#import "ScannerEngine.h"

@implementation UpdateFirmwareViewController (Helper)

/// Get release date label string
/// @param revision Revison string
/// @param date Date value
/// @param firmwareNameArray Firmware name array
-(NSString*)processReleasedDateLableString:(NSString*)revision withDate:(NSString*)date withFirmwareName:(NSMutableArray*)firmwareNameArray
{
    if (date == nil && revision == nil && date == nil) {
        return ZT_FW_UPDATE_EMPTY_STRING;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:ZT_FW_UPDATE_DATE_FORMAT_dd_MM_yyyy];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    if (dateFromString == nil) {
        [dateFormatter setDateFormat:ZT_FW_UPDATE_DATE_FORMAT_MM_dd_yyyy];
        dateFromString = [dateFormatter dateFromString:date];
    }
    
    [dateFormatter setDateFormat:ZT_FW_UPDATE_DATE_FORMAT_DOT_yyyy_dd_MM];
    NSString *formattedDate = [dateFormatter stringFromDate:dateFromString];
    if (revision == nil) {
        revision = ZT_FW_UPDATE_EMPTY_STRING;
    }
    if (formattedDate == nil) {
        formattedDate = ZT_FW_UPDATE_EMPTY_STRING;
    }
    NSString *firmwareName = [self getCorrectFirmwareName:firmwareNameArray];
    if (firmwareName == nil) {
        firmwareName = ZT_FW_UPDATE_EMPTY_STRING;
    }
    
    if([[ScannerEngine sharedScannerEngine] firmwareDidUpdate]) {
        return [NSString stringWithFormat:ZT_FW_UPDATE_CURRENT_RELEASE_FORMAT, revision,formattedDate, firmwareVersion];
    } else {
        return [NSString stringWithFormat:ZT_FW_UPDATE_TO_RELEASE_FORMAT, revision,formattedDate, firmwareName];
    }
}

/// Get firmware name from aarya
/// @param firmwareNameArray Firmware name array
- (NSString*)getCorrectFirmwareName:(NSMutableArray*)firmwareNameArray{
    NSString *matchingFirmwareName = nil;
    CFTimeInterval startTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = ZT_FW_UPDATE_CONTENT_READER_INIT_ELAPSED_TIME;
    while (firmwareVersion == nil && elapsedTime < ZT_FW_UPDATE_CONTENT_READER_ELAPSED_TIME) {
        [NSThread sleepForTimeInterval:ZT_FW_UPDATE_CONTENT_READER_THREAD_SLEEP];
        elapsedTime = CACurrentMediaTime() - startTime;
    }
    for (NSString *firmwareNameString in firmwareNameArray) {
        if ([firmwareNameString isEqualToString:firmwareVersion]) {
            matchingFirmwareName = firmwareNameString;
            break;
        }
    }
    if (matchingFirmwareName == nil) {
        for (NSString *firmwareNameString in firmwareNameArray) {
            if (firmwareNameString.length > ZT_FW_UPDATE_NAME_STRING_INDEX && [[firmwareNameString substringToIndex:ZT_FW_UPDATE_NAME_STRING_INDEX] isEqualToString:[firmwareVersion substringToIndex:ZT_FW_UPDATE_NAME_STRING_INDEX]]) {
                matchingFirmwareName = firmwareNameString;
                break;
            }
        }
    }
    return matchingFirmwareName;
}

/// Check firmware file and set selected file path
- (NSString*)getAvailableFirmwareFile{
    selectedFirmwareFilePath = nil;
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:ZT_PLUGIN_DEFAULT_DOCUMENT];
    NSString *downloadPathString = [documentDirectory stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    //first look for plugins
    NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:downloadPathString];
   
    if (pluginArray.count == ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO) {
       
        NSArray *firmwareFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:downloadPathString];
        NSArray *firmwareFileArrayEdat = [self findFiles:@"edat" fromPath:downloadPathString];
        NSArray *firmwareFileArrayEDAT = [self findFiles:@"EDAT" fromPath:downloadPathString];
      
        if (firmwareFileArray.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO || firmwareFileArrayEdat.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO || firmwareFileArrayEDAT.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO) {
            
            commandType = ZT_INFO_UPDATE_FROM_DAT;
            NSString *pathValue = @"";
            if (firmwareFileArray.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO){
                pathValue = (NSString*)[downloadPathString stringByAppendingPathComponent:(NSString*)firmwareFileArray[ZT_FW_UPDATE_PLUGINS_ARRAY_FILE_INDEX]];
            }
            else if(firmwareFileArrayEdat.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO){
                pathValue = (NSString*)[downloadPathString stringByAppendingPathComponent:(NSString*)firmwareFileArrayEdat[ZT_FW_UPDATE_PLUGINS_ARRAY_FILE_INDEX]];
            }
            else if(firmwareFileArrayEDAT.count > ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO){
                pathValue = (NSString*)[downloadPathString stringByAppendingPathComponent:(NSString*)firmwareFileArrayEDAT[ZT_FW_UPDATE_PLUGINS_ARRAY_FILE_INDEX]];
            }
            
            selectedFirmwareFilePath = [[NSString alloc] initWithString: pathValue];
        }
    } else {
        commandType = ZT_INFO_UPDATE_FROM_PLUGIN;
        NSString *pathValue = (NSString*)[downloadPathString stringByAppendingPathComponent:(NSString*)pluginArray[ZT_FW_UPDATE_PLUGINS_ARRAY_FILE_INDEX]];
        selectedFirmwareFilePath = [[NSString alloc] initWithString: pathValue];
    }
    return selectedFirmwareFilePath;
}

/// Find file from given path
/// @param extension File's extension
/// @param path File path
/// @Return Matches plugins files
- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path{
    NSMutableArray *matchesFiles = [[NSMutableArray alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matchesFiles addObject:item];
        }
    }
    
  
    return matchesFiles;
}

/// Find file from given path
/// @param extension File's extension
/// @param path File path
/// @Return Matches plugins files
- (NSString *)findFilesEdatName:(NSString *)extension fromPath:(NSString*)path{
   
        // Get the file manager instance
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Retrieve the contents of the directory
        NSError *error = nil;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
        
        if (error) {
            NSLog(@"Error reading directory: %@", error.localizedDescription);
            return @"";
        }
        
        // Specify the file extension you're interested in
        NSString *desiredExtension = @"edat"; // Change this to the desired extension
        
        // Filter files by the desired extension
        NSMutableArray *filteredFileNames = [NSMutableArray array];
        for (NSString *fileName in files) {
            if ([[fileName pathExtension] isEqualToString:desiredExtension]) {
                [filteredFileNames addObject:fileName];
            }
        }
        
        // Print the filtered file names
        NSLog(@"Files with .%@ extension:", desiredExtension);
        NSString* fileNameOfEdat= @"";
        for (NSString *fileName in filteredFileNames) {
            NSLog(@"%@", fileName);
            NSString *fileNameWithoutExtension = [fileName stringByDeletingPathExtension];
                   // Get the file extension
            NSLog(@"File Name without Extension: %@", fileNameWithoutExtension);
            fileNameOfEdat = fileNameWithoutExtension;
        }
    return fileNameOfEdat;
}

/// Get plugins mismatch attributed string
- (NSMutableAttributedString*)getPluginMismatchString{
    UIColor *contentColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        contentColor = [UIColor labelColor];
    }
    else
    {
        contentColor = [UIColor blackColor];
    }
    NSMutableAttributedString * mismatchContentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:FW_PAGE_PLUGIN_MISMATCH_CONTENT_STRING_FORMAT,FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE, FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO]];

    NSMutableParagraphStyle *paragraphStyle;
    paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setTabStops:@[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:15 options:[NSDictionary dictionary]]]];
    [paragraphStyle setDefaultTabInterval:15];
    [paragraphStyle setFirstLineHeadIndent:0];
    [paragraphStyle setHeadIndent:15];

    [mismatchContentString addAttributes:@{NSParagraphStyleAttributeName: paragraphStyle} range:NSMakeRange(0,[mismatchContentString length])];
    [mismatchContentString addAttribute:NSForegroundColorAttributeName
                   value:contentColor
                   range:NSMakeRange(0,[mismatchContentString length])];
    return mismatchContentString;
}

/// Get plugins mismatch attributed string
- (NSMutableAttributedString*)getFirmwareUpdateHelpString{
    UIColor *contentColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        contentColor = [UIColor labelColor];
    }
    else
    {
        contentColor = [UIColor blackColor];
    }
    
    NSMutableAttributedString * helpContentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:FW_PAGE_HELP_SCREEN_CONTENT_STRING_FORMAT,FW_PAGE_HELP_PAGE_TITLE, FW_PAGE_HELP_CONTENT_ONE,FW_PAGE_HELP_CONTECT_TWO]];

    NSString * titleString = FW_PAGE_HELP_PAGE_TITLE;
    [helpContentString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} range:NSMakeRange(0, titleString.length)];
    
    NSMutableParagraphStyle *paragraphStyle;
    paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setTabStops:@[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:15 options:[NSDictionary dictionary]]]];
    [paragraphStyle setDefaultTabInterval:15];
    [paragraphStyle setFirstLineHeadIndent:0];
    [paragraphStyle setHeadIndent:15];

    [helpContentString addAttributes:@{NSParagraphStyleAttributeName: paragraphStyle} range:NSMakeRange(0,[helpContentString length])];
    [helpContentString addAttribute:NSForegroundColorAttributeName
                   value:contentColor
                   range:NSMakeRange(0,[helpContentString length])];
    return helpContentString;
}


/// Find file from given path
/// @param extension File's extension
/// @param path File path
/// @Return Matches plugins files
- (NSString *)findFilesEDATtName:(NSString *)extension fromPath:(NSString*)path{
   
        // Get the file manager instance
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Retrieve the contents of the directory
        NSError *error = nil;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
        
        if (error) {
            NSLog(@"Error reading directory: %@", error.localizedDescription);
            return @"";
        }
        
        // Specify the file extension you're interested in
        NSString *desiredExtension = @"EDAT"; // Change this to the desired extension
        
        // Filter files by the desired extension
        NSMutableArray *filteredFileNames = [NSMutableArray array];
        for (NSString *fileName in files) {
            if ([[fileName pathExtension] isEqualToString:desiredExtension]) {
                [filteredFileNames addObject:fileName];
            }
        }
        
        // Print the filtered file names
        NSLog(@"Files with .%@ extension:", desiredExtension);
        NSString* fileNameOfEdat= @"";
        for (NSString *fileName in filteredFileNames) {
            NSLog(@"%@", fileName);
            NSString *fileNameWithoutExtension = [fileName stringByDeletingPathExtension];
                   
            // Get the file extension
            NSLog(@"File Name without Extension: %@", fileNameWithoutExtension);
               
            fileNameOfEdat = fileNameWithoutExtension;
        }
    return fileNameOfEdat;
}
@end
