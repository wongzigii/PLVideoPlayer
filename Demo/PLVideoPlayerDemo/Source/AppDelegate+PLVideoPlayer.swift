enum PLVideoPlayerAllowRotationType: Int {
    case portrait = 0
    case allButUpsideDown
    case landscapeLeftOrRight
}
private var AssociatedObjectHandle: UInt8 = 0

extension AppDelegate {
    
    var allowRotationType: PLVideoPlayerAllowRotationType {
        get {
            let a = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? PLVideoPlayerAllowRotationType ?? .portrait
            return a
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.allowRotationType == .portrait {
            return .portrait
        } else if self.allowRotationType == .allButUpsideDown {
            return .allButUpsideDown
        } else {
            return [.landscapeLeft, .landscapeRight]
        }
    }
}

// helper function to set allow rotation type
func updateDeviceAllowRotationType(type: PLVideoPlayerAllowRotationType) {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    delegate.allowRotationType = type
}
