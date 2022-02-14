//
//  GameScene.swift
//  BaseController Shared
//
//  Created by Pedro Cacique.
//  Contributor Joaquim Pessoa Filho
//

import SpriteKit
import GameController

class GameScene: SKScene, JoystickDelegate, SKPhysicsContactDelegate {
    
    var animal = SKSpriteNode(imageNamed: "parrot")
    var monster = SKSpriteNode(imageNamed: "monster")
    var monsterInitialPosition: CGPoint {
        let x = self.size.width - 60
        let y = self.size.height - 60
        
        return CGPoint(x: x, y: y)
    }
    
    let initialPosition = CGPoint(x: 100, y: 100)
    let multiplier: CGFloat = 10.0
    let joystickController: JoystickController = JoystickController()
    var lastActionTime: TimeInterval = TimeInterval.zero
    let whaitForNextAction: Double = 1
    
    var dx:CGFloat = 0
    var dy:CGFloat = 0
    
    var monsterX: CGFloat = -1
    var monsterY: CGFloat = 0
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    func setUpScene() {
        joystickController.delegate = self
        joystickController.observeForGameControllers()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
        
        createAnimal()
                
        monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: monster.texture!.size())
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = 1 << 2

        insertMonster()


       
 
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print(contact.bodyA)
        print(contact.bodyB)
        resetAnimal()
        monster.position = monsterInitialPosition
    }
    
    func createAnimal() {
        let animalName = ["parrot", "bear", "buffalo", "chick"]
        let index = Int.random(in: 0..<animalName.count)
        
        animal.removeFromParent()
        animal = SKSpriteNode(imageNamed: animalName[index])
        animal.position = initialPosition
        
        animal.physicsBody = SKPhysicsBody(texture: animal.texture!, size: animal.texture!.size())
        animal.physicsBody?.isDynamic = true
        animal.physicsBody?.categoryBitMask = 1 << 1
        animal.physicsBody?.contactTestBitMask = 1 << 2
        
        self.addChild(animal)
    }
    
    func insertMonster() {
        monster.setScale(0.1)
        monster.position = monsterInitialPosition
        
        self.addChild(monster)
    }
    
    func moveAnimal(dx: CGFloat, dy: CGFloat) {
        var xValue = animal.position.x + dx * multiplier
        var yValue = animal.position.y + dy * multiplier
        
        let animalWidth = animal.size.width/2
        let animalHeight = animal.size.height/2
        
        //        if xValue > self.size.width {
        //            xValue = 0
        //        }
        //        if xValue < 0 {
        //            xValue = self.size.width
        //        }
        //        if yValue > self.size.height {
        //            yValue = 0
        //        }
        //        if yValue < 0 {
        //            yValue = self.size.height
        //        }
        
        if xValue > self.size.width - animalWidth {
            xValue = self.size.width - animalWidth
        }
        if xValue < animalWidth {
            xValue = animalWidth
        }
        if yValue > self.size.height - animalHeight {
            yValue = self.size.height  - animalHeight
        }
        if yValue < animalHeight {
            yValue = animalHeight
        }
        
        animal.position = CGPoint(x: xValue, y: yValue)
    }
    
    func moveMonster(xValue: CGFloat) {
        monster.position.x = monster.position.x + xValue

    }
    
    func resetAnimal() {
        animal.position = initialPosition
        createAnimal()
    }
    
    override func update(_ currentTime: TimeInterval) {
        joystickController.update(currentTime)
        moveAnimal(dx: dx, dy: dy)
        moveMonster(xValue: monsterX)
    }
    
#if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
#else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
#endif
    
    //MARK :- iOS and tvOS
#if os(iOS) || os(tvOS)
    // Touch-based event handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
#endif
    
#if os(OSX)
    // Mouse-based event handling
    override func mouseDown(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    
    // evita o beep quando aperta uma tecla normalmente
    override func keyDown(with event: NSEvent) { }
    override func keyUp(with event: NSEvent) { }
#endif
    
    //MARK:- JoystickDelegate
    func controllerDidConnect(controller: GCController) {
        print("Controller connected")
    }
    
    func controllerDidDisconnect() {
        print("Controller disconnected")
    }
    
    func keyboardDidConnect(keyboard: GCKeyboard) {
        print("Keyboard connected")
    }
    
    func keyboardDidDisconnect(keyboard: GCKeyboard) {
        print("Keyboard disconnected")
    }
    
    func buttonPressed(command: GameCommand) {
        print("pressed: \(command)")
        
        switch command {
        case .UP:
            dy = 1
        case .DOWN:
            dy = -1
        case .RIGHT:
            dx = 1
        case .LEFT:
            dx = -1
        case .ACTION:
            resetAnimal()
            return
        }
        
    }
    
    func buttonReleased(command: GameCommand) {
        print("released: \(command)")
        switch command {
        case .UP:
            dy = 0
        case .DOWN:
            dy = 0
        case .RIGHT:
            dx = 0
        case .LEFT:
            dx = 0
        default:
            return
        }
    }
    
    func joystickUpdate(_ currentTime: TimeInterval){
        if let gamePadLeft = joystickController.gamePadLeft {
            if gamePadLeft.xAxis.value != 0 || gamePadLeft.yAxis.value != 0{
                let dx: CGFloat = CGFloat(gamePadLeft.xAxis.value)
                let dy: CGFloat = CGFloat(gamePadLeft.yAxis.value)
                // print("dpad: \(dx), \(dy)")
                moveAnimal(dx: dx, dy: dy)
            }
        }
        
        if let buttonX = joystickController.buttonX {
            if buttonX.isPressed{
                // print("X Button: \(buttonX.isPressed)")
                if(lastActionTime + whaitForNextAction < currentTime) {
                    resetAnimal()
                    lastActionTime = currentTime
                }
            }
        }
    }
}
