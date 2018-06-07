//
//  GameScene.swift
//  NinjaGame
//
//  Created by Alumno on 06/06/18.
//  Copyright © 2018 Alumno. All rights reserved.
//

import SpriteKit
import GameplayKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat{
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint{
    func length() -> CGFloat{
        return sqrt(x * x + y * y)
    }
    func normalized()->CGPoint{
        return self / length()
    }
}

struct PhysicsCategory{
    static let none:    UInt32 = 0
    static let all:     UInt32 = UInt32.max
    static let monster: UInt32 = 0b1
    static let star:    UInt32 = 0b10
    static let ninja: UInt32 = 0b11
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let bg = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "ninja")
    var monstersDestroyed = 0
    var label: SKLabelNode!
    var lives = 3
    var liveImages = [SKSpriteNode]()
    var maxKunaiNumber = 10
    var currentNumberOfKunais = 0
    override func didMove(to view: SKView) {
        //ADD BG
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = 1
        self.addChild(bg)
        
        //ADD PLAYER
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.zPosition = 2
        
        //DEFINE PLAYER PHYSICS
        player.physicsBody =  SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.ninja
        player.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
        addChild(player)
        
        //ADD LIVEs
        liveImages.append(SKSpriteNode(imageNamed: "head"))
        liveImages[0].position = CGPoint(x: size.width * 0.8, y: size.height * 0.95)
        liveImages[0].zPosition = 2
        liveImages.append(SKSpriteNode(imageNamed: "head"))
        liveImages[1].position = CGPoint(x: (size.width * 0.8) + (liveImages[0].size.width * 1.3), y: size.height * 0.95)
        liveImages[1].zPosition = 2
        liveImages.append(SKSpriteNode(imageNamed: "head"))
        liveImages[2].position = CGPoint(x: (size.width * 0.8) + (liveImages[0].size.width * 2.6), y: size.height * 0.95)
        liveImages[2].zPosition = 2
        addChild(liveImages[0])
        addChild(liveImages[1])
        addChild(liveImages[2])
        
        //DEFINE THE PHYSIC WORLD
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //ADD LABEL
        label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Monsters killed: 0"
        label.fontSize = 15
        label.fontColor = .black
        label.position = CGPoint(x: size.width * 0.15, y: size.height * 0.95)
        label.zPosition = 2
        addChild(label)
        
        //START CREATING MONSTERS
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: 1.0)])))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    func addMonster(){
        //ADD MONSTER
        let monster = SKSpriteNode(imageNamed: "zombie")
        let y = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: y)
        monster.zPosition = 2
        addChild(monster)
        //DEFINE MONSTER PHYSICS
        monster.physicsBody =  SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.ninja | PhysicsCategory.star
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        //MOVE MONSTER
        let duration = 10.0 //random(min: CGFloat(2.0), max: CGFloat(4.0))
        let move = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: y), duration: TimeInterval(duration))
        let moveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([move, moveDone]))
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentNumberOfKunais < maxKunaiNumber {
            print("currenNumberOfKunais \(currentNumberOfKunais)")
            currentNumberOfKunais += 1
            //GET THE FIRST PLACE WHERE THE USER TOUCHED THE SCREEN
            guard let touch = touches.first else{
                return
            }
            //GET LOCATION ON SCREEN
            let location = touch.location(in: self)
            //CREATE PROJECTILE
            let projectile = SKSpriteNode(imageNamed: "kunai")
            projectile.position = player.position
            projectile.zPosition = player.zPosition
            let offset = location - projectile.position
            if offset.x < 0{
                return
            }
            
            //DEFINE PROJECTILE PHYSICS
            projectile.physicsBody =  SKPhysicsBody(rectangleOf: projectile.size)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.star
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            addChild(projectile)
            //DO THE MATH
            let direction = offset.normalized()
            let amount = direction * 1000
            let destination = amount + projectile.position
            //THROW THE PROJECTILE
            let move = SKAction.move(to: destination, duration: 2.0)
            let moveDone = SKAction.removeFromParent()
            let action = SKAction.perform(#selector(projectileDone), onTarget: self)
            projectile.run(SKAction.sequence([move, action, moveDone]))
        }
        else{
            print("Hay \(currentNumberOfKunais) kunais y solo caben \(maxKunaiNumber)")
        }
    }
    
    @objc func projectileDone(){
        self.currentNumberOfKunais -= 1
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode){
        monstersDestroyed += 1
        label.text = "Monsters killed: \(monstersDestroyed)"
        
        //REMOVE BOTH NODES
        projectile.removeFromParent()
        monster.removeFromParent()
        
        //SUBSTRACT KUNAI
        currentNumberOfKunais -= 1
        
        //REMOVE A KUNAI
        if (monstersDestroyed % 10 == 0) && (maxKunaiNumber > 1){
            maxKunaiNumber -= 1
        }
    }
    
    func monsterDidCollideWithPlayer(monster: SKSpriteNode){
        if lives  > 0 {
            //REMOVE NODE
            monster.removeFromParent()
            //CHANGE LIVE COUNTER AND IMAGE
            lives -= 1
            liveImages[lives].texture = SKTexture(imageNamed: "zhead")
        }
        else{
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.ninja && contact.bodyB.categoryBitMask == PhysicsCategory.monster {
            monsterDidCollideWithPlayer(monster: contact.bodyB.node as! SKSpriteNode)
        }
        else if contact.bodyB.categoryBitMask == PhysicsCategory.ninja && contact.bodyA.categoryBitMask == PhysicsCategory.monster {
            monsterDidCollideWithPlayer(monster: contact.bodyA.node as! SKSpriteNode)
        }
        else if contact.bodyA.categoryBitMask == PhysicsCategory.star && contact.bodyB.categoryBitMask == PhysicsCategory.monster {
            projectileDidCollideWithMonster(projectile: contact.bodyA.node as! SKSpriteNode, monster: contact.bodyB.node as! SKSpriteNode)
        }
        else if contact.bodyB.categoryBitMask == PhysicsCategory.star && contact.bodyA.categoryBitMask == PhysicsCategory.monster {
            projectileDidCollideWithMonster(projectile: contact.bodyB.node as! SKSpriteNode, monster: contact.bodyA.node as! SKSpriteNode)
        }
    }
}
