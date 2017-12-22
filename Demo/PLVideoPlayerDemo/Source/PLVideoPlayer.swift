//
// 基于 https://github.com/pili-engineering/PLPlayerKit 二次开发播放器
// A video player built on top of PLPlayerKit https://github.com/pili-engineering/PLPlayerKit, written in Swift
// Author: Zigii Wong
//

import SnapKit

class PLVideoPlayer: NSObject {
    
    static let shared = PLVideoPlayer()
    
    /// 七牛播放器
    lazy var player: PLPlayer = {
		var player = PLPlayer(url: self.url, option: self.option)!
    	player.delegate = self
		return player
    }()
    
    /// 七牛播放器配置
    var option: PLPlayerOption = {
       	let option = PLPlayerOption.default()
        option.setOptionValue(15, forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)
        return option
    }()
	
    /// Container view for player
    var playView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    /// Container view for player when fullscreen
    var fullView: UIView = {
       	let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    /// 是否直播
    var isLive: Bool = false
    
    /// 是否正在快速定位
    var isSeeking: Bool = false

//    /// 代理
//    weak var delegate: PLVideoPlayerDelegate?
    
    /// 是否全屏
    var isFullScreen: Bool = false {
        didSet {
            playerControl.isFullScreen = isFullScreen
        }
    }
    
    /// is the video playable
    var playable: Bool = true

    /// is playing while entering background
    var isPlayingWhileEnteringBackground: Bool = false
    
    var timer: Timer?
    
    lazy var playerControl: PLVideoPlayerSchedular = {
        let playerControl = PLVideoPlayerSchedular()
        playerControl.delegate = self
        return playerControl
    }()
    
    var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    /// The url or resource
    var url: URL?
    
    /// the superview we will assign lately
    var superPlayerView: UIView?
    
   	override init() {
        super.init()
        setupAVAudioSession()
        setupNotification()
    }
    
    func playAudio(_ urlString: String?) {
        if urlString == nil { assertionFailure("url should not be nil") }
        if let urlStr = urlString {
            if urlStr.hasPrefix("http://") || urlStr.hasPrefix("https://") {
                url = URL(string: urlStr)
            } else {
                url = URL(fileURLWithPath: urlStr)
            }
        } else {
            assertionFailure("no url")
        }
	}
    
    func playVideo(_ urlString: String?, on view: UIView) {
        superPlayerView = view
        if urlString == nil { assertionFailure("url should not be nil") }
        if let urlStr = urlString {
            if urlStr.hasPrefix("http://") || urlStr.hasPrefix("https://") {
                url = URL(string: urlStr)
                isLive = false
            } else if urlStr.hasPrefix("rtmp") || urlStr.hasPrefix("flv") {
                url = URL(string: urlStr)
                isLive = true
            } else {
                url = URL(fileURLWithPath: urlStr)
            }
        } else {
            assertionFailure("no url")
        }
        
//        releasePlayer()
        setupPlayerUI()
        setupPlayerAndPlay()
    }
    
    func layoutPlayerLayer() {
        if !isFullScreen, let superView = self.superPlayerView {
            self.playView.frame = superView.bounds
            self.player.playerView?.frame = self.playView.bounds
            self.playerControl.frame = self.playView.bounds
        }
    }
    
    func play() {
        player.play()
        startProcess()
    }
    
    func pause() {
        player.pause()
        endProcess()
        playerControl.endLoading()
    }
    
    func stop() {
        player.stop()
        endProcess()
        playerControl.endLoading()
    }
    
    func releasePlayer() {
        NotificationCenter.default.removeObserver(self)
    	//todo
        endProcess()
        player.stop()
        player.playerView?.removeFromSuperview()
        playView.removeFromSuperview()
        playerControl.removeFromSuperview()
    	
        updateDeviceAllowRotationType(type: .portrait)
        UIDevice.current.setValue(NSNumber(value: UIDeviceOrientation.portrait.rawValue), forKey: "orientation")
    	UIApplication.shared.isStatusBarHidden = false
    }
    
    private func setupAVAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {}
    }
    
