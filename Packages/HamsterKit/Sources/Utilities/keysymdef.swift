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
public let XK_Shift_L: Int32 = 0xffe1
/// Right shift
public let XK_Shift_R: Int32 = 0xffe2
/// Left control
public let XK_Control_L: Int32 = 0xffe3
/// Right control
public let XK_Control_R: Int32 = 0xffe4
/// Caps lock
public let XK_Caps_Lock: Int32 = 0xffe5
/// Shift lock
public let XK_Shift_Lock: Int32 = 0xffe6
/// Left meta
public let XK_Meta_L: Int32 = 0xffe7
/// Right meta
public let XK_Meta_R: Int32 = 0xffe8
/// Left alt
public let XK_Alt_L: Int32 = 0xffe9
/// Right alt
public let XK_Alt_R: Int32 = 0xffea
/// Left super
public let XK_Super_L: Int32 = 0xffeb
/// Right super
public let XK_Super_R: Int32 = 0xffec
/// Left hyper
public let XK_Hyper_L: Int32 = 0xffed
/// Right hyper
public let XK_Hyper_R: Int32 = 0xffee

// MARK: special

/// Back space, back char
public let XK_BackSpace: Int32 = 0xff08
/// Enter
public let XK_KP_Enter: Int32 = 0xff8d
public let XK_Escape: Int32 = 0xff1b
/// Delete, rubout
public let XK_Delete: Int32 = 0xffff
/// Return, enter
public let XK_Return: Int32 = 0xff0d
/// U+0020 SPACE
public let XK_space: Int32 = 0x0020
public let XK_Tab: Int32 = 0xff09

// MARK: number

public let XK_0: Int32 = 0x0030 /* U+0030 DIGIT ZERO */
public let XK_1: Int32 = 0x0031 /* U+0031 DIGIT ONE */
public let XK_2: Int32 = 0x0032 /* U+0032 DIGIT TWO */
public let XK_3: Int32 = 0x0033 /* U+0033 DIGIT THREE */
public let XK_4: Int32 = 0x0034 /* U+0034 DIGIT FOUR */
public let XK_5: Int32 = 0x0035 /* U+0035 DIGIT FIVE */
public let XK_6: Int32 = 0x0036 /* U+0036 DIGIT SIX */
public let XK_7: Int32 = 0x0037 /* U+0037 DIGIT SEVEN */
public let XK_8: Int32 = 0x0038 /* U+0038 DIGIT EIGHT */
public let XK_9: Int32 = 0x0039 /* U+0039 DIGIT NINE */

// MARK: Character

public let XK_A: Int32 = 0x0041 /* U+0041 LATIN CAPITAL LETTER A */
public let XK_B: Int32 = 0x0042 /* U+0042 LATIN CAPITAL LETTER B */
public let XK_C: Int32 = 0x0043 /* U+0043 LATIN CAPITAL LETTER C */
public let XK_D: Int32 = 0x0044 /* U+0044 LATIN CAPITAL LETTER D */
public let XK_E: Int32 = 0x0045 /* U+0045 LATIN CAPITAL LETTER E */
public let XK_F: Int32 = 0x0046 /* U+0046 LATIN CAPITAL LETTER F */
public let XK_G: Int32 = 0x0047 /* U+0047 LATIN CAPITAL LETTER G */
public let XK_H: Int32 = 0x0048 /* U+0048 LATIN CAPITAL LETTER H */
public let XK_I: Int32 = 0x0049 /* U+0049 LATIN CAPITAL LETTER I */
public let XK_J: Int32 = 0x004a /* U+004A LATIN CAPITAL LETTER J */
public let XK_K: Int32 = 0x004b /* U+004B LATIN CAPITAL LETTER K */
public let XK_L: Int32 = 0x004c /* U+004C LATIN CAPITAL LETTER L */
public let XK_M: Int32 = 0x004d /* U+004D LATIN CAPITAL LETTER M */
public let XK_N: Int32 = 0x004e /* U+004E LATIN CAPITAL LETTER N */
public let XK_O: Int32 = 0x004f /* U+004F LATIN CAPITAL LETTER O */
public let XK_P: Int32 = 0x0050 /* U+0050 LATIN CAPITAL LETTER P */
public let XK_Q: Int32 = 0x0051 /* U+0051 LATIN CAPITAL LETTER Q */
public let XK_R: Int32 = 0x0052 /* U+0052 LATIN CAPITAL LETTER R */
public let XK_S: Int32 = 0x0053 /* U+0053 LATIN CAPITAL LETTER S */
public let XK_T: Int32 = 0x0054 /* U+0054 LATIN CAPITAL LETTER T */
public let XK_U: Int32 = 0x0055 /* U+0055 LATIN CAPITAL LETTER U */
public let XK_V: Int32 = 0x0056 /* U+0056 LATIN CAPITAL LETTER V */
public let XK_W: Int32 = 0x0057 /* U+0057 LATIN CAPITAL LETTER W */
public let XK_X: Int32 = 0x0058 /* U+0058 LATIN CAPITAL LETTER X */
public let XK_Y: Int32 = 0x0059 /* U+0059 LATIN CAPITAL LETTER Y */
public let XK_Z: Int32 = 0x005a /* U+005A LATIN CAPITAL LETTER Z */
public let XK_a: Int32 = 0x0061 /* U+0061 LATIN SMALL LETTER A */
public let XK_b: Int32 = 0x0062 /* U+0062 LATIN SMALL LETTER B */
public let XK_c: Int32 = 0x0063 /* U+0063 LATIN SMALL LETTER C */
public let XK_d: Int32 = 0x0064 /* U+0064 LATIN SMALL LETTER D */
public let XK_e: Int32 = 0x0065 /* U+0065 LATIN SMALL LETTER E */
public let XK_f: Int32 = 0x0066 /* U+0066 LATIN SMALL LETTER F */
public let XK_g: Int32 = 0x0067 /* U+0067 LATIN SMALL LETTER G */
public let XK_h: Int32 = 0x0068 /* U+0068 LATIN SMALL LETTER H */
public let XK_i: Int32 = 0x0069 /* U+0069 LATIN SMALL LETTER I */
public let XK_j: Int32 = 0x006a /* U+006A LATIN SMALL LETTER J */
public let XK_k: Int32 = 0x006b /* U+006B LATIN SMALL LETTER K */
public let XK_l: Int32 = 0x006c /* U+006C LATIN SMALL LETTER L */
public let XK_m: Int32 = 0x006d /* U+006D LATIN SMALL LETTER M */
public let XK_n: Int32 = 0x006e /* U+006E LATIN SMALL LETTER N */
public let XK_o: Int32 = 0x006f /* U+006F LATIN SMALL LETTER O */
public let XK_p: Int32 = 0x0070 /* U+0070 LATIN SMALL LETTER P */
public let XK_q: Int32 = 0x0071 /* U+0071 LATIN SMALL LETTER Q */
public let XK_r: Int32 = 0x0072 /* U+0072 LATIN SMALL LETTER R */
public let XK_s: Int32 = 0x0073 /* U+0073 LATIN SMALL LETTER S */
public let XK_t: Int32 = 0x0074 /* U+0074 LATIN SMALL LETTER T */
public let XK_u: Int32 = 0x0075 /* U+0075 LATIN SMALL LETTER U */
public let XK_v: Int32 = 0x0076 /* U+0076 LATIN SMALL LETTER V */
public let XK_w: Int32 = 0x0077 /* U+0077 LATIN SMALL LETTER W */
public let XK_x: Int32 = 0x0078 /* U+0078 LATIN SMALL LETTER X */
public let XK_y: Int32 = 0x0079 /* U+0079 LATIN SMALL LETTER Y */
public let XK_z: Int32 = 0x007a /* U+007A LATIN SMALL LETTER Z */

