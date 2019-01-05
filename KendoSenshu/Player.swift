//
//  Player.swift
//  KendoSenshu
//
//  Created by ruroot on 11/5/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Player {
    var dojoId      = String()
    var email       = String()
    var name        = String()
    var password    = String()
    var stats       = Stats()
    
    init() {
        self.dojoId     = ""
        self.email      = ""
        self.name       = ""
        self.password   = ""
        self.stats      = Stats()
    }
}