    private func setupPlayerUI() {
        
        guard let superPlayerView = self.superPlayerView else {
            assertionFailure("SuperPlayerView is nil")
            return
        }
        superPlayerView.addSubview(playView)
        playView.frame = superPlayerView.bounds

        self.playView.addSubview(self.playerControl)
        self.playerControl.frame = self.playView.bounds

        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func setupPlayerAndPlay() {
        self.playView.insertSubview(self.player.playerView!, at: 0)

        self.player.playerView?.frame = self.playView.bounds
    }
    
    private func setupNotification() {
        // screen orientation change
        observeDeviceOrientation()
        // audio volume change
        NotificationCenter.default.addObserver(self, selector: #selector(observeAudioVolumeChange), name: .PLVideoPlayerSystemVolumeDidChange, object: nil)
        // audio route change
        NotificationCenter.default.addObserver(self, selector: #selector(observeAudioRouteChange), name: .PLVideoPlayerAVAudioSessionRouteChange, object: nil)
        // enter foreground
        NotificationCenter.default.addObserver(self, selector: #selector(observeApplicationBecomeActive), name: .PLVideoPlayerUIApplicationDidBecomeActive, object: nil)
        // enter background
        NotificationCenter.default.addObserver(self, selector: #selector(observeApplicationWillResignActive), name: .PLVideoPlayerUIApplicationWillResignActive, object: nil)
    }
    
    private func startProcess() {
        if isLive { return }
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFunction(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    private func endProcess() {
        if isLive { return }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFunction(timer: Timer) {
        if player.isPlaying && !isSeeking {
            let currentTime = CMTimeGetSeconds(player.currentTime)
            let totalTime = CMTimeGetSeconds(player.totalDuration)
            playerControl.playTo(currentTime: currentTime, totalTime: totalTime)
        }
    }
    
    @objc func observeScreenOrientationChange(notification: Notification) {
        fullScreen(orientation: UIDevice.current.orientation)
    }
    
    @objc func observeAudioVolumeChange(notification: Notification) {
        //todo
    }
    
    @objc func observeAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            break
        case .oldDeviceUnavailable:
            if isLive {
                play()
            } else {
                pause()
            }
            break
        default:
            break
        }
    }
        
    @objc func observeApplicationBecomeActive(notification: Notification) {
        if isPlayingWhileEnteringBackground {
            play()
        }
        
        observeDeviceOrientation()
        if isFullScreen {
            updateDeviceAllowRotationType(type: .portrait)
        }
    }
    
    @objc func observeApplicationWillResignActive(notification: Notification) {
        isPlayingWhileEnteringBackground = player.isPlaying
        pause()
        
        removeDeviceOrientationObserver()
        if isFullScreen  {
            updateDeviceAllowRotationType(type: .landscapeLeftOrRight)
        }
    }
    
    private func removeDeviceOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: .PLVideoPlayerUIDeviceOrientationDidChange, object: nil)
    }
    
    private func observeDeviceOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeScreenOrientationChange), name: .PLVideoPlayerUIDeviceOrientationDidChange, object: nil)
    }
}

// MARK: - Screen Orientation transitation
extension PLVideoPlayer {
    
    func becomeFullScreen() {
        fullScreen(orientation: .landscapeLeft)
    }
    
    func becomeOriginScreen() {
        fullScreen(orientation: .portrait)
    }
    
    func fullScreen(orientation: UIDeviceOrientation) {
        if !canRotateBy(orientation: orientation) { return }

        let transform = getRotateTransform(orientation: orientation)
        currentOrientation = orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            playView.removeFromSuperview()
            updateDeviceAllowRotationType(type: .landscapeLeftOrRight)
            
            UIDevice.current.setValue(NSNumber(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
            UIDevice.current.setValue(NSNumber(value: orientation.rawValue), forKey: "orientation")
            
            //
            if let superView = superPlayerView?.viewController()?.view {
                
                superView.addSubview(fullView)
                self.fullView.frame = superView.bounds
                
                let width = max(ScreenWidth, ScreenHeight)
                let height = min(ScreenWidth, ScreenHeight)
                let window = UIApplication.shared.keyWindow!
                window.addSubview(self.playView)
                
                print("now the width is : \(width)")
                print("now the width is : \(height)")
                playerControl.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    if !self.isFullScreen {
                        let frame = CGRect(x: (height-width)/2, y: (width-height)/2, width: width, height: height)
                        self.resetViewTo(frame: frame)
                    }
                    self.playView.transform = transform
                }, completion: { finished in
                    self.playerControl.isHidden = false
                })
                
                UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeLeft
                UIApplication.shared.statusBarStyle = .lightContent
                UIApplication.shared.isStatusBarHidden = false
                isFullScreen = true
            }
        } else if orientation == .portrait {
            fullView.removeFromSuperview()
            playView.removeFromSuperview()
            updateDeviceAllowRotationType(type: .portrait)
            UIDevice.current.setValue(NSNumber(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
            UIDevice.current.setValue(NSNumber(value: orientation.rawValue), forKey: "orientation")
            
            if let superPlayerView = superPlayerView {
                superPlayerView.addSubview(playView)
                playerControl.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.playView.transform = transform
                    self.resetViewTo(frame: superPlayerView.bounds)
                }, completion: { finiised in
                    self.playerControl.isHidden = false
                })
            }
            
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.portrait
            UIApplication.shared.statusBarStyle = .lightContent // set current statusbar style
            UIApplication.shared.isStatusBarHidden = false
            isFullScreen = false
        }
    }
    
