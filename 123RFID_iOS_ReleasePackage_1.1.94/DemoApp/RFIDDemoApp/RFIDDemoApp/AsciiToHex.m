//
//  AsciiToHex.m
//  RFIDDemoApp
//
//  Created by Nilusha Wimalasena on 2021-10-07.
//  Copyright © 2021 Zebra Technologies. All rights reserved.
//

#import "AsciiToHex.h"

#define BYTE_TO_HEX_FORMAT @"%02x"
#define START_END_CHARACTER @"'"

@implementation AsciiToHex

-(id)init
{
    self = [super init];
    if (self != nil)
    {
    
    }
    return self;
}

+ (NSString *)stringFromAsciiString:(NSString *)asciiString{
    
//    if(asciiString != NULL){
//        
//        if(![[asciiString substringToIndex:1] isEqualToString: START_END_CHARACTER] && ![[asciiString substringFromIndex:[asciiString length]-1] isEqualToString: START_END_CHARACTER])
//        {
//            return asciiString;
//        }
//        
//        NSRange asciiStringRange = NSMakeRange(1,asciiString.length - 2);
//        NSString *selectedAsciiString = [asciiString substringWithRange:asciiStringRange];
//        
//        const unsigned char *bytes = (const unsigned char *)[selectedAsciiString UTF8String];
//        
//        NSMutableString *hex = [NSMutableString new];
//        for (NSInteger possession = 0; possession < selectedAsciiString.length; possession++) {
//            [hex appendFormat:BYTE_TO_HEX_FORMAT, bytes[possession]];
//        }
//        return [hex copy];
//        
//    }
//    else{
//        return @"";
//    }
    
    if (asciiString != nil && asciiString.length > 0) {
        // Check if the first and last characters are not equal to START_END_CHARACTER
        if (![[asciiString substringToIndex:1] isEqualToString:START_END_CHARACTER] &&
            ![[asciiString substringFromIndex:asciiString.length - 1] isEqualToString:START_END_CHARACTER]) {
            return asciiString;
        }
        
        // Ensure the string has at least 2 characters for this range operation
        if (asciiString.length > 2) {
            NSRange asciiStringRange = NSMakeRange(1, asciiString.length - 2);
            NSString *selectedAsciiString = [asciiString substringWithRange:asciiStringRange];
            
            const unsigned char *bytes = (const unsigned char *)[selectedAsciiString UTF8String];
            
            NSMutableString *hex = [NSMutableString new];
            for (NSInteger possession = 0; possession < selectedAsciiString.length; possession++) {
                [hex appendFormat:BYTE_TO_HEX_FORMAT, bytes[possession]];
            }
            return [hex copy];
        } else {
            // Handle the case where the string is too short for range operation
            return @"";
        }
    } else {
        return @"";
    }
}


@end
