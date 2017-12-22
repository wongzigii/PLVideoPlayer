extension NavigationController {
    override var shouldAutorotate: Bool {
         return self.visibleViewController!.shouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.visibleViewController!.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.visibleViewController!.preferredInterfaceOrientationForPresentation
    }
}

extension UITabBarController {
    override open var shouldAutorotate: Bool {
        if let select = self.selectedViewController {
            return select.shouldAutorotate
        }
        return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let select = self.selectedViewController {
            return select.supportedInterfaceOrientations
        }
        return UIInterfaceOrientationMask.portrait
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let select = self.selectedViewController {
            return select.preferredInterfaceOrientationForPresentation
        }
        return UIInterfaceOrientation.portrait
    }
}

