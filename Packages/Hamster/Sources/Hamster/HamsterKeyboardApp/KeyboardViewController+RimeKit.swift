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
  var keyboardAbsolutePath: URL { Bundle.main.resourceURL! }
  
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
    
    let traits = IRimeTraits()
    traits.sharedDataDir = self.sharedDataDir
    traits.userDataDir = self.userDir
    traits.appName = AppConstants.rimeAppName
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "仓鼠"
    
    self.rimeEngine.setNotificationDelegate(HamsterRimeNotification())
    self.rimeEngine.startService(traits)
  }
  
  func rimeShutdown() {
    self.rimeEngine.stopService()
  }
}
