//
//  Item.swift
//  Final Game
//
//  Created by iD Student on 7/24/17.
//  Copyright © 2017 iD Tech. All rights reserved.
//

import Foundation
import SpriteKit

class Item: SKSpriteNode {
    let title : String
    let text: String
    let hitBox : Int
    let textureName : String
    init(_ imageNamed: String, _ title: String, _ text: String){
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        textureName = imageNamed
        self.title = title
        self.text = text
        hitBox = 16
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class Weapon : Item {
    let damage : Int
    let shotSpeed : Double
    init(_ imageNamed: String, _ title: String, _ text: String, _ damage: Int, _ shotSpeed: Double){
        self.damage = damage
        self.shotSpeed = shotSpeed
        super.init(imageNamed, title, text)
    }
    required init?(coder aDecoder: NSCoder) {
            
        fatalError("init(coder:) has not been implemented")
    }
}

class Clothing : Item {
    let protection : Int
    let weight : Double
    init(_ imageNamed: String, _ title: String, _ text: String, _ protection: Int, _ weight: Double){
        self.protection = protection
        self.weight = weight
        super.init(imageNamed, title, text)
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
