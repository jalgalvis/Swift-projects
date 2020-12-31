//
//  SessionToSend.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation

class SessionToSend : Codable {
    
    //MARK: Properties
    
    var sessionID: String = ""
    var placeID: Int = 0
    var tableID: Int = 0
    var userEmail: String = ""
    var userPassword: String = ""
    
    
    //MARK: Initialization
    
    
    init(SessionID : String, PlaceID: Int, TableID : Int, userEmail: String, userPassword: String) {
        
        self.sessionID = SessionID
        self.placeID = PlaceID
        self.tableID = TableID
        self.userEmail = userEmail
        self.userPassword = userPassword
    }
}
