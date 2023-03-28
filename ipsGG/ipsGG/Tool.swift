import UIKit
import GameplayKit

class myNode: GKGraphNode {
    var name: String
    var pos: (x: Double, y: Double)
    var travelCost: [GKGraphNode: Float] = [:]
    var layer: Int
    
    init(name: String, pos: (x: Double, y: Double), layer: Int) {
        self.name = name
        self.pos = pos
        self.layer = layer
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        return travelCost[node] ?? 0
    }
    
    func addConnection(to node: GKGraphNode, bidirectional: Bool = true, weight: Float) {
        self.addConnections(to: [node], bidirectional: bidirectional)
        travelCost[node] = weight
        guard bidirectional else { return }
        (node as? myNode)?.travelCost[self] = weight
    }
}

func print(_ path: [GKGraphNode]) {
    path.compactMap({ $0 as? myNode}).forEach { node in
        print(node.name)
    }
}
func pX(_ path: [GKGraphNode]) -> [Float] {
    var x = [Float]()
    path.compactMap({ $0 as? myNode}).forEach { node in
        x.append(Float(node.pos.x))
    }
    return x
}

func pY(_ path: [GKGraphNode]) -> [Float] {
    var y = [Float]()
    path.compactMap({ $0 as? myNode}).forEach { node in
        y.append(Float(node.pos.y))
    }
    return y
}

func printCost(for path: [GKGraphNode]) {
    var total: Float = 0
    for i in 0..<(path.count-1) {
        total += path[i].cost(to: path[i+1])
    }
    print(total)
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
