Since Objective-C class methods can't be called from Swift 3.1 and up, it will need a different approach. I made this to swizzle viewWillDisappear to stop a spinner from spinning.


    extension UIViewController {

        @objc func viewWillDisappearOverride(_ animated: Bool) {
            self.viewWillDisappearOverride(animated) //Incase we need to override this method

            if self.isMovingFromParent {
                SpinnerManager.shared.stopSpinner()
            }
        }

        static func swizzleViewWillDisappear() {
        //Make sure This isn't a subclass of UIViewController, So that It applies to all UIViewController childs
            if self != UIViewController.self {
                return
            }
            let _: () = {
                let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
                let swizzledSelector = #selector(UIViewController.viewWillDisappearOverride(_:))
                guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }()
        }
    }

//and then to activate it I just called UIViewController.swizzleViewWillDisappear() from AppDelegate from inside didFinishLaunchingWithOptions