/// Delegate of PLVideoPlayer
public protocol PLVideoPlayerControlDelegate: class {
    func playerControl(control: PLVideoPlayerControl, didTappedBackButton button: UIButton)
    func playerControl(control: PLVideoPlayerControl, didTappedShareButton button: UIButton)
    func playerControl(control: PLVideoPlayerControl, didTappedFullScreenButton button: UIButton)
    func playerControl(control: PLVideoPlayerControl, didTappedPlayButton button: UIButton)
    func playerControl(control: PLVideoPlayerControl, didTappedNextButton button: UIButton)
    func playerControl(control: PLVideoPlayerControl, didChangeStatus status: PLVideoPlayerErrorStatus)
    func playerControl(control: PLVideoPlayerControl, sliderValueChanged slider: UISlider)
    func playerControl(control: PLVideoPlayerControl, sliderValueChangedEnd slider: UISlider)
}
