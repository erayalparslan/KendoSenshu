//
//  Score.swift
//  KendoSenshu
//
//  Created by ruroot on 11/1/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Score {
    
    var aSymbol: String
    var bSymbol: String
    var aScore:  String
    var bScore:  String
    var time:    String
    
    init(aSymbol: String, bSymbol: String, aScore: String, bScore: String, time: String) {
        self.aSymbol = aSymbol
        self.bSymbol = bSymbol
        self.aScore  = aScore
        self.bScore  = bScore
        self.time    = time
    }
}
