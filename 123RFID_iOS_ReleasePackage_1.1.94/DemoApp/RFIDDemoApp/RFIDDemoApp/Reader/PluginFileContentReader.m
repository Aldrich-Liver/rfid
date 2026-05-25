//
//  PluginFileContentReader.m
//  RFIDDemoApp
//
//  Created by Sivarajah Pranavan on 2021-09-16.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "PluginFileContentReader.h"
#import "ui_config.h"
#import "ZZArchive.h"
#import "ZZArchiveEntry.h"

@interface PluginFileContentReader()
{
    NSMutableArray *scannerFirmwareVersions;
}

@end

@implementation PluginFileContentReader


/// Read plugins
/// @param block completion block
- (NSString*)readPluginFileData:(void (^)(FirmwareUpdateModel *model))block{
    firmwareModel = [[FirmwareUpdateModel alloc] init];
    scannerFirmwareVersions = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //extract release note text from the zip
        NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:ZT_PLUGIN_DEFAULT_DOCUMENT];
        NSString *downloadDirectory = [documentDirectory stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
        //first look for plugins
        NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:downloadDirectory];
        if (pluginArray.count > ZT_PLUGINS_FILE_CONTENT_READER_ZERO_INDEX) {
            //now we have a plugin file. get the text file out of it.
            pngFileName = nil;
            NSString *pathForPlugin = [downloadDirectory stringByAppendingPathComponent:pluginArray[ZT_PLUGINS_FILE_CONTENT_READER_ZERO_INDEX]];
            ZZArchive* oldArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:pathForPlugin] error:nil];
            for (ZZArchiveEntry *firstArchiveEntry in oldArchive.entries) {
                NSString *fileName = firstArchiveEntry.fileName;
                if ([[fileName pathExtension] isEqualToString:ZT_RELEASE_NOTES_FILE_EXTENTION]) {
                    [self readReleaseNotes:firstArchiveEntry];
                    
                    if (releaseNotes == nil) {
                        [self readReleaseNotes:firstArchiveEntry];
                    }
                } else if([fileName isEqualToString:ZT_METADATA_FILE]) {
                    NSData *releaseNoteData = [firstArchiveEntry newDataWithError:nil];
                    xmlContent = [NSString stringWithUTF8String:[releaseNoteData bytes]];
                    [self parseXMLData:releaseNoteData];
                    
                    firmwareModel.supportedModels = modelList;
                    NSString *formattedPlugInRev = [plugInRev stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    NSString *formattedPlugInRevNoSpace = [formattedPlugInRev stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    firmwareModel.plugInRev = formattedPlugInRevNoSpace;
                    NSString *formattedPluginDate = [plugInDate stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    NSString *formattedPluginDateNoSpace = [formattedPluginDate stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    firmwareModel.releasedDate = formattedPluginDateNoSpace;
                    firmwareModel.firmwareNameArray = scannerFirmwareVersions;
                    
                    NSString *plugFamilyFinlae = [plugFamily stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    NSString *plugNameFinlae = [plugName stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
                    firmwareModel.plugFamily = [NSString stringWithFormat:ZT_PLUGINS_FILE_CONTENT_READER_FAMILY_FORMAT, plugFamilyFinlae, plugNameFinlae];
                    
                    if (pngFileName != nil) {
                        for (ZZArchiveEntry *crntArchiveEntry in oldArchive.entries) {
                            NSString *fileName = crntArchiveEntry.fileName;
                            if ([fileName isEqualToString:pngFileName]) {
                                //we find a match
                                firmwareModel.imgData = [crntArchiveEntry newDataWithError:nil];
                            }
                        }
                    }
                }
            }
        }
        if (releaseNotes == nil) {
            NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:downloadDirectory];
            if (pluginArray.count > ZT_PLUGINS_FILE_CONTENT_READER_ZERO_INDEX) {
                //now we have a plugin file. get the text file out of it.
                pngFileName = nil;
                NSString *pathForPlugin = [downloadDirectory stringByAppendingPathComponent:pluginArray[ZT_PLUGINS_FILE_CONTENT_READER_ZERO_INDEX]];
                ZZArchive* oldArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:pathForPlugin] error:nil];
                for (ZZArchiveEntry *firstArchiveEntry in oldArchive.entries) {
                    NSString *fileName = firstArchiveEntry.fileName;
                    if ([[fileName pathExtension] isEqualToString:ZT_RELEASE_NOTES_FILE_EXTENTION]) {
                        [self readReleaseNotes:firstArchiveEntry];
                        
                        if (releaseNotes == nil) {
                            [self readReleaseNotes:firstArchiveEntry];
                            if (releaseNotes == nil) {
                                [self readReleaseNotes:firstArchiveEntry];
                            }
                        }
                    }
                }
            }
        }
        block(firmwareModel);
    });
    
    return nil;
}