// MARK: function

public let XK_F1: Int32 = 0xffbe
public let XK_F2: Int32 = 0xffbf
public let XK_F3: Int32 = 0xffc0
public let XK_F4: Int32 = 0xffc1
public let XK_F5: Int32 = 0xffc2
public let XK_F6: Int32 = 0xffc3
public let XK_F7: Int32 = 0xffc4
public let XK_F8: Int32 = 0xffc5
public let XK_F9: Int32 = 0xffc6
public let XK_F10: Int32 = 0xffc7
public let XK_F11: Int32 = 0xffc8
public let XK_F12: Int32 = 0xffc9
public let XK_F13: Int32 = 0xffca
public let XK_F14: Int32 = 0xffcb
public let XK_F15: Int32 = 0xffcc
public let XK_F16: Int32 = 0xffcd
public let XK_F17: Int32 = 0xffce
public let XK_F18: Int32 = 0xffcf
public let XK_F19: Int32 = 0xffd0

// MARK: Cursor control & motion

public let XK_Home: Int32 = 0xff50
/// Move left, left arrow
public let XK_Left: Int32 = 0xff51
/// Move up, up arrow
public let XK_Up: Int32 = 0xff52
/// Move right, right arrow
public let XK_Right: Int32 = 0xff53
/// Move down, down arrow
public let XK_Down: Int32 = 0xff54
/// Prior, previous
public let XK_Prior: Int32 = 0xff55
public let XK_Page_Up: Int32 = 0xff55
/// Next
public let XK_Next: Int32 = 0xff56
public let XK_Page_Down: Int32 = 0xff56
/// EOL
public let XK_End: Int32 = 0xff57
/// BOL
public let XK_Begin: Int32 = 0xff58

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

/// U+005B LEFT SQUARE BRACKET [
public let XK_bracketleft: Int32 = 0x005b
/// U+005C REVERSE SOLIDUS \
public let XK_backslash: Int32 = 0x005c
/// U+005D RIGHT SQUARE BRACKET ]
public let XK_bracketright: Int32 = 0x005d
/// U+002D HYPHEN-MINUS
public let XK_minus: Int32 = 0x002d
public let XK_equal: Int32 = 0x003
public let XK_comma: Int32 = 0x002c /* U+002C COMMA */
public let XK_period: Int32 = 0x002e /* U+002E FULL STOP */
public let XK_semicolon: Int32 = 0x003b /* U+003B SEMICOLON */
public let XK_grave: Int32 = 0x0060 /* U+0060 GRAVE ACCENT */
public let XK_apostrophe: Int32 = 0x0027 /* U+0027 APOSTROPHE */
