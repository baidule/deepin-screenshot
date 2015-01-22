import QtQuick 2.1
import "calculateRect.js" as CalcEngine

Item {
	property bool selected: false
	property bool reSized: false
	property bool rotated: false
	property bool firstDraw: false
	property bool firstRelativeCalculate: false
	property bool isHovered: false

	property point clickedPoint
	property var points: []
	property var portion: []
	property var mainPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]
	property var minorPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]

    property int numberOrder
    property string shape: "line"
    property var bigPointRadius: 2
	property var smallPointRadius: 1
	property int clickedKey: 0
	property int linewidth: 3
	property int drawColor: 3

    onDrawColorChanged: { windowView.set_save_config(shape, "color_index", drawColor)}
    onLinewidthChanged: { windowView.set_save_config(shape, "linewidth_index", linewidth)}
	function _initMainPoints() {
		var startPoint = points[0]
		var endPoint = points[points.length - 1]
		var leftX = points[0].x
		var leftY = points[0].y
		var rightX = points[0].x
		var rightY = points[0].y

		for (var i = 1; i < points.length; i++) {

			leftX = Math.min(leftX, points[i].x)
			leftY = Math.min(leftY, points[i].y)
			rightX = Math.max(rightX, points[i].x)
			rightY = Math.max(rightY, points[i].y)
		}

		mainPoints[0] = Qt.point(Math.max(leftX - 5, 0), Math.max(leftY - 5, 0))
		mainPoints[1] = Qt.point(Math.max(leftX - 5, 0), Math.min(rightY + 5, screenHeight))
		mainPoints[2] = Qt.point(Math.min(rightX + 5, screenWidth), Math.max(leftY - 5, 0))
		mainPoints[3] = Qt.point(Math.min(rightX + 5, screenWidth), Math.min(rightY + 5, screenHeight))

		CalcEngine.changePointsOrder(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
	}
	function draw(ctx) {
		if (!firstDraw) { _initMainPoints() }

		minorPoints = CalcEngine.getAnotherFourPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])

		var startPoint = points[0]
		var endPoint = points[points.length - 1]

		ctx.lineWidth = linewidth
		ctx.strokeStyle = screen.colorCard(drawColor)
		ctx.beginPath()
		ctx.moveTo(points[0].x, points[0].y)

		for(var i = 1; i < points.length; i++) {
			ctx.lineTo(points[i].x, points[i].y)
		}
		ctx.stroke()
		if (isHovered) {
			ctx.lineWidth = 1
			ctx.strokeStyle = "#01bdff"
			ctx.beginPath()
			ctx.moveTo(points[0].x, points[0].y)

			for(var i = 1; i < points.length; i++) {
				ctx.lineTo(points[i].x, points[i].y)
			}
			ctx.stroke()
		}
		if (selected||reSized||rotated) {
			ctx.lineWidth = 1
			ctx.strokeStyle = "black"
			ctx.fillStyle = "yellow"

			/* Rotate */
			var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])

			ctx.beginPath()
			ctx.arc(rotatePoint.x, rotatePoint.y, bigPointRadius + linewidth/2, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			ctx.lineWidth = linewidth
			ctx.strokeStyle = "white"
			ctx.fillStyle = "white"
			/* Top left */
			ctx.beginPath()
			ctx.arc(mainPoints[1].x, mainPoints[1].y, bigPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Top right */
			ctx.beginPath()
			ctx.arc(mainPoints[3].x, mainPoints[3].y, bigPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Bottom left */
			ctx.beginPath()
			ctx.arc(mainPoints[0].x, mainPoints[0].y, bigPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Bottom right */
			ctx.beginPath()
			ctx.arc(mainPoints[2].x, mainPoints[2].y, bigPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			minorPoints = CalcEngine.getAnotherFourPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
			/* Top */
			ctx.beginPath()
			ctx.arc(minorPoints[0].x, minorPoints[0].y, smallPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Bottom */
			ctx.beginPath()
			ctx.arc(minorPoints[1].x, minorPoints[1].y, smallPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Left */
			ctx.beginPath()
			ctx.arc(minorPoints[2].x, minorPoints[2].y, smallPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			/* Right */
			ctx.beginPath()
			ctx.arc(minorPoints[3].x, minorPoints[3].y, smallPointRadius, 0, Math.PI * 2, false)
			ctx.closePath()
			ctx.fill()
			ctx.stroke()

			ctx.lineWidth = 1
			ctx.strokeStyle = "white"
			ctx.beginPath()
			ctx.moveTo(mainPoints[0].x, mainPoints[0].y)
			ctx.lineTo(mainPoints[2].x, mainPoints[2].y)
			ctx.lineTo(mainPoints[3].x, mainPoints[3].y)
			ctx.lineTo(mainPoints[1].x, mainPoints[1].y)
			ctx.lineTo(mainPoints[0].x, mainPoints[0].y)
			ctx.closePath()
			ctx.stroke()
		}
	}
	function clickOnPoint(p) {
		selected = false
		reSized = false
		rotated = false
		clickedPoint = Qt.point(0, 0)

		if (CalcEngine.pointClickIn(mainPoints[0], p)) {
			var result =  true
			reSized = result
			clickedKey = 1
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(mainPoints[1], p)) {
			var result =  true
			reSized = result
			clickedKey = 2
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(mainPoints[2], p)) {
			var result =  true
			reSized = result
			clickedKey = 3
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(mainPoints[3], p)) {
			var result =  true
			reSized = result
			clickedKey = 4
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(minorPoints[0], p)) {
			var result =  true
			reSized = result
			clickedKey = 5
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(minorPoints[1], p)) {
			var result =  true
			reSized = result
			clickedKey = 6
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(minorPoints[2], p)) {
			var result =  true
			reSized = result
			clickedKey = 7
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointClickIn(minorPoints[3], p)) {
			var result =  true
			reSized = result
			clickedKey = 8
			clickedPoint = p
			return result
		}
		if (rotateOnPoint(p)) {
			var result = true
			rotated = true
			clickedPoint = p
			return result
		}
		for (var i = 0; i < points.length; i++) {
			if (CalcEngine.pointClickIn(points[i], p)) {
				var result = true
				selected = result
				clickedPoint = p
				return result

			}
		}
	}

	function handleDrag(p) {
		var delX = p.x - clickedPoint.x
		var delY = p.y - clickedPoint.y
		for(var i = 0; i < 4; i++) {
			mainPoints[i] = Qt.point(mainPoints[i].x + delX, mainPoints[i].y + delY)
		}
		for (var i = 0; i < points.length; i++) {
			points[i] = Qt.point(points[i].x + delX, points[i].y + delY)
		}
		clickedPoint = p
	}
	function handleResize(p, key) {

		if (reSized) {
			if (!firstRelativeCalculate) {
				for(var i = 0; i < points.length; i++) {
					portion.push(CalcEngine.relativePostion(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], points[i]))

				}
				firstRelativeCalculate = true
			}
			var points1 = CalcEngine.reSizePointPosititon(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p, key)
			for (var i = 0; i < 4; i ++) { mainPoints[i] = points1[i] }

			for (var i = 0; i < points.length; i++) {
				points[i] = CalcEngine.getNewPostion(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], portion[i])
			}
		}
		clickedPoint = p
	}



	function rotateOnPoint(p) {
		var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		if (p.x >= rotatePoint.x - 5 && p.x <= rotatePoint.x + 5 && p.y >= rotatePoint.y - 5 && p.y <= rotatePoint.y + 5) {
			rotated = true
		} else {
			rotated = false
		}
		clickedPoint = rotatePoint
		return rotated
	}

	function handleRotate(p) {
		var centerInPoint = Qt.point((mainPoints[0].x + mainPoints[3].x) / 2, (mainPoints[0].y + mainPoints[3].y) / 2)
		var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		var angle = CalcEngine.calcutateAngle(clickedPoint, p, centerInPoint)
		for (var i = 0; i < 4; i++) {
			mainPoints[i] = CalcEngine.pointRotate(centerInPoint, mainPoints[i], angle)
		}
		for(var i = 0; i < points.length; i++) {
			points[i] = CalcEngine.pointRotate(centerInPoint, points[i], angle)
		}
		clickedPoint = p
	}

	function hoverOnRotatePoint(p) {
		var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		if (p.x >= rotatePoint.x - 5 && p.x <= rotatePoint.x + 5 && p.y >= rotatePoint.y - 5 && p.y <= rotatePoint.y + 5) {
			var result = true
		} else {
			var result = false
		}
		clickedPoint = rotatePoint
		return  result
	}
	function hoverOnShape(p) {
		var result = false
		for (var i = 0; i < points.length; i++) {
			if (CalcEngine.pointClickIn(points[i], p)) {
				var result = true
			}
		}
		isHovered = result
		return result
	}
}
