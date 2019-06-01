//
//  GameScene.swift
//  CoinMan
//
//  Created by 장용범 on 30/01/2019.
//  Copyright © 2019 장용범. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
    var zombieTimer: Timer?
    
    //var ground: SKSpriteNode?
    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    
    var yourScoreLabel: SKLabelNode?
    var finalScoreLabel: SKLabelNode?
    var continueLabel: SKLabelNode?
    
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilCategory: UInt32 = 0x1 << 4
    let zombieCategory: UInt32 = 0x1 << 5
    
    
    var score = 0{
        didSet{
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    let clearScore = 20
    
    var isPlaying = true
    var isStop = false
    var jumpCount = 0
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        var coinManRun: [SKTexture] = []
        for number in 0 ... 20{
            coinManRun.append(SKTexture(imageNamed: "skeleton-run_\(number)"))
        }
        
        
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.05)))
        
        
        
        //        ground = childNode(withName: "ground") as? SKSpriteNode
        //        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        //        ground?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        scoreLabel = childNode(withName: "score") as? SKLabelNode
        
        setBGM()
        setBackground()
        startTimers()
        createGrass()
        createZombie()
    }
    
    func setBGM(){
        let rand = Int.random(in: 1..<4)
        let bgm = SKAudioNode(fileNamed: "bgm\(rand).mp3")
        addChild(bgm)
        
        bgm.run(SKAction.play())
    }
    
    func setBackground(){
        let background = SKSpriteNode(imageNamed: "zombieworld")
        background.size = frame.size
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1
        addChild(background)
    }
    
    func startTimers(){
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createCoin()
        })
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.createBomb()
        })
        
        zombieTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true, block: { (timer) in
            self.createFastZombie()
        })
        
    }
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        
        for number in 0...numberOfGrass{
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = 0
            grass.physicsBody?.contactTestBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            let grassX = -size.width / 2 + grass.size.width / 2 + grass.size.width * CGFloat(number)
            let grassY = -size.height / 2 + grass.size.height / 2 - 10
            grass.position = CGPoint(x: grassX, y: grassY)
            
            let speed: Double = 100
            
            let firstMoveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            let grassFullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullMove,resetGrass]))
            
            grass.run(SKAction.sequence([firstMoveLeft, resetGrass, grassMovingForever]))
        }
    }
    
    func createCoin(){
        let coin = SKSpriteNode(imageNamed: "vaccine")
        coin.size = CGSize(width: 100, height: 100)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height/2 - coin.size.height
        let minY = -size.height/2 + coin.size.height + sizingGrass.size.height
        
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(maxY-minY)))
        
        coin.position = CGPoint(x: size.width/2 + coin.size.width/2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 3)
        
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func createBomb(){
        let bomb = SKSpriteNode(imageNamed: "virus")
        bomb.size = CGSize(width: 100, height: 100)
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height/2 - bomb.size.height
        let minY = -size.height/2 + bomb.size.height + sizingGrass.size.height
        
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(maxY-minY)))
        
        bomb.position = CGPoint(x: size.width/2 + bomb.size.width/2, y: bombY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 3)
        
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func createZombie(){
        let zombie = SKSpriteNode(imageNamed: "Run1")
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.contactTestBitMask = coinManCategory
        
        var coinManRun: [SKTexture] = []
        for number in 4 ... 10{
            let tex = SKTexture(imageNamed: "Run\(number)")
            coinManRun.append(tex)
        }
        
        
        zombie.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.1)))
        zombie.size = CGSize(width: 170, height: 250)
        zombie.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 170, height: 250))
        zombie.physicsBody?.affectedByGravity = false
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.contactTestBitMask = coinManCategory
        zombie.physicsBody?.collisionBitMask = 0
        addChild(zombie)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
    
