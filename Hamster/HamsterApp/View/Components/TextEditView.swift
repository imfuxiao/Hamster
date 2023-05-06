//
//  TextEditView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import Foundation
import Runestone
import SwiftUI
import TreeSitterLua
import TreeSitterLuaQueries
import TreeSitterLuaRunestone
import TreeSitterYAML
import TreeSitterYAMLQueries
import TreeSitterYAMLRunestone

class TextEditorCoordinator: TextViewDelegate {
  @Binding var text: String

  init(text: Binding<String>) {
    self._text = text
  }

  func textViewDidEndEditing(_ textView: TextView) {
    text = textView.text
    Logger.shared.log.debug("TextEditorCoordinator textViewDidEndEditing")
  }
}

enum FileType: CaseIterable {
  case yaml
  case lua
  case notSupported
}

struct TextEditorView: UIViewRepresentable {
  let fileType: FileType
  @Binding var fileContent: String

  func makeUIView(context: Context) -> Runestone.TextView {
    let textView = TextView()
    textView.backgroundColor = UIColor(named: "BackgroundColor")
    textView.showLineNumbers = true
    // Highlight the selected line.
    textView.lineSelectionDisplayType = .line
    // Show a page guide after the 80th character.
    textView.showPageGuide = true
    textView.pageGuideColumn = 80
    // Show all invisible characters.
    textView.showTabs = true
    textView.showSpaces = true
    textView.showLineBreaks = true
    textView.showSoftLineBreaks = true
    // Set the line-height to 130%
    textView.lineHeightMultiplier = 1.3
    // 设置委托
    textView.editorDelegate = context.coordinator
    return textView
  }

  func updateUIView(_ textView: Runestone.TextView, context: Context) {
    Logger.shared.log.debug("TextEditorView updateUIView()")
    if fileType == .yaml {
      let state = TextViewState(text: fileContent, language: TreeSitterLanguage.yaml)
      textView.setState(state)
      return
    }
    if fileType == .lua {
      let state = TextViewState(text: fileContent, language: TreeSitterLanguage.lua)
      textView.setState(state)
      return
    }

    textView.text = fileContent
  }

  func makeCoordinator() -> TextEditorCoordinator {
    Logger.shared.log.debug("TextEditorView makeCoordinator()")
    return TextEditorCoordinator(text: $fileContent)
  }

  typealias UIViewType = TextView
  typealias Coordinator = TextEditorCoordinator
}

struct Preview_TextEditorView: PreviewProvider {
  static var fileType = FileType.yaml
  @State static var fileContent = """
  config_version: '0.40'

  schema_list:
    - schema: clover
    - schema: double_pinyin_flypy
    - schema: qq86wubi
    - schema: wubi86_jidian
    - schema: wubi86_jidian_pinyin

  switcher:
    caption: 〔方案選單〕
    hotkeys:
      - Control+grave
      - Control+Shift+grave
      - F4
  """

  static var previews: some View {
    VStack {
      TextEditorView(fileType: fileType, fileContent: $fileContent)
    }
  }
}
