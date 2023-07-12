//
//  ToolbarStepperModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import UIKit

public struct StepperModel {
  var text: String
  var value: Double
  var minValue: Double
  var maxValue: Double
  var stepValue: Double
  var valueChangeHandled: (Double) -> Void

  public init(text: String = "", value: Double = 0, minValue: Double = 0, maxValue: Double = .infinity, stepValue: Double = 1, valueChangeHandled: @escaping (Double) -> Void = { _ in }) {
    self.text = text
    self.value = value
    self.minValue = minValue
    self.maxValue = maxValue
    self.stepValue = stepValue
    self.valueChangeHandled = valueChangeHandled
  }
}
