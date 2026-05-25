//
//  Sgtin96.m
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2023-03-20.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sgtin96.h"

// Implementation of Sgtin96 class which decodes RFID tags data to SGTIN96 format
@implementation Sgtin96

NSInteger companyPrefixBitTable[7] = {20, 24, 27, 30, 34, 37, 20};
NSInteger itemReferenceIndicatorBitTable[7] = {24, 20, 17, 14, 10, 7, 4};
NSInteger companyPrefixLengths[7] = {12, 11, 10, 9, 8, 7, 6};
NSInteger partitionValues[7] = {0, 1, 2, 3, 4, 5, 6};

NSInteger companyPrefixBits;
NSInteger itemReferenceIndicatorBits;

// returns company prefix length from companyPrefixLengths array
-(NSInteger) getCompanyPrefixLength: (NSInteger) i {
    return companyPrefixLengths[i];
}

// returns partition value from partitionValues array
-(NSInteger) getPartitionValue: (NSInteger) i {
    return partitionValues[i];
}

// returns the company prefix bits
-(NSInteger) getCompanyPrefixBits {
    return companyPrefixBits;
}

// returns the item reference indicator bits
-(NSInteger) getItemReferenceIndicatorBits {
    return itemReferenceIndicatorBits;
}

// Checks the company prefix length is between 6 and 12 and returns it
-(NSInteger) getByCompanyPrefixLength: (NSInteger) companyPrefixLength {
    if (companyPrefixLength < 6 || companyPrefixLength > 12) {
        @throw NSInvalidArgumentException;
                    
    }
    return (companyPrefixLength - 6);
}

// returns the index of the element in company prefix bits array to get the partiotin value
-(NSInteger) getIndexFromCPBarrayToGetPV: (NSInteger) partitionValue {
    if (partitionValue < 0 || partitionValue > 6) {
        @throw NSInvalidArgumentException;
                    
    }
    return (6 - partitionValue);
}

// returns the value from company prefix bits table
-(NSInteger) returnValueFromCPBTable: (NSInteger) i{
    return companyPrefixBitTable[i];
}

NSString *HEADER = @"00110000";
NSInteger Sgtin96LengthBits = 96;
NSInteger Sgtin96LengthHex = 24;

// Prepend the zeros to company prefix and item reference for binary numbers
-(NSString *) zeroFillBinary: (NSString*) s n:(NSInteger) n {
    NSInteger fill = n - s.length;
    NSString *Zeros = @"";
    if (fill > 0) {
        Zeros = [Zeros stringByReplacingOccurrencesOfString:@"\0"
                                             withString:@"0"];
    }
    return [NSString stringWithFormat:@"%@%@", Zeros, s];
}

// Prepend the zeros to company prefix and item reference for non binary numbers
-(NSString *) zeroFillNotBinary: (NSString*) s n:(NSInteger) n {

    NSString* format =[NSString stringWithFormat:@"%%0%zdzd", n];
    NSInteger sInt = [s integerValue];
    NSString *theString = [NSString stringWithFormat:format, sInt];

    return  theString;
}

// Binary to Hex conversion
-(NSString *) binaryToHex: (NSString*) bin {
   const char* cstr = [bin cStringUsingEncoding: NSASCIIStringEncoding];
   NSUInteger len = strlen(cstr);
   const char* lastChar = cstr + len - 1;
   NSUInteger curVal = 1;
   NSUInteger result = 0;
    
   while (lastChar >= cstr) {
       if (*lastChar == '1')
       {
           result += curVal;
       }
       lastChar--;
       curVal <<= 1;
   }
    NSString *resultStr = [NSString stringWithFormat: @"%lx", (unsigned long)result];
    return resultStr;
}

// Hex to binary conversion
- (NSString*)hexToBinary:(NSString*)hexString
{
NSMutableString *returnString = [NSMutableString string];
    for(int i = 0; i < [hexString length]; i++)
    {
        char c = [[hexString lowercaseString] characterAtIndex:i];

        switch(c) {
            case '0': [returnString appendString:@"0000"]; break;
            case '1': [returnString appendString:@"0001"]; break;
            case '2': [returnString appendString:@"0010"]; break;
            case '3': [returnString appendString:@"0011"]; break;
            case '4': [returnString appendString:@"0100"]; break;
            case '5': [returnString appendString:@"0101"]; break;
            case '6': [returnString appendString:@"0110"]; break;
            case '7': [returnString appendString:@"0111"]; break;
            case '8': [returnString appendString:@"1000"]; break;
            case '9': [returnString appendString:@"1001"]; break;
            case 'a': [returnString appendString:@"1010"]; break;
            case 'b': [returnString appendString:@"1011"]; break;
            case 'c': [returnString appendString:@"1100"]; break;
            case 'd': [returnString appendString:@"1101"]; break;
            case 'e': [returnString appendString:@"1110"]; break;
            case 'f': [returnString appendString:@"1111"]; break;
            default : break;
        }
    }

    return returnString;
}

// Binary to integer conversion
-(long) binaryToInt: (NSString*) bin {
    return strtol([bin UTF8String], NULL, 2);
}

// The main decode function (decodes RFID tags to SGTI96 format
-(NSString *)decode: (NSString *) sgtin96_epc {

    NSInteger filterValue, partitionValue, companyPrefixBits, companyPrefixLength, itemReferenceLength;
    NSInteger itemReferenceValue;
    long companyPrefixValue, serialNumber;
    NSString *companyPrefixFinalValue, *itemReferenceFinalValue;

        
    NSString *binary = [self zeroFillBinary:[self hexToBinary:sgtin96_epc] n:Sgtin96LengthBits];
    
    NSString *header = [binary substringToIndex:8];
        
    if ([header isEqualToString:HEADER]) {
        filterValue = [self binaryToInt:[binary substringWithRange:NSMakeRange(8, 3)]];

        partitionValue = [self binaryToInt:[binary substringWithRange:NSMakeRange(11, 3)]];

        if (partitionValue > 6) {
            @throw NSInvalidArgumentException;
        }

        NSInteger tempCPBIndex = [self getIndexFromCPBarrayToGetPV:partitionValue];
        companyPrefixBits = [self returnValueFromCPBTable:tempCPBIndex];

        companyPrefixLength = [self getCompanyPrefixLength:tempCPBIndex];

        companyPrefixValue = [self binaryToInt:[binary substringWithRange:NSMakeRange(14, companyPrefixBits)]];

        if (companyPrefixLength >= pow(10, companyPrefixLength)) {
            @throw NSInvalidArgumentException;
        }

        companyPrefixFinalValue = [self zeroFillNotBinary:[NSString stringWithFormat:@"%ld", companyPrefixValue] n:companyPrefixLength];

        itemReferenceLength = 13 - companyPrefixLength;

        itemReferenceValue = [self binaryToInt:[binary substringWithRange:NSMakeRange(14+companyPrefixBits, 58 - (14+companyPrefixBits))]];

        itemReferenceFinalValue = [self zeroFillNotBinary:[NSString stringWithFormat:@"%d", (int)itemReferenceValue] n:itemReferenceLength];
        
        NSString *itemReferencePrintValue = [NSString stringWithFormat:@"%d", [itemReferenceFinalValue intValue]];

        serialNumber = [self binaryToInt:[binary substringFromIndex:58]];

        NSString *rv = [NSString stringWithFormat:@"urn:epc:tag:sgtin-96:%ld.%@.%@.%ld", (long)filterValue, companyPrefixFinalValue, itemReferencePrintValue, serialNumber];;

        return rv;

    } else {
        return sgtin96_epc;
    }

   
}


@end
