//
//  GameScene.swift
//  Final Game
//
//  Created by iD Student on 7/20/17.
//  Copyright © 2017 iD Tech. All rights reserved.
//

import SpriteKit
import GameplayKit

struct BodyType {
    
    static let None: UInt32 = 0
    static let Zombie: UInt32 = 1
    static let Bullet: UInt32 = 2
    static let Hero: UInt32 = 4
}

struct GameState {
    static let Menu: UInt32 = 0
    static let Playing: UInt32 = 1
    static let GameOver: UInt32 = 2
    static let Inventory: UInt32 = 3
}

class Enemy: SKSpriteNode {
    
    var hp : Int
    var max : Int
    var spd : Double
    var hitBox : Int
    var damage : Int
    let hpBar = SKSpriteNode()
    
    init(imageNamed: String) {
        
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        hp = 10
        max = 10
        spd = 0.5
        damage = 2
        hitBox = 32
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class Player: SKSpriteNode {
    var hp : Int
    var max : Int
    var spd : Double
    var hitBox : Int
    let hpBar = SKSpriteNode()
    var weapon : Weapon
    var clothing : Clothing
    var items = [Item]()
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        hp = 10
        max = 10
        spd = 0.5
        hitBox = 32
        weapon = Weapon("", "", "", 0, 0)
        clothing = Clothing("", "", "", 0, 0)
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let moveCircle = SKSpriteNode(imageNamed: "moveCircle");
    let aimCircle = SKSpriteNode(imageNamed: "aimCircle");
    var touchLocation = CGPoint(x: 0, y: 0)
    var targetEnemy = Enemy(imageNamed: "")
    
    let inventorySprite = SKSpriteNode(imageNamed: "inventory")
    let closeInv = SKSpriteNode(imageNamed: "closeInv")
    let itemPage = SKSpriteNode(imageNamed: "itemPage")
    let back = SKSpriteNode(imageNamed: "back")
    let use = SKSpriteNode(imageNamed: "use")
    var inventorySize = CGSize(width:1,height:1)
    var inventoryPositions : [CGPoint] = []
    var inventoryPage = false
    
    let player = Player(imageNamed: "character")
    var enemies = [Enemy]()
    var Items = [Item]()
    var groundItems = [Item]()
    var inventoryItems = [Item]()
    var bullets = [SKSpriteNode()]
    
    let map = SKSpriteNode()
    
    var cam : SKCameraNode?
    var canMove = true
    var invOpen = false
    
    var GS = GameState.Playing
    
    override func didMove(to view: SKView) {
        
        player.hp = 10
        player.max = 10
        player.spd = 200
        player.hitBox = 32
        player.zPosition = 2
        
        backgroundColor = UIColor.lightGray
        map.texture = SKTexture(imageNamed: "building")
        map.size = CGSize(width:640,height:640)
        map.position = CGPoint(x:0,y:0)
        map.zPosition = -1
        addChild(map)
        addChild(player)
        
        targetEnemy = Enemy(imageNamed: "")
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        
        addZombie(100,0)
        addZombie(0,100)
        addZombie(-100,0)
        addZombie(0,-100)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0);
        physicsWorld.contactDelegate = self;
        
        var i = 0
        while i <= 11{
            inventoryPositions.append(CGPoint(x:0,y:0))
            i += 1;
        }
        
        /*0*/ Items.append(Item("item", "item", "item"))
        /*1*/ Items.append(Weapon("gun", "The Gun", "The default gun that you start with", 1, 1))
        /*2*/ Items.append(Clothing("clothes", "Clothing", "the default clothing that you start with", 1, 1))
        /*3*/ Items.append(Weapon("gun", "The Machine Gun", "Shoots really fast", 1, 0.25))
        
        player.weapon = Items[3] as! Weapon
        player.clothing = Items[2] as! Clothing
        
        addItem(-100, -100, Items[0])
        addItem(100, 100, Items[1])
        addItem(100, -100, Items[2])
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self)
        
        if GS == GameState.Playing {
            
            var move = false
            if canMove == true{
            move = true
            }
        
            for i in enemies{
                if touchObject(touchLocation, i, i.hitBox){
                    if i != targetEnemy {
                        shootAt(zombie: i)
                        move = false
                    } else if i == targetEnemy {
                        targetEnemy = Enemy(imageNamed: "")
                        aimCircle.removeFromParent()
                        removeAction(forKey: "shoot")
                        move = false
                    }
                }
            }
        
            if touchObject(touchLocation, player, player.hitBox) {
                
                movePlayer(destination: CGPoint(x:player.position.x,y:player.position.y))
                
                inventorySprite.position = player.position
                inventorySprite.zPosition = 3
                addChild(inventorySprite)
                
                updateInvPos()
                
                closeInv.position.x = inventorySprite.position.x + (276)
                closeInv.position.y = inventorySprite.position.y + (168)
                closeInv.zPosition = 4
                addChild(closeInv)
                
                canMove = false
                removeAction(forKey: "moveAction")
                
                GS = GameState.Inventory
                for i in player.items{
                    if let itemIndex = player.items.index(of: i) {
                        inventoryItems.append(i)
                        player.items[itemIndex].size.width = 96
                        player.items[itemIndex].size.height = 96
                        player.items[itemIndex].position = inventoryPositions[itemIndex]
                        player.items[itemIndex].zPosition = 4
                        addChild(player.items[itemIndex])
                    }
                }
                move = false
            }
        
            for i in groundItems {
                if touchObject(touchLocation, i, i.hitBox) && !touchObject(touchLocation, player, player.hitBox){
                    if let itemIndex = groundItems.index(of: i) {
                    
                        groundItems.remove(at: itemIndex)
                    }
                    player.items.append(i)
                    if let itemIndex = player.items.index(of: i) {
                        if itemIndex >= 12 {
                            player.items.remove(at: itemIndex)
                        }
                    }
                    i.removeFromParent()
                    move = false
                }
            }

            if action(forKey: "moveAction") == nil && move == true {

                movePlayer(destination: touchLocation)
            }
            
        } else if GS == GameState.Inventory {
            
            if touchObject(touchLocation, closeInv, Int(closeInv.size.width)/2){
                GS = GameState.Playing

                inventorySprite.removeFromParent()
                itemPage.removeFromParent()
                back.removeFromParent()
                use.removeFromParent()
                closeInv.removeFromParent()
                
                canMove = true
                for i in inventoryItems {
                    if let itemIndex = inventoryItems.index(of: i){
                        inventoryItems.remove(at: itemIndex)
                        i.size.width = 32
                        i.size.height = 32
                        i.removeFromParent()
                    }
                }
            }
            
            for i in inventoryItems {
                
                if touchObject(touchLocation, i, i.hitBox*3){
                    
                    inventoryPage = true
                    i.removeFromParent()
                    
                    itemPage.position = player.position
                    itemPage.zPosition = 5
                    addChild(itemPage)
                    
                    back.position.x = player.position.x - 120
                    back.position.y = player.position.y - 120
                    back.zPosition = 6
                    addChild(back)
                    use.position.x = player.position.x + 120
                    use.position.y = player.position.y - 120
                    use.zPosition = 6
                    addChild(use)
                    
                    i.size.width = 192
                    i.size.height = 192
                    i.position.x = player.position.x - 120
                    i.position.y = player.position.y + 60
                    i.zPosition = 6
                    addChild(i)
                }
            }
            
            if touchRectObject(touchLocation, back, Int(back.size.width)/2, Int(back.size.height)/2) && inventoryPage == true {
                
                itemPage.removeFromParent()
                back.removeFromParent()
                use.removeFromParent()
                inventoryPage = false
                for i in inventoryItems{
                    if let itemIndex = inventoryItems.index(of: i){
                        i.removeFromParent()
                        i.position = inventoryPositions[itemIndex]
                        i.zPosition = 4
                        i.size.width = 96
                        i.size.height = 96
                        addChild(player.items[itemIndex])
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if let camera = cam, let pl = player as SKSpriteNode? {
            camera.position = pl.position
        }
        aimCircle.position = targetEnemy.position
        inventorySprite.position = player.position
        updateInvPos()
        if GS == GameState.Playing {
        
            for i in bullets {
                if touchObject(i.position, targetEnemy, targetEnemy.hitBox) {
                    if let bulletIndex = bullets.index(of: i) {
                        bullets.remove(at: bulletIndex)
                    }
                    i.removeFromParent()
                    bulletHitZombie(bullet: i, zombie: targetEnemy)
                    return
                }
            }
        
            for i in enemies{

                if touchObject(i.position,player,player.hitBox) == false {
                    i.removeAction(forKey: "hitPlayer")
                    let vector = CGVector(dx: -(i.position.x - player.position.x), dy: -(i.position.y - player.position.y))
                    let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double (vector.dy)))
                    for j in enemies {
                        if touchObject(i.position, j, j.hitBox) && j != i {
                            let vector2 = CGVector(dx: -(i.position.x - j.position.x), dy: -(i.position.y - j.position.y))
                            let vector2Length : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
                            i.position.x -= vector2.dx/CGFloat(vector2Length/(i.spd))
                            i.position.y -= vector2.dy/CGFloat(vector2Length/(i.spd))
                        }else{
                            i.position.x += vector.dx/CGFloat(vectorLength/i.spd)
                            i.position.y += vector.dy/CGFloat(vectorLength/i.spd)
                        }
                    }
                } else if i.action(forKey: "hitPlayer") == nil{
                    heroHitZombie(player: player, zombie: i)
                }
            
                i.hpBar.position = CGPoint(x: i.position.x, y: i.position.y + 32);
                let percentage = Double(i.hp) / Double(i.max) * 100
            
                if percentage >= 75 {
                    i.hpBar.color = UIColor.green
                    i.hpBar.size = CGSize(width:32,height:8)
                }else if percentage >= 50 {
                    i.hpBar.color = UIColor.yellow
                    i.hpBar.size = CGSize(width:24,height:8)
                }else if percentage >= 25 {
                    i.hpBar.color = UIColor.orange
                    i.hpBar.size = CGSize(width:16,height:8)
                }else if percentage > 0 {
                    i.hpBar.color = UIColor.red
                    i.hpBar.size = CGSize(width:8,height:8)
                }
            
                if i.hp <= 0{
                    if let zombieIndex = enemies.index(of: i) {
                    
                        enemies.remove(at: zombieIndex)
                    }
                    explode(object: i as SKSpriteNode, explosionSize: 10, explosionRadius: i.hitBox, color: UIColor.red)
                    i.removeFromParent()
                    i.hpBar.removeFromParent()
                    aimCircle.removeFromParent()
                    removeAction(forKey: "shoot")
                }
            }
        }
        if GS == GameState.Inventory{
            removeAction(forKey: "moveAction")
        }
    }
    
    func movePlayer (destination: CGPoint) {
        moveCircle.removeFromParent()
        moveCircle.position = CGPoint(x:destination.x, y:destination.y)
        addChild(moveCircle)
        let vector = CGVector(dx: -(player.position.x - destination.x), dy: -(player.position.y - destination.y))
        let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
        let moveAction = SKAction.repeat(SKAction.move(by: vector, duration: vectorLength/player.spd), count: 1)
        player.run(moveAction, withKey : "moveAction")
    }
    
    func shootAt (zombie: Enemy) {
        aimCircle.removeFromParent()
        targetEnemy = zombie
        let shoot = SKAction.repeatForever(SKAction.sequence([SKAction.run{self.shootBullet(target: zombie)},SKAction.wait(forDuration: player.weapon.shotSpeed)]))
        run(shoot, withKey: "shoot")
        addChild(aimCircle)
    }
    
    func shootBullet(target: Enemy){
        //shoot a bullet
        let bullet = SKSpriteNode();
        bullet.color = UIColor.gray;
        bullet.size = CGSize(width:5,height:5);
        bullet.position = CGPoint(x: player.position.x, y: player.position.y);
        
        bullets.append(bullet)
        addChild(bullet)
        
        let vector = CGVector(dx: -(player.position.x - target.position.x), dy: -(player.position.y - target.position.y))
        let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))

        let projectileAction = SKAction.sequence([
            SKAction.repeat(
                SKAction.move(by: vector, duration: vectorLength/1000), count: 10),
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
            ])
        bullet.run(projectileAction)
    }
    
