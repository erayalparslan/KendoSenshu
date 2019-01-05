//
//  Match.swift
//  KendoSenshu
//
//  Created by ruroot on 10/30/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Match {
    var matchId         = String()
    var groupName       = String()
    var isFinished      = String()
    var playerA         = String()
    var playerB         = String()
    var duration        = String()
    var aEmail          = String()
    var bEmail          = String()
    var scoreA          = Int()
    var scoreB          = Int()
    
    
    init() {
        matchId         = ""
        groupName       = ""
        isFinished      = "no"
        playerA         = ""
        playerB         = ""
        duration        = ""
        scoreA          = 0
        scoreB          = 0
    }
}
