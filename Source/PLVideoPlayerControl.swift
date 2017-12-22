import UIKit

/// Type of player control
///
/// - normalMini:
/// - normalFullScreen:
/// - liveMini//todo:
/// - liveFullScreen//todo:
public enum PLVideoPlayerControlType {
    case normalMini
    case normalFullScreen
    case liveMini 		// todo
    case liveFullScreen // todo
}

/// The swipe direction
///
/// - horizontal: horizontal direction
/// - vertical: vertical direction
public enum PLVideoPlayerSwipeDirection {
    case horizontal
    case vertical
}

open class PLVideoPlayerControl: UIView {
    
    open var fullScreenButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "player_fullscreen"), for: .normal)
        button.setBackgroundImage(UIImage(named: "player_mini"), for: .selected)
        button.addTarget(self, action: #selector(fullScreenAction(_:)), for: .touchUpInside)
        return button
    }()
    
    open var playOrPauseButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "player_play"), for: .normal)
        button.setBackgroundImage(UIImage(named: "player_pause"), for: .selected)
        button.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
        return button
    }()

    open var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    open var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
 	var progressSlider: PLVideoPlayerSlider = {
        let slider = PLVideoPlayerSlider()
        slider.setThumbImage(UIImage(named: "player_thumb"), for: .normal)
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor(white: 1.0, alpha: 0.4)
        slider.cacheTrackTintColor = .lightGray
        slider.addTarget(self, action: #selector(sliderValueChangedAction), for: .valueChanged)
        slider.addTarget(self, action: #selector(silderValueChangedEndAction), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return slider
    }()
    
    var isFullScreen: Bool = false {
        didSet {
            // chatview todo
            endAnimation()
            controlViewHidden(isHidden: false)
            startAnimation()
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            self.playOrPauseButton.isSelected = isPlaying
            if isPlaying {
                startAnimation()
            } else {
                endAnimation()
                controlViewHidden(isHidden: false)
            }
        }
    }
    
    public var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        return indicator
    }()
    
    var bottomBarHeight: Int {
        switch type {
        case .normalMini, .liveMini:
            return 35
        case .normalFullScreen, .liveFullScreen:
            return 40
        }
    }
    
    //@IBOutlet weak var centerPlayButton: UIButton!
    
    open weak var delegate: PLVideoPlayerControlDelegate?
    
    fileprivate var timer: Timer?
    fileprivate var type: PLVideoPlayerControlType = .normalMini
    fileprivate var swipeDirection: PLVideoPlayerSwipeDirection = .vertical
    
    init(type: PLVideoPlayerControlType) {
        super.init(frame: .zero)
        
        self.type = type
        
        self.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(bottomBarHeight)
        }
        
        bottomBar.addSubview(playOrPauseButton)
        playOrPauseButton.snp.makeConstraints { make in
            make.left.equalTo(bottomBar).offset(10)
            make.size.equalTo(20)
            make.centerY.equalTo(bottomBar)
        }
        
        bottomBar.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(playOrPauseButton.snp.right).offset(5)
            make.centerY.equalTo(bottomBar)
        }
        
        bottomBar.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            make.left.equalTo(currentTimeLabel.snp.right).offset(8)
            make.centerY.equalTo(bottomBar)
        }
        
        bottomBar.addSubview(totalTimeLabel)
        totalTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(progressSlider.snp.right).offset(8)
            make.centerY.equalTo(bottomBar)
            make.width.equalTo(currentTimeLabel)
        }
        
        bottomBar.addSubview(fullScreenButton)
        fullScreenButton.snp.makeConstraints { make in
            make.left.equalTo(totalTimeLabel.snp.right).offset(5)
            make.centerY.equalTo(bottomBar)
            make.right.equalTo(bottomBar).offset(-10)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapControl))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        self.addGestureRecognizer(swipe)
    }
    
    func startLoading() {
        indicator.removeFromSuperview()
        addSubview(indicator)
        indicator.center = self.center
        indicator.startAnimating()
    }
    
    func endLoading() {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
    
    func playTo(time: Double, totalTime: Double) {
        let current = String.hourTimeStringFrom(second: time)
        let total = String.hourTimeStringFrom(second: totalTime)
        self.currentTimeLabel.text = current
        self.totalTimeLabel.text = total
        self.progressSlider.value = Float(time/totalTime)
    }
    
    @objc func fullScreenAction(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.playerControl(control: self, didTappedFullScreenButton: sender)
        }
    }
    
    @objc func playOrPauseAction(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.playerControl(control: self, didTappedPlayButton: sender)
        }
    }

    @objc func sliderValueChangedAction(sender: UISlider) {
        endAnimation()
        if let delegate = self.delegate {
            delegate.playerControl(control: self, sliderValueChanged: sender)
        }
    }
    
    @objc func silderValueChangedEndAction(sender: UISlider) {
        startAnimation()
        if let delegate = self.delegate {
            delegate.playerControl(control: self, sliderValueChangedEnd: sender)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.indicator.center = self.center
    }
    
    override open func removeFromSuperview() {
        super.removeFromSuperview()
        endAnimation()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapControl))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    @objc func didSwipe(_ swipe: UISwipeGestureRecognizer) {
        let locationPoint = swipe.location(in: self)
        // todo
        let direction = swipe.direction
        
        switch swipe.state {
        case .began:
            print("began")
        case .changed:
            print("changed")
        case .ended:
            print("ended")
        case .possible:
            print("possible")
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        }
    }

    @objc func didTapControl(gesture: UITapGestureRecognizer) {
        endAnimation()
        
        // chatview
        
        self.controlViewHidden(isHidden: !bottomBar.isHidden)
        if !bottomBar.isHidden {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(controlAnimation), userInfo: nil, repeats: false)
        }
    }
    
    private func endAnimation() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func controlAnimation() {
        controlViewHidden(isHidden: true)
    }
    
    private func controlViewHidden(isHidden: Bool) {
        self.bottomBar.isHidden = isHidden
        
        if isFullScreen {
            UIApplication.shared.isStatusBarHidden = isHidden
        } else {
            UIApplication.shared.isStatusBarHidden = false
        }
    }
}

extension PLVideoPlayerControl: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
}
