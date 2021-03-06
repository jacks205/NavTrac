//
//  TempTimeEstimateCell.swift
//  Routes
//
//  Created by Mark Jackson on 3/22/15.
//  Copyright (c) 2015 Mark Jackson. All rights reserved.
//

import UIKit
import MapKit

struct RouteTableViewCellConst {
    static let IndicatorRectXOffset : CGFloat = 0.025
    static let TrafficIndicatorOffsetPercentage : CGFloat = 0.75
    static let IndicatorBaseWidthPercentage : CGFloat = 0.45
    static let IndicatorBaseHeight : CGFloat = 30
    
    static let MinimumVisibleLatitude = 0.1
}

class RouteTableViewCell: UITableViewCell {
    @IBOutlet weak var startLocation : UILabel!
    @IBOutlet weak var endLocation: UILabel!
    @IBOutlet weak var viaRouteDescription : UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var totalDistance : String?
    var totalTravelTime : String?
    
    var baseTime : Int?
    var trafficTime : Int?
    
    var trafficColor : UIColor?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.createTravelTimeLabel()
        self.setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeTravelTimeLabel()
    }
    
    func removeTravelTimeLabel(){
        for subView in self.contentView.subviews{
            if subView.tag == 100{
                subView.removeFromSuperview()
            }
        }
    }
    
    func createTravelTimeLabel(){
        let indicatorXPosition : CGFloat = self.frame.width * RouteTableViewCellConst.IndicatorRectXOffset
        let indicatorYPosition : CGFloat = self.frame.height * RouteTableViewCellConst.TrafficIndicatorOffsetPercentage
        let baseWidth : CGFloat = self.frame.width * RouteTableViewCellConst.IndicatorBaseWidthPercentage
        let travelTimeLabel : UILabel = UILabel(frame: CGRectMake(indicatorXPosition + 10, indicatorYPosition - 15, baseWidth, RouteTableViewCellConst.IndicatorBaseHeight))
        if let totalTravelTime = self.totalTravelTime{
            travelTimeLabel.text = totalTravelTime
        }else{
            travelTimeLabel.text = "N/A"
        }
        travelTimeLabel.textColor = UIColor.whiteColor()
        travelTimeLabel.font = UIFont(name: "Helvetica Neue", size: 11)
        travelTimeLabel.tag = 100
        self.contentView.addSubview(travelTimeLabel)
    }
    
    override func drawRect(rect: CGRect) {
        //Drawing code
        let ref  = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ref)
        //Draw Line across cell
        let lineWidth :CGFloat = 1
        let indicatorYPosition : CGFloat = self.frame.height * RouteTableViewCellConst.TrafficIndicatorOffsetPercentage
        self.drawWidthLine(ref, lineWidth: lineWidth, yPosition: indicatorYPosition)
        
        //Draw rounded rectangle
        let indicatorCornerRadius : CGFloat = 70
        let indicatorXPosition : CGFloat = self.frame.width * RouteTableViewCellConst.IndicatorRectXOffset
        let baseWidth : CGFloat = self.frame.width * RouteTableViewCellConst.IndicatorBaseWidthPercentage
        let indicatorRect = CGRectMake(indicatorXPosition, indicatorYPosition -  RouteTableViewCellConst.IndicatorBaseHeight / 2, baseWidth, RouteTableViewCellConst.IndicatorBaseHeight)
        self.drawTrafficIndicatorBase(indicatorRect, cornerRadius: indicatorCornerRadius)
        
        //Fill rounded rectangle
        let (color : CGColorRef, percentageFill : CGFloat) = determineTrafficIndicator()
        let fillWidth : CGFloat = baseWidth * percentageFill
        let fillRect : CGRect = CGRectMake(indicatorXPosition, indicatorYPosition -  RouteTableViewCellConst.IndicatorBaseHeight / 2, fillWidth, RouteTableViewCellConst.IndicatorBaseHeight)
        self.fillTrafficIndicatorBase(ref, rect: fillRect, cornerRadius: indicatorCornerRadius, color: color, fillWidth: fillWidth)
        CGContextRestoreGState(ref)
    }
    
    func fillTrafficIndicatorBase(ref : CGContextRef, rect : CGRect, cornerRadius : CGFloat, color : CGColorRef, fillWidth : CGFloat){
        CGContextSaveGState(ref)
        UIColor(CGColor: color)!.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.fill()
        path.addClip()
        CGContextRestoreGState(ref)
    }
    
    func drawTrafficIndicatorBase(rect : CGRect, cornerRadius : CGFloat){
        let color : UIColor = UIColor(CGColor: Colors.IndicatorBackground)!
        color.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.fill()
    }
    
    func drawWidthLine(ref : CGContextRef, lineWidth : CGFloat, yPosition : CGFloat){
        CGContextSaveGState(ref)
        CGContextSetLineWidth(ref, lineWidth)
        CGContextSetStrokeColorWithColor(ref, Colors.IndicatorBackground)
        CGContextMoveToPoint(ref, 0, yPosition)
        CGContextAddLineToPoint(ref, self.frame.width, yPosition)
        CGContextStrokePath(ref)
        CGContextRestoreGState(ref)
    }
    
    func determineTrafficIndicator() -> (CGColorRef, CGFloat){
        var colorIndicator : CGColor = Colors.TrafficColors.GreenLight
        var percentageFill : CGFloat = 0.6
        if let base = self.baseTime {
            if let traffic = self.trafficTime{
                if traffic > base * 3/2 && traffic < base * 2{
                    colorIndicator = Colors.TrafficColors.YellowLight
                    percentageFill = 0.75
                } else if traffic >= base * 2{
                    colorIndicator = Colors.TrafficColors.RedLight
                    percentageFill = 0.9
                }
            }
        }
        return (colorIndicator, percentageFill)
    }
    
    //Sets the via description to give an idea of the route that the information is for
    //Can accept nil value
    func setViaDescription(mainRoads : [String]?){
        var description : String = "via"
        if let roads = mainRoads{
            for (var i = 0; i < roads.count; ++i){
                description += " \(roads[i])"
                if(i == roads.count - 2){
                    description += " and"
                }
                else if(i < roads.count - 2){
                    description += " ,"
                }
            }
        }else{
            description += " Unknown"
        }
        self.viaRouteDescription.text = description
    }
    
    
    
    
}
