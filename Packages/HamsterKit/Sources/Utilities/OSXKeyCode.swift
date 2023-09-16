//
//  MacOSKeyCode.swift
//  HamsterKeyboard
//
//  Created by morse on 15/4/2023.
//

import Foundation

// 代码来源:
// https://github.com/rime/squirrel/blob/master/macos_keycode.h

// masks
let OSX_CAPITAL_MASK: Int32 = 1 << 16
let OSX_SHIFT_MASK: Int32 = 1 << 17
let OSX_CTRL_MASK: Int32 = 1 << 18
let OSX_ALT_MASK: Int32 = 1 << 19
let OSX_COMMAND_MASK: Int32 = 1 << 20

// key codes
//
// credit goes to tekezo@
// https://github.com/tekezo/Karabiner/blob/master/src/bridge/generator/keycode/data/KeyCode.data

// ----------------------------------------
// alphabet
let OSX_VK_A: Int32 = 0x0
let OSX_VK_B: Int32 = 0xb
let OSX_VK_C: Int32 = 0x8
let OSX_VK_D: Int32 = 0x2
let OSX_VK_E: Int32 = 0xe
let OSX_VK_F: Int32 = 0x3
let OSX_VK_G: Int32 = 0x5
let OSX_VK_H: Int32 = 0x4
let OSX_VK_I: Int32 = 0x22
let OSX_VK_J: Int32 = 0x26
let OSX_VK_K: Int32 = 0x28
let OSX_VK_L: Int32 = 0x25
let OSX_VK_M: Int32 = 0x2e
let OSX_VK_N: Int32 = 0x2d
let OSX_VK_O: Int32 = 0x1f
let OSX_VK_P: Int32 = 0x23
let OSX_VK_Q: Int32 = 0xc
let OSX_VK_R: Int32 = 0xf
let OSX_VK_S: Int32 = 0x1
let OSX_VK_T: Int32 = 0x11
let OSX_VK_U: Int32 = 0x20
let OSX_VK_V: Int32 = 0x9
let OSX_VK_W: Int32 = 0xd
let OSX_VK_X: Int32 = 0x7
let OSX_VK_Y: Int32 = 0x10
let OSX_VK_Z: Int32 = 0x6

// ----------------------------------------
// number

let OSX_VK_KEY_0: Int32 = 0x1d
let OSX_VK_KEY_1: Int32 = 0x12
let OSX_VK_KEY_2: Int32 = 0x13
let OSX_VK_KEY_3: Int32 = 0x14
let OSX_VK_KEY_4: Int32 = 0x15
let OSX_VK_KEY_5: Int32 = 0x17
let OSX_VK_KEY_6: Int32 = 0x16
let OSX_VK_KEY_7: Int32 = 0x1a
let OSX_VK_KEY_8: Int32 = 0x1c
let OSX_VK_KEY_9: Int32 = 0x19

// ----------------------------------------
// symbol

// BACKQUOTE is also known as grave accent or backtick.
let OSX_VK_BACKQUOTE: Int32 = 0x32
let OSX_VK_BACKSLASH: Int32 = 0x2a
let OSX_VK_BRACKET_LEFT: Int32 = 0x21
let OSX_VK_BRACKET_RIGHT: Int32 = 0x1e
let OSX_VK_COMMA: Int32 = 0x2b
let OSX_VK_DOT: Int32 = 0x2f
let OSX_VK_EQUAL: Int32 = 0x18
let OSX_VK_MINUS: Int32 = 0x1b
let OSX_VK_QUOTE: Int32 = 0x27
let OSX_VK_SEMICOLON: Int32 = 0x29
let OSX_VK_SLASH: Int32 = 0x2c

// ----------------------------------------
// keypad

