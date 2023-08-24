//
//  keysymdef.swift
//  HamsterKeyboard
//
//  Created by morse on 15/4/2023.
//

/// 代码来源
/// https://www.cl.cam.ac.uk/~mgk25/ucs/keysymdef.h
///

/// Void symbol
public let XK_VoidSymbol: Int32 = 0xffffff

// MARK: Modifiers

/// Left shift
let XK_Shift_L: Int32 = 0xffe1
/// Right shift
let XK_Shift_R: Int32 = 0xffe2
/// Left control
let XK_Control_L: Int32 = 0xffe3
/// Right control
let XK_Control_R: Int32 = 0xffe4
/// Caps lock
let XK_Caps_Lock: Int32 = 0xffe5
/// Shift lock
let XK_Shift_Lock: Int32 = 0xffe6
/// Left meta
let XK_Meta_L: Int32 = 0xffe7
/// Right meta
let XK_Meta_R: Int32 = 0xffe8
/// Left alt
let XK_Alt_L: Int32 = 0xffe9
/// Right alt
let XK_Alt_R: Int32 = 0xffea
/// Left super
let XK_Super_L: Int32 = 0xffeb
/// Right super
let XK_Super_R: Int32 = 0xffec
/// Left hyper
let XK_Hyper_L: Int32 = 0xffed
/// Right hyper
let XK_Hyper_R: Int32 = 0xffee

// MARK: special

/// Back space, back char
public let XK_BackSpace: Int32 = 0xff08
/// Enter
let XK_KP_Enter: Int32 = 0xff8d
let XK_Escape: Int32 = 0xff1b
/// Delete, rubout
let XK_Delete: Int32 = 0xffff
/// Return, enter
public let XK_Return: Int32 = 0xff0d
/// U+0020 SPACE
public let XK_space: Int32 = 0x0020
public let XK_Tab: Int32 = 0xff09

// MARK: function

let XK_F1: Int32 = 0xffbe
let XK_F2: Int32 = 0xffbf
let XK_F3: Int32 = 0xffc0
let XK_F4: Int32 = 0xffc1
let XK_F5: Int32 = 0xffc2
let XK_F6: Int32 = 0xffc3
let XK_F7: Int32 = 0xffc4
let XK_F8: Int32 = 0xffc5
let XK_F9: Int32 = 0xffc6
let XK_F10: Int32 = 0xffc7
let XK_F11: Int32 = 0xffc8
let XK_F12: Int32 = 0xffc9
let XK_F13: Int32 = 0xffca
let XK_F14: Int32 = 0xffcb
let XK_F15: Int32 = 0xffcc
let XK_F16: Int32 = 0xffcd
let XK_F17: Int32 = 0xffce
let XK_F18: Int32 = 0xffcf
let XK_F19: Int32 = 0xffd0

// MARK: Cursor control & motion

let XK_Home: Int32 = 0xff50
/// Move left, left arrow
let XK_Left: Int32 = 0xff51
/// Move up, up arrow
let XK_Up: Int32 = 0xff52
/// Move right, right arrow
let XK_Right: Int32 = 0xff53
/// Move down, down arrow
let XK_Down: Int32 = 0xff54
/// Prior, previous
let XK_Prior: Int32 = 0xff55
let XK_Page_Up: Int32 = 0xff55
/// Next
let XK_Next: Int32 = 0xff56
let XK_Page_Down: Int32 = 0xff56
/// EOL
let XK_End: Int32 = 0xff57
/// BOL
let XK_Begin: Int32 = 0xff58

// MARK: keypad

let XK_KP_0: Int32 = 0xffb0
let XK_KP_1: Int32 = 0xffb1
let XK_KP_2: Int32 = 0xffb2
let XK_KP_3: Int32 = 0xffb3
let XK_KP_4: Int32 = 0xffb4
let XK_KP_5: Int32 = 0xffb5
let XK_KP_6: Int32 = 0xffb6
let XK_KP_7: Int32 = 0xffb7
let XK_KP_8: Int32 = 0xffb8
let XK_KP_9: Int32 = 0xffb9
/// , Separator, often comma
let XK_KP_Separator: Int32 = 0xffac
/// .
let XK_KP_Decimal: Int32 = 0xffae
/// =
let XK_KP_Equal: Int32 = 0xffbd
/// -
let XK_KP_Subtract: Int32 = 0xffad
/// '*'
let XK_KP_Multiply: Int32 = 0xffaa
/// +
let XK_KP_Add: Int32 = 0xffab
/// '/'
let XK_KP_Divide: Int32 = 0xffaf

// MARK: pc keyboard

let XK_Menu: Int32 = 0xff67
/// Insert, insert here
let XK_Insert: Int32 = 0xff63
let XK_Num_Lock: Int32 = 0xff7f
/// Pause, hold
let XK_Pause: Int32 = 0xff13
let XK_Print: Int32 = 0xff61
let XK_Scroll_Lock: Int32 = 0xff14

/// U+005B LEFT SQUARE BRACKET
let XK_bracketleft: Int32 = 0x005b
/// U+005C REVERSE SOLIDUS
let XK_backslash: Int32 = 0x005c
/// U+005D RIGHT SQUARE BRACKET
let XK_bracketright: Int32 = 0x005d
/// U+002D HYPHEN-MINUS
let XK_minus: Int32 = 0x002d
