//
//  PhysicsEnv.swift
//  PhysicsCharts
//
//  Created by Brandon Knox on 6/26/24.
//

import SwiftUI
import SpriteKit
import Foundation

class GameScene: SKScene {
    @ObservedObject var controls = UIJoin.shared
    
    @AppStorage("TimesAppLoaded") private var timesAppLoaded = 0
    @AppStorage("LastRed") private var lastRed = 0.0
    @AppStorage("LastGreen") private var lastGreen = 0.43
    @AppStorage("LastBlue") private var lastBlue = 0.83
    
    // vars used for camera gestures
    var initialCenter = CGPoint()
    var startX = CGFloat()
    var startY = CGFloat()
    var cameraScale = CGFloat()
    
    enum JoinStyle: String {
        case pin = "pin"
        case spring = "spring"
        case limit = "limit"
        case fixed = "fixed"
        case sliding = "sliding"
    }
    
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()

    func didBegin(_ contact: SKPhysicsContact) {
//        &&
//            contact.bodyA.node?.name == "ball" &&
//            contact.bodyB.node?.name == "ball"
        print("Collision!")
        if contact.collisionImpulse > 5 {
            
            let shockwave = SKShapeNode(circleOfRadius: 1)

            shockwave.position = contact.contactPoint
            addChild(shockwave)
            
            shockwave.run(shockWaveAction)
        }
    }
    
    // info on gesture recognizers: https://developer.apple.com/documentation/uikit/uigesturerecognizer
    
