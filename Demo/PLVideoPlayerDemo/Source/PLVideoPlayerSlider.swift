import UIKit

class PLVideoPlayerSlider: UISlider {
    var cacheTrackTintColor: UIColor = .lightGray {
        didSet {
            self.cacheSlider.minimumTrackTintColor = cacheTrackTintColor
        }
    }
    
    var cacheValue: Float = 0 {
        didSet {
            self.cacheSlider.value = cacheValue
        }
    }
    
    override var maximumTrackTintColor: UIColor? {
        didSet {
            super.maximumTrackTintColor = .clear
            self.cacheSlider.maximumTrackTintColor = maximumTrackTintColor
        }
    }
    
    var cacheSlider: PLVideoPlayerCacheSlider = {
       	let slider = PLVideoPlayerCacheSlider()
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.maximumTrackTintColor = .clear
        
        self.addSubview(cacheSlider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cacheSlider.frame = self.bounds
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var newReact = rect
        newReact.origin.x = rect.origin.x - 3
        newReact.size.width = rect.size.width + 6
        return super.thumbRect(forBounds: bounds, trackRect: newReact, value: value)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.y = bounds.size.height / 2.0 - 1
        newBounds.size.height = 2
        return newBounds
    }
}

class PLVideoPlayerCacheSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.thumbTintColor = .clear
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var newReact = rect
        newReact.origin.x = rect.origin.x - 11
        newReact.size.width = rect.size.width + 22
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value).insetBy(dx: 11, dy: 11)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.y = bounds.size.height / 2.0 - 1
        newBounds.size.height = 2
        return newBounds
    }
}
