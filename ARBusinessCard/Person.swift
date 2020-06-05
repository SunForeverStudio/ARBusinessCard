//
//  Person.swift
//  ARBusinessCard
//
//  Created by jian sun on 2020/06/05.
//  Copyright © 2020 jian sun. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var twitter : String = ""
    @objc dynamic var facebook : String = ""
    @objc dynamic var phone : String = ""
    @objc dynamic var email : String = ""
    @objc dynamic var location : String = ""
    @objc dynamic var homepage : String = ""
    
    @objc dynamic var createdDate : Date = NSDate() as Date
    @objc dynamic var updatedDate : Date = NSDate() as Date

}
