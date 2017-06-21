//
//  DrawingViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/21/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import Foundation

class DrawingViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    
    var polylines: [Polyline] = []
    var currentPolyline: Polyline!
    var lastPoint: CGPoint!
    var liveQuery: CBLLiveQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshBarButtonPressed(_ sender: Any) {
        for polyline in polylines {
            if let error = try? polyline.deleteDocument() {
                print(error)
            }
        }
        polylines = []
        mainImageView.image = nil
    }
    
    func setupUI(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        liveQuery = appDelegate!.kDatabase!.createAllDocumentsQuery().asLive()
        liveQuery.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.new, context: nil)
        if let error = try? liveQuery.run() {
            print(error)
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as! CBLLiveQuery) == liveQuery {
            polylines.removeAll(keepingCapacity: false)
            
            for (_, row) in liveQuery.rows!.allObjects.enumerated() {
                polylines.append(Polyline(for: (row as! CBLQueryRow).document!)!)
            }
            
            drawPolylines()
        }
    }
    
    func drawPolylines(){
        UIGraphicsBeginImageContext(view.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        mainImageView.image?.draw(in: view.bounds)

        context!.setLineWidth(1)
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setBlendMode(.normal)
        context!.setLineCap(.round)
        
        context!.beginPath()
        
        for polyline in polylines {
            if let firstPoint = polyline.points.first {
                context!.move(to: CGPoint(x: firstPoint["x"]!, y: firstPoint["x"]!))
            }
            
            for point in polyline.points {
                context!.addLine(to: CGPoint(x: point["x"]!, y: point["y"]!))
            }
        }
        context!.strokePath()
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            currentPolyline = Polyline(forNewDocumentIn: appDelegate!.kDatabase!)
            currentPolyline.points.append(["x" : lastPoint.x, "y" : lastPoint.y])
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            currentPolyline.points.append(["x" : currentPoint.x, "y" : currentPoint.y])
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        mainImageView.image?.draw(in: view.bounds)
        
        
        context!.setLineWidth(1)
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setBlendMode(.normal)
        context!.setLineCap(.round)
        
        context!.beginPath()
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context!.strokePath()
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let error = try? currentPolyline.save() {
            print(error)
        }
    }
}
