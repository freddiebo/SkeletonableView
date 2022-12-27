//
//  SkeletonView.swift
//
//
//  Created by Vladislav Bondarev on 26.12.2022.
//


import UIKit

/// Протокол, котрый позволяет указать UIView, которые будут анимироваться
/// По умолчанию: все subviews
public protocol SkeletonView: UIView {
    func animatedViews() -> [UIView]
}

// MARK: - Default implementation
public extension SkeletonView {
    func animatedViews() -> [UIView] {
        subviews
    }
}
