//
//  GameScene.swift
//  GridSnake
//
//  Created by Salvatore Manna on 29/03/22.
//

import SpriteKit
import GameplayKit

struct SnakeSinglePart{
    var snakeBodyPart: SKShapeNode = SKShapeNode(rectOf: CGSize(width: snakeSize, height: snakeSize))
    
    
    var currentDirection: String = "Right"
    var previousDirection: String = "Right"
    var nextDirection: String = "Right"

}

var snakeBody: [SnakeSinglePart] = []


struct PhysicsMasks{
    static let snakeHeadMask: UInt32 = 1 << 0
    static let collectibleMask: UInt32 = 1 << 1
    static let firstBodyPartMask: UInt32 = 1<<2
    static let bodyPartMask: UInt32 = 1<<3
    
    static let none: UInt32 = 1 << 8
}

var movementTimeFrame: CGFloat = 0.05
//var movementTimeFrame: CGFloat = 0.03

var movementSpeed: CGFloat = 1

var xDir: CGFloat = 0
var yDir: CGFloat = 0

var snakeSize: CGFloat = 16

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var numberOfRows: Int
    var numberOfColumns: Int
    var playableWidth:CGFloat = 400
    var playableHeight:CGFloat = 720
    var playableBackground: SKShapeNode
    
    var snakeHead: SKShapeNode = SKShapeNode(rectOf: CGSize(width: snakeSize, height: snakeSize))
    
    var previousDirection: String = ""
    var currentDirection: String = ""
    var nextDirection: String = ""
    
    var firstStart = true
    
    var collectiblesCounter = 0
    
    override init(size: CGSize) {
        
        numberOfRows = Int(playableHeight/snakeSize)
        numberOfColumns = Int(playableWidth/snakeSize)
        
        playableBackground = SKShapeNode(rectOf: CGSize(width: playableWidth, height: playableHeight))
        
//        print("\(size.height)+\(size.width)")
//        print("\(playableWidth):\(numberOfColumns) + \(playableHeight):\(numberOfRows)")
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        self.scene?.physicsWorld.contactDelegate = self
        
        addSwipeGestureRecognizers()
        
        backgroundColor = .black
        
        playableBackground.strokeColor = .systemGray
        playableBackground.fillColor = .systemGray
        playableBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(playableBackground)
        
        snakeHead.fillColor = .white
        snakeHead.position = CGPoint(x: size.width/2, y: size.height/2)

        setUpNode(myNode: &snakeHead, myColor: .white, myX: playableBackground.position.x-playableWidth/2+snakeSize/2, myY: playableBackground.position.y+playableHeight/2-snakeSize/2, myZ: 5, myDynamic: false, myCategoryBitMask: PhysicsMasks.snakeHeadMask, myTestBitMask: PhysicsMasks.collectibleMask, myCollisionBitMask: PhysicsMasks.none, myName: "snakeHead")
        
        spawnCollectible()
        
//        snakeBody.append(SnakeSinglePart())
//        snakeBody[0].snakeBodyPart.fillColor = .white
//        snakeBody[0].snakeBodyPart.position = CGPoint(x: size.width/2-snakeSize, y: size.height/2)
//        addChild(snakeBody[0].snakeBodyPart)
//
//        snakeBody.append(SnakeSinglePart())
//        snakeBody[1].snakeBodyPart.fillColor = .white
//        snakeBody[1].snakeBodyPart.position = CGPoint(x: size.width/2-snakeSize*2, y: size.height/2)
//        addChild(snakeBody[1].snakeBodyPart)
        
//
//        snakeHeadMovement()

    }
    
    func spawnCollectible(){
        let myColumn = Int.random(in: 0..<numberOfColumns)
        let myRow = Int.random(in: 0..<numberOfRows)
        
        var collectible = SKShapeNode(rectOf: CGSize(width: snakeSize, height: snakeSize))
        collectible.position.x = (playableBackground.position.x-playableWidth/2+snakeSize/2)+CGFloat((myColumn-1*16))
        collectible.position.y = (playableBackground.position.y-playableHeight/2-snakeSize/2)+CGFloat((myRow-1*16))
        
        setUpNode(myNode: &collectible, myColor: .red, myX: (playableBackground.position.x-playableWidth/2+snakeSize/2)+CGFloat((myColumn*16))
, myY: (playableBackground.position.y-playableHeight/2-snakeSize/2)+CGFloat((myRow*16))
, myZ: 5, myDynamic: true, myCategoryBitMask: PhysicsMasks.collectibleMask, myTestBitMask: PhysicsMasks.snakeHeadMask, myCollisionBitMask: PhysicsMasks.none, myName: "collectible-\(collectiblesCounter)")
        collectiblesCounter += 1
        
    }
    
    func setUpNode(myNode: inout SKShapeNode, myColor: UIColor, myX: CGFloat, myY: CGFloat, myZ: CGFloat, myDynamic: Bool, myCategoryBitMask: UInt32, myTestBitMask: UInt32, myCollisionBitMask: UInt32, myName: String){
        myNode.position = CGPoint(x: myX, y: myY)
        myNode.strokeColor = myColor
        myNode.fillColor = myColor
        myNode.zPosition = myZ
        myNode.name = myName
        
        myNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: snakeSize, height: snakeSize))
        myNode.physicsBody?.affectedByGravity = false
        myNode.physicsBody?.restitution = 0
        myNode.physicsBody?.isDynamic = myDynamic
        myNode.physicsBody?.categoryBitMask = myCategoryBitMask
        myNode.physicsBody?.collisionBitMask = myCollisionBitMask
        myNode.physicsBody?.contactTestBitMask = myTestBitMask
        
        addChild(myNode)
    }
    
    func snakeHeadMovement(){
        print("Head: \(previousDirection)+\(currentDirection)+\(nextDirection)")
        switch nextDirection{
        case "Up":
//            currentDirection = nextDirection
            xDir = 0
            yDir = movementSpeed
        case "Down":
//            currentDirection = nextDirection
            xDir = 0
            yDir = -movementSpeed
        case "Right":
//            currentDirection = nextDirection
            xDir = movementSpeed
            yDir = 0
        case "Left":
//            currentDirection = nextDirection
            xDir = -movementSpeed
            yDir = 0
        default:
            return
        }
        snakeHead.position.x += xDir*(snakeSize)
        snakeHead.position.y += yDir*(snakeSize)

        currentDirection = nextDirection
        print("Head: \(previousDirection)+\(currentDirection)+\(nextDirection)")
        
        var index = 0
        
        if(snakeBody.count > 0){
            snakeBody[index].nextDirection = previousDirection
            snakeBodyMovement(index: &index)
            
        }
        
        index = 0
        if(snakeBody.count > 0){
            for index in 0...snakeBody.count-1{
                snakeBody[index].previousDirection = snakeBody[index].currentDirection
//                if(index != 0){
//
//                } else {
//                    snakeBody[index].previousDirection = snakeBody[index].currentDirection
//                }
            }
        }
//        for index in 0...snakeBody.count-1{
//            if(index > 0){
//                snakeBody[index].nextDirection = snakeBody[index-1].currentDirection
//                snakeBodyMovement(index: index)
//            } else {
//                snakeBody[index].nextDirection = currentDirection
//                snakeBodyMovement(index: index)
//            }
//        }
        
        previousDirection = currentDirection
        print("Head: \(previousDirection)+\(currentDirection)+\(nextDirection)")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+movementTimeFrame, execute: {
            self.snakeHeadMovement()
        })
    }
    
    func snakeBodyMovement(index: inout Int){
        print("\(index)Pre: \(snakeBody[index].previousDirection)+\(snakeBody[index].currentDirection)+\(snakeBody[index].nextDirection)")
        switch snakeBody[index].nextDirection{
        case "Up":
            xDir = 0
            yDir = movementSpeed
        case "Down":
            xDir = 0
            yDir = -movementSpeed
        case "Right":
            xDir = movementSpeed
            yDir = 0
        case "Left":
            xDir = -movementSpeed
            yDir = 0
        default:
            return
        }
        snakeBody[index].snakeBodyPart.position.x += xDir*(snakeSize)
        snakeBody[index].snakeBodyPart.position.y += yDir*(snakeSize)
        
        snakeBody[index].currentDirection = snakeBody[index].nextDirection

        print("\(index): \(snakeBody[index].previousDirection)+\(snakeBody[index].currentDirection)+\(snakeBody[index].nextDirection)")
        
        if(snakeBody.count-1 > index){
            index += 1
            snakeBody[index].nextDirection = snakeBody[index-1].previousDirection
            snakeBodyMovement(index: &index)
        }
        
        snakeBody[index].previousDirection = snakeBody[index].currentDirection
        print("\(index): \(snakeBody[index].previousDirection)+\(snakeBody[index].currentDirection)+\(snakeBody[index].nextDirection)")
        
    }
    
    //*****************
    //FUNZIONI PER GESTIRE LO SWIPE
    func addSwipeGestureRecognizers(){
        let swipeGestureDirections: [UISwipeGestureRecognizer.Direction] = [.up, .down, .right, .left]
        
        for direction in swipeGestureDirections{
            let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gestureRecognizer.direction = direction
            self.view?.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer){
        if let gesture = gesture as? UISwipeGestureRecognizer{
            switch gesture.direction {
            case .up:
                    if(currentDirection != "Down" && currentDirection != "Up"){
                        nextDirection = "Up"
                        if(firstStart){
                            firstStart = false
                            snakeHeadMovement()
                        }
//                        yDir = movementSpeed
//                        xDir = 0
                }
            case .down:
                    if(currentDirection != "Up" && currentDirection != "Down"){
                        nextDirection = "Down"
                        if(firstStart){
                            firstStart = false
                            snakeHeadMovement()
                        }
//                        yDir = -movementSpeed
//                        xDir = 0
                }
            case .right:
                    if(currentDirection != "Left" && currentDirection != "Rigth"){
                        nextDirection = "Right"
                        if(firstStart){
                            firstStart = false
                            snakeHeadMovement()
                        }
//                        xDir = movementSpeed
//                        yDir = 0
                    }
            case .left:
                    if(currentDirection != "Left" && currentDirection != "Right"){
                        nextDirection = "Left"
                        if(firstStart){
                            firstStart = false
                            snakeHeadMovement()
                        }
//                        xDir = -movementSpeed
//                        yDir = 0
                }
            default:
                print("Default")
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        if(snakeHead.position.x > (playableBackground.position.x + playableWidth/2 )){
            snakeHead.position.x = playableBackground.position.x-playableWidth/2+snakeSize/2
        }
        if(snakeHead.position.x < (playableBackground.position.x - playableWidth/2 + snakeSize/2 )){
            snakeHead.position.x = playableBackground.position.x+playableWidth/2-snakeSize/2
        }
        if(snakeHead.position.y > (playableBackground.position.y + playableHeight/2  )){
            snakeHead.position.y = playableBackground.position.y-playableHeight/2+snakeSize/2
        }
        if(snakeHead.position.y < (playableBackground.position.y - playableHeight/2 + snakeSize/2 )){
            snakeHead.position.y = playableBackground.position.y+playableHeight/2-snakeSize/2
        }
        
        if(snakeBody.count != 0){
            for index in 0...snakeBody.count-1{
                if(snakeBody[index].snakeBodyPart.position.x > (playableBackground.position.x + playableWidth/2 )){
                    snakeBody[index].snakeBodyPart.position.x = playableBackground.position.x-playableWidth/2+snakeSize/2
                }
                if(snakeBody[index].snakeBodyPart.position.x < (playableBackground.position.x - playableWidth/2 + snakeSize/2 )){
                    snakeBody[index].snakeBodyPart.position.x = playableBackground.position.x+playableWidth/2-snakeSize/2
                }
                if(snakeBody[index].snakeBodyPart.position.y > (playableBackground.position.y + playableHeight/2  )){
                    snakeBody[index].snakeBodyPart.position.y = playableBackground.position.y-playableHeight/2+snakeSize/2
                }
                if(snakeBody[index].snakeBodyPart.position.y < (playableBackground.position.y - playableHeight/2 + snakeSize/2 )){
                    snakeBody[index].snakeBodyPart.position.y = playableBackground.position.y+playableHeight/2-snakeSize/2
                }
            }
        }
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
                
        if contact.bodyA.node?.name == "snakeHead"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        let nodeName = secondBody.node?.name
        
        if(firstBody.node?.name == "snakeHead" && nodeName!.contains("collectible")){
            enumerateChildNodes(withName: "*"){node, _ in
                if(node.name == secondBody.node?.name){
                    node.removeFromParent()
                    self.spawnCollectible()
                    self.addSnakePart()
                }
            }
        }
    }
    
    func addSnakePart(){
            if(snakeBody.count == 0){
                snakeBody.append(SnakeSinglePart())
                var myX: CGFloat
                var myY: CGFloat
                switch currentDirection{
                case "Up":
                    myX = snakeHead.position.x
                    myY = snakeHead.position.y-snakeSize
                    snakeBody[snakeBody.count-1].currentDirection = currentDirection
                case "Down":
                    myX = snakeHead.position.x
                    myY = snakeHead.position.y+snakeSize
                    snakeBody[snakeBody.count-1].currentDirection = currentDirection
                case "Right":
                    myX = snakeHead.position.x-snakeSize
                    myY = snakeHead.position.y
                    snakeBody[snakeBody.count-1].currentDirection = currentDirection
                case "Left":
                    myX = snakeHead.position.x+snakeSize
                    myY = snakeHead.position.y
                    snakeBody[snakeBody.count-1].currentDirection = currentDirection
                default:
                    return
                }
                setUpNode(myNode: &snakeBody[snakeBody.count-1].snakeBodyPart, myColor: .blue, myX: myX, myY: myY, myZ: 5, myDynamic: true, myCategoryBitMask: PhysicsMasks.firstBodyPartMask, myTestBitMask: PhysicsMasks.none, myCollisionBitMask: PhysicsMasks.none, myName: "bodyPart-\(snakeBody.count)")
            } else if(snakeBody.count != 0){
                snakeBody.append(SnakeSinglePart())
                var myX: CGFloat
                var myY: CGFloat
                switch snakeBody[snakeBody.count-2].currentDirection{
                case "Up":
                    myX = snakeBody[snakeBody.count-2].snakeBodyPart.position.x
                    myY = snakeBody[snakeBody.count-2].snakeBodyPart.position.y-snakeSize
                    snakeBody[snakeBody.count-1].currentDirection = snakeBody[snakeBody.count-2].currentDirection
                case "Down":
                    myX = snakeBody[snakeBody.count-2].snakeBodyPart.position.x
                    myY = snakeBody[snakeBody.count-2].snakeBodyPart.position.y+snakeSize
                    snakeBody[snakeBody.count-1].currentDirection = snakeBody[snakeBody.count-2].currentDirection
                case "Right":
                    myX = snakeBody[snakeBody.count-2].snakeBodyPart.position.x-snakeSize
                    myY = snakeBody[snakeBody.count-2].snakeBodyPart.position.y
                    snakeBody[snakeBody.count-1].currentDirection = snakeBody[snakeBody.count-2].currentDirection
                case "Left":
                    myX = snakeBody[snakeBody.count-2].snakeBodyPart.position.x+snakeSize
                    myY = snakeBody[snakeBody.count-2].snakeBodyPart.position.y
                    snakeBody[snakeBody.count-1].currentDirection = snakeBody[snakeBody.count-2].currentDirection
                default:
                    return
                }
                setUpNode(myNode: &snakeBody[snakeBody.count-1].snakeBodyPart, myColor: .blue, myX: myX, myY: myY, myZ: 5, myDynamic: true, myCategoryBitMask: PhysicsMasks.firstBodyPartMask, myTestBitMask: PhysicsMasks.none, myCollisionBitMask: PhysicsMasks.none, myName: "bodyPart-\(snakeBody.count)")
            }
        
    }
    
    
}
