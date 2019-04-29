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
    
    var score = 0{
        didSet{
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    let clearScore = 5
    
    var isPlaying = true
    var isStop = false
    
    
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
    }
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        
        for number in 0...numberOfGrass{
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = groundAndCeilCategory
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
            for number in 0 ... 7{
                //zombieManRun.append(SKTexture(imageNamed: "Walk (\(number))"))
                zombieManRun.append(SKTexture(imageNamed: "__Zombie01_Dead_00\(number)"))
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
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 70000))
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
                //coinMan?.run(SKAction.animate(with: zombieManRun, timePerFrame: 0.5))
                
                //coinMan?.run(SKAction.playSoundFileNamed("zombie.wav", waitForCompletion: false))
                
                //            self.gameOver {
                //                self.pauseGame()
                //            }
                self.gameOver(finished: self.pauseGame)
            }
            
            if contact.bodyB.categoryBitMask == bombCategory{
                print("GAME OVER")
                
                //            var zombieManRun: [SKTexture] = []
                //            for number in 0 ... 7{
                //                //zombieManRun.append(SKTexture(imageNamed: "Walk (\(number))"))
                //                zombieManRun.append(SKTexture(imageNamed: "__Zombie01_Dead_00\(number)"))
                //            }
                //
                //            coinMan?.run(SKAction.playSoundFileNamed("zombie.wav", waitForCompletion: false))
                //
                //            coinMan?.run(SKAction.animate(with: zombieManRun, timePerFrame: 0.15))
                
                //coinMan?.run(SKAction.playSoundFileNamed("zombie.wav", waitForCompletion: false))
                
                self.gameOver(finished: self.pauseGame)
            }
            
        }
    }
    
    
}
