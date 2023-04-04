//
//  TextEditView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import Foundation
import Runestone
import SwiftUI
import TreeSitterYAML
import TreeSitterYAMLQueries
import TreeSitterYAMLRunestone

class TextEditorCoordinator: TextViewDelegate {
  @Binding var text: String

  init(text: Binding<String>) {
    self._text = text
  }

  func textViewDidChange(_ textView: TextView) {
    text = textView.text
  }
}

enum FileType: CaseIterable {
  case yaml
  case notSupported
}

struct TextEditorView: UIViewRepresentable {
  let fileType: FileType
  @Binding var fileContent: String

  func makeUIView(context: Context) -> Runestone.TextView {
    let textView = TextView()
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
    // TODO: 暂时只支持yaml的语法高亮
    if fileType == .yaml {
      let state = TextViewState(text: fileContent, language: TreeSitterLanguage.yaml)
      textView.setState(state)
      return
    }
    textView.text = fileContent
  }

  func makeCoordinator() -> TextEditorCoordinator {
    TextEditorCoordinator(text: $fileContent)
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