let OSX_VK_KEYPAD_0: Int32 = 0x52
let OSX_VK_KEYPAD_1: Int32 = 0x53
let OSX_VK_KEYPAD_2: Int32 = 0x54
let OSX_VK_KEYPAD_3: Int32 = 0x55
let OSX_VK_KEYPAD_4: Int32 = 0x56
let OSX_VK_KEYPAD_5: Int32 = 0x57
let OSX_VK_KEYPAD_6: Int32 = 0x58
let OSX_VK_KEYPAD_7: Int32 = 0x59
let OSX_VK_KEYPAD_8: Int32 = 0x5b
let OSX_VK_KEYPAD_9: Int32 = 0x5c
let OSX_VK_KEYPAD_CLEAR: Int32 = 0x47
let OSX_VK_KEYPAD_COMMA: Int32 = 0x5f
let OSX_VK_KEYPAD_DOT: Int32 = 0x41
let OSX_VK_KEYPAD_EQUAL: Int32 = 0x51
let OSX_VK_KEYPAD_MINUS: Int32 = 0x4e
let OSX_VK_KEYPAD_MULTIPLY: Int32 = 0x43
let OSX_VK_KEYPAD_PLUS: Int32 = 0x45
let OSX_VK_KEYPAD_SLASH: Int32 = 0x4b

// ----------------------------------------
// special

let OSX_VK_DELETE: Int32 = 0x33
let OSX_VK_ENTER: Int32 = 0x4c
let OSX_VK_ENTER_POWERBOOK: Int32 = 0x34
let OSX_VK_ESCAPE: Int32 = 0x35
let OSX_VK_FORWARD_DELETE: Int32 = 0x75
let OSX_VK_HELP: Int32 = 0x72
let OSX_VK_RETURN: Int32 = 0x24
let OSX_VK_SPACE: Int32 = 0x31
let OSX_VK_TAB: Int32 = 0x30

// ----------------------------------------
// function
let OSX_VK_F1: Int32 = 0x7a
let OSX_VK_F2: Int32 = 0x78
let OSX_VK_F3: Int32 = 0x63
let OSX_VK_F4: Int32 = 0x76
let OSX_VK_F5: Int32 = 0x60
let OSX_VK_F6: Int32 = 0x61
let OSX_VK_F7: Int32 = 0x62
let OSX_VK_F8: Int32 = 0x64
let OSX_VK_F9: Int32 = 0x65
let OSX_VK_F10: Int32 = 0x6d
let OSX_VK_F11: Int32 = 0x67
let OSX_VK_F12: Int32 = 0x6f
let OSX_VK_F13: Int32 = 0x69
let OSX_VK_F14: Int32 = 0x6b
let OSX_VK_F15: Int32 = 0x71
let OSX_VK_F16: Int32 = 0x6a
let OSX_VK_F17: Int32 = 0x40
let OSX_VK_F18: Int32 = 0x4f
let OSX_VK_F19: Int32 = 0x50

// ----------------------------------------
// functional

let OSX_VK_BRIGHTNESS_DOWN: Int32 = 0x91
let OSX_VK_BRIGHTNESS_UP: Int32 = 0x90
let OSX_VK_DASHBOARD: Int32 = 0x82
let OSX_VK_EXPOSE_ALL: Int32 = 0xa0
let OSX_VK_LAUNCHPAD: Int32 = 0x83
let OSX_VK_MISSION_CONTROL: Int32 = 0xa0

// ----------------------------------------
// cursor

let OSX_VK_CURSOR_UP: Int32 = 0x7e
let OSX_VK_CURSOR_DOWN: Int32 = 0x7d
let OSX_VK_CURSOR_LEFT: Int32 = 0x7b
let OSX_VK_CURSOR_RIGHT: Int32 = 0x7c

let OSX_VK_PAGEUP: Int32 = 0x74
let OSX_VK_PAGEDOWN: Int32 = 0x79
let OSX_VK_HOME: Int32 = 0x73
let OSX_VK_END: Int32 = 0x77

