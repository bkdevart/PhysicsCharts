//
//  ObjectSettings.swift
//  PhysicsCharts
//
//  Created by Brandon Knox on 6/26/24.
//

import SwiftUI
import SpriteKit
import UniformTypeIdentifiers  // for svg
//import Charts

enum Shape: String, CaseIterable, Identifiable {
    case rectangle, data
    var id: Self { self }
}

enum Fonts: String, CaseIterable, Identifiable {
    case Didot, Baskerville, Chalkduster, Courier, Menlo
    var id: Self { self }
}

struct Pima: Codable, Identifiable {
    
    let id: Int
    let Pregnancies: Float
    let Glucose: Float
    let BloodPressure: Float
    let SkinThickness: Float
    let Insulin: Float
    let BMI: Float
    let DiabetesPedigreeFunction: Float
    let Age: Float
    let Outcome: Float
    
    // TODO: see if you can get this formatted to 2 decimal places
    var BMIString: String { BMI.formatted(.number) }
    var GlucoseString: String { Glucose.formatted(.number) }
}

// using this to track box size and color selection across views
class UIJoin: ObservableObject {
    @Published var selectedShape: Shape = .rectangle
    @Published var screenWidth: CGFloat = 428.0
    @Published var screenHeight: CGFloat = 428.0
    @Published var boxHeight = 6.0
    @Published var boxWidth = 6.0
    @Published var isPainting = false
    @Published var selectedNode = SKNode()
    @Published var selectedNodes = [SKNode]()
    @Published var nodeCount = 0
    @Published var removeOn = false
    @Published var paintLayer = 0
    @Published var pourOn = false
    @Published var density: CGFloat = 1.0
    @Published var mass: CGFloat = 1.0  // don't actually know default value to set
    @Published var staticNode = false
    @Published var linearDamping = 0.1
    @Published var scalePixels = 1.0  // generic default value
    @Published var drop = true
    @Published var cameraLocked = true
    @Published var cameraScale = 1.0
    @Published var usingCamGesture = false  // used to prevent shape drops, etc
    @Published var cameraOrigin = CGPoint(x: 0.0, y: 0.0)
    @Published var physicsEnvScale = 8.0  // this is multiplied by screen size
    @Published var letterText = "B"  // used for text shape
    @Published var letterFont = "Menlo"
    
    @Published var gameScene = SKScene(fileNamed: "physicsWorld")
    @Published var camera = SKCameraNode()
    
    @Published var pima = [Pima]()
    @Published var filteredBMI = [Pima]()
    @Published var filteredGlucose = [Pima]()
    @Published var filteredTable = [Pima]()
    
    @Published var filterBMI = Float(75)  // Float()
    @Published var filterGlucose = Float(200)  // Float()
    
    // game vars
    @Published var playMode = false
    @Published var lastNode = SKNode()
    @Published var jumpStrength = 0.25
    @Published var lastNodeSpeed = 0.0
    
    // data vars
    @Published var dataOutcome = Float(1.0)
    
    public func jumpNodeRight() {
        // applyImpulse
        lastNode.physicsBody?.applyImpulse(CGVector(dx: 10 * jumpStrength, dy: 30 * jumpStrength))
        lastNodeSpeed = lastNode.speed
        
    }
    
    public func jumpNodeLeft() {
        lastNode.physicsBody?.applyImpulse(CGVector(dx: -10 * jumpStrength, dy: 30 * jumpStrength))
        lastNodeSpeed = lastNode.speed
    }
    
