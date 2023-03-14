import Combine
import Foundation
import KeyboardKit
import LibrimeKit
import Plist
import UIKit

/**
 键盘ViewController
 */
open class HamsterKeyboardViewController: KeyboardInputViewController {
    public var rimeEngine = RimeEngine.shared
    public var appSettings = HamsterAppSettings()
  
    @PlistWrapper(path: Bundle.main.url(forResource: "DefaultSkinExtend", withExtension: "plist")!)
    public var skinExtend: Plist
  
    @PlistWrapper(path: Bundle.main.url(forResource: "DefaultAction", withExtension: "plist")!)
    public var actionExtend: Plist
    
    var cancel = Set<AnyCancellable>()
  
    override public func viewDidLoad() {
        #if DEBUG
            NSLog("viewDidLoad() begin")
        #endif
    
        do {
            try self.rimeEngine.launch()
            
            self.appSettings.$switchTraditionalChinese
                .receive(on: RunLoop.main)
                .sink {
                    print("-----------\n combine traditionalMode \($0)")
                    _ = self.rimeEngine.simplifiedChineseMode(!$0)
                }
                .store(in: &self.cancel)
            
            self.appSettings.$showKeyPressBubble
                .receive(on: RunLoop.main)
                .sink {
                    print("-----------\n combine showKeyPressBubble \($0)")
                    self.calloutContext.input.isEnabled = $0
                }
                .store(in: &self.cancel)
            
            self.appSettings.$rimeSelectSchema
                .receive(on: RunLoop.main)
                .sink { selectSchema in
                    print("-----------\n combine selected schema \(selectSchema)")
                    let schema = self.rimeEngine.getSchemas()
                        .first(where: {
                            $0.schemaId == selectSchema
                        })
                    if let schema = schema {
                        _ = self.rimeEngine.setSchema(schema.schemaId)
                    }
                }
                .store(in: &self.cancel)
            
        } catch {
            // TODO: RIME 异常启动处理
            print("rime start error: ")
            print(error.localizedDescription)
        }
    
        self.keyboardAppearance = HamsterKeyboardAppearance(
            keyboardContext: self.keyboardContext
        )
        
        self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(
            keyboardContext: self.keyboardContext,
            inputSetProvider: self.inputSetProvider
        )
        
        self.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: self)
        self.autocompleteProvider = HamsterAutocompleteProvider(engine: self.rimeEngine)
        self.keyboardBehavior = HamsterKeyboardBehavior(keyboardContext: self.keyboardContext)
        self.calloutActionProvider = DisabledCalloutActionProvider() // 禁用长按按钮
        self.calloutContext = KeyboardCalloutContext(
            action: HamsterActionCalloutContext(
                actionHandler: keyboardActionHandler,
                actionProvider: calloutActionProvider
            ),
            input: InputCalloutContext(
                isEnabled: UIDevice.current.userInterfaceIdiom == .phone)
        )
        
        if !self.appSettings.showKeyPressBubble {
            self.calloutContext.input.isEnabled = false
        }
        
        // TODO: 动态设置 local
        self.keyboardContext.locale = Locale(identifier: "zh-Hans")
        
        super.viewDidLoad()
    }
  
    override public func viewDidDisappear(_ animated: Bool) {
        #if DEBUG
            NSLog("viewDidDisappear() begin")
        #endif
    }
  
    override public func viewWillSetupKeyboard() {
        #if DEBUG
            NSLog("viewWillSetupKeyboard() begin")
        #endif
        
        let alphabetKeyboard = AlphabetKeyboard(keyboardInputViewController: self)
            .environmentObject(self.rimeEngine)
            .environmentObject(self.appSettings)
        
        setup(with: alphabetKeyboard)
//        setup(with: HamsterKeyboard(controler: self))
        
//        alphabetKeyboard.observer()
    }
}

extension Plist {
    var strDict: [String: String] {
        var extend: [String: String] = [:]
        if let dict = dict {
            for (key, value) in dict {
                if let value = value as? String {
                    extend[(key as! String).lowercased()] = value
                }
            }
        }
        return extend
    }
}

public extension HamsterKeyboardViewController {
//    func insertAutocompleteSuggestion(_ suggestion: AutocompleteSuggestion) {
//        textDocumentProxy.insertAutocompleteSuggestion(suggestion)
//        keyboardActionHandler.handle(.release, on: .character(""))
//    }
    
    func setHamsterKeyboardType(_ type: KeyboardType) {
        // TODO: 切换九宫格
//        if case .numeric = type {
//            keyboardContext.keyboardType = .custom(named: KeyboardConstant.keyboardType.NumberGrid)
//            return
//        }
        keyboardContext.keyboardType = type
    }
}
