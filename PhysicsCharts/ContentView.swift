//
//  ContentView.swift
//  PhysicsCharts
//
//  Created by Brandon Knox on 6/26/24.
//

import SwiftUI
import CoreData
import SpriteKit

struct ContentView: View {
    @Environment(\.colorScheme) var currentMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass  // to get screenSize (iPad or iPhone)
    
    @State private var boxHeight = 6.0
    @State private var boxWidth = 6.0
    @State private var sceneHeight = 500
    @State private var density = 1.0
    @State private var staticNode = false
    @State private var linearDamping = 0.1
    @State private var letterText = "B"
    @State private var letterFont = "Menlo"
    
    @AppStorage("LastRed") private var lastRed = 0.0
    @AppStorage("LastGreen") private var lastGreen = 0.43
    @AppStorage("LastBlue") private var lastBlue = 0.83
    
    // using this to track box size and color selection as it changes
    let controls = UIJoin.shared

    // houses shape picker selection
    @State private var selectedShape: Shape = .data
    @State public var removeOn = false
    @State public var pourOn = false
    @State public var isPainting = false
    @State public var isJumping = false
    @State public var cameraZoom = 1.0
//    @State public var lastNodeSpeed = 0.0
    
    
    
    @GestureState var magnifyBy = 1.0
    
    struct PlayerStats: View {
        let controls = UIJoin.shared
        
        var body: some View {
            var nodeCount = controls.nodeCount
            Text("Nodes: \(nodeCount)")
        }
    }
    
    struct JumpButtons: View {
        @State public var jumpStrength = 0.25
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        let controls = UIJoin.shared
        
        private func jumpRight() {
            controls.jumpNodeRight()
        }
        
        private func jumpLeft() {
            controls.jumpNodeLeft()
        }
        
        private func updateJumpStrength() {
            
        }
        
