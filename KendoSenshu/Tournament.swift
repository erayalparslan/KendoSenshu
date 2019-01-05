//
//  Tournament.swift
//  KendoSenshu
//
//  Created by ruroot on 11/4/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Tournament {
    var id          = String()
    var name        = String()
    var category    = String()
    var date        = String()
    var location    = String()
    var isEnded     = String()
    
    init() {
        self.id         = ""
        self.name       = ""
        self.category   = ""
        self.date       = ""
        self.location   = ""
        self.isEnded    = "no"
    }
}