// ----------------------------------------
// modifiers
let OSX_VK_CAPSLOCK: Int32 = 0x39
let OSX_VK_COMMAND_L: Int32 = 0x37
let OSX_VK_COMMAND_R: Int32 = 0x36
let OSX_VK_CONTROL_L: Int32 = 0x3b
let OSX_VK_CONTROL_R: Int32 = 0x3e
let OSX_VK_FN: Int32 = 0x3f
let OSX_VK_OPTION_L: Int32 = 0x3a
let OSX_VK_OPTION_R: Int32 = 0x3d
let OSX_VK_SHIFT_L: Int32 = 0x38
let OSX_VK_SHIFT_R: Int32 = 0x3c

// ----------------------------------------
// pc keyboard

let OSX_VK_PC_APPLICATION: Int32 = 0x6e
let OSX_VK_PC_BS: Int32 = 0x33
let OSX_VK_PC_DEL: Int32 = 0x75
let OSX_VK_PC_INSERT: Int32 = 0x72
let OSX_VK_PC_KEYPAD_NUMLOCK: Int32 = 0x47
let OSX_VK_PC_PAUSE: Int32 = 0x71
let OSX_VK_PC_POWER: Int32 = 0x7f
let OSX_VK_PC_PRINTSCREEN: Int32 = 0x69
let OSX_VK_PC_SCROLLLOCK: Int32 = 0x6b

// ----------------------------------------
// international

let OSX_VK_DANISH_DOLLAR: Int32 = 0xa
let OSX_VK_DANISH_LESS_THAN: Int32 = 0x32

let OSX_VK_FRENCH_DOLLAR: Int32 = 0x1e
let OSX_VK_FRENCH_EQUAL: Int32 = 0x2c
let OSX_VK_FRENCH_HAT: Int32 = 0x21
let OSX_VK_FRENCH_MINUS: Int32 = 0x18
let OSX_VK_FRENCH_RIGHT_PAREN: Int32 = 0x1b

let OSX_VK_GERMAN_CIRCUMFLEX: Int32 = 0xa
let OSX_VK_GERMAN_LESS_THAN: Int32 = 0x32
let OSX_VK_GERMAN_PC_LESS_THAN: Int32 = 0x80
let OSX_VK_GERMAN_QUOTE: Int32 = 0x18
let OSX_VK_GERMAN_A_UMLAUT: Int32 = 0x27
let OSX_VK_GERMAN_O_UMLAUT: Int32 = 0x29
let OSX_VK_GERMAN_U_UMLAUT: Int32 = 0x21

let OSX_VK_ITALIAN_BACKSLASH: Int32 = 0xa
let OSX_VK_ITALIAN_LESS_THAN: Int32 = 0x32

let OSX_VK_JIS_ATMARK: Int32 = 0x21
let OSX_VK_JIS_BRACKET_LEFT: Int32 = 0x1e
let OSX_VK_JIS_BRACKET_RIGHT: Int32 = 0x2a
let OSX_VK_JIS_COLON: Int32 = 0x27
let OSX_VK_JIS_DAKUON: Int32 = 0x21
let OSX_VK_JIS_EISUU: Int32 = 0x66
let OSX_VK_JIS_HANDAKUON: Int32 = 0x1e
let OSX_VK_JIS_HAT: Int32 = 0x18
let OSX_VK_JIS_KANA: Int32 = 0x68
let OSX_VK_JIS_PC_HAN_ZEN: Int32 = 0x32
let OSX_VK_JIS_UNDERSCORE: Int32 = 0x5e
let OSX_VK_JIS_YEN: Int32 = 0x5d

let OSX_VK_RUSSIAN_PARAGRAPH: Int32 = 0xa
let OSX_VK_RUSSIAN_TILDE: Int32 = 0x32

let OSX_VK_SPANISH_LESS_THAN: Int32 = 0x32
let OSX_VK_SPANISH_ORDINAL_INDICATOR: Int32 = 0xa

let OSX_VK_SWEDISH_LESS_THAN: Int32 = 0x32
let OSX_VK_SWEDISH_SECTION: Int32 = 0xa