    func bulletHitZombie(bullet:SKSpriteNode, zombie: Enemy) {
        
        explode(object: zombie as SKSpriteNode, explosionSize: 3, explosionRadius: zombie.hitBox, color: UIColor.red)
        zombie.hp -= player.weapon.damage
        print(zombie.hp)
    }
    
    func heroHitZombie(player:Player, zombie: Enemy) {
        
        let hitPlayer = SKAction.repeatForever(SKAction.sequence([SKAction.run{self.takeDamage(zombie: zombie)},SKAction.wait(forDuration: 1)]))
        zombie.run(hitPlayer, withKey: "hitPlayer")
    }
    
    func takeDamage (zombie : Enemy) {
        let calcDamage = player.clothing.protection - zombie.damage
        if calcDamage >= 0 {
            return
        }
        else{
            player.hp += calcDamage
        }
        print(player.hp)
    }
    
    func addZombie(_ x:Double,_ y:Double){
        let zombie : Enemy
        zombie = Enemy(imageNamed: "zombie")
        
        zombie.position.x = CGFloat(x)
        zombie.position.y = CGFloat(y)
        zombie.zPosition = 1
        
        zombie.hp = Int(arc4random_uniform(10) + 10)
        zombie.max = zombie.hp
        zombie.spd = Double(Int(arc4random_uniform(21)) + 30)/100
        zombie.hitBox = 32
        
        addChild(zombie)
        addChild(zombie.hpBar)
        enemies.append(zombie)
    }
    
