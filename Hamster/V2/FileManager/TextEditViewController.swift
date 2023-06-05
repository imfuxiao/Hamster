//
//  TextEditViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import ProgressHUD
import Runestone
import TreeSitterLua
import TreeSitterLuaQueries
import TreeSitterLuaRunestone
import TreeSitterYAML
import TreeSitterYAMLQueries
import TreeSitterYAMLRunestone
import UIKit

class TextEditViewController: UIViewController, TextViewDelegate {
  init(fileURL: URL) {
    self.fileURL = fileURL

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let fileURL: URL

  lazy var textView: TextView = {
    let textView = TextView()
    textView.backgroundColor = .systemBackground
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
    textView.editorDelegate = self
    return textView
  }()
}

// MARK: override UIViewControler

extension TextEditViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = fileURL.lastPathComponent
    view.backgroundColor = UIColor.systemBackground

    let textView = textView
    let fileContent = (try? String(contentsOfFile: fileURL.path)) ?? ""
    if fileURL.pathExtension == "yaml" {
      let state = TextViewState(text: fileContent, language: TreeSitterLanguage.yaml)
      textView.setState(state)
    } else if fileURL.pathExtension == "lua" {
      let state = TextViewState(text: fileContent, language: TreeSitterLanguage.lua)
      textView.setState(state)
    } else {
      textView.text = fileContent
    }

    textView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(textView)
    
    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: view.topAnchor),
      textView.bottomAnchor.constraint(equalTo: view.CustomKeyboardLayoutGuide.topAnchor),
      textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    
    // navigation item
    // 添加导入按钮
    let saveItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveFileContent))
    navigationItem.rightBarButtonItem = saveItem
  }
}

// MARK: implementation TextViewDelegate

extension TextEditViewController {
  @objc func saveFileContent() {
    Logger.shared.log.debug("TextEditViewController textViewDidEndEditing")
    let fileContent = textView.text
    do {
      try fileContent.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
      ProgressHUD.showSuccess("保存成功")
      navigationController?.popViewController(animated: true)
    } catch {
      Logger.shared.log.debug("TextEditorView save error: \(error.localizedDescription)")
      ProgressHUD.showError("保存失败", delay: 1.5)
    }
  }
}
