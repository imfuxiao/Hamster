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
let XK_VoidSymbol: Int32 = 0xffffff

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
let XK_BackSpace: Int32 = 0xff08
/// Enter
let XK_KP_Enter: Int32 = 0xff8d
let XK_Escape: Int32 = 0xff1b
/// Delete, rubout
let XK_Delete: Int32 = 0xffff
/// Return, enter
let XK_Return: Int32 = 0xff0d
/// U+0020 SPACE
let XK_Tab: Int32 = 0xff09
let XK_Eisu_toggle: Int32 = 0xff30

// Mark: function

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

// Mark: Cursor control & motion

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

// Mark: keypad
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
let XK_Clear: Int32 = 0xff0b
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

// Mark: pc keyboard

let XK_Menu: Int32 = 0xff67
/// Insert, insert here
let XK_Insert: Int32 = 0xff63
let XK_Num_Lock: Int32 = 0xff7f
/// Pause, hold
let XK_Pause: Int32 = 0xff13
let XK_Print: Int32 = 0xff61
let XK_Scroll_Lock: Int32 = 0xff14

// ASCII
let XK_space: Int32 = 0x0020
let XK_exclam: Int32 = 0x0021
let XK_quotedbl: Int32 = 0x0022
let XK_numbersign: Int32 = 0x0023
let XK_dollar: Int32 = 0x0024
let XK_percent: Int32 = 0x0025
let XK_ampersand: Int32 = 0x0026
let XK_apostrophe: Int32 = 0x0027
let XK_quoteright: Int32 = 0x0027
let XK_parenleft: Int32 = 0x0028
let XK_parenright: Int32 = 0x0029
let XK_asterisk: Int32 = 0x002a
let XK_plus: Int32 = 0x002b
let XK_comma: Int32 = 0x002c
let XK_minus: Int32 = 0x002d
let XK_period: Int32 = 0x002e
let XK_slash: Int32 = 0x002f
let XK_0: Int32 = 0x0030
let XK_1: Int32 = 0x0031
let XK_2: Int32 = 0x0032
let XK_3: Int32 = 0x0033
let XK_4: Int32 = 0x0034
let XK_5: Int32 = 0x0035
let XK_6: Int32 = 0x0036
let XK_7: Int32 = 0x0037
let XK_8: Int32 = 0x0038
let XK_9: Int32 = 0x0039
let XK_colon: Int32 = 0x003a
let XK_semicolon: Int32 = 0x003b
let XK_less: Int32 = 0x003c
let XK_equal: Int32 = 0x003d
let XK_greater: Int32 = 0x003e
let XK_question: Int32 = 0x003f
let XK_at: Int32 = 0x0040
let XK_A: Int32 = 0x0041
let XK_B: Int32 = 0x0042
let XK_C: Int32 = 0x0043
let XK_D: Int32 = 0x0044
let XK_E: Int32 = 0x0045
let XK_F: Int32 = 0x0046
let XK_G: Int32 = 0x0047
let XK_H: Int32 = 0x0048
let XK_I: Int32 = 0x0049
let XK_J: Int32 = 0x004a
let XK_K: Int32 = 0x004b
let XK_L: Int32 = 0x004c
let XK_M: Int32 = 0x004d
let XK_N: Int32 = 0x004e
let XK_O: Int32 = 0x004f
let XK_P: Int32 = 0x0050
let XK_Q: Int32 = 0x0051
let XK_R: Int32 = 0x0052
let XK_S: Int32 = 0x0053
let XK_T: Int32 = 0x0054
let XK_U: Int32 = 0x0055
let XK_V: Int32 = 0x0056
let XK_W: Int32 = 0x0057
let XK_X: Int32 = 0x0058
let XK_Y: Int32 = 0x0059
let XK_Z: Int32 = 0x005a
let XK_bracketleft: Int32 = 0x005b
let XK_backslash: Int32 = 0x005c
let XK_bracketright: Int32 = 0x005d
let XK_asciicircum: Int32 = 0x005e
let XK_underscore: Int32 = 0x005f
let XK_grave: Int32 = 0x0060
let XK_quoteleft: Int32 = 0x0060
let XK_a: Int32 = 0x0061
let XK_b: Int32 = 0x0062
let XK_c: Int32 = 0x0063
let XK_d: Int32 = 0x0064
let XK_e: Int32 = 0x0065
let XK_f: Int32 = 0x0066
let XK_g: Int32 = 0x0067
let XK_h: Int32 = 0x0068
let XK_i: Int32 = 0x0069
let XK_j: Int32 = 0x006a
let XK_k: Int32 = 0x006b
let XK_l: Int32 = 0x006c
let XK_m: Int32 = 0x006d
let XK_n: Int32 = 0x006e
let XK_o: Int32 = 0x006f
let XK_p: Int32 = 0x0070
let XK_q: Int32 = 0x0071
let XK_r: Int32 = 0x0072
let XK_s: Int32 = 0x0073
let XK_t: Int32 = 0x0074
let XK_u: Int32 = 0x0075
let XK_v: Int32 = 0x0076
let XK_w: Int32 = 0x0077
let XK_x: Int32 = 0x0078
let XK_y: Int32 = 0x0079
let XK_z: Int32 = 0x007a
let XK_braceleft: Int32 = 0x007b
let XK_bar: Int32 = 0x007c
let XK_braceright: Int32 = 0x007d
let XK_asciitilde: Int32 = 0x007e
