//
//  item.swift
//  FindYourCause
//
//  Created by Laksh on 02/03/19.
//  Copyright © 2019 Laksh. All rights reserved.
//

import UIKit

class item{
    var itemName:String
    var itemSatisfaction:String
    var itemPrice:String
    var itemImage:UIImage?
    
    init?(itemName:String,itemSatisfaction:String,itemPrice:String,itemImage:UIImage?){
        
        if itemName.isEmpty{
            return nil
        }
        
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemSatisfaction = itemSatisfaction
        self.itemImage = itemImage
    }

}