    public func loadSingleRow() -> (Pima, Pima) {
        // pick random row to return
        let dataSize = pima.count
        // TODO: create random number for index based off of length of data
        let dataIndex = Int.random(in: 0...(dataSize - 1))
        let sampleRow = pima[dataIndex]
        
        let maxIdValue = pima.max { $0.id < $1.id }?.id
        let minIdValue = pima.min { $0.id < $1.id }?.id
        let idRange = Float(maxIdValue! - minIdValue!)
        let idShade = Int(Float(sampleRow.id) / idRange)
        
        let maxPregnanciesValue = pima.max { $0.Pregnancies < $1.Pregnancies }?.Pregnancies
        let minPregnanciesValue = pima.min { $0.Pregnancies < $1.Pregnancies }?.Pregnancies
        let pregnanciesRange = Float(maxPregnanciesValue! - minPregnanciesValue!)
        let pregnanciesShade = sampleRow.Pregnancies / pregnanciesRange
        
        let maxGlucoseValue = pima.max { $0.Glucose < $1.Glucose }?.Glucose
        let minGlucoseValue = pima.min { $0.Glucose < $1.Glucose }?.Glucose
        let glucoseRange = Float(maxGlucoseValue! - minGlucoseValue!)
        let glucoseShade = sampleRow.Glucose / glucoseRange
        
        let maxBloodPressureValue = pima.max { $0.BloodPressure < $1.BloodPressure }?.BloodPressure
        let minBloodPressureValue = pima.min { $0.BloodPressure < $1.BloodPressure }?.BloodPressure
        let bloodPressureRange = Float(maxBloodPressureValue! - minBloodPressureValue!)
        let bloodPressureShade = sampleRow.BloodPressure / bloodPressureRange
        
        let maxSkinThicknessValue = pima.max { $0.SkinThickness < $1.SkinThickness }?.SkinThickness
        let minSkinThicknessValue = pima.min { $0.SkinThickness < $1.SkinThickness }?.SkinThickness
        let skinThicknessRange = Float(maxSkinThicknessValue! - minSkinThicknessValue!)
        let skinThicknessShade = sampleRow.SkinThickness / skinThicknessRange
        
        let maxInsulinValue = pima.max { $0.Insulin < $1.Insulin }?.Insulin
        let minInsulinValue = pima.min { $0.Insulin < $1.Insulin }?.Insulin
        let insulinRange = Float(maxInsulinValue! - minInsulinValue!)
        let insulinShade = sampleRow.Insulin / insulinRange
        
        let maxBMIValue = pima.max { $0.BMI < $1.BMI }?.BMI
        let minBMIValue = pima.min { $0.BMI < $1.BMI }?.BMI
        let BMIRange = Float(maxBMIValue! - minBMIValue!)
        let BMIShade = sampleRow.BMI / BMIRange
        
        let maxDiabetesPedigreeFunctionValue = pima.max { $0.DiabetesPedigreeFunction < $1.DiabetesPedigreeFunction }?.DiabetesPedigreeFunction
        let minDiabetesPedigreeFunctionValue = pima.min { $0.DiabetesPedigreeFunction < $1.DiabetesPedigreeFunction }?.DiabetesPedigreeFunction
        let diabetesPedigreeFunctionRange = Float(maxDiabetesPedigreeFunctionValue! - minDiabetesPedigreeFunctionValue!)
        let diabetesPedigreeFunctionShade = sampleRow.DiabetesPedigreeFunction / diabetesPedigreeFunctionRange
        
        let maxAgeValue = pima.max { $0.Age < $1.Age }?.Age
        let minAgeValue = pima.min { $0.Age < $1.Age }?.Age
        let ageRange = Float(maxAgeValue! - minAgeValue!)
        let ageShade = sampleRow.Age / ageRange
        
        let maxOutcomeValue = pima.max { $0.Outcome < $1.Outcome }?.Outcome
        let minOutcomeValue = pima.min { $0.Outcome < $1.Outcome }?.Outcome
        let outcomeRange = Float(maxOutcomeValue! - minOutcomeValue!)
        let outcomeShade = sampleRow.Outcome / outcomeRange
        
        
        // TODO: change above code to create two arrays - one with original row and one with converted values for colors (float between 0-1)
        
        // TODO: create new struct to return with just the scaled values, return both
        let scaleData = Pima(id: idShade, Pregnancies: pregnanciesShade, Glucose: glucoseShade, BloodPressure: bloodPressureShade, SkinThickness: skinThicknessShade, Insulin: insulinShade, BMI: BMIShade, DiabetesPedigreeFunction: diabetesPedigreeFunctionShade, Age: ageShade, Outcome: outcomeShade)
        return (sampleRow, scaleData)  // singleRow
    }
    
