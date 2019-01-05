//
//  Stats.swift
//  KendoSenshu
//
//  Created by ruroot on 12/21/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Stats {
    var age         = Int()
    var win         = Int()
    var lose        = Int()
    var rank        = String()
    var lastPlace   = String()
    var mastery     = String()
    
    init(){
        self.age        = 0
        self.win        = 0
        self.lose       = 0
        self.rank       = ""
        self.lastPlace  = ""
        self.mastery    = ""
    }
}
