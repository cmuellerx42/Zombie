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

struct ItemType {
    
    static let None: UInt32 = 0
    static let Comestible: UInt32 = 1
    static let Weapon: UInt32 = 2
    static let Clothing: UInt32 = 4
}

struct GameState {
    static let PreGame: UInt32 = 0
    static let Playing: UInt32 = 1
    static let GameOver: UInt32 = 2
}

class Enemy: SKSpriteNode {
    
    var hp : Int
    var max : Int
    var spd : Double
    var hitBox : Int
    let hpBar = SKSpriteNode()
    
    init(imageNamed: String) {
        
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        hp = 10
        max = 10
        spd = 0.5
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
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        hp = 10
        max = 10
        spd = 0.5
        hitBox = 32
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class Item: SKSpriteNode {
    var title : String
    var text: String
    var type: UInt32
    
    init(imageNamed: String){
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        title = ""
        text = ""
        type = 0
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class Bullet: SKSpriteNode {
    
    var targetObject : Enemy
    
    init(imageNamed: String){
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        targetObject = Enemy(imageNamed: "")
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let moveCircle = SKSpriteNode(imageNamed: "moveCircle");
    var touchLocation = CGPoint(x: 0, y: 0)
    
    let player = Player(imageNamed: "character")
    var enemies = [Enemy]()
    var bullets = [Bullet]()
    
    var cam : SKCameraNode?
    
    override func didMove(to view: SKView) {
        
        player.hp = 10
        player.max = 10
        player.spd = 200
        player.hitBox = 32
        
        backgroundColor = UIColor.white
        addChild(player)
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        
        addZombie(100,0)
        addZombie(0,100)
        addZombie(-100,0)
        addZombie(0,-100)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0);
        physicsWorld.contactDelegate = self;
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
        
        var move = true
        var vectors : [Double] = []
        
        for i in enemies{
            if touchObject(touchLocation, i, i.hitBox){
                let vector = CGVector(dx: -(i.position.x - touchLocation.x), dy: -(i.position.y - touchLocation.y))
                let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
                vectors.append(Double(vectorLength))
                move = false
            }else{
                move = true
            }
        }
        if move == false {
        let minimum = vectors.min()
        if let position = vectors.index(of: minimum!) {
            for i in enemies {
                if position == enemies.index(of:i) {
                    shootBullet(thing: i)
                }
            }
        }
        }
        
        if touchObject(touchLocation, player, player.hitBox){
            print("ouch!")
            move = false
        }

        if action(forKey: "moveAction") == nil && move {

            moveCircle.removeFromParent()
            moveCircle.position = CGPoint(x:touchLocation.x, y:touchLocation.y)
            addChild(moveCircle)
            let vector = CGVector(dx: -(player.position.x - touchLocation.x), dy: -(player.position.y - touchLocation.y))
            let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
            let moveAction = SKAction.repeat(SKAction.move(by: vector, duration: vectorLength/player.spd), count: 1)
            player.run(moveAction, withKey : "moveAction")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if let camera = cam, let pl = player as SKSpriteNode? {
            camera.position = pl.position
        }
        
        for i in bullets{
            if touchObject(i.position, i.targetObject as SKSpriteNode, i.targetObject.hitBox) {
                if let bulletIndex = bullets.index(of: i) {
                        bullets.remove(at: bulletIndex)
                }
                i.removeFromParent()
                bulletHitZombie(bullet: i, zombie: i.targetObject)
            }
        }
        
        
        
        for i in enemies{

            if touchObject(i.position,player,player.hitBox) == false {
                let vector = CGVector(dx: -(i.position.x - player.position.x), dy: -(i.position.y - player.position.y))
                let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
                for j in enemies {
                    if j != i {
                        if touchObject(i.position, j, j.hitBox) == false {
                            i.position.x += vector.dx/CGFloat(vectorLength/i.spd)
                            i.position.y += vector.dy/CGFloat(vectorLength/i.spd)
                        }else{
                            let vector2 = CGVector(dx: -(i.position.x - j.position.x), dy: -(i.position.y - j.position.y))
                            let vector2Length : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
                            i.position.x -= vector2.dx/CGFloat(vector2Length/(i.spd))
                            i.position.y -= vector2.dy/CGFloat(vector2Length/(i.spd))
                        }
                    }
                }
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
            }
        }
    }
    
    func shootBullet(thing:Enemy){
        //shoot a bullet
        let bullet = Bullet(imageNamed: "")
        bullet.color = UIColor.gray;
        bullet.size = CGSize(width:5,height:5);
        bullet.position = CGPoint(x: player.position.x, y: player.position.y);
        
        bullet.targetObject = thing
        
        bullets.append(bullet)
        addChild(bullet)
        
        let vector = CGVector(dx: -(player.position.x - thing.position.x), dy: -(player.position.y - thing.position.y))
        
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
        zombie.hp -= 1
        print(zombie.hp)
    }
    
    func heroHitZombie(player:Player, zombie: Enemy) {
        
        player.hp -= 1
        print(player.hp)
    }
    
    func addZombie(_ x:Double,_ y:Double){
        let zombie : Enemy
        zombie = Enemy(imageNamed: "zombie")
        zombie.color = UIColor.blue
        
        zombie.position.x = CGFloat(x)
        zombie.position.y = CGFloat(y)
        
        zombie.hp = Int(arc4random_uniform(10) + 10)
        zombie.max = zombie.hp
        zombie.spd = Double(Int(arc4random_uniform(21)) + 30)/100
        zombie.hitBox = 32
        
        addChild(zombie)
        addChild(zombie.hpBar)
        enemies.append(zombie)
    }
    
    func touchObject(_ touchPoint : CGPoint,_ object : SKSpriteNode,_ hitBox : Int) -> Bool {
        if (Int(object.position.x) - hitBox) < Int(touchPoint.x) && Int(touchPoint.x) < (Int(object.position.x) + hitBox) && (Int(object.position.y) - hitBox) < Int(touchPoint.y) && Int(touchPoint.y) < (Int(object.position.y) + hitBox) {
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
}