    // TODO: create object to store physics environment state
//    struct physicEnvStruct: Codable, Identifiable {
//        var id: ObjectIdentifier
//
//        // TODO: research how to make conform to encodable/decodable
//        var physicScene: SpriteView
//    }

    
    // TODO:  override the scene’s didChangeSize(_:) method, which is called whenever the scene changes size. When this method is called, you should update the scene’s contents to match the new size.
    override func didChangeSize(_ oldSize: CGSize) {
        /**
         # summary
         This function could be used to detect changes in the size of the app window and perform some actions accordingly (such as adjusting the layout of the app's UI).
         ## detail
         This is an "override" function in Swift, which means that it is replacing a default function that is called when a certain event occurs in the app. In this case, it is replacing the "didChangeSize" function, which is called when the size of the app's window changes.

         The function takes in an argument called "oldSize" which is of type CGSize. This argument represents the size of the app window before it was changed.

         In the body of the function, there are two lines of code that are currently commented out. These lines would increment a counter and print out a message indicating that the screen size has changed and the number of times it has changed.

         The final line of code prints out a message with the current size of the window.
         */
        // a number here to track (useful for debug for now)
//        controls.screenSizeChangeCount += 1
//        print("Screen changed \(controls.screenSizeChangeCount) times!")
//        print("New size:\(size)")
    }
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        /**
         # summary
         This is Swift code that overrides the method didMove(to view: SKView) in an SKScene subclass. It initializes the physics environment for the scene and sets up various gesture recognizers for the view.
         
         ## detail
         Specifically, it sets the physics body for the scene to be an edge loop with a certain size and a camera origin at the center. It also adds gesture recognizers for pinch zooming the camera, panning the camera, and moving the scene on the screen with three fingers. Lastly, it increments a variable timesAppLoaded to keep track of how many times the app has been loaded.
        */
        // initialize physics environment
        timesAppLoaded += 1
        let screenSizeX = 428.0  // dynamically do this later
        let physicsSize = screenSizeX * controls.physicsEnvScale
        let cameraOrigin = CGPoint(x: 0, y: 0)  // x was (physicsSize / 2)
        controls.cameraOrigin = cameraOrigin
        let physicsZone = CGRect(origin: cameraOrigin,
                                 size: CGSize(width: physicsSize,
                                              height: physicsSize))
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsZone)

        
        // adding pinch recgonizer for camera zoom
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(GameScene.pinchDetected(sender:)))
        view.addGestureRecognizer(pinch)
        
        // adding camera PanGestureRecognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panDetected(sender:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        view.addGestureRecognizer(pan)
        
        // hidden easter egg: 3 finger pan that moves scene on screen
        let moveScreen = UIPanGestureRecognizer(target: self, action: #selector(GameScene.screenPanDetected(sender:)))
        moveScreen.minimumNumberOfTouches = 3
        moveScreen.maximumNumberOfTouches = 3
        view.addGestureRecognizer(moveScreen)
    }
    
    @objc func pinchDetected(sender: UIPinchGestureRecognizer) {
        /**
         # summary
         This code seems to define a function named pinchDetected that handles a pinch gesture using UIPinchGestureRecognizer. The function updates the view's position based on the user's gesture.
         
         ## detail
         When the user starts pinching, the current position of the camera is saved, and the controls are marked as usingCamGesture.

         When the gesture is not cancelled, the scaling value of the camera is updated using the sender.scale property, and the cameraScale property is multiplied by 1 divided by the scale value. Additionally, the usingCamGesture property is set to false.

         If the gesture is cancelled, the camera scale is set back to the previous state, and usingCamGesture is also set to false.

         There is a TODO comment in the code that asks whether the camera reset is causing any issues, and future testing is suggested to verify this.
         
         ## pinch functions
         - handlePinchBegan
         - handlePinchChanged
         - handlePinchCancelled
         */
        // handle the pinch using scale value

        switch sender.state {
        case .began:
            handlePinchBegan()
        case .changed, .ended:
            handlePinchChanged(sender)
        case .cancelled:
            handlePinchCancelled()
        default:
            break
        }
    }
    
    func handlePinchBegan() {
        // Save the current camera scale for reference
        cameraScale = controls.camera.xScale
        controls.usingCamGesture = true
    }

    func handlePinchChanged(_ sender: UIPinchGestureRecognizer) {
        guard let camera = camera else { return }

        // Update the camera scale based on pinch gesture
        let newScale = cameraScale * 1 / sender.scale
        camera.setScale(newScale)
        controls.camera.xScale = newScale
        controls.usingCamGesture = false
    }

    func handlePinchCancelled() {
        // Restore the camera scale to its previous state on pinch cancellation
        guard let camera = camera else { return }
        camera.setScale(cameraScale)
        controls.usingCamGesture = false
        // TODO: Is this causing camera reset? Continue testing to verify.
    }
    
    // https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
    @objc func panDetected(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        let translation = sender.translation(in: view.superview)

        switch sender.state {
        case .began:
            handlePanBegan(translation)
        case .changed:
            handlePanChanged(translation)
        case .cancelled:
            handlePanCancelled()
        default:
            break
        }
    }

    func handlePanBegan(_ translation: CGPoint) {
        // Record the starting position of the camera for relative movement
        startX = controls.camera.position.x
        startY = controls.camera.position.y
        controls.usingCamGesture = true
    }

    func handlePanChanged(_ translation: CGPoint) {
        // Update the camera position based on the translation
        camera?.position.x = startX - translation.x
        camera?.position.y = startY + translation.y
        controls.camera.position = camera!.position
        controls.usingCamGesture = false
    }

    func handlePanCancelled() {
        // Restore the camera position to its original state on pan cancellation
        camera?.position.x = startX
        camera?.position.y = startY
        controls.camera.position = camera!.position
        controls.usingCamGesture = false
    }
    
    @objc func screenPanDetected(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            handleScreenPanBegan(view, sender)
        case .changed:
            handleScreenPanChanged(view, sender)
        case .cancelled:
            handleScreenPanCancelled(view)
        default:
            break
        }
    }

    func handleScreenPanBegan(_ view: UIView, _ sender: UIPanGestureRecognizer) {
        // Save the view's original position.
        initialCenter = view.center
    }

    func handleScreenPanChanged(_ view: UIView, _ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view.superview)
        // Update the view's position based on the translation.
        let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
        view.center = newCenter
    }

    func handleScreenPanCancelled(_ view: UIView) {
        // On cancellation, return the view to its original location.
        view.center = initialCenter
    }

    // release
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        handleNonPaintingTouchesEnded(touchedNodes, location)
        controls.gameScene = self
    }

    func handleNonPaintingTouchesEnded(_ touchedNodes: [SKNode], _ location: CGPoint) {
        controls.selectedNodes = touchedNodes
        
        guard let selectedNode = touchedNodes.first else {
            controls.drop = true
            // don't drop if erasing
            if !controls.removeOn && controls.drop != false {
                if controls.selectedShape == .data {
                    // make negative outcome bar
                    controls.dataOutcome = 0.0
                    let spaceApart = 20.0 / 2
                    let node1Location = CGPoint(x: location.x - spaceApart, y: location.y)
                    let newNode1 = renderNode(location: node1Location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                    addChild(newNode1)
                    // make positive outcome bar
                    controls.dataOutcome = 1.0
                    let node2Location = CGPoint(x: location.x + spaceApart, y: location.y)
                    let newNode2 = renderNode(location: node2Location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                    
                    addChild(newNode2)
                    controls.lastNode = newNode2
                } else {
                    let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                    
                    addChild(newNode)
                    controls.lastNode = newNode
                }
            }
            return
        }
    
        handleNonPaintNodeSelectedEnded(selectedNode)
    }

    func handleNonPaintNodeSelectedEnded(_ selectedNode: SKNode) {
        controls.selectedNode = selectedNode
        controls.lastNode = selectedNode
        controls.drop = false
        
        if controls.removeOn {
            selectedNode.removeFromParent()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /**
         # summary
         This Swift programming code is about handling touch events, specifically touchesMoved and touchesBegan events.
         
         ## detail
         In the touchesMoved function, the code is checking if the user is painting. If not, the code is checking if any physics node has been dragged and updating its position. If the user is painting, the code is trying to detect if the user is using the eraser or adding paint to the canvas.
         
         In the touchesBegan function, the code is checking if the user is selecting any non-paint node by tapping on it. If so, the node is logged for drag motion. If the user is painting, the code is checking if the user is using the eraser or adding paint to the canvas by tapping on it. Finally, the code is updating the controls structure and keeping track of all children objects (shape nodes).
         
         The code also contains several TODO comments that suggest there are some improvements that need to be made in the code logic. The code also uses some physics and node rendering functions that are not shown here.
         
         ## drag functions
                - touchesMoved
            - handleDraggedNonPaintingTouches
            - handleDraggedPhysicsNode
            - handleDraggedPourCode
            - handleDraggedPaintingTouches
            - handleDraggedErasingPaint
            - handleDraggedPainting
         */
        handleDraggedNonPaintingTouches(touches)
        controls.gameScene = self
    }
    
    func handleDraggedNonPaintingTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if controls.selectedNodes.count > 0 {
                handleDraggedPhysicsNode(location)
            }
        }
    }

    func handleDraggedPhysicsNode(_ location: CGPoint) {
        if controls.selectedNode.zPosition != -5 {
            controls.selectedNode.position = location
            controls.drop = false
        }
    }
 
    // tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        setBackgroundColor()

        handleNonPaintingTouchesBegan(at: location)

        controls.gameScene = self
    }

    func setBackgroundColor() {
        backgroundColor = UIColor(red: abs(lastRed - 1.0),
                                  green: abs(lastGreen - 1.0),
                                  blue: abs(lastBlue - 1.0),
                                  alpha: 0.5)
    }

    func handleNonPaintingTouchesBegan(at location: CGPoint) {
        let touchedNodes = nodes(at: location)
        controls.selectedNodes = touchedNodes

        guard touchedNodes.count > 0 else { return }

        let selectedNode = touchedNodes[0]
        if selectedNode.zPosition != -5 {
            controls.selectedNode = selectedNode
            if controls.removeOn {
                controls.selectedNode.removeFromParent()
            }
        }
    }
    
    func renderRowShape(shape: Shape, location: CGPoint, kind: JoinStyle) {
        /**
         # summary
         This is a function in Swift programming that renders a row of nodes, each representing a feature of a diabetes dataset.
         
         ## description
         The function starts by loading a row of data, choosing a random color for the row, and creating a node for the outcome feature (whether or not the person has diabetes) with a specific color and location. It then creates nodes for each of the other features in the row (ID, pregnancies, glucose level, blood pressure, skin thickness, insulin level, BMI, diabetes pedigree function, and age) and pins them to the previous node using a specific kind of joint. Finally, the last node of the row is set as the lastNode property of the controls object.
         */
        // flow is different since it does a row at a time
        let (_, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: create toggles for features
//        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.Outcome), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(outcomeNode)
        
        let idNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(idNode)
        // TODO: temporarily trying head on sliding (it pops off)
        pinJoinNodes(nodeA: outcomeNode, nodeB: idNode, kind: .sliding)

        let pregnanciesNode = createFeatureNodeShape(shape: shape, scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(pregnanciesNode)
        pinJoinNodes(nodeA: idNode, nodeB: pregnanciesNode, kind: kind)

        let glucoseNode = createFeatureNodeShape(shape: shape, scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(glucoseNode)
        pinJoinNodes(nodeA: pregnanciesNode, nodeB: glucoseNode, kind: kind)

        let bloodPressureNode = createFeatureNodeShape(shape: shape, scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(bloodPressureNode)
        pinJoinNodes(nodeA: glucoseNode, nodeB: bloodPressureNode, kind: kind)

        let skinThicknessNode = createFeatureNodeShape(shape: shape, scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(skinThicknessNode)
        pinJoinNodes(nodeA: bloodPressureNode, nodeB: skinThicknessNode, kind: kind)

        let insulinNode = createFeatureNodeShape(shape: shape, scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(insulinNode)
        pinJoinNodes(nodeA: skinThicknessNode, nodeB: insulinNode, kind: kind)
        
        let BMINode = createFeatureNodeShape(shape: shape, scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(BMINode)
        pinJoinNodes(nodeA: insulinNode, nodeB: BMINode, kind: kind)
        
        let diabetesPedigreeFunctionNode = createFeatureNodeShape(shape: shape, scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(diabetesPedigreeFunctionNode)
        pinJoinNodes(nodeA: BMINode, nodeB: diabetesPedigreeFunctionNode, kind: kind)
        
        let ageNode = createFeatureNodeShape(shape: shape, scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(ageNode)
        pinJoinNodes(nodeA: diabetesPedigreeFunctionNode, nodeB: ageNode, kind: kind)
        
        controls.lastNode = ageNode
    }
    
    func renderRow(location: CGPoint, kind: JoinStyle) {
        /**
         # summary
         This Swift code creates a function called renderRow that renders a row of data.
         
         ## description
         The function loads a single row of data and chooses a random color for it. It then creates different nodes using a custom function called createFeatureNode, which takes in the chosen color, the location where the node will be placed, and some other parameters. The feature nodes created are for pregnancy, glucose, blood pressure, skin thickness, insulin, BMI, diabetes pedigree function, and age.

         pinJoinNodes is another custom function that creates a physics joint between two nodes; this function is used to create a connection between the feature nodes. Finally, the function creates an outcome node that is either a smiley or a frowny face depending on if the patient has diabetes.

         There are some TODO comments in the code that suggest some parts of it are temporary and may need further development or customization. Overall, this code appears to be part of a larger project related to diabetes data analysis and visualization.
         */
        // flow is different since it does a row at a time
        let (_, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: create toggles for features
        let idNode = createFeatureNode(text: "i", scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(idNode)

        let pregnanciesNode = createFeatureNode(text: "P", scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(pregnanciesNode)
        pinJoinNodes(nodeA: idNode, nodeB: pregnanciesNode, kind: kind)

        let glucoseNode = createFeatureNode(text: "G", scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(glucoseNode)
        pinJoinNodes(nodeA: pregnanciesNode, nodeB: glucoseNode, kind: kind)

        let bloodPressureNode = createFeatureNode(text: "b", scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(bloodPressureNode)
        pinJoinNodes(nodeA: glucoseNode, nodeB: bloodPressureNode, kind: kind)

        let skinThicknessNode = createFeatureNode(text: "S", scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(skinThicknessNode)
        pinJoinNodes(nodeA: bloodPressureNode, nodeB: skinThicknessNode, kind: kind)

        let insulinNode = createFeatureNode(text: "I", scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(insulinNode)
        pinJoinNodes(nodeA: skinThicknessNode, nodeB: insulinNode, kind: kind)
        
        let BMINode = createFeatureNode(text: "B", scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(BMINode)
        pinJoinNodes(nodeA: insulinNode, nodeB: BMINode, kind: kind)
        
        let diabetesPedigreeFunctionNode = createFeatureNode(text: "D", scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(diabetesPedigreeFunctionNode)
        pinJoinNodes(nodeA: BMINode, nodeB: diabetesPedigreeFunctionNode, kind: kind)
        
        let ageNode = createFeatureNode(text: "A", scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(ageNode)
        pinJoinNodes(nodeA: diabetesPedigreeFunctionNode, nodeB: ageNode, kind: kind)

        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNode(text: hasDiabetes ? "☹︎" : "☻", scale: 1.0, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(outcomeNode)
        // TODO: temporarily trying head on sliding (it pops off)
        pinJoinNodes(nodeA: ageNode, nodeB: outcomeNode, kind: .sliding)
        
        controls.lastNode = idNode
    }
    
    func pinJoinNodes(nodeA: SKNode, nodeB: SKNode, kind: JoinStyle, anchorX: Float=0.0, anchorY: Float=0.0) {
        /**
         # summary
         This is a Swift function that creates various types of physics joints between two SKNodes.
         
         ## description
         The function takes in two SKNodes, a JoinStyle enum that specifies the type of joint to create, and optional Float values for setting the anchor position.

         Inside the function, there is a switch statement that determines which type of joint to create based on the provided JoinStyle enum. The function then calculates the anchor positions for each joint and creates the appropriate SKPhysicsJoint object using the attributes of the SKNodes. Finally, the joint is added to the physics world to apply the desired physics behavior between the two nodes. Depending on the type of joint, there are some TODOs that still need to be implemented. Overall, this function is used to add physics interactions between two SKNodes in a game or simulation.
         
         ## joke
         As a joke, did you hear about the programmer who was afraid of negative numbers? They’ll stop at nothing to avoid them!
         */
        switch kind {
        case .pin:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition)
            self.physicsWorld.add(newJoint)
        case .spring:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            // TODO: make inverse of anchorA
            let newAnchorXB = nodeB.position.x - CGFloat(anchorX)
            let newAnchorYB = nodeB.position.y - CGFloat(anchorY)
            let newAnchorBPosition = CGPoint(x: newAnchorXB, y: newAnchorYB)
            let newJoint = SKPhysicsJointSpring.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: newAnchorPosition, anchorB: newAnchorBPosition)
            self.physicsWorld.add(newJoint)
        case .limit:
            // TODO: see if you can modify anchor position
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)  // nodeA.position
            let newJoint = SKPhysicsJointLimit.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: newAnchorPosition, anchorB: nodeB.position)
            self.physicsWorld.add(newJoint)
        case .fixed:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointFixed.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition)
            self.physicsWorld.add(newJoint)
        case .sliding:
            // using this on everything causes performance issues
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointSliding.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition, axis: CGVector(dx: 1.0, dy: 1.0))
            self.physicsWorld.add(newJoint)
        }
    }
}
