import Vue from "vue";
import VueI18n from "vue-i18n";

import en from "./en.json";
import zhCN from "./zh-cn.json";
import zhTW from "./zh-tw.json";

Vue.use(VueI18n);

export function detectLocale() {
  let locale = (navigator.language || navigator.browserLangugae).toLowerCase();
  switch (true) {
    case /^en.*/i.test(locale):
      locale = "en";
      break;
    case /^zh-CN/i.test(locale):
      locale = "zh-cn";
      break;
    case /^zh-TW/i.test(locale):
      locale = "zh-tw";
      break;
    case /^zh.*/i.test(locale):
      locale = "zh-cn";
      break;
    default:
      locale = "en";
  }

  return locale;
}

const removeEmpty = (obj) =>
  Object.keys(obj)
    .filter((k) => obj[k] !== null && obj[k] !== undefined && obj[k] !== "") // Remove undef. and null and empty.string.
    .reduce(
      (newObj, k) =>
        typeof obj[k] === "object"
          ? Object.assign(newObj, { [k]: removeEmpty(obj[k]) }) // Recurse.
          : Object.assign(newObj, { [k]: obj[k] }), // Copy value.
      {}
    );

export const rtlLanguages = ["he", "ar"];

const i18n = new VueI18n({
  locale: detectLocale(),
  fallbackLocale: "en",
  messages: {
    en: en,
    "zh-cn": removeEmpty(zhCN),
    "zh-tw": removeEmpty(zhTW),
  },
});

export default i18n;
