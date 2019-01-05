//
//  Dojo.swift
//  KendoSenshu
//
//  Created by ruroot on 11/19/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Dojo {
 
    var id              = String()
    var name            = String()
    var location        = String()
    var yearFounded     = String()
    var players         = [String]()
    
    init() {
        self.id              = ""
        self.name            = ""
        self.location        = ""
        self.yearFounded     = ""
        self.players         = [String]()
    }
}