    func addItem(_ x:Double,_ y:Double,_ itemType:Item){
        let item : Item = itemType
    
        item.position.x = CGFloat(x)
        item.position.y = CGFloat(y)
        item.zPosition = 0
        
        addChild(item)
        groundItems.append(item)
    }
    
    func touchObject(_ touchPoint : CGPoint,_ object : SKSpriteNode,_ hitBox : Int) -> Bool {
        if (Int(object.position.x) - hitBox) < Int(touchPoint.x) && Int(touchPoint.x) < (Int(object.position.x) + hitBox) && (Int(object.position.y) - hitBox) < Int(touchPoint.y) && Int(touchPoint.y) < (Int(object.position.y) + hitBox) {
            return true
        }else{
            return false
        }
    }
    
    func touchRectObject(_ touchPoint : CGPoint,_ object : SKSpriteNode,_ hitBoxWidth : Int,_ hitBoxHeight : Int) -> Bool {
        if (Int(object.position.x) - hitBoxWidth) < Int(touchPoint.x) && Int(touchPoint.x) < (Int(object.position.x) + hitBoxWidth) && (Int(object.position.y) - hitBoxHeight) < Int(touchPoint.y) && Int(touchPoint.y) < (Int(object.position.y) + hitBoxHeight) {
            return true
        }else{
            return false
        }
    }
    
