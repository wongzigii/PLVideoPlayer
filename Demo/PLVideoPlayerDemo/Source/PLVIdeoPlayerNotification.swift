extension NSNotification.Name {
    static let PLVideoPlayerSystemVolumeDidChange = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    
    static let PLVideoPlayerUIDeviceOrientationDidChange = UIDeviceOrientationDidChange
    
    static let PLVideoPlayerAVAudioSessionRouteChange = AVAudioSessionRouteChange
    
    static let PLVideoPlayerUIApplicationDidBecomeActive = UIApplicationDidBecomeActive
    
    static let PLVideoPlayerUIApplicationWillResignActive = UIApplicationWillResignActive
}
