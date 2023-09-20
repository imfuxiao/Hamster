<template>
  <nav :class="{ active }">
    <template>
      <button
        class="action"
        @click="toRoot"
        :aria-label="$t('sidebar.myFiles')"
        :title="$t('sidebar.myFiles')"
      >
        <i class="material-icons">folder</i>
        <!-- <span>{{ $t("sidebar.myFiles") }}</span> -->
        <span>根目录</span>
      </button>

      <div>
        <button
          @click="$store.commit('showHover', 'newDir')"
          class="action"
          :aria-label="$t('sidebar.newFolder')"
          :title="$t('sidebar.newFolder')"
        >
          <i class="material-icons">create_new_folder</i>
          <span>{{ $t("sidebar.newFolder") }}</span>
        </button>

        <!-- <button
          @click="$store.commit('showHover', 'newFile')"
          class="action"
          :aria-label="$t('sidebar.newFile')"
          :title="$t('sidebar.newFile')"
        >
          <i class="material-icons">note_add</i>
          <span>{{ $t("sidebar.newFile") }}</span>
        </button> -->
      </div>
    </template>

    <div
      class="credits"
      v-if="$router.currentRoute.path.includes('/files/')"
      style="width: 90%; margin: 2em 2.5em 3em 2.5em"
    >
      <progress-bar :val="usage.usedPercentage" size="small"></progress-bar>
      <br />
      {{ usage.used }} of {{ usage.total }} used
    </div>
  </nav>
</template>

<script>
import { files as api } from "@/api";
import {
disableExternal,
loginPage,
noAuth,
signup,
version,
} from "@/utils/constants";
import prettyBytes from "pretty-bytes";
import ProgressBar from "vue-simple-progress";
import { mapState } from "vuex";

export default {
  name: "sidebar",
  components: {
    ProgressBar,
  },
  computed: {
    ...mapState(["user"]),
    active() {
      return this.$store.state.show === "sidebar";
    },
    signup: () => signup,
    version: () => version,
    disableExternal: () => disableExternal,
    canLogout: () => !noAuth && loginPage,
  },
  asyncComputed: {
    usage: {
      async get() {
        let path = this.$route.path.endsWith("/")
          ? this.$route.path
          : this.$route.path + "/";
        let usageStats = { used: 0, total: 0, usedPercentage: 0 };
        try {
          let usage = await api.usage(path);
          usageStats = {
            used: prettyBytes(usage.used, { binary: true }),
            total: prettyBytes(usage.total, { binary: true }),
            usedPercentage: Math.round((usage.used / usage.total) * 100),
          };
        } catch (error) {
          this.$showError(error);
        }
        return usageStats;
      },
      default: { used: "0 B", total: "0 B", usedPercentage: 0 },
      shouldUpdate() {
        return this.$router.currentRoute.path.includes("/files/");
      },
    },
  },
  methods: {
    toRoot() {
      this.$router.push({ path: "/files/" }, () => {});
      this.$store.commit("closeHovers");
    },
    toSettings() {
      this.$router.push({ path: "/settings" }, () => {});
      this.$store.commit("closeHovers");
    },
    help() {
      this.$store.commit("showHover", "help");
    },
  },
};
</script>
