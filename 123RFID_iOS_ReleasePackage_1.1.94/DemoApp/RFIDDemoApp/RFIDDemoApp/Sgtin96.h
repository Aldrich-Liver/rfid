//
//  Sgtin96.h
//  RFIDDemoApp
//
//  Created by Rajapaksha, Chamika on 2023-03-20.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

#import <Foundation/Foundation.h>

// Header file for the Sgtin96 class which decodes the RFID tags to SGTIN96 format
@interface Sgtin96 : NSObject

-(NSInteger) getCompanyPrefixLength: (NSInteger) i;
-(NSInteger) getPartitionValue: (NSInteger) i;
-(NSInteger) getCompanyPrefixBits;
-(NSInteger) getItemReferenceIndicatorBits;
-(NSInteger) getByCompanyPrefixLength: (NSInteger) companyPrefixLength;
-(NSInteger) getIndexFromCPBarrayToGetPV: (NSInteger) partitionValue ;
-(NSInteger) returnValueFromCPBTable: (NSInteger) i;
-(NSString *) zeroFillBinary: (NSString*) s n:(NSInteger) n;
-(NSString *) zeroFillNotBinary: (NSString*) s n:(NSInteger) n;
-(NSString *) binaryToHex: (NSString*) bin;
-(NSString*) hexToBinary: (NSString*) hex;
-(NSString *)decode: (NSString *) sgtin96_epc;
-(long) binaryToInt: (NSString*) bin;

@end
