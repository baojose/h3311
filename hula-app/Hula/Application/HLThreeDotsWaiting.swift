//
//  HLThreeDotsWaiting.swift
//  Hula
//
//  Created by Juan Searle on 09/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import SpriteKit

class HLThreeDotsWaiting: SKScene {
    let distance: CGFloat = 10
    let dotsColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    override func didMove(to view: SKView) {
        //self.scaleMode = .aspectFit
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
        //print("loading texture...")
        //print(self.frame)
        for i in 1..<4 {
            let node2 = SKShapeNode(circleOfRadius: 2.0)
            
            node2.fillColor = dotsColor
            node2.strokeColor = dotsColor
            node2.position.x = distance * (CGFloat(i))
            node2.position.y = 5
            /*
            let node = SKLabelNode()
            node.text = "\(i)"
            node.name = "dot\(i)"
            node.fontColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            node.verticalAlignmentMode = .center
            node.horizontalAlignmentMode = .center
            node.fontSize = 50
            node.position.y = 50
            node.position.x = distance * (CGFloat(i))
            self.addChild(node)
            */
            self.addChild(node2)
        }
        
    }
    override init(size:CGSize){
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateDots() {
        let nodes: [SKNode] = self.children
        //print(nodes)
        for (index, node) in nodes.enumerated() {
            node.run(.sequence([
                .wait(forDuration: TimeInterval(index) * 0.2),
                .repeatForever(.sequence([
                    .scale(to: 1.5, duration: 0.3),
                    .scale(to: 1, duration: 0.3),
                    .wait(forDuration: 2)
                    ]))
                ]))
        }
    }

}