    public func loadGlucoseFilter() {
        // modify this to just pick a single index for now
        filteredGlucose = pima.filter{ $0.id == 5 }
    }
    
    public func loadData() {
        if let localData = readLocalFile(forName: "diabetes") {
            parse(jsonData: localData)
            // TODO: set file to shared object
            print("File found!")
        } else {
            print("File not found")
        }
    }
    
    // pull in JSON data
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }

    private func parse(jsonData: Data) {  // -> [Pima]
        print("Parsing...")
        do {
            let decodedData = try JSONDecoder().decode([Pima].self,
                                                       from: jsonData)
            print("Pregancies[0]: ", decodedData[0].Pregnancies)
            print("Outcome[0]: ", decodedData[0].Outcome)
            print("===================================")
            // push to shared object
            self.pima = decodedData
        } catch {
            print("decode error")
        }
    }

    static var shared = UIJoin()
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}

// TODO: to understand physics body shapes and joins better, replace letters with shapes
func createFeatureNodeShape(shape: Shape, scale: Float, chosenColor: Color, location: CGPoint, hasPhysics: Bool) -> SKShapeNode {
    @ObservedObject var controls = UIJoin.shared
    
    // user can choose height and width
    //  * Double(scale)
    let boxWidth = Int(((controls.boxWidth) / 100.0) * Double(controls.scalePixels))
    let boxHeight = Int(((controls.boxHeight) / 100.0) * Double(controls.scalePixels))
    
    switch shape {
    case .data:
        // TODO: this is a hack to satisify requirement of returning node, it's handled in createFeatureNode function - fix
        return SKShapeNode()

    case .rectangle:
        // TODO: replace this with SKShapeNode code (try both circle and square)
        let path = CGMutablePath()
        let box_half = Int(boxWidth) / 2
        path.move(to: CGPoint(x: -box_half, y: Int(boxHeight)))  // upper left corner
        path.addLine(to: CGPoint(x: box_half, y: Int(boxHeight)))  // upper right corner
        path.addLine(to: CGPoint(x: box_half, y: 0)) // bottom right corner
        path.addLine(to: CGPoint(x: -box_half, y: 0))  // bottom left corner
        let box = SKShapeNode(path: path)
        box.fillColor = UIColor(red: UIColor(chosenColor).rgba.red,
                                green: UIColor(chosenColor).rgba.green,
                                blue: UIColor(chosenColor).rgba.blue,
                                alpha: CGFloat(scale))
        box.strokeColor = UIColor(chosenColor)
        box.position = location
        box.zPosition = CGFloat(0)
        box.physicsBody = SKPhysicsBody(polygonFrom: path)
        // default density value is 1.0, anything higher is relative to this
        box.physicsBody?.density = controls.density
        // TODO: figure out how to add in mass control while factoring in density
        
        // modify static/dynamic property based on toggle
        box.physicsBody?.isDynamic = !controls.staticNode
        box.physicsBody?.linearDamping = controls.linearDamping
        return box
    }
    
}

func createFeatureNode(text: String, scale: Float, chosenColor: Color, location: CGPoint, hasPhysics: Bool) -> SKLabelNode {
    @ObservedObject var controls = UIJoin.shared
    
    // user can choose height and width
    let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.scalePixels))
    let myText = SKLabelNode(fontNamed: controls.letterFont)
    myText.text = text
    if text == "☹︎" || text == "☻" {
        myText.fontSize = CGFloat(boxWidth * 2)  // * 2
    } else {
        myText.fontSize = CGFloat(boxWidth)
    }
    
    myText.fontColor = UIColor(red: UIColor(chosenColor).rgba.red, green: UIColor(chosenColor).rgba.green, blue: UIColor(chosenColor).rgba.blue, alpha: CGFloat(scale))
    myText.position = location
    if hasPhysics {
        // because faces are doubled in size for appearance, physics body has to be halved
        if text == "☹︎" || text == "☻" {
            myText.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(myText.frame.width / 2))
        } else {
            //        myText.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: myText.frame.width, height: myText.frame.height))
            myText.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(myText.frame.width))
        }
        // default density value is 1.0, anything higher is relative to this
        myText.physicsBody?.density = controls.density
        // TODO: figure out how to add in mass control while factoring in density
        
        // modify static/dynamic property based on toggle
        myText.physicsBody?.isDynamic = !controls.staticNode
        myText.physicsBody?.linearDamping = controls.linearDamping
    }
    return myText
}