    func resetViewTo(frame: CGRect) {
        self.playView.frame = frame
        self.playerControl.frame = playView.bounds
        self.player.playerView?.frame = playView.bounds
    }
    
    func canRotateBy(orientation: UIDeviceOrientation) -> Bool {
        if currentOrientation == orientation { return false }
        if orientation == .portrait || orientation == .landscapeLeft || orientation == .landscapeRight {
            return true
        } else {
            return false
        }
    }
    
    func getRotateTransform(orientation: UIDeviceOrientation) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        if orientation == .landscapeLeft {
            transform = CGAffineTransform(rotationAngle: CGFloat(Float.pi / 2))
        } else if orientation == .landscapeRight {
            transform = CGAffineTransform(rotationAngle: -1 * CGFloat(Float.pi / 2))
        }
        return transform
    }
}


// MARK: - PLPlayerDelegate
extension PLVideoPlayer: PLPlayerDelegate {
    
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        if state == .statusCaching {
            playerControl.startLoading()
        } else {
            playerControl.endLoading()
        }
        
        switch state {
        case .statusPreparing: break
        case .statusReady: break
        case .statusError: break
        case .stateAutoReconnecting: break
        case .statusUnknow: break
        case .statusCaching: break
        case .statusPlaying:
            playerControl.isPlaying = true
            playerControl.endLoading()
            break
        case .statusPaused:
            playerControl.isPlaying = false
            break
        case .statusStopped:
            playerControl.isPlaying = false
            break
        case .statusCompleted:
            break
        }
    }
    
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        print(error.debugDescription)
        if isFullScreen {
            fullScreen(orientation: .portrait)
        }
        playerControl.endLoading()
        
        // todo show playerErrorStatus
    }
}

// MARK: - PLVideoPlayerControlDelegate
extension PLVideoPlayer: PLVideoPlayerControlDelegate {
    
    func playerControl(control: PLVideoPlayerControl, didTappedBackButton button: UIButton) {
        // todo
    }
    
    func playerControl(control: PLVideoPlayerControl, didTappedShareButton button: UIButton) {
        // todo
    }
    
    func playerControl(control: PLVideoPlayerControl, didTappedFullScreenButton button: UIButton) {
        if isFullScreen {
            fullScreen(orientation: .portrait)
        } else {
            fullScreen(orientation: .landscapeLeft)
        }
    }
    
    func playerControl(control: PLVideoPlayerControl, didTappedPlayButton button: UIButton) {
        if player.isPlaying {
            player.pause()
        	playerControl.isPlaying = false
        } else {
            player.play()
            playerControl.isPlaying = true
        }
    }
    
    func playerControl(control: PLVideoPlayerControl, didTappedNextButton button: UIButton) {
        // todo
    }
    
    func playerControl(control: PLVideoPlayerControl, didChangeStatus status: PLVideoPlayerErrorStatus) {
        // todo
        switch status {
        case .playError:
            break
        case .netViaWWAN:
            break
        case .notReachable:
            break
        }
    }
    
    func playerControl(control: PLVideoPlayerControl, sliderValueChangedEnd slider: UISlider) {
        let time = Int32(CMTimeGetSeconds(player.totalDuration) * Double(slider.value))
        let scale = Int32(player.currentTime.timescale)
        let cmtime = CMTimeMake(Int64(time * scale), scale)
        player.seek(to: cmtime)
        isSeeking = false
    }
    
    func playerControl(control: PLVideoPlayerControl, sliderValueChanged slider: UISlider) {
        let currentTime = CMTimeGetSeconds(player.totalDuration) * Double(slider.value)
        let totalTime = CMTimeGetSeconds(player.totalDuration)
        playerControl.playTo(currentTime: currentTime, totalTime: totalTime)
        isSeeking = true
    }
}
