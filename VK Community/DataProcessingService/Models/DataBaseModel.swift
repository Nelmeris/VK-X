//
//  DataBaseModel.swift
//  VK Community
//
//  Created by Артем on 20.05.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class DataBaseModel: Object {
    
    required convenience init(json: JSON) {
        self.init()
    }
    
    func isEqual (_ object: DataBaseModel) -> Bool {
        return false
    }
    
}
