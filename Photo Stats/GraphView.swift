//
//  GraphView.swift
//  Photo Stats
//
//  Created by Matthieu Rouif on 17/09/2015.
//  Copyright © 2015 As-App. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    var graph1Points:[Int] = [4, 2, 6, 4, 5, 12, 3]
    var graph2Points:[Int] = [2, 4, 5, 1, 2, 12, 1]

    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height

        //set up background clipping area
//        let path = UIBezierPath(roundedRect: rect,
//            byRoundingCorners: UIRectCorner.AllCorners,
//            cornerRadii: CGSize(width: 8.0, height: 8.0))
//        path.addClip()

        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        //6 - draw the gradient
        let startPoint = CGPoint.zero
        
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            .DrawsAfterEndLocation)
        
        //calculate the x point
        
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graph1Points.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = (graph1Points + graph2Points).maxElement()
        
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        
        // draw the line graph
        
        UIColor.whiteColor().setFill()
        UIColor.whiteColor().setStroke()
        
        //set up the points line
        let graph1Path = UIBezierPath()
        //go to start of line
        graph1Path.moveToPoint(CGPoint(x:columnXPoint(0),
            y:columnYPoint(graph1Points[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graph1Points.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                y:columnYPoint(graph1Points[i]))
            graph1Path.addLineToPoint(nextPoint)
        }
        
        graph1Path.stroke()
        
        
        // draw the second line graph
        
        UIColor.blueColor().setFill()
        UIColor.blueColor().setStroke()
        
        //set up the points line
        let graph2Path = UIBezierPath()
        //go to start of line
        graph2Path.moveToPoint(CGPoint(x:columnXPoint(0),
            y:columnYPoint(graph2Points[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graph2Points.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                y:columnYPoint(graph2Points[i]))
            graph2Path.addLineToPoint(nextPoint)
        }
        
        graph2Path.stroke()

        
        
//        //Create the clipping path for the graph gradient
//        
//        //1 - save the state of the context (commented out for now)
//        //CGContextSaveGState(context)
//        
//        //2 - make a copy of the path
//        let clippingPath = graph1Path.copy() as! UIBezierPath
//        
//        //3 - add lines to the copied path to complete the clip area
//        clippingPath.addLineToPoint(CGPoint(
//            x: columnXPoint(graph1Points.count - 1),
//            y:height))
//        clippingPath.addLineToPoint(CGPoint(
//            x:columnXPoint(0),
//            y:height))
//        clippingPath.closePath()
//        
//        //4 - add the clipping path to the context
//        clippingPath.addClip()
//        
//        //5 - check clipping path - temporary code
//        UIColor.whiteColor().setFill()
//        let rectPath = UIBezierPath(rect: self.bounds)
//        rectPath.fill()
//        //end temporary code
//        
//        
//        let highestYPoint = columnYPoint(maxValue)
//        startPoint = CGPoint(x:margin, y: highestYPoint)
//        endPoint = CGPoint(x:margin, y:self.bounds.height)
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsAfterEndLocation)
//        //CGContextRestoreGState(context)
//        
//        //draw the line on top of the clipped gradient
//        graph1Path.lineWidth = 2.0
//        graph1Path.stroke()
//        
//        //Draw the circles on top of graph stroke
//        for i in 0..<graph1Points.count {
//            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graph1Points[i]))
//            point.x -= 5.0/2
//            point.y -= 5.0/2
//            
//            let circle = UIBezierPath(ovalInRect:
//                CGRect(origin: point,
//                    size: CGSize(width: 5.0, height: 5.0)))
//            circle.fill()
//        }
        
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.moveToPoint(CGPoint(x:margin, y: topBorder))
        linePath.addLineToPoint(CGPoint(x: width - margin,
            y:topBorder))
        
        //center line
        linePath.moveToPoint(CGPoint(x:margin,
            y: graphHeight/2 + topBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.moveToPoint(CGPoint(x:margin,
            y:height - bottomBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
}