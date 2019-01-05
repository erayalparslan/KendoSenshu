//
//  Global.swift
//  KendoSenshu
//
//  Created by ruroot on 10/23/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation

class Global {
    static var selectedPlayer             = Player()
    static var selectedDojo               = Dojo()
    static var selectedTournament         : Tournament!
    
    static var isComingFromEditTournament = false
    static var isComingFromNewTournamanet = false
    static var isComingFromNewDojo        = false
    static var isComingFromEditDojo       = false
    static var isComingFromRegister       = false
    static let defaults = UserDefaults.standard
    
    static func setMainUser(email: String, password: String, isAdmin: Bool) {
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        defaults.set(isAdmin, forKey: "isAdmin")
    }
    
    static func getMainUser() -> (String, String, Bool) {
        let username = defaults.string(forKey: "email") ?? ""
        let password = defaults.string(forKey: "password") ?? ""
        let isAdmin  = defaults.bool(forKey: "isAdmin")
        return (username,password, isAdmin)
    }
    
    static func setGroupStageWarning(to value: Bool){
        defaults.set(value, forKey: "groupStageWarning")
    }
    
    static func getGroupStageWarning() -> Bool{
        let val = defaults.bool(forKey: "groupStageWarning")
        return val
    }
    
    
}
