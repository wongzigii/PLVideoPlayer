import UIKit

enum PLVideoPlayerSchedularType {
    
    /// normal video player
    case normal
    
    /// live stream video player
    case live
}

open class PLVideoPlayerSchedular: UIView {

    open weak var delegate: PLVideoPlayerControlDelegate? {
        didSet {
            miniControl.delegate = delegate
            fullScreenControl.delegate = delegate
        }
    }
    
    var type: PLVideoPlayerSchedularType = .normal
    
    var isFullScreen: Bool = false {
        didSet {
            miniControl.isHidden = isFullScreen
            fullScreenControl.isHidden = !isFullScreen
            
            miniControl.isFullScreen = isFullScreen
            fullScreenControl.isFullScreen = isFullScreen
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            miniControl.isPlaying = isPlaying
            fullScreenControl.isPlaying = isPlaying
        }
    }
    
    lazy var miniControl: PLVideoPlayerControl = {
        var control: PLVideoPlayerControl
        switch self.type {
        case .live:
            control = PLVideoPlayerControl(type: .liveMini)
        case .normal:
            control = PLVideoPlayerControl(type: .normalMini)
        }

        return control
    }()
    
    lazy var fullScreenControl: PLVideoPlayerControl = {
        var control: PLVideoPlayerControl
        switch self.type {
        case .live:
            control = PLVideoPlayerControl(type: .liveFullScreen)
            break
        case .normal:
            control = PLVideoPlayerControl(type: .normalFullScreen)
            break
        }
        control.isHidden = true
        return control
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.type = .normal
        
        fullScreenControl.isHidden = true
        
        addSubview(miniControl)
        
        addSubview(fullScreenControl)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        miniControl.startLoading()
        fullScreenControl.startLoading()
    }
    
    func endLoading() {
        miniControl.endLoading()
        fullScreenControl.endLoading()
    }
    
    func playTo(currentTime: Double, totalTime: Double) {
        miniControl.playTo(time: currentTime, totalTime: totalTime)
        fullScreenControl.playTo(time: currentTime, totalTime: totalTime)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        miniControl.frame = self.bounds
        fullScreenControl.frame = self.bounds
    }
}
