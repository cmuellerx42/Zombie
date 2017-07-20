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
    static let PreGame: UInt32 = 0
    static let Playing: UInt32 = 1
    static let GameOver: UInt32 = 2
}

class Enemy: SKSpriteNode {
    
    var hp : Int
    var max : Int
    var spd : Double
    let hpBar = SKSpriteNode();
    
    init(imageNamed: String) {
        
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        hp = 10
        max = 10
        spd = 0.5
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var character = SKSpriteNode(imageNamed: "character");
    var characterSpeed : Double = 200;
    let moveCircle = SKSpriteNode(imageNamed: "moveCircle");
    var touchLocation = CGPoint(x: 0, y: 0)
    
    var hp = 10
    
    var enemies = [Enemy]()
    
    override func didMove(to view: SKView) {
        
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        character.physicsBody?.isDynamic = true
        character.physicsBody?.categoryBitMask = BodyType.Hero
        character.physicsBody?.contactTestBitMask = BodyType.Zombie
        character.physicsBody?.collisionBitMask = 0
        
        backgroundColor = UIColor.white
        addChild(character)
        
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
        
        for i in enemies{
            if touchActor(touchLocation, i){
                shootBullet()
                move = false
            }
        }
        
        if touchActor(touchLocation, character){
            print("ouch!")
            move = false
        }

        if action(forKey: "moveAction") == nil && move {

            moveCircle.removeFromParent()
            moveCircle.position = CGPoint(x:touchLocation.x, y:touchLocation.y)
            addChild(moveCircle)
            let vector = CGVector(dx: -(character.position.x - touchLocation.x), dy: -(character.position.y - touchLocation.y))
            let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
            let moveAction = SKAction.repeat(SKAction.move(by: vector, duration: vectorLength/characterSpeed), count: 1)
            character.run(moveAction, withKey : "moveAction")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for i in enemies{
            if touchActor(i.position,character) == false {
                let vector = CGVector(dx: -(i.position.x - character.position.x), dy: -(i.position.y - character.position.y))
                let vectorLength : Double = sqrt((Double(vector.dx)*Double(vector.dx)) + (Double(vector.dy)*Double(vector.dy)))
                i.position.x += vector.dx/CGFloat(vectorLength/i.spd)
                i.position.y += vector.dy/CGFloat(vectorLength/i.spd)
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
                i.removeFromParent()
                i.hpBar.removeFromParent()
            }
        }
    }
    
    func shootBullet(){
        //shoot a bullet
        let bullet = SKSpriteNode();
        bullet.color = UIColor.gray;
        bullet.size = CGSize(width:5,height:5);
        bullet.position = CGPoint(x: character.position.x, y: character.position.y);
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = BodyType.Bullet
        bullet.physicsBody?.contactTestBitMask = BodyType.Zombie
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        
        let vector = CGVector(dx: -(character.position.x - touchLocation.x), dy: -(character.position.y - touchLocation.y))
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
        
        bullet.removeFromParent()
        zombie.hp -= 1
        print(zombie.hp)
    }
    
    func heroHitZombie(player:SKSpriteNode, zombie: Enemy) {
        
        hp -= 1
        print(hp)
    }
    
    func addZombie(_ x:Double,_ y:Double){
        let zombie : Enemy
        zombie = Enemy(imageNamed: "zombie")
        
        zombie.physicsBody = SKPhysicsBody(rectangleOf: zombie.size)
        zombie.physicsBody?.isDynamic = true
        zombie.physicsBody?.categoryBitMask = BodyType.Zombie
        zombie.physicsBody?.contactTestBitMask = BodyType.Bullet
        zombie.physicsBody?.collisionBitMask = 0
        
        zombie.position.x = CGFloat(x)
        zombie.position.y = CGFloat(y)
        
        zombie.hp = Int(arc4random_uniform(20) + 10)
        zombie.max = zombie.hp
        zombie.spd = Double(Int(arc4random_uniform(51)) + 50)/100
        
        addChild(zombie)
        addChild(zombie.hpBar)
        enemies.append(zombie)
    }
    
    func touchActor(_ touchPoint : CGPoint,_ actor : SKSpriteNode) -> Bool {
        if (actor.position.x - 32) < touchPoint.x && touchPoint.x < (actor.position.x + 32) && (actor.position.y - 32) < touchPoint.y && touchPoint.y < (actor.position.y + 32) {
            return true
        }else{
            return false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let contactA = bodyA.categoryBitMask
        let contactB = bodyB.categoryBitMask
        
        switch contactA {
            
        case BodyType.Zombie:
            
            
            switch contactB {
                
                
            case BodyType.Zombie:
                
                break
                
                
            case BodyType.Bullet:
                
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? Enemy {
                    
                    bulletHitZombie(bullet: bodyBNode, zombie: bodyANode)
                    
                }
                
                
            case BodyType.Hero:
                
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? Enemy {
                    
                    heroHitZombie(player: bodyBNode, zombie: bodyANode)
                    
                }
                
                
            default:
                
                break
                
            }
            
            
        case BodyType.Bullet:
            
            
            switch contactB {
                
                
            case BodyType.Zombie:
                
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    
                    bulletHitZombie(bullet: bodyANode, zombie: bodyBNode)
                    
                }
                
                
            case BodyType.Bullet:
                
                break
                
                
            case BodyType.Hero:
                
                break
                
                
            default:
                
                break
                
            }
            
            
        case BodyType.Hero:
            
            
            switch contactB {
                
                
            case BodyType.Zombie:
                
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    
                    heroHitZombie(player: bodyANode, zombie: bodyBNode)
                    
                }
                
                
            case BodyType.Bullet:
                
                break
                
                
                
            case BodyType.Hero:
                
                break
                
                
            default:
                
                break
                
            }
            
            
        default:
            
            break
            
        }
    }
}
