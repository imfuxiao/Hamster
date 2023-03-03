import LibrimeKit

class HamsterRimeNotification: IRimeNotificationDelegate {
    func onDelployStart() {
        print("HamsterRimeNotification: onDelployStart")
    }
  
    func onDeploySuccess() {
        print("HamsterRimeNotification: onDeploySuccess")
    }
  
    func onDeployFailure() {
        print("HamsterRimeNotification: onDeployFailure")
    }
  
    func onChangeMode(_ mode: String) {
        print("HamsterRimeNotification: onChangeMode, mode: ", mode)
    }
  
    func onLoadingSchema(_ schema: String) {
        print("HamsterRimeNotification: onLoadingSchema, schema: ", schema)
    }
}

extension HamsterKeyboardViewController {
    func rimeStart() throws {
        try ShareManager.initKeyboardInputMethodResources(keyboardAbsolutePath: ShareManager.keyboardAbsolutePath)
    
        let traits = IRimeTraits()
        traits.sharedDataDir = ShareManager.sharedDataDir
        traits.userDataDir = ShareManager.userDir
        traits.distributionCodeName = "Hamster"
        traits.distributionName = "仓鼠"
        traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        // TODO: appName设置名字会产生异常
        // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
        // traits.appName = "rime.Hamster"
    
        self.rimeEngine.setNotificationDelegate(HamsterRimeNotification())
        self.rimeEngine.startService(traits)
    }
}
