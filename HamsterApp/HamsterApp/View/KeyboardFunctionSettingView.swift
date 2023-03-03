//
//  KeyboardFunctionSettingView.swift
//  HamsterApp
//
//  Created by morse on 17/2/2023.
//

import SwiftUI

struct KeyboardFunctionSettingView: View {
    @EnvironmentObject
    var appSettings: HamsterAppSettings
  
    var body: some View {
        List {
            Toggle("按键时显示弹出字符", isOn: $appSettings.preferences.showKeyPressBubble)
            Toggle("使用插入符号^", isOn: $appSettings.preferences.useInsertSymbol)
            Toggle("繁体输出", isOn: $appSettings.preferences.isTraditionalChinese)
      
            Picker(selection: /*@START_MENU_TOKEN@*/ .constant(1)/*@END_MENU_TOKEN@*/, label: Text("每页显示候选字数量")) {
                /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
            }
      
            Section {
                Toggle("按键音反馈", isOn: $appSettings.preferences.useKeyboardSound)
        
                Toggle("按键震动反馈", isOn: $appSettings.preferences.useKeyboardHaptic)
                if appSettings.preferences.useKeyboardHaptic {
                    Picker(selection: /*@START_MENU_TOKEN@*/ .constant(1)/*@END_MENU_TOKEN@*/, label: Text("震动强度")) {
                        /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                        /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
                    }
                }
        
                Toggle("空格滑动", isOn: $appSettings.preferences.useSpaceSlide)
            } header: {
                Text("按键效果")
            }
        }
    }
}

struct KeyboardFunctionSettingView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardFunctionSettingView()
            .environmentObject(HamsterAppSettings())
    }
}
