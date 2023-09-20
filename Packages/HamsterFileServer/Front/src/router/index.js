import i18n, { rtlLanguages } from "@/i18n";
import store from "@/store";
import { baseURL, name } from "@/utils/constants";
import Errors from "@/views/Errors";
import Files from "@/views/Files";
import Layout from "@/views/Layout";
import Login from "@/views/Login";
import Vue from "vue";
import Router from "vue-router";

Vue.use(Router);

const titles = {
  Login: "sidebar.login",
  Share: "buttons.share",
  Files: "files.files",
  Settings: "sidebar.settings",
  ProfileSettings: "settings.profileSettings",
  Shares: "settings.shareManagement",
  GlobalSettings: "settings.globalSettings",
  Users: "settings.users",
  User: "settings.user",
  Forbidden: "errors.forbidden",
  NotFound: "errors.notFound",
  InternalServerError: "errors.internal",
};

const router = new Router({
  base: baseURL,
  mode: "history",
  routes: [
    {
      path: "/login",
      name: "Login",
      component: Login,
      beforeEnter: (to, from, next) => {
        if (store.getters.isLogged) {
          return next({ path: "/files" });
        }

        next();
      },
    },
    {
      path: "/*",
      component: Layout,
      children: [
        // {
        //   path: "/share/*",
        //   name: "Share",
        //   component: Share,
        // },
        {
          path: "/files/*",
          name: "Files",
          component: Files,
          meta: {
            requiresAuth: false,
          },
        },
        {
          path: "/403",
          name: "Forbidden",
          component: Errors,
          props: {
            errorCode: 403,
            showHeader: true,
          },
        },
        {
          path: "/404",
          name: "NotFound",
          component: Errors,
          props: {
            errorCode: 404,
            showHeader: true,
          },
        },
        {
          path: "/500",
          name: "InternalServerError",
          component: Errors,
          props: {
            errorCode: 500,
            showHeader: true,
          },
        },
        {
          path: "/files",
          redirect: {
            path: "/files/",
          },
        },
        {
          path: "/*",
          redirect: (to) => `/files${to.path}`,
        },
      ],
    },
  ],
});

router.beforeEach((to, from, next) => {
  const title = i18n.t(titles[to.name]);
  document.title = title + " - " + name;

  /*** RTL related settings per route ****/
  const rtlSet = document.querySelector("body").classList.contains("rtl");
  const shouldSetRtl = rtlLanguages.includes(i18n.locale);
  switch (true) {
    case shouldSetRtl && !rtlSet:
      document.querySelector("body").classList.add("rtl");
      break;
    case !shouldSetRtl && rtlSet:
      document.querySelector("body").classList.remove("rtl");
      break;
  }

  // if (to.matched.some((record) => record.meta.requiresAuth)) {
  //   if (!store.getters.isLogged) {
  //     next({
  //       path: "/login",
  //       query: { redirect: to.fullPath },
  //     });

  //     return;
  //   }

  //   if (to.matched.some((record) => record.meta.requiresAdmin)) {
  //     if (!store.state.user.perm.admin) {
  //       next({ path: "/403" });
  //       return;
  //     }
  //   }
  // }

  next();
});

export default router;