/// Read release note data
/// @param firstArchiveEntry First archive entry
- (void)readReleaseNotes:(ZZArchiveEntry*)firstArchiveEntry
{
    NSData *releaseNoteData = [firstArchiveEntry newDataWithError:nil];
    releaseNotes =  [[NSString alloc] initWithData:releaseNoteData encoding:NSUTF8StringEncoding];
    firmwareModel.releaseNotes = releaseNotes;
}


/// Read string from file
/// @param filePath File path
- (NSString*)readStringFromFile:(NSString*)filePath{
    return [NSString stringWithContentsOfFile:filePath
                                     encoding:NSUTF8StringEncoding
                                        error:NULL];
}

/// Find files from path
/// @param extension File extension
/// @param path File path
- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}


/// Parse XML data
/// @param xmlData XML data
- (void)parseXMLData:(NSData*)xmlData{
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    
    // set delegate
    [nsXmlParser setDelegate:self];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    if (success) {
    } else {
        NSLog(@"Error parsing document!");
    }
}


/// XML parser
/// @param parser NSXML parser
/// @param elementName Element Name
/// @param namespaceURI URL
/// @param qualifiedName Qualified name
/// @param attributeDict Attribute dictionary
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDictionary {
    if ([elementName isEqualToString:ZT_MODEL_LIST_TAG]) {
        modelList = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:ZT_FIRMWARE_NAME_TAG]) {
        // We are done with user entry – add the parsed user
        [scannerFirmwareVersions addObject:[[[attributeDictionary objectForKey:ZT_PLUGINS_FILE_CONTENT_READER_KEY_NAME]stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING]stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING]];
    }
}

/// Parser
/// @param parser NSXML Parser
/// @param string Found characters
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElementValue) {
        // init the ad hoc string with the value
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        // append value to the ad hoc string
        [currentElementValue appendString:string];
    }
}


/// Parser
/// @param parser NSXML parser
/// @param elementName End element
/// @param namespaceURI Namespace URI
/// @param qName Name
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    
    if ([elementName isEqualToString:ZT_MODEL_LIST_TAG]) {
        // We reached the end of the XML document
        return;
    } else if ([elementName isEqualToString:ZT_MODEL_TAG]) {
        // We are done with user entry – add the parsed user
        NSString *deviceName = [[currentElementValue stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING] stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
        [modelList addObject:deviceName];
    } else if ([elementName isEqualToString:ZT_REVISION_TAG]) {
        // We are done with user entry – add the parsed user
        plugInRev = currentElementValue;
    } else if ([elementName isEqualToString:ZT_RELEASED_DATE_TAG]) {
        // We are done with user entry – add the parsed user
        plugInDate = currentElementValue;
    } else if ([elementName isEqualToString:ZT_FAMILY_TAG]) {
        // We are done with user entry – add the parsed user
        plugFamily = currentElementValue;
    } else if ([elementName isEqualToString:ZT_NAME_TAG]) {
        // We are done with user entry – add the parsed user
        plugName = currentElementValue;
    } else if ([elementName isEqualToString:ZT_PLUGINS_FILE_CONTENT_READER_COMPONENT]) {
        // We are done with user entry – add the parsed user
        [scannerFirmwareVersions addObject:[[currentElementValue stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING] stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING]];
    } else if ([elementName isEqualToString:ZT_PICTURE_FILE_NAME]) {
        // We are done with user entry – add the parsed user
        pngFileName = [[currentElementValue stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING] stringByReplacingOccurrencesOfString:ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING withString:ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING];
    }

    currentElementValue = nil;
}

@end