let OSX_VK_SWISS_LESS_THAN: Int32 = 0x32
let OSX_VK_SWISS_SECTION: Int32 = 0xa

let OSX_VK_UK_SECTION: Int32 = 0xa

// int osx_modifiers_to_rime_modifiers(unsigned long modifiers);
// int osx_keycode_to_rime_keycode(int keycode, int keychar, int shift, int caps);

public enum RimeModifier {
  public static let kShiftMask: Int32 = 1 << 0
  public static let kLockMask: Int32 = 1 << 1
  public static let kControlMask: Int32 = 1 << 2
  public static let kMod1Mask: Int32 = 1 << 3
  public static let kAltMask: Int32 = kMod1Mask
  public static let kMod2Mask: Int32 = 1 << 4
  public static let kMod3Mask: Int32 = 1 << 5
  public static let kMod4Mask: Int32 = 1 << 6
  public static let kMod5Mask: Int32 = 1 << 7
  public static let kButton1Mask: Int32 = 1 << 8
  public static let kButton2Mask: Int32 = 1 << 9
  public static let kButton3Mask: Int32 = 1 << 10
  public static let kButton4Mask: Int32 = 1 << 11
  public static let kButton5Mask: Int32 = 1 << 12

  /* The next few modifiers are used by XKB, so we skip to the end.
   * Bits 15 - 23 are currently unused. Bit 29 is used internally.
   */

  /* ibus :) mask */
  public static let kHandledMask: Int32 = 1 << 24
  public static let kForwardMask: Int32 = 1 << 25
  public static let kIgnoredMask: Int32 = kForwardMask

  public static let kSuperMask: Int32 = 1 << 26
  public static let kHyperMask: Int32 = 1 << 27
  public static let kMetaMask: Int32 = 1 << 28

  public static let kReleaseMask: Int32 = 1 << 30

  public static let kModifierMask: Int32 = 0x5f00_1fff
}

struct KeyCodeMapping {
  let osxKeyCode: Int32
  let rimeKeyCode: Int32
}

