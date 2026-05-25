//
//  HexToAscii.m
//  RFIDDemoApp
//
//  Created by Nilusha Wimalasena on 2021-09-27.
//  Copyright © 2021 Zebra Technologies. All rights reserved.
//

#import "HexToAscii.h"

#define STARTING_END_CHARACTER @"'"
#define EMPTY_CHARACTER @" "
#define CHARACTER_IDENTIFICATION @"%c"

/// Convert string to hex string
@implementation HexToAscii

static char EXTENDED_ASCII_CHAR[] = { (char)0x00C7, (char)0x00FC, (char)0x00E9, (char)0x00E2,
    (char)0x00E4, (char)0x00E0, (char)0x00E5, (char)0x00E7, (char)0x00EA, (char)0x00EB, (char)0x00E8, (char)0x00EF,
    (char)0x00EE, (char)0x00EC, (char)0x00C4, (char)0x00C5, (char)0x00C9, (char)0x00E6, (char)0x00C6, (char)0x00F4,
    (char)0x00F6, (char)0x00F2, (char)0x00FB, (char)0x00F9, (char)0x00FF, (char)0x00D6, (char)0x00DC, (char)0x00A2,
    (char)0x00A3, (char)0x00A5, (char)0x20A7, (char)0x0192, (char)0x00E1, (char)0x00ED, (char)0x00F3, (char)0x00FA,
    (char)0x00F1, (char)0x00D1, (char)0x00AA, (char)0x00BA, (char)0x00BF, (char)0x2310, (char)0x00AC, (char)0x00BD,
    (char)0x00BC, (char)0x00A1, (char)0x00AB, (char)0x00BB, (char)0x2591, (char)0x2592, (char)0x2593, (char)0x2502,
    (char)0x2524, (char)0x2561, (char)0x2562, (char)0x2556, (char)0x2555, (char)0x2563, (char)0x2551, (char)0x2557,
    (char)0x255D, (char)0x255C, (char)0x255B, (char)0x2510, (char)0x2514, (char)0x2534, (char)0x252C, (char)0x251C,
    (char)0x2500, (char)0x253C, (char)0x255E, (char)0x255F, (char)0x255A, (char)0x2554, (char)0x2569, (char)0x2566,
    (char)0x2560, (char)0x2550, (char)0x256C, (char)0x2567, (char)0x2568, (char)0x2564, (char)0x2565, (char)0x2559,
    (char)0x2558, (char)0x2552, (char)0x2553, (char)0x256B, (char)0x256A, (char)0x2518, (char)0x250C, (char)0x2588,
    (char)0x2584, (char)0x258C, (char)0x2590, (char)0x2580, (char)0x03B1, (char)0x00DF, (char)0x0393, (char)0x03C0,
    (char)0x03A3, (char)0x03C3, (char)0x00B5, (char)0x03C4, (char)0x03A6, (char)0x0398, (char)0x03A9, (char)0x03B4,
    (char)0x221E, (char)0x03C6, (char)0x03B5, (char)0x2229, (char)0x2261, (char)0x00B1, (char)0x2265, (char)0x2264,
    (char)0x2320, (char)0x2321, (char)0x00F7, (char)0x2248, (char)0x00B0, (char)0x2219, (char)0x00B7, (char)0x221A,
    (char)0x207F, (char)0x00B2, (char)0x25A0, (char)0x00A0 };

-(id)init
{
    self = [super init];
    if (self != nil)
    {
    
    }
    return self;
}

/// Convert string to hex string
/// @param hexString The hex valued string
/// @Return ASCII value result
+ (NSString *)stringFromHexString:(NSString *)hexString {

    if(hexString != NULL && ![hexString isEqualToString:@""])
    {
        // The hex codes should all be two characters.
        if (([hexString length] % 2) != 0)
            return hexString;
        
        NSMutableString *asciiString = [[NSMutableString alloc]init];
        [asciiString appendString:STARTING_END_CHARACTER];
        
        for (int characterIndex = 0; characterIndex < [hexString length]; characterIndex += 2) {
            unsigned char firstCharacter = [hexString characterAtIndex:characterIndex];
            unsigned char secondCharacter = [hexString characterAtIndex:(characterIndex+1)];
            unsigned char hexCharacter = (char)([self hexToInteger:firstCharacter] << 4 | [self hexToInteger:secondCharacter]);
            if([self hexToInteger:firstCharacter] <= 7 && [self hexToInteger:secondCharacter] <= 0xf && hexCharacter > 0x20 && hexCharacter <= 0x7f){
                [asciiString appendString: [NSString stringWithFormat:CHARACTER_IDENTIFICATION, hexCharacter]];
            }else if([self hexToInteger:firstCharacter] >= 8 && [self hexToInteger:secondCharacter] <= 0xf && hexCharacter >= 0x80 && hexCharacter <= 0xff){
                [asciiString appendString: [NSString stringWithFormat:CHARACTER_IDENTIFICATION, EXTENDED_ASCII_CHAR[(int)hexCharacter - 0x7F]]];
            }else{
                [asciiString appendString: EMPTY_CHARACTER];
            }
        }
        [asciiString appendString: STARTING_END_CHARACTER];
        return asciiString;
        
    }else{
        return hexString;
    }
}

/// Convert hex value to integer value
/// @param characterValue The character value which need to convert to int
/// @Return Integer value of the character
+ (int)hexToInteger:(char)characterValue{
    
    if('a' <= characterValue && characterValue <= 'f')
        return characterValue - 'a' + 10;
    if('A' <= characterValue && characterValue <= 'F')
        return characterValue - 'A' + 10;
    if('0' <= characterValue && characterValue <= '9')
        return characterValue - '0';
    return 0;
}


@end