    func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
    }
    
    func explode(object: SKSpriteNode, explosionSize: Int, explosionRadius: Int, color: UIColor){
        var explosions: [SKSpriteNode] = []
        
        for _ in 1...explosionSize {
            explosions.append(SKSpriteNode())
        }
        
        for explosion in explosions {
            
            explosion.color = color
            explosion.size = CGSize(width: 3, height: 3);
            explosion.position = CGPoint(x: object.position.x, y: object.position.y);
            
            addChild(explosion);
            
            let randomExplosionX = object.position.x + CGFloat(arc4random_uniform(UInt32(explosionRadius))) - CGFloat(explosionRadius/2)
            
            let randomExplosionY = object.position.y + CGFloat(arc4random_uniform(UInt32(explosionRadius))) - CGFloat(explosionRadius/2)
            
            let moveExplosion: SKAction
            
            let vector = CGVector(dx: -(object.position.x - CGFloat(randomExplosionX)), dy: -(y: object.position.y - CGFloat(randomExplosionY)))
            
            moveExplosion = SKAction.move(by: vector, duration: 1)
            explosion.run(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
        }
    }
    
    func updateInvPos() {
        inventoryPositions[0] = CGPoint(x:inventorySprite.position.x - 180, y: inventorySprite.position.y + 120)
        inventoryPositions[1] = CGPoint(x:inventorySprite.position.x - 60, y: inventorySprite.position.y + 120)
        inventoryPositions[2] = CGPoint(x:inventorySprite.position.x + 60, y: inventorySprite.position.y + 120)
        inventoryPositions[3] = CGPoint(x:inventorySprite.position.x + 180, y: inventorySprite.position.y + 120)
        inventoryPositions[4] = CGPoint(x:inventorySprite.position.x - 180, y: inventorySprite.position.y)
        inventoryPositions[5] = CGPoint(x:inventorySprite.position.x - 60, y: inventorySprite.position.y)
        inventoryPositions[6] = CGPoint(x:inventorySprite.position.x + 60, y: inventorySprite.position.y)
        inventoryPositions[7] = CGPoint(x:inventorySprite.position.x + 180, y: inventorySprite.position.y)
        inventoryPositions[8] = CGPoint(x:inventorySprite.position.x - 180, y: inventorySprite.position.y - 120)
        inventoryPositions[9] = CGPoint(x:inventorySprite.position.x - 60, y: inventorySprite.position.y - 120)
        inventoryPositions[10] = CGPoint(x:inventorySprite.position.x + 60, y: inventorySprite.position.y - 120)
        inventoryPositions[11] = CGPoint(x:inventorySprite.position.x + 180, y: inventorySprite.position.y - 120)
    }
}
