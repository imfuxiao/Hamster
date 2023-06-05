//
//  DisabledCalloutActionProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-05.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This provider can be used to disable callout actions.

 该提供程序可用于禁用呼出操作。
 */
public class DisabledCalloutActionProvider: CalloutActionProvider {
  public init() {}

  public func calloutActions(
    for action: KeyboardAction
  ) -> [KeyboardAction] { [] }
}
