//
//  PaintingClass.swift
//  Historical-Paintings
//
//  Created by Dillon Fernando on 2/7/17.
//  Copyright © 2017 Dillon Fernando. All rights reserved.
//

import UIKit

class PaintingClass: NSObject {
    
    var paintingName = ""
    var paintingURL = ""
    
    
    init (name: String, image: String) {
        self.paintingName = name
        self.paintingURL = image
    }
}