let keyCodeMappings: [KeyCodeMapping] = [
  // MARK: modifiers

  .init(osxKeyCode: OSX_VK_CAPSLOCK, rimeKeyCode: XK_Caps_Lock),
  .init(osxKeyCode: OSX_VK_COMMAND_L, rimeKeyCode: XK_Super_L),
  .init(osxKeyCode: OSX_VK_COMMAND_R, rimeKeyCode: XK_Super_R),
  .init(osxKeyCode: OSX_VK_CONTROL_L, rimeKeyCode: XK_Control_L),
  .init(osxKeyCode: OSX_VK_CONTROL_R, rimeKeyCode: XK_Control_R),
  .init(osxKeyCode: OSX_VK_FN, rimeKeyCode: XK_Hyper_L),
  .init(osxKeyCode: OSX_VK_OPTION_L, rimeKeyCode: XK_Alt_L),
  .init(osxKeyCode: OSX_VK_OPTION_R, rimeKeyCode: XK_Alt_R),
  .init(osxKeyCode: OSX_VK_SHIFT_L, rimeKeyCode: XK_Shift_L),
  .init(osxKeyCode: OSX_VK_SHIFT_R, rimeKeyCode: XK_Shift_R),

  // MARK: special

  .init(osxKeyCode: OSX_VK_DELETE, rimeKeyCode: XK_BackSpace),
  .init(osxKeyCode: OSX_VK_ENTER, rimeKeyCode: XK_KP_Enter),
  .init(osxKeyCode: OSX_VK_ESCAPE, rimeKeyCode: XK_Escape),
  .init(osxKeyCode: OSX_VK_FORWARD_DELETE, rimeKeyCode: XK_Delete),
  .init(osxKeyCode: OSX_VK_RETURN, rimeKeyCode: XK_Return),
  .init(osxKeyCode: OSX_VK_SPACE, rimeKeyCode: XK_space),
  .init(osxKeyCode: OSX_VK_TAB, rimeKeyCode: XK_Tab),

  // MARK: function

  .init(osxKeyCode: OSX_VK_F1, rimeKeyCode: XK_F1),
  .init(osxKeyCode: OSX_VK_F2, rimeKeyCode: XK_F2),
  .init(osxKeyCode: OSX_VK_F3, rimeKeyCode: XK_F3),
  .init(osxKeyCode: OSX_VK_F4, rimeKeyCode: XK_F4),
  .init(osxKeyCode: OSX_VK_F5, rimeKeyCode: XK_F5),
  .init(osxKeyCode: OSX_VK_F6, rimeKeyCode: XK_F6),
  .init(osxKeyCode: OSX_VK_F7, rimeKeyCode: XK_F7),
  .init(osxKeyCode: OSX_VK_F8, rimeKeyCode: XK_F8),
  .init(osxKeyCode: OSX_VK_F9, rimeKeyCode: XK_F9),
  .init(osxKeyCode: OSX_VK_F10, rimeKeyCode: XK_F10),
  .init(osxKeyCode: OSX_VK_F11, rimeKeyCode: XK_F11),
  .init(osxKeyCode: OSX_VK_F12, rimeKeyCode: XK_F12),
  .init(osxKeyCode: OSX_VK_F13, rimeKeyCode: XK_F13),
  .init(osxKeyCode: OSX_VK_F14, rimeKeyCode: XK_F14),
  .init(osxKeyCode: OSX_VK_F15, rimeKeyCode: XK_F15),
  .init(osxKeyCode: OSX_VK_F16, rimeKeyCode: XK_F16),
  .init(osxKeyCode: OSX_VK_F17, rimeKeyCode: XK_F17),
  .init(osxKeyCode: OSX_VK_F18, rimeKeyCode: XK_F18),
  .init(osxKeyCode: OSX_VK_F19, rimeKeyCode: XK_F19),

  // MARK: cursor

  .init(osxKeyCode: OSX_VK_CURSOR_UP, rimeKeyCode: XK_Up),
  .init(osxKeyCode: OSX_VK_CURSOR_DOWN, rimeKeyCode: XK_Down),
  .init(osxKeyCode: OSX_VK_CURSOR_LEFT, rimeKeyCode: XK_Left),
  .init(osxKeyCode: OSX_VK_CURSOR_RIGHT, rimeKeyCode: XK_Right),
  .init(osxKeyCode: OSX_VK_PAGEUP, rimeKeyCode: XK_Page_Up),
  .init(osxKeyCode: OSX_VK_PAGEDOWN, rimeKeyCode: XK_Page_Down),
  .init(osxKeyCode: OSX_VK_HOME, rimeKeyCode: XK_Home),
  .init(osxKeyCode: OSX_VK_END, rimeKeyCode: XK_End),

  // MARK: keypad

  .init(osxKeyCode: OSX_VK_KEYPAD_0, rimeKeyCode: XK_KP_0),
  .init(osxKeyCode: OSX_VK_KEYPAD_1, rimeKeyCode: XK_KP_1),
  .init(osxKeyCode: OSX_VK_KEYPAD_2, rimeKeyCode: XK_KP_2),
  .init(osxKeyCode: OSX_VK_KEYPAD_3, rimeKeyCode: XK_KP_3),
  .init(osxKeyCode: OSX_VK_KEYPAD_4, rimeKeyCode: XK_KP_4),
  .init(osxKeyCode: OSX_VK_KEYPAD_5, rimeKeyCode: XK_KP_5),
  .init(osxKeyCode: OSX_VK_KEYPAD_6, rimeKeyCode: XK_KP_6),
  .init(osxKeyCode: OSX_VK_KEYPAD_7, rimeKeyCode: XK_KP_7),
  .init(osxKeyCode: OSX_VK_KEYPAD_8, rimeKeyCode: XK_KP_8),
  .init(osxKeyCode: OSX_VK_KEYPAD_9, rimeKeyCode: XK_KP_9),
  .init(osxKeyCode: OSX_VK_KEYPAD_COMMA, rimeKeyCode: XK_KP_Separator),
  .init(osxKeyCode: OSX_VK_KEYPAD_DOT, rimeKeyCode: XK_KP_Decimal),
  .init(osxKeyCode: OSX_VK_KEYPAD_EQUAL, rimeKeyCode: XK_KP_Equal),
  .init(osxKeyCode: OSX_VK_KEYPAD_MINUS, rimeKeyCode: XK_KP_Subtract),
  .init(osxKeyCode: OSX_VK_KEYPAD_MULTIPLY, rimeKeyCode: XK_KP_Multiply),
  .init(osxKeyCode: OSX_VK_KEYPAD_PLUS, rimeKeyCode: XK_KP_Add),
  .init(osxKeyCode: OSX_VK_KEYPAD_SLASH, rimeKeyCode: XK_KP_Divide),

  // MARK: pc keyboard

  .init(osxKeyCode: OSX_VK_PC_APPLICATION, rimeKeyCode: XK_Menu),
  .init(osxKeyCode: OSX_VK_PC_INSERT, rimeKeyCode: XK_Insert),
  .init(osxKeyCode: OSX_VK_PC_KEYPAD_NUMLOCK, rimeKeyCode: XK_Num_Lock),
  .init(osxKeyCode: OSX_VK_PC_PAUSE, rimeKeyCode: XK_Pause),
  .init(osxKeyCode: OSX_VK_PC_PRINTSCREEN, rimeKeyCode: XK_Print),
  .init(osxKeyCode: OSX_VK_PC_SCROLLLOCK, rimeKeyCode: XK_Scroll_Lock),

  .init(osxKeyCode: -1, rimeKeyCode: -1),
]

