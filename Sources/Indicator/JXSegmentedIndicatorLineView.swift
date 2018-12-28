//
//  JXSegmentedIndicatorLineView.swift
//  JXSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

public enum JXSegmentedIndicatorLineStyle {
    case normal
    case lengthen
    case lengthenOffset
}

open class JXSegmentedIndicatorLineView: JXSegmentedIndicatorBaseView {
    open var lineStyle: JXSegmentedIndicatorLineStyle = .normal
    open var lineScrollOffsetX: CGFloat = 10    //lineStyle为lengthenOffset使用，滚动时x的偏移量

    open override func commonInit() {
        super.commonInit()

        indicatorHeight = 3
    }

    open override func refreshIndicatorState(model: JXSegmentedIndicatorParamsModel) {
        super.refreshIndicatorState(model: model)

        backgroundColor = indicatorColor
        layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)

        let width = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame)
        let height = getIndicatorHeight(itemFrame: model.currentSelectedItemFrame)
        let x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - width)/2
        var y = model.currentSelectedItemFrame.size.height - height - verticalMargin
        if indicatorPosition == .top {
            y = verticalMargin
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }

    open override func contentScrollViewDidScroll(model: JXSegmentedIndicatorParamsModel) {
        super.contentScrollViewDidScroll(model: model)

        let rightItemFrame = model.rightItemFrame
        let leftItemFrame = model.leftItemFrame
        let percent = model.percent
        var targetX: CGFloat = leftItemFrame.origin.x
        var targetWidth = getIndicatorWidth(itemFrame: leftItemFrame)

        if percent == 0 {
            targetX = leftItemFrame.origin.x + (leftItemFrame.size.width - targetWidth)/2
        }else {
            let leftWidth = targetWidth
            let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame)
            let leftX = leftItemFrame.origin.x + (leftItemFrame.size.width - leftWidth)/2
            let rightX = rightItemFrame.origin.x + (rightItemFrame.size.width - rightWidth)/2

            switch lineStyle {
                case .normal:
                    targetX = JXSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: CGFloat(percent))
                    if indicatorWidth == JXSegmentedViewAutomaticDimension {
                        targetWidth = JXSegmentedViewTool.interpolate(from: leftItemFrame.size.width, to: rightItemFrame.size.width, percent: CGFloat(percent))
                    }
                case .lengthen:
                    //前50%，只增加width；后50%，移动x并减小width
                    let maxWidth = rightX - leftX + rightWidth
                    if percent <= 0.5 {
                        targetX = leftX
                        targetWidth = JXSegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: CGFloat(percent*2))
                    }else {
                        targetX = JXSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: CGFloat((percent - 0.5)*2))
                        targetWidth = JXSegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: CGFloat((percent - 0.5)*2))
                    }
                case .lengthenOffset:
                    //前50%，增加width，并少量移动x；后50%，少量移动x并减小width
                    let maxWidth = rightX - leftX + rightWidth - lineScrollOffsetX*2
                    if percent <= 0.5 {
                        targetX = JXSegmentedViewTool.interpolate(from: leftX, to: leftX + lineScrollOffsetX, percent: CGFloat(percent*2))
                        targetWidth = JXSegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: CGFloat(percent*2))
                    }else {
                        targetX = JXSegmentedViewTool.interpolate(from:leftX + lineScrollOffsetX, to: rightX, percent: CGFloat((percent - 0.5)*2))
                        targetWidth = JXSegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: CGFloat((percent - 0.5)*2))
                    }
            }
        }

        //允许变动frame的情况：1、允许滚动；2、不允许滚动，但是已经通过手势滚动切换一页内容了；
        if isScrollEnabled || (!isScrollEnabled && !model.isClicked && percent == 0) {
            self.frame.origin.x = targetX
            self.frame.size.width = targetWidth
        }
    }

    open override func selectItem(model: JXSegmentedIndicatorParamsModel) {
        super.selectItem(model: model)

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame)
        var toFrame = self.frame
        toFrame.origin.x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - targetWidth)/2
        toFrame.size.width = targetWidth
        if isScrollEnabled {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.frame = toFrame
            }) { (_) in
            }
        }else {
            frame = toFrame
        }
    }

}
