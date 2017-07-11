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
    
    let addCupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.setTitle("Add Cup", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAddCup), for: .touchUpInside)
        return button
    }()
    
    let addCubeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.setTitle("Add Cup", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAddCube), for: .touchUpInside)
        return button
    }()
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min // 0xFFFFFFFF same as UInt32.max
    }
    
    
    @objc func handleAddCup() {
        let zCoords = randomFloat(min: -2, max: -0.2)
        
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        cubeNode.position = SCNVector3(0,0,zCoords) // This is in metres
        sceneView.scene.rootNode.addChildNode(cubeNode)
        
        
        
        print("Added cup")
        
    }
    
    @objc func handleAddCube() {
        print("Added cube")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    func setupViews() {
        view.addSubview(sceneView)
        view.addSubview(addCupButton)
        view.addSubview(addCubeButton)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        addCupButton.translatesAutoresizingMaskIntoConstraints = false
        addCubeButton.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        
        addCupButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        addCupButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addCupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addCupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
