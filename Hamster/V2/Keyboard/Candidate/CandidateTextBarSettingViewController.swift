//
//  CandidateTextBarSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class CandidateTextBarSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  init(parentController: KeyboardSettingViewController, appSettings: HamsterAppSettings) {
    self.parentController = parentController
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let appSettings: HamsterAppSettings
  private unowned let parentController: KeyboardSettingViewController

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.allowsSelection = false
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  lazy var steppers: [CandidateStepperModel] = [
    .init(
      text: "候选字最大数量",
      value: Double(appSettings.rimeMaxCandidateSize),
      minValue: 50,
      maxValue: 500,
      stepValue: 50,
      valueChangeHandled: { [unowned self] in
        appSettings.rimeMaxCandidateSize = Int32($0)
      }
    ),
    .init(
      text: "候选字体大小",
      value: Double(appSettings.rimeCandidateTitleFontSize),
      minValue: 10,
      maxValue: 30,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        appSettings.rimeCandidateTitleFontSize = Int($0)
      }
    ),
    .init(
      text: "候选栏高度",
      value: Double(appSettings.candidateBarHeight),
      minValue: 30,
      maxValue: 80,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        appSettings.candidateBarHeight = CGFloat($0)
      }
    ),
  ]
}

// MARK: override UIViewController

extension CandidateTextBarSettingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "候选栏"
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    parentController.tableView.reloadData()
  }
}

// MARK: implementation UITableViewDataSource, UITableViewDelegate

extension CandidateTextBarSettingViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    4
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section != 3 {
      return 1
    }
    return steppers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return ToggleTableViewCell(
        text: "启用候选栏",
        toggleValue: appSettings.enableCandidateBar,
        toggleHandled: { [unowned self] in
          appSettings.enableCandidateBar = $0
        }
      )
    }

    if indexPath.section == 1 {
      return ToggleTableViewCell(
        text: "启用内嵌模式",
        toggleValue: appSettings.enableInputEmbeddedMode,
        toggleHandled: { [unowned self] in
          appSettings.enableInputEmbeddedMode = $0
        }
      )
    }

    if indexPath.section == 2 {
      return ToggleTableViewCell(
        text: "显示候选项索引",
        toggleValue: appSettings.enableShowCandidateIndex,
        toggleHandled: { [unowned self] in
          appSettings.enableShowCandidateIndex = $0
        }
      )
    }

    if let cell = tableView.dequeueReusableCell(withIdentifier: StepperTableViewCell.identifier), let cell = cell as? StepperTableViewCell {
      let stepModel = steppers[indexPath.row]
      cell.label.text = stepModel.text
      cell.valueLabel.text = String(Int(stepModel.value))
      cell.stepper.value = stepModel.value
      cell.stepper.minimumValue = stepModel.minValue
      cell.stepper.maximumValue = stepModel.maxValue
      cell.stepper.stepValue = stepModel.stepValue
      cell.valueChangeHandled = stepModel.valueChangeHandled
      return cell
    }

    return UITableViewCell()
  }
}

struct CandidateStepperModel {
  let text: String
  let value: Double
  let minValue: Double
  let maxValue: Double
  let stepValue: Double
  let valueChangeHandled: (Double) -> Void
}
