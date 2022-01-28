import Foundation
import ARKit
import SwiftUI
import SceneKit.ModelIO
import RealityKit


enum ARDemoErrors: Swift.Error {
    case failedLoadingUSDZ
}

// MARK: - ARViewIndicator
struct ARViewIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }
    func updateUIViewController(_ uiViewController:
                                ARViewIndicator.UIViewControllerType, context:
                                UIViewControllerRepresentableContext<ARViewIndicator>) { }
}


class ARView: UIViewController, ARSCNViewDelegate {
    let assetFileName: String = "Meshy"
    let assetFileExt: String = "usdz"
    var mdlAsset: MDLAsset? = nil
    var mdlObject: MDLObject? = nil
    
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.scene = SCNScene()
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        
        //        guard let url = Bundle.main.url(forResource: "Meshy", withExtension: "usdz") else
        guard let url = Bundle.main.url(forResource: assetFileName, withExtension: assetFileExt) else{ 
            print("Failed to load 'Meshy.usdz' file.")
            return
        }
        mdlAsset = MDLAsset(url: url)
        mdlAsset?.loadTextures()
        mdlObject = mdlAsset?.object(at: 0)
    }
    // MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        arView.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    // MARK: - ARSCNViewDelegate
    func sessionWasInterrupted(_ session: ARSession) {}
    
    func sessionInterruptionEnded(_ session: ARSession) {}
    func session(_ session: ARSession, didFailWithError error: Error)
    {}
    func session(_ session: ARSession, cameraDidChangeTrackingState
                 camera: ARCamera) {}
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        self.arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /// Tag: CreateARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = ARPlane(anchor: planeAnchor, in: arView)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
        
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let plane = node.childNodes.first as? ARPlane
        else { return }
        
        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        plane.updateExtent(planeAnchor, node)
        plane.updateClassification(planeAnchor)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // All future code will go inside this method if not stated otherwise
        
        guard let location = touches.first?.location(in: arView) else {
            // In a production app we should provide feedback to the user here        
            print("Couldn't find a touch")
            return
        }
        guard let query = arView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any) else {
            // In a production app we should provide feedback to the user here        
            print("Couldn't create a query!")
            return
        }
        guard let result = arView.session.raycast(query).first else {
            print("Couldn't match the raycast with a plane.")
            return
        }
        _ = createModelNode(result.worldTransform, arView.scene.rootNode)
    }
    
    private func createModelNode(_ transform: simd_float4x4, _ parent: SCNNode) -> SCNNode {
        let scale: Float = 0.025
        let wrapperNode = SCNNode()
        parent.addChildNode(wrapperNode)
        
        if mdlObject != nil {
            let node = SCNNode(mdlObject: mdlObject!)
            wrapperNode.addChildNode(node)
            wrapperNode.transform = SCNMatrix4(transform)
            wrapperNode.scale = SCNVector3(scale, scale, scale)
        }
        return wrapperNode
    }
}
