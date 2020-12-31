//
//  SessionClass.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation
import RealmSwift

class Session: Object {
    
    //MARK: Properties
    @objc dynamic var sessionID: String = ""
    @objc dynamic var placeID = Int()
    @objc dynamic var placeName: String = ""
    @objc dynamic var tableNumber: Int = 0
    @objc dynamic var userEmail: String = ""
    @objc dynamic var userPassword: String = ""
    @objc dynamic var status: Int = 2
    @objc dynamic var billExistFlag: Bool = false
    @objc dynamic var roundExistFlag: Bool = false
    @objc dynamic var placeColorString: String = ""
    @objc dynamic var backgroundImageURL: String = ""
    @objc dynamic var backgroundImageData: String = ""
    var backgroundImage = UIImage()
    var placeColor: UIColor {
            return UIColor(colorCode: placeColorString, alpha: 1.0)
    }
    
    //MARK: Initialization
    
    
    convenience init(sessionID: String, placeID: Int, tableID: Int, userEmail: String, userPassword: String, billID: String) {
        self.init()
    }
    
    //MARK: Methods

    //TODO: Coding session methods
    
    func codeDate (DateToSave: Date) -> String {
        let Formatter = DateFormatter()
        // Coding format string without AM - PM
        Formatter.locale = Locale(identifier: "en_US_POSIX")
        Formatter.dateFormat = "ddMMMyyHHmmsss"
        let CodedDate = Formatter.string(from: DateToSave)
        
        return CodedDate
    }
    
    func deCodeDate (ExpectedFormat: String, CodedDate: String) -> String {
        let Formatter = DateFormatter()
        Formatter.locale = Locale(identifier: "en_US_POSIX")
        Formatter.dateFormat = "ddMMMyyHHmmsss"
        let OrderDate = Formatter.date(from: CodedDate)
        Formatter.dateFormat = ExpectedFormat
        return Formatter.string(from: OrderDate!)
        
    }
    
    //TODO: Reaml methods
    
    class func existSessionRealm () -> Bool {
        let realm = try! Realm()
        let session = realm.objects(Session.self)
        return !session.isEmpty
    }
    
    
    class func createRealm (newSession: Session = Session()) {
        let realm = try! Realm()
        let currentSession = realm.objects(Session.self)
        
        do {
            try realm.write {
                if currentSession.count > 0 {
                    realm.delete(currentSession[0])
                }
                realm.add(newSession)
            }
        } catch {
            print("error")
        }
    }
    
    class func updateRealm (newSession: Session) {
        let realm = try! Realm()
        let currentSession = realm.objects(Session.self)[0]
        
        do {
            try realm.write {
                currentSession.sessionID = newSession.sessionID
                currentSession.placeID = newSession.placeID
                currentSession.placeName = newSession.placeName
                currentSession.tableNumber = newSession.tableNumber
                currentSession.userEmail = newSession.userEmail
                currentSession.userPassword = newSession.userPassword
                currentSession.billExistFlag = newSession.billExistFlag
                currentSession.roundExistFlag = newSession.roundExistFlag
                currentSession.placeColorString = newSession.placeColorString
                currentSession.backgroundImageURL = newSession.backgroundImageURL
                currentSession.backgroundImageData = newSession.backgroundImageData
            }
        } catch {
            print("error")
        }
    }
    
    class func getsessionRealm () -> Session {
        let realm = try! Realm()
        let session = realm.objects(Session.self)[0]
        let newSession = Session()
        newSession.sessionID = session.sessionID
        newSession.placeID = session.placeID
        newSession.placeName = session.placeName
        newSession.tableNumber = session.tableNumber
        newSession.userEmail = session.userEmail
        newSession.userPassword = session.userPassword
        newSession.billExistFlag = session.billExistFlag
        newSession.roundExistFlag = session.roundExistFlag
        newSession.placeColorString = session.placeColorString
        newSession.backgroundImageURL = session.backgroundImageURL
        newSession.backgroundImageData = session.backgroundImageData
        
        return newSession
    }
}