func osxModifiersToRimeModifiers(modifiers: Int32) -> Int32 {
  var ret: Int32 = 0

  if modifiers & OSX_CAPITAL_MASK > 0 {
    ret |= RimeModifier.kLockMask
  }
  if modifiers & OSX_SHIFT_MASK > 0 {
    ret |= RimeModifier.kShiftMask
  }
  if modifiers & OSX_CTRL_MASK > 0 {
    ret |= RimeModifier.kControlMask
  }
  if modifiers & OSX_ALT_MASK > 0 {
    ret |= RimeModifier.kAltMask
  }
  if modifiers & OSX_COMMAND_MASK > 0 {
    ret |= RimeModifier.kSuperMask
  }
  return ret
}

let lowercaseA: Int32 = .init(("a" as Character).asciiValue!)
let uppercaseA: Int32 = .init(("A" as Character).asciiValue!)
let lowercaseZ: Int32 = .init(("z" as Character).asciiValue!)

func osxKeycodeToRimeKeycode(keycode: Int32, keychar: Int32, shift: Int32, caps: Int32) -> Int32 {
  for mapping in keyCodeMappings {
    if keycode == mapping.osxKeyCode {
      return mapping.rimeKeyCode
    }
  }

  // NOTE: IBus/Rime use different keycodes for uppercase/lowercase letters.
  // 注意：IBus/Rime 对大写/小写字母使用不同的键码。
  if keychar >= lowercaseA && keychar <= lowercaseZ && ((shift > 0) != (caps > 0)) {
    // lowercase to uppercase
    return keychar - lowercaseA + uppercaseA
  }

  if keychar >= 0x20 && keychar <= 0x7e {
    return keychar
  }
  else if keychar == 0x1b { // ^[
    return XK_bracketleft
  }
  else if keychar == 0x1c { // ^\
    return XK_backslash
  }
  else if keychar == 0x1d { // ^]
    return XK_bracketright
  }
  else if keychar == 0x1f { // ^_
    return XK_minus
  }

  return XK_VoidSymbol
}
