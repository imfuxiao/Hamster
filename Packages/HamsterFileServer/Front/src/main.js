import App from "@/App";
import i18n from "@/i18n";
import router from "@/router";
import store from "@/store";
import Vue from "@/utils/vue";
import cssVars from "css-vars-ponyfill";
import { sync } from "vuex-router-sync";
import "whatwg-fetch";

cssVars();

sync(store, router);

async function start() {
  // try {
  // if (loginPage) {
  // await validateLogin();
  // } else {
  // await login("", "", "");
  // }
  // } catch (e) {
  // console.log(e);
  // }

  // if (recaptcha) {
  //   await new Promise((resolve) => {
  //     const check = () => {
  //       if (typeof window.grecaptcha === "undefined") {
  //         setTimeout(check, 100);
  //       } else {
  //         resolve();
  //       }
  //     };

  //     check();
  //   });
  // }

  new Vue({
    render: (h) => h(App),
    store,
    router,
    i18n,
    template: "<App/>",
    components: { App },
  }).$mount("#app");
}

start();