func renderBox(boxWidth: Int, boxHeight: Int, chosenColor: Color, location: CGPoint, zPosition: Int) -> SKNode {
    let path = CGMutablePath()
    let box_half = Int(boxWidth) / 2
    path.move(to: CGPoint(x: -box_half, y: Int(boxHeight)))  // upper left corner
    path.addLine(to: CGPoint(x: box_half, y: Int(boxHeight)))  // upper right corner
    path.addLine(to: CGPoint(x: box_half, y: 0)) // bottom right corner
    path.addLine(to: CGPoint(x: -box_half, y: 0))  // bottom left corner
    let box = SKShapeNode(path: path)
    box.fillColor = UIColor(chosenColor)
    box.strokeColor = UIColor(chosenColor)
    box.position = location
    box.zPosition = CGFloat(zPosition)
    box.physicsBody = SKPhysicsBody(polygonFrom: path)
    return box
}

func renderNode(location: CGPoint,
                hasPhysics: Bool=false,
                zPosition: Int=0,
                lastRed: Double,
                lastGreen: Double,
                lastBlue: Double,
                letterText: String) -> SKNode {
    @ObservedObject var controls = UIJoin.shared
    
    controls.nodeCount += 1
    // user can choose height and width
    var boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.scalePixels))
    var boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.scalePixels))
    // each color betwen 0 and 1 (based on slider)
    let chosenColor: Color = Color(red: lastRed,
                                   green: lastGreen,
                                   blue: lastBlue)
    
    controls.selectedNode = SKNode()
    switch controls.selectedShape {
    case .data:
        // TODO: process data and stack all 768 datapoints
        // sum up counts of each outcome, make hight of rectangle based on this, drop two rectangles
        var totalOutcome1 = 0
        var totalOutcome0 = 0

        for patient in controls.pima {
            if patient.Outcome == 1 {
                totalOutcome1 += 1
            } else if patient.Outcome == 0 {
                totalOutcome0 += 1
            }
        }
        
        boxWidth = boxWidth / 3
        // scale rectangle around outcome counts
        if controls.dataOutcome == 1.0 {
            boxHeight = Int((Float(totalOutcome1) / Float(controls.pima.count)) * Float(controls.screenHeight))
        } else {
            boxHeight = Int((Float(totalOutcome0) / Float(controls.pima.count)) * Float(controls.screenHeight))
        }

        let box = renderBox(boxWidth: boxWidth, boxHeight: boxHeight, chosenColor: chosenColor, location: location, zPosition: zPosition)
        
        return box

    case .rectangle:
        let box = renderBox(boxWidth: boxWidth, boxHeight: boxHeight, chosenColor: chosenColor, location: location, zPosition: zPosition)
        return box
    }
}


// this view is used by info screen to show object info
struct ObjectSettings: View {
    @AppStorage("TimesAppLoaded") private var timesAppLoaded = 0
    @AppStorage("LastRed") private var lastRed = 0.0
    @AppStorage("LastGreen") private var lastGreen = 0.43
    @AppStorage("LastBlue") private var lastBlue = 0.83
    
    @ObservedObject var controls = UIJoin.shared
    
    var body: some View {
        Group {
            Text("Stored values:")
                .font(.headline)
            Text("Times app started: \(timesAppLoaded)")
            Text("Stored Red: \(lastRed)")
            Text("Stored Green: \(lastGreen)")
            Text("Stored Blue: \(lastBlue)")
        }
        Spacer()
        Text("Current object values:")
            .font(.headline)
        Text("Object Height: \(controls.boxHeight)")
        Text("Object Width: \(controls.boxWidth)")
        Text("Screen Height: \(controls.screenHeight)")
        Text("Screen Width: \(controls.screenWidth)")
        
    }
}

