extension UIView {
    func viewController() -> UIViewController? {
        var parentView: UIView? = self.superview ?? nil
        while parentView != nil {
            parentView = parentView?.superview
            let responder = parentView?.next
            if let r = responder, r is NavigationController {
                return (r as! UIViewController)
            }
        }
        return nil
    }
}

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
