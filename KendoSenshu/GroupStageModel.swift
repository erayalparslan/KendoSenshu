//
//  GroupStageModel.swift
//  KendoSenshu
//
//  Created by ruroot on 12/16/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class GroupStageModel {
    var groupName = String()
    var players = [Player]()
    
    init() {
        self.groupName = ""
        self.players   = [Player]()
    }
}