//        let maxY = size.height/2 - zombie.size.height
//        let minY = -size.height/2 + zombie.size.height + sizingGrass.size.height
        
        //let bombY = maxY - CGFloat(arc4random_uniform(UInt32(maxY-minY)))
        
        zombie.position = CGPoint(x: -size.width/2 - zombie.size.width/2, y: -size.height/2 + zombie.size.height/2 + sizingGrass.size.height/2)
        
        let moveRight = SKAction.moveBy(x: size.width + zombie.size.width, y: 0, duration: 130)
        
        zombie.run(SKAction.sequence([moveRight, SKAction.removeFromParent()]))
    }
    
    func createFastZombie(){
        let zombie = SKSpriteNode(imageNamed: "Run1")
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.contactTestBitMask = coinManCategory
        
        var coinManRun: [SKTexture] = []
        for number in 4 ... 10{
            let tex = SKTexture(imageNamed: "Run\(number)-2")
            coinManRun.append(tex)
        }
        zombie.run(SKAction.playSoundFileNamed("EvilLaugh.mp3", waitForCompletion: false))
        
        zombie.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.1)))
        zombie.size = CGSize(width: 100, height: 150)
        zombie.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 150))
        zombie.physicsBody?.affectedByGravity = false
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.contactTestBitMask = coinManCategory
        zombie.physicsBody?.collisionBitMask = 0
        addChild(zombie)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        //        let maxY = size.height/2 - zombie.size.height
        //        let minY = -size.height/2 + zombie.size.height + sizingGrass.size.height
        
        //let bombY = maxY - CGFloat(arc4random_uniform(UInt32(maxY-minY)))
        
        zombie.position = CGPoint(x: -size.width - zombie.size.width/2, y: -size.height/2 + zombie.size.height/2 + sizingGrass.size.height/2)
        
        let moveRight = SKAction.moveBy(x: 2*size.width + zombie.size.width, y: 0, duration: 9)
        
        zombie.run(SKAction.sequence([moveRight, SKAction.removeFromParent()]))
    }
    
    func createPause(){
        let pause = SKSpriteNode(imageNamed: "interface")
        pause.name = "pause"
        pause.zPosition = 1
        pause.physicsBody = SKPhysicsBody(rectangleOf: pause.size)
        pause.physicsBody?.affectedByGravity = false
        pause.position = CGPoint(x: size.height/2, y: size.width/2)
        addChild(pause)
        
    }
    
    func gameOver(finished : () -> Void ){
        
        isPlaying = false
        
        if score < clearScore{
            coinMan?.run(SKAction.playSoundFileNamed("zombie.wav", waitForCompletion: false))
            
            var zombieManRun: [SKTexture] = []
            for number in 1 ... 8{
                zombieManRun.append(SKTexture(imageNamed: "Dead\(number)"))
            }
            
            coinMan?.run(SKAction.playSoundFileNamed("zombie.wav", waitForCompletion: false))
            
            coinMan?.run(SKAction.animate(with: zombieManRun, timePerFrame: 0.15))
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: pauseGame)
        }else{
            coinMan?.run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: pauseGame)
        }
        
        //        finished()
        
    }
    
    func pauseGame() {
        
        print("pause Game")
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        if isStop{
            yourScoreLabel = SKLabelNode(text: "Pause")
            yourScoreLabel?.fontName = "Creepster-Regular"
            yourScoreLabel?.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            yourScoreLabel!.position = CGPoint(x: 0, y: 200)
            yourScoreLabel!.fontSize = 100
            yourScoreLabel?.zPosition = 1
            addChild(yourScoreLabel!)
            
            
            let playButton = SKSpriteNode(imageNamed: "play")
            playButton.size = CGSize(width: 100, height: 100)
            playButton.zPosition = 1
            playButton.position = CGPoint(x: 0, y: -200)
            playButton.name = "continue"
            addChild(playButton)
            
            //            continueLabel = SKLabelNode(text: "Continue")
            //            continueLabel!.name = "continue"
            //            continueLabel?.fontName = "Creepster-Regular"
            //            continueLabel?.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            //            continueLabel!.position = CGPoint(x: 0, y: 0)
            //            continueLabel!.fontSize = 80
            //            continueLabel?.zPosition = 1
            //            addChild(continueLabel!)
        }else{
            
            if score == clearScore{
                
                yourScoreLabel = SKLabelNode(text: "Congratulation!")
                yourScoreLabel?.fontName = "Creepster-Regular"
                yourScoreLabel?.fontColor = #colorLiteral(red: 0, green: 0.6487853168, blue: 0, alpha: 1)
                yourScoreLabel!.position = CGPoint(x: 0, y: 200)
                yourScoreLabel!.fontSize = 100
                yourScoreLabel?.zPosition = 1
                addChild(yourScoreLabel!)
                
                
                finalScoreLabel = SKLabelNode(text: "You Survived!!")
                finalScoreLabel?.fontName = "Creepster-Regular"
                finalScoreLabel?.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                finalScoreLabel!.position = CGPoint(x: 0, y: 0)
                finalScoreLabel!.fontSize = 80
                finalScoreLabel?.zPosition = 1
                addChild(finalScoreLabel!)
                
                let playButton = SKSpriteNode(imageNamed: "replay")
                playButton.size = CGSize(width: 100, height: 100)
                playButton.zPosition = 1
                playButton.position = CGPoint(x: 0, y: -200)
                playButton.name = "replay"
                addChild(playButton)
            }else{
                
                
                
                yourScoreLabel = SKLabelNode(text: "Your Score:")
                yourScoreLabel?.fontName = "Creepster-Regular"
                yourScoreLabel?.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                yourScoreLabel!.position = CGPoint(x: 0, y: 200)
                yourScoreLabel!.fontSize = 100
                yourScoreLabel?.zPosition = 1
                addChild(yourScoreLabel!)
                
                finalScoreLabel = SKLabelNode(text: "\(score)")
                finalScoreLabel?.fontName = "Creepster-Regular"
                finalScoreLabel?.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                finalScoreLabel!.position = CGPoint(x: 0, y: 0)
                finalScoreLabel!.fontSize = 200
                finalScoreLabel?.zPosition = 1
                addChild(finalScoreLabel!)
                
                let playButton = SKSpriteNode(imageNamed: "play")
                playButton.size = CGSize(width: 100, height: 100)
                playButton.zPosition = 1
                playButton.position = CGPoint(x: 0, y: -200)
                playButton.name = "play"
                addChild(playButton)
            }
            
            
        }
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        func restartGameScene(){
            
            let gameScene:GameScene = GameScene(fileNamed: "GameScene")! // create your new scene
            let transition = SKTransition.fade(with: .red, duration: 2) // create type of transition (you can check in documentation for more transtions)
            gameScene.scaleMode = SKSceneScaleMode.fill
            self.view!.presentScene(gameScene, transition: transition)
        }
        
        if !(scene?.isPaused)!{
            if jumpCount < 2{
                coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 60000))
                jumpCount += 1
            }
        }
        
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            
            for node in theNodes{
                if node.name == "play" || node.name == "replay"{
                    // Restart
                    restartGameScene()
                    score = 0
                    isPlaying = true
                    //                    node.removeFromParent()
                    //                    yourScoreLabel?.removeFromParent()
                    //                    finalScoreLabel?.removeFromParent()
                    //                    scene?.isPaused = false
                    startTimers()
                    
                    
                }
                
//                if node.name == "pauseButton"{
//                    isStop = true
//                    pauseGame()
//                }
//
//                if node.name == "continue"{
//                    yourScoreLabel?.removeFromParent()
//                    finalScoreLabel?.removeFromParent()
//                    scene?.isPaused = false
//                }
                
                
            }
        }
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        
        if isPlaying{
            
            if contact.bodyA.categoryBitMask == coinCategory{
                score += 1
                contact.bodyA.node?.removeFromParent()
                coinMan?.run(SKAction.playSoundFileNamed("coin2.mp3", waitForCompletion: false))
                
                if score == clearScore{
                    self.gameOver(finished: self.pauseGame)
                }
                
            }
            
            if contact.bodyB.categoryBitMask == coinCategory{
                score += 1
                contact.bodyB.node?.removeFromParent()
                coinMan?.run(SKAction.playSoundFileNamed("coin2.mp3", waitForCompletion: false))
                
                if score == clearScore{
                    self.gameOver(finished: self.pauseGame)
                }
                
            }
            
            if contact.bodyA.categoryBitMask == bombCategory{
                print("GAME OVER")
                var zombieManRun: [SKTexture] = []
                for number in 1 ... 10{
                    zombieManRun.append(SKTexture(imageNamed: "__Zombie01_Dead_00\(number)"))
                }
                
                self.gameOver(finished: self.pauseGame)
            }
            
            if contact.bodyB.categoryBitMask == bombCategory{
                print("GAME OVER")
                
                self.gameOver(finished: self.pauseGame)
            }
            
            if contact.bodyA.categoryBitMask == groundAndCeilCategory{
                jumpCount = 0
            }
            
            if contact.bodyB.categoryBitMask == groundAndCeilCategory{
                jumpCount = 0
            }
            
            if contact.bodyA.categoryBitMask == zombieCategory{
                self.gameOver(finished: self.pauseGame)
            }
            
            if contact.bodyB.categoryBitMask == zombieCategory{
                self.gameOver(finished: self.pauseGame)
            }
        }
    }
    
    
}
