import Foundation

/**
 应用设置配置
 */
public enum AppSettings {
  /**
   UI设置
   */
  public class UISettings {}
  
  /**
   功能设置
      */
  public class FeatureSettings {
    
    var traditionalMode: TraditionalMode?
    
    /**
     繁体功能设置
     */
    public class TraditionalMode {
      var enable: Bool = false
      var showSimplified = false
    }
  }
  
  public class OtherSettings {
    
  }
}
