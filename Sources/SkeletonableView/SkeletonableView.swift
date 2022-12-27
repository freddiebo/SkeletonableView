//
//  SkeletonView.swift
//
//
//  Created by Vladislav Bondarev on 26.12.2022.
//

import UIKit

/// Протокол, предоставляющий `UIView` показывать скелетон-заглушку (при
/// загрузке данных, например).
public protocol SkeletonableView: UIView {
    
    /// UIView, котрая показывается в качестве skeleton.
    /// Должна конформить протокол SkeletonView
    /// На основе её subviews будут вычислены участки для
    /// анимированного `CAGradientLayer`.
    /// Обязательное свойство.
    var skeletonView: SkeletonView { get set }
    
    /// Закругления углов у `skeletonView`
    /// Default value is: cornerRadius этой view
    func skeletonCornerRadius() -> CGFloat
    
    /// Цвета градиента. Значения по умолчанию:
    /// F7F7FA, E4E4EB, F7F7FA.
    func gradientColors() -> [CGColor]
    
    /// Время с которым происходи анимация `CAGradientLayer`
    /// Default value is: 0.8
    func animationTimeInterval() -> TimeInterval
    
    /// Расположение цветов градиента в процентах от максимальной ширины
    /// Default value is: [0.25, 0.5, 0.75]
    func gradientLocations() -> [NSNumber]
    
    /// Метод, который показывает `skeletonView`. В случае, если
    /// параметр `isAnimate` true:
    /// добавляется `CAGradientLayer` с повторяющейся анимацией.
    /// Чтобы скрыть `skeletonView` используйте метод `hideSkeleton`
    func showSkeleton(isAnimate: Bool)
    
    /// Метод, скрывающий `skeletonView`, если он присутствует на данной view
    func hideSkeleton()
    
    /// Метод, позволяющий пересчитать значение `bounds` у `CAGradientLayer` в случае наличии его на `skeletonView`. Также пересчитывается 'mask'.
    func recalculateGradientBounds()
}

// MARK: - Default implementation
public extension SkeletonableView {
    func recalculateGradientBounds() {
        guard let gradientSublayer = skeletonView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) else { return }
        gradientSublayer.removeFromSuperlayer()
        skeletonView.layer.addSublayer(gradientSublayer)
        gradientSublayer.frame = skeletonView.layer.bounds
        let shape = CAShapeLayer()
        shape.frame = skeletonView.layer.bounds
        let bezierPath = UIBezierPath()
        skeletonView.animatedViews().forEach {
            bezierPath.append(UIBezierPath(roundedRect: $0.frame, cornerRadius: $0.layer.cornerRadius))
        }
        shape.path = bezierPath.cgPath
        gradientSublayer.mask = shape
    }
    
    func showSkeleton(isAnimate: Bool) {
        guard skeletonView.superview != self else { return }
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.layer.cornerRadius = skeletonCornerRadius()
        
        addSubview(skeletonView)
        
        self.skeletonView.alpha = 1
        self.skeletonView.layer.opacity = 1
        self.skeletonView.layer.sublayers?.forEach { $0.opacity = 1 }
        
        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: topAnchor),
            skeletonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            skeletonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            skeletonView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        layoutIfNeeded()
        
        if isAnimate {
            let gradientLayer = skeletonView.layer.sublayers?.last as? CAGradientLayer ?? CAGradientLayer()

            skeletonView.layer.addSublayer(gradientLayer)
            gradientLayer.frame = skeletonView.layer.bounds
            gradientLayer.cornerRadius = skeletonCornerRadius()
            gradientLayer.maskedCorners = layer.maskedCorners
            gradientLayer.locations = gradientLocations()
            
            let delta = (UIScreen.main.bounds.width / 2) * tan(CGFloat.pi / 180 * 10)
            let gradientHeight = UIScreen.main.bounds.height
            let deltaPercent = delta / gradientHeight
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5 - deltaPercent)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5 + deltaPercent)
            gradientLayer.colors = gradientColors()
            
            let shape = CAShapeLayer()
            shape.frame = skeletonView.layer.bounds
            let bezierPath = UIBezierPath()
            skeletonView.animatedViews().forEach {
              bezierPath.append(UIBezierPath(roundedRect: $0.frame, cornerRadius: $0.layer.cornerRadius))
            }
            shape.path = bezierPath.cgPath
            gradientLayer.mask = shape
            
            let animation = CABasicAnimation(keyPath: NSStringFromSelector(#selector(getter: CAGradientLayer.locations)))
            animation.duration = animationTimeInterval()
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            animation.fromValue = gradientLocations().map { $0.decimalValue - 1 }
            animation.toValue = gradientLocations().map { $0.decimalValue + 1 }
            gradientLayer.add(animation, forKey: nil)
        }
    }
    
    func hideSkeleton() {
        guard skeletonView.superview == self else { return }
        UIView.animate(withDuration: 0.5, animations: {
            self.skeletonView.alpha = 0
            self.skeletonView.layer.opacity = 0
            self.skeletonView.layer.sublayers?.forEach { $0.opacity = 0 }
        }, completion: { _ in
            self.skeletonView.removeFromSuperview()
            guard let gradientSublayer = self.skeletonView.layer.sublayers?.last as? CAGradientLayer else { return }
            gradientSublayer.removeAllAnimations()
        })
    }
    
    func animationTimeInterval() -> TimeInterval {
        TimeInterval(0.8)
    }
    
    func gradientColors() -> [CGColor] {
        let skeletonDarkGrayColor = UIColor(red: 228.0 / 255.0,
                                            green: 228.0 / 255.0,
                                            blue: 235.0 / 255.0,
                                            alpha: 1.0)
        let skeletonLightGrayColor = UIColor(red: 247.0 / 255.0,
                                             green: 247.0 / 255.0,
                                             blue: 250.0 / 255.0,
                                             alpha: 1.0)
        
        return [skeletonLightGrayColor.cgColor,
                skeletonDarkGrayColor.cgColor,
                skeletonLightGrayColor.cgColor]
    }
    
    func gradientLocations() -> [NSNumber] {
        [0.25, 0.5, 0.75]
    }
    
    func skeletonCornerRadius() -> CGFloat {
        layer.cornerRadius
    }
}
