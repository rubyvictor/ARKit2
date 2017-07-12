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

class ViewController: UIViewController {

    let sceneView: ARSCNView = {
        let sv = ARSCNView()
        sv.backgroundColor = .purple
        return sv
    }()
    
    let addSunglassButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.setTitle("Add sunglass", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAddSunglass), for: .touchUpInside)
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
    
    @objc func handleAddSunglass() {
        let sunglassNode = SCNNode()
        
        let cc = getCameraCoordinates(sceneView: sceneView)
        guard let xPos = cc.x else { return }
        guard let yPos = cc.y else { return }
        guard let zPos = cc.z else { return }
        sunglassNode.position = SCNVector3(xPos, yPos, zPos)
        
        guard let virtualObjectScene = SCNScene(named: "sunglass.dae", inDirectory: "art.scnassets", options: nil) else { return }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        sunglassNode.addChildNode(wrapperNode)
        
        sceneView.scene.rootNode.addChildNode(sunglassNode)
        
        print("Added sunglass")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    func setupViews() {
        view.addSubview(sceneView)
        view.addSubview(addSunglassButton)
        view.addSubview(addCubeButton)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        addSunglassButton.translatesAutoresizingMaskIntoConstraints = false
        addCubeButton.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        
        addSunglassButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        addSunglassButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addSunglassButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addSunglassButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addCubeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        addCubeButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addCubeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addCubeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    

    
}
