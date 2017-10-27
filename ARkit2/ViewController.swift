//
//  ViewController.swift
//  ARkit2
//
//  Created by Victor Lee on 11/7/17.
//  Copyright © 2017 VictorLee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    let sceneView: ARSCNView = {
        let sv = ARSCNView()
        sv.backgroundColor = .purple
        return sv
    }()
    
    let addShipButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.setTitle("Add ship", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAddShip), for: .touchUpInside)
        return button
    }()
    
    let addCubeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.setTitle("Add Cube", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAddCube), for: .touchUpInside)
        return button
    }()
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min // 0xFFFFFFFF same as UInt32.max
    }
    
    func getCameraCoordinates(sceneView: ARSCNView) -> MyCameraCoordinates {
        if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
            let cameraCoordinates = MDLTransform(matrix: cameraTransform)
            
            var cc = MyCameraCoordinates(x: 0, y: 0, z: 0)
            cc.x = cameraCoordinates.translation.x
            cc.y = cameraCoordinates.translation.y
            cc.z = cameraCoordinates.translation.z
            return cc
        }
        return MyCameraCoordinates()
    }
    
    @objc func handleAddCube() {
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        let cc = getCameraCoordinates(sceneView: sceneView)
        guard let xPos = cc.x else { return }
        guard let yPos = cc.y else { return }
        guard let zPos = cc.z else { return }
        
        cubeNode.position = SCNVector3(xPos, yPos, zPos)
        
        sceneView.scene.rootNode.addChildNode(cubeNode)

        print("Added cube")
        
    }
    
    @objc func handleAddShip() {
        let shipNode = SCNNode()
        
        let cc = getCameraCoordinates(sceneView: sceneView)
        guard let xPos = cc.x else { return }
        guard let yPos = cc.y else { return }
        guard let zPos = cc.z else { return }
        shipNode.position = SCNVector3(xPos, yPos, zPos)
        
        guard let virtualObjectScene = SCNScene(named: "ship.scn", inDirectory: "art.scnassets", options: nil) else { return }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        
        shipNode.addChildNode(wrapperNode)
        
        sceneView.scene.rootNode.addChildNode(shipNode)
        
        print("Added ship with button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        
        setupViews()
        
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
//        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        addTapGestureToSceneView()
    }
    
    func setupViews() {
        view.addSubview(sceneView)
        view.addSubview(addShipButton)
        view.addSubview(addCubeButton)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        addShipButton.translatesAutoresizingMaskIntoConstraints = false
        addCubeButton.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        
        addShipButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        addShipButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addShipButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addShipButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addCubeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        addCubeButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addCubeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addCubeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    // Add GestureRecognition to sceneView
    func addTapGestureToSceneView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleDidTap(withGestureRecognizer: )))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Gesture Recognizer to remove object tapped.  But conflicts with touchesBegan method
    @objc func handleDidTap(withGestureRecognizer recognizer: UIGestureRecognizer){
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(tapLocation)
        guard let node = hitTestResult.first?.node else { return }
        node.removeFromParentNode()
        print("Deleted ship or cube with gesture")
    }
    
    //Override touch method to add Ship wherever you tap on the screen OR if tap a ship to remove sceneview
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let hitResult = sceneView.hitTest(touch.location(in: sceneView), types: ARHitTestResult.ResultType.featurePoint)
            
        guard let pointResult = hitResult.last else { return }
        let pointTransform = SCNMatrix4(pointResult.worldTransform)
        let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43)
        addShip(position: pointVector)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //Method to add ship by tapping anywhere on the scene
    func addShip(position: SCNVector3) {
        let shipNode = SCNNode()
        
        guard let virtualObjectScene = SCNScene(named: "ship.scn", inDirectory: "art.scnassets", options: nil) else { return }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        
        shipNode.addChildNode(wrapperNode)
        shipNode.position = position
        
        sceneView.scene.rootNode.addChildNode(shipNode)
        
        print("Added ship with tap")
        
    }
    
    
    
}

