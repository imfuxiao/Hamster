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
  var keyboardAbsolutePath: URL {
    try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
  }
  
  var sharedDataDir: String {
    self.keyboardAbsolutePath.appendingPathComponent(
      AppConstants.keyboardExtentionResourcesPath + "/" + AppConstants.rimeSharedSupportPathName,
      isDirectory: true).path
  }
  
  var userDir: String {
    self.keyboardAbsolutePath.appendingPathComponent(
      AppConstants.keyboardExtentionResourcesPath + "/" + AppConstants.rimeUserPathName,
      isDirectory: true).path
  }
  
  func rimeStart() throws {
    try ShareManager.initKeyboardInputMethodResources(keyboardAbsolutePath: self.keyboardAbsolutePath)
    
    rimeShutdown()
    
    let traits = IRimeTraits()
    traits.sharedDataDir = self.sharedDataDir
    traits.userDataDir = self.userDir
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "仓鼠"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // TODO: appName设置名字会产生异常
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
//    traits.appName = "rime.Hamster"
    
    self.rimeEngine.setNotificationDelegate(HamsterRimeNotification())
    self.rimeEngine.startService(traits)
  }
  
  func rimeShutdown() {
    self.rimeEngine.stopService()
  }
}