        var body: some View {
            HStack {
                Button(action: jumpLeft) {
                    Image(systemName: "arrow.up.left.circle")
                        .font(.system(size: 35))
                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                        .padding()
                }
                Spacer()
                Button(action: jumpRight) {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 35))
                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                        .padding()
                }
            }
        }
    }
    
    // use this view to test out new ideas
    struct PlayView: View {
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        let controls = UIJoin.shared
        
        private func setDefaults() {
            // TODO: set to new shape and other parameters. start with circle-worm as a base
            controls.loadData()
            controls.playMode = true
        }
        
        var body: some View {
            NavigationView {
                Group {
                    VStack {
                        PhysicsView()
                        // TODO: add text display for node info
                        JumpButtons()
                    }
                }
                .background(Color(red: lastRed, green: lastGreen, blue: lastBlue, opacity: 0.25))
            }
            .onAppear(perform: setDefaults)
            .onDisappear(perform: { controls.playMode = false })
        }
    }
    
    struct IOSView: View {
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        let controls = UIJoin.shared
        
        @State private var outcome = 1.0
        
        var body: some View {
            NavigationView {
                Group {
                    VStack {
                        HStack {
                            VStack {
                                PickerView()
                                VStack {
                                    Text("Outcome: \(String(format: "%.f", outcome))")
                                    Slider(value: $outcome, in: 0...1, step: 1)
                                        .onChange(of: outcome) { _ in
                                            // TODO: log value in shared variable to be read by render methods
                                            controls.dataOutcome = Float(outcome)
                                        }
                                }
                            }
                            .padding()
                            RGBSliders()
                        }
                        PhysicsView()
                        JumpButtons()
                        PlayerStats()
                    }
                }
                .background(Color(red: lastRed, green: lastGreen, blue: lastBlue, opacity: 0.25))
            }
        }
    }
    
    struct ClearInfoButtons: View {
        
        let controls = UIJoin.shared
        
        private func removeAll() {
            controls.gameScene?.removeAllChildren()
        }
        
        var body: some View {
            HStack {
                Spacer()
                // TODO: fix clear method
                Button(action: removeAll) {
                    Text("Clear All")
                }
                Spacer()
                // shows different information here (user color settings, size settings)
                NavigationLink("Object Info", destination: ObjectSettings())
                Spacer()
                NavigationLink("Play View", destination: PlayView())
                Spacer()
            }
        }
    }
    
    struct PhysicsSliders: View {
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        @State private var density = 1.0
        @State private var linearDamping = 0.1
        
        let controls = UIJoin.shared
        
        private func sliderDensityChanged(to newValue: Float) {
            controls.density = CGFloat(newValue)
        }
        
        private func sliderLinearDampingChanged(to newValue: Float) {
            controls.linearDamping = CGFloat(newValue)
        }
        
        var body: some View {
            HStack {
                HStack {
                    Text("Density")
                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                    Slider(value: $density, in: 0...10, step: 1.0)
                        .padding([.horizontal])
                        .onChange(of: Float(density), perform: sliderDensityChanged)
                }
                .padding()
                HStack {
                    Text("L Damp")
                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                    Slider(value: $linearDamping, in: 0...1, step: 0.1)
                        .padding([.horizontal])
                        .onChange(of: Float(linearDamping), perform: sliderLinearDampingChanged)
                }
                .padding()
            }
        }
    }
    
    struct PhysicsView: View {
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        let controls = UIJoin.shared
        
        var scene: SKScene {
            // making this square helps with ratio issues when drawing shapes
            let scene = GameScene()
//            guard let scene = GameScene(fileNamed: "physicsWorld") else {
//                let scene = GameScene()
//                return scene
//            }
            // TODO: make sure dynamic sizing is working properly - not sure if this is used
            let maxHeight = controls.screenHeight  // 2532
            let maxWidth = controls.screenWidth  // 1170
            // TODO: create variable with smaller of two screen values to use for resizing
            var scalePixels = 1.0  // generic default value
            if maxHeight > maxWidth {
                scalePixels = maxWidth
            } else {
                scalePixels = maxHeight
            }
            controls.scalePixels = scalePixels
            // TODO: can screen orientation be detected here for different height/width?
            scene.size = CGSize(width: scalePixels, height: scalePixels)
//            scene.size = CGSize(width: maxWidth, height: maxHeight)
            scene.scaleMode = .aspectFit
            scene.view?.showsDrawCount = true
            // making complementary color of chosen object color
            scene.backgroundColor = UIColor(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), alpha: 0.5)
            
            // add camera node
            let cameraNode = SKCameraNode()
            // place this at the center bottom of physics view
            cameraNode.position = CGPoint(x: scene.size.height * controls.physicsEnvScale,
                                          y: scene.size.height / 2)
            scene.addChild(cameraNode)
            scene.camera = cameraNode
            
            // update shared references
            controls.gameScene = scene
            controls.camera = cameraNode
            
            return scene
        }
        
        private func storeGeometry(for geometry: GeometryProxy) {
            controls.screenWidth = geometry.size.width
            controls.screenHeight = geometry.size.height
        }
        
        var body: some View {
            HStack {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    SpriteView(scene: scene)
                        .frame(width: width)
                        .onAppear{ self.storeGeometry(for: geometry) }
                }
            }
        }
    }
    
    struct RGBSliders: View {
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        private func sliderColorRChanged(to newValue: Double) {
            lastRed = newValue
        }
        
        private func sliderColorGChanged(to newValue: Double) {
            // save user defaults
            lastGreen = newValue
        }
        
        private func sliderColorBChanged(to newValue: Double) {
            lastBlue = newValue
        }
        
        var body: some View {
            // RGB color selection
            VStack {
                VStack {
                    // TODO: see if you can caculate complimentary color to current and adjust RGB text to match
                    // red selector
                    VStack(spacing:0) {
                        SliderView(value: $lastRed,
                                    sliderRange: 0...1,
                                    thumbColor: .red,
                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                        )
                        .frame(height:30)
                        .onChange(of: lastRed, perform: sliderColorRChanged)
                    }
                    // green selector
                    VStack(spacing:0) {
                        SliderView(value: $lastGreen,
                                    sliderRange: 0...1,
                                    thumbColor: .green,
                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                        )
                        .frame(height:30)
                        .onChange(of: lastGreen, perform: sliderColorGChanged)
                    }
                    // blue selector
                    VStack(spacing:0) {
                        SliderView(value: $lastBlue,
                                    sliderRange: 0...1,
                                    thumbColor: .blue,
                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                        )
                        .frame(height:30)
                        .onChange(of: lastBlue, perform: sliderColorBChanged)
                    }
                }
                .padding()
                .background(Color(red: lastRed, green: lastGreen, blue: lastBlue))  // gives preview of chosen color
                .cornerRadius(20)
            }
            .padding()
        }
    }
    
    struct SizeSliders: View {
        // siders for controlling shape height/width
        @AppStorage("LastRed") private var lastRed = 0.0
        @AppStorage("LastGreen") private var lastGreen = 0.43
        @AppStorage("LastBlue") private var lastBlue = 0.83
        
        @State private var boxHeight = 6.0
        @State private var boxWidth = 6.0
        
        let controls = UIJoin.shared
        
        var body: some View {
            HStack {
                Text("H")
                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                Slider(value: $boxHeight, in: 1...100, step: 1)
                    .padding([.horizontal])
                    .onChange(of: boxHeight, perform: sliderBoxHeightChanged)
            }
            HStack {
                Text("W")
                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                Slider(value: $boxWidth, in: 1...100, step: 1)
                    .padding([.horizontal])
                    .onChange(of: boxWidth, perform: sliderBoxWidthChanged)
            }
        }
        
        private func sliderBoxHeightChanged(to newValue: Double) {
            controls.boxHeight = Double(newValue.rounded())
        }
        
        private func sliderBoxWidthChanged(to newValue: Double) {
            controls.boxWidth = Double(newValue.rounded())
        }
    }
    
    struct PickerView: View {
        // this view has shape and font dropdowns
        @State private var selectedShape: Shape = .data
        @State private var letterFont = "Menlo"
        
        let controls = UIJoin.shared
        
        var body: some View {
            VStack {
                Picker("Shape", selection: $selectedShape) {
                    Text("Data").tag(Shape.data)
                    Text("Rectangle").tag(Shape.rectangle)
                }
                .onChange(of: selectedShape, perform: shapeChanged)
            }
        }
        
        private func shapeChanged(to newValue: Shape) {
            controls.selectedShape = newValue
            // TODO: if data, load data
            if newValue == .data {
//                controls.loadData()
            }
        }
        
        private func fontChanged(to newValue: String) {
            controls.letterFont = newValue
        }
    }
    
    struct SliderView: View {
        @Binding var value: Double
        
        @State var lastCoordinateValue: CGFloat = 0.0
        var sliderRange: ClosedRange<Double> = 1...100
        var thumbColor: Color = .yellow
        var minTrackColor: Color = .blue
        var maxTrackColor: Color = .gray
        
        
        var body: some View {
            GeometryReader { gr in
                // TODO: may need to tweak these (hard to hit targets)
                let thumbHeight = gr.size.height * 1.1
                let thumbWidth = gr.size.width * 0.03  // make this larger and see if it helps orig val: 0.03, 0.1 has bad look
                let radius = gr.size.height * 0.5
                let minValue = gr.size.width * 0.015
                let maxValue = (gr.size.width * 0.98) - thumbWidth
                
                let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
                let lower = sliderRange.lowerBound
                
                // TODO: look into pulling this from elsewhere (can't get user defaults from here)
                let sliderVal = (self.value - lower) * scaleFactor + minValue
                
                ZStack {
                    Rectangle()
                        .foregroundColor(maxTrackColor)
                        .frame(width: gr.size.width, height: gr.size.height * 0.95)
                        .clipShape(RoundedRectangle(cornerRadius: radius))
                    HStack {
                        Rectangle()
                            .foregroundColor(minTrackColor)
                        // Invalid frame dimension (negative or non-finite).
                        .frame(width: sliderVal, height: gr.size.height * 0.95)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    HStack {
                        RoundedRectangle(cornerRadius: radius)
                            .foregroundColor(thumbColor)
                            .frame(width: thumbWidth, height: thumbHeight)
                            .offset(x: sliderVal)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { v in
                                        if (abs(v.translation.width) < 0.1) {
                                            self.lastCoordinateValue = sliderVal
                                        }
                                        if v.translation.width > 0 {
                                            let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minValue) / scaleFactor)  + lower
                                        } else {
                                            let nextCoordinateValue = max(minValue, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minValue) / scaleFactor) + lower
                                        }
                                   }
                            )
                        Spacer()
                    }
                }
            }
        }
    }

    struct PourToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                            "drop.fill" : "drop")
                        .renderingMode(.template)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    struct StaticToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "hand.raised.brakesignal": "brakesignal")
                        .renderingMode(.template)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    struct ClearToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "eraser.fill": "eraser")
                        .renderingMode(.template)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // this works opposite due to variable being set to false by default
    struct PaintToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "paintbrush.fill": "paintbrush")
                        .renderingMode(.template)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // this is where the views are drawn (iPhone and iPad currently supported)
    @ViewBuilder
    var body: some View {
        if horizontalSizeClass == .compact {
            IOSView()
                .onAppear(perform: {
                    controls.playMode = false
                    controls.loadData()
                })
        } else {
            // ipad view - fix IOSView
            IOSView()
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear(perform: {controls.playMode = false})
        }
    }
}
