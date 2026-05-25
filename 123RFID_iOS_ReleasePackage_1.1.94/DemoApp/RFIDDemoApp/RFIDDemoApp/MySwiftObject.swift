//
//  MySwiftObject.swift
//  RFIDDemoApp
//
//  Created by Madesan Venkatraman on 02/11/23.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//

import Foundation

class MySwiftObject : NSObject {
    
    @objc func convertToHexa(tagID:String) -> Bool
    {
        let epcData = Int(tagID, radix: 16) ?? 0
        let result:Bool
        if((epcData & 0x8000) > 0)
        {
            result = true;
        }else
        {
            result = false;
        }
        return result;
    }
}
