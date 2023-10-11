//
//  ViewController.swift
//  korvaboosti
//
//  Created by Viippola, Essi on 24.7.2023.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fire off plane detection
        startPlaneDetection()
        
        // Get touch's 2D location
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        
        // Touch location
        let tapLocation = recognizer.location(in: arView)
        
        // Raycast (2D -> 3D)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            
            // 3D point
            let worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            
            // Create sphere
            //let sphere = createSphere()
            
            // Create korvapuusti
            let sphere = createKorvapuusti()
            
            // Place the sphere
            placeObject(object: sphere, at: worldPosition)
        }
        
    }
    
    func startPlaneDetection(){
        
        arView.automaticallyConfigureSession = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
    }
    
    func createSphere() -> ModelEntity {
        
        // Create mesh
        let sphere = MeshResource.generateSphere(radius: 0.05)
        
        // Assign material
        let sphereMaterial = SimpleMaterial(color: .blue, roughness: 0, isMetallic: true)
        
        // Model entity
        let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])
        
        return sphereEntity
    }
    
    func createKorvapuusti() -> ModelEntity {
        
        let path = Bundle.main.path(forResource: "korvapuusti", ofType: "usdz")!
        let url = URL(fileURLWithPath: path)
        let sphere = try! Entity.loadModel(contentsOf: url)
        
        //let sphere = try! Entity.loadModel(named: "korvapuusti", in: nil)
        
        print(sphere)
        
        return sphere
    }
    
    func placeObject(object: ModelEntity, at location: SIMD3<Float>){
        
        // Anchor
        let objectAnchor = AnchorEntity(world: location)
        
        // Tie model to anchor
        objectAnchor.addChild(object)
        
        // Add both to the scene
        arView.scene.addAnchor(objectAnchor)
    }
    
}
