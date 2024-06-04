//
//  ViewController.swift
//  ARular
//
//  Created by Tahir Mac aala on 04/06/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var nodes: [SCNNode] = []
    var meter: Double?
    var lineNode = SCNNode()
    var textMeasure = SCNNode()
    var outlineNode = SCNNode()
    
    @IBAction func Clear(_ sender: Any) {
        if nodes.count >= 2 {
            for x in nodes {
                x.removeFromParentNode()
            }
            textMeasure.removeFromParentNode()
            lineNode.removeFromParentNode()
            outlineNode.removeFromParentNode()
            nodes = [SCNNode]()
        }
        print("Cleared")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func addNode(at hitResult: ARHitTestResult) {
        let nodeGeometry = SCNSphere(radius: 0.008)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.07843, green: 0.42352, blue: 0.58039, alpha: 1.0)
        nodeGeometry.materials = [material]
        let node = SCNNode(geometry: nodeGeometry)
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                   hitResult.worldTransform.columns.3.y,
                                   hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        nodes.append(node)
        
        if nodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let start = nodes[0]
        let end = nodes[1]
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2)
            + pow(end.position.y - start.position.y, 2)
            + pow(end.position.z - start.position.z, 2)
        )
        
        meter = Double(abs(distance))
        let mark = Measurement(value: meter ?? 0, unit: UnitLength.meters)
        let toCM = mark.converted(to: UnitLength.inches)
        
        let value = "\(toCM)"
        let finalValue = String(value.prefix(5)) + " inch"
        
        updateText(text: finalValue, atPosition: end.position)
        lineNode.removeFromParentNode()
        lineNode = LineNode(from: start.position, to: end.position, lineColor: UIColor(red: 0.07843, green: 0.42352, blue: 0.58039, alpha: 1.0))
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textMeasure.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.font = UIFont.systemFont(ofSize: 10)
        
        let textOutline = SCNText(string: text, extrusionDepth: 0.5)
        textOutline.font = UIFont.systemFont(ofSize: 10)
        
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = UIColor(red: 175/255, green: 211/255, blue: 226/255, alpha: 1)
        textGeometry.firstMaterial = frontMaterial
        
        let backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = UIColor.black
        textGeometry.materials = [frontMaterial, backMaterial]
        
        textMeasure = SCNNode(geometry: textGeometry)
        textMeasure.position = SCNVector3(x: position.x + 0.001, y: position.y, z: position.z + 0.003)
        textMeasure.scale = SCNVector3(x: 0.007, y: 0.007, z: 0.007)
        
        let outlineMaterial = SCNMaterial()
        outlineMaterial.diffuse.contents = UIColor.black
        textOutline.firstMaterial = outlineMaterial
        
        outlineNode = SCNNode(geometry: textOutline)
        outlineNode.position = SCNVector3(x: position.x/2, y: position.y/2 + 0.0148, z: position.z/2 - 0.01)
        outlineNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textMeasure)
//        sceneView.scene.rootNode.addChildNode(outlineNode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nodes.count >= 2 {
            for x in nodes {
                x.removeFromParentNode()
            }
            textMeasure.removeFromParentNode()
            lineNode.removeFromParentNode()
            outlineNode.removeFromParentNode()
            nodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addNode(at: hitResult)
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
}
