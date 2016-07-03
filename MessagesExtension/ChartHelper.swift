//
//  ChartHelper.swift
//  Pollarious
//
//  Created by Julian Dunskus on 29/06/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit

class ChartHelper {
	
	static func longDistanceSequence(count: Int) -> [Int] {
		let half = (count - 1) / 2
		var ints = [0]
		var prev = 0
		for _ in 1 ..< count {
			prev = (prev + half) % count
			while ints.contains(prev) {
				prev = (prev + 1) % count
			}
			ints.append(prev)
		}
		return ints
	}
	
	static func drawCircleSegments(ofSizes sizes: [CGFloat], inImageOf imageSize: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(imageSize)
		defer {
			UIGraphicsEndImageContext()
		}
		
		let context = UIGraphicsGetCurrentContext()!
		
		let lesserSize = min(imageSize.width, imageSize.height)
		let midPoint = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)
		let radius = lesserSize / 3
		
		var previousAngle: CGFloat = -CGFloat.pi / 2
		let colorBase = longDistanceSequence(count: sizes.count)
		var colors: [CGColor] = colorBase.map {
			UIColor(hue: CGFloat($0) / CGFloat(colorBase.count), saturation: 0.75, brightness: 1, alpha: 1).cgColor
		}
		var currentColor = 0
		
		let backgroundColor = #colorLiteral(red: 0.1956433058, green: 0.2113749981, blue: 0.2356699705, alpha: 1)
		backgroundColor.set()
		UIRectFill(CGRect(origin: CGPoint.zero, size: imageSize))
		
		context.setStrokeColor(backgroundColor.cgColor)
		context.setLineWidth(lesserSize / 150)
		
		let passes: [CGPathDrawingMode] = [.fill, .stroke]
		for mode in passes {
			currentColor = 0
			for fraction in sizes {
				let endAngle = previousAngle + fraction * 2 * CGFloat.pi
				
				context.setFillColor(colors[currentColor])
				currentColor += 1
				
				let path = CGMutablePath()
				path.moveTo(nil, x: midPoint.x, y: midPoint.y)
				path.addArc(nil, x: midPoint.x, y: midPoint.y, radius: radius, startAngle: previousAngle, endAngle: endAngle, clockwise: false)
				path.moveTo(nil, x: midPoint.x, y: midPoint.y)
				
				context.addPath(path)
				context.drawPath(using: mode)
				
				previousAngle = endAngle
			}
		}
		
		return UIGraphicsGetImageFromCurrentImageContext()!
	}
}
