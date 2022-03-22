//
//  ViewController.swift
//  MyFirstARApp
//
//  Created by 오국원 on 2022/03/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setUpARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    //MARK: Setup Methods
    
    func setUpARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    //MARK: Object Placement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "Legendary_Godzilla_2014", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Oject placement failed - couldn't find surface.")
        }
    }
    
    func placeObject(name entityname: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityname)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation,.translation],for: entity)
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "Legendary_Godzilla_2014" {
                placeObject(name: anchorName, for: anchor)
            }
        }
    }
}
