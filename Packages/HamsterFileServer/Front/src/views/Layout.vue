<template>
  <div>
    <div v-if="progress" class="progress">
      <div v-bind:style="{ width: this.progress + '%' }"></div>
    </div>
    <sidebar></sidebar>
    <main>
      <router-view></router-view>
      <!-- <shell v-if="isExecEnabled && isLogged && user.perm.execute" /> -->
    </main>
    <prompts></prompts>
    <!-- <upload-files></upload-files> -->
  </div>
</template>

<script>
import Sidebar from "@/components/Sidebar";
import Prompts from "@/components/prompts/Prompts";
import { mapGetters, mapState } from "vuex";
// import UploadFiles from "../components/prompts/UploadFiles";

export default {
  name: "layout",
  components: {
    Sidebar,
    Prompts,
    // UploadFiles,
  },
  computed: {
    ...mapGetters(["isLogged", "progress"]),
    ...mapState(["user"]),
  },
  watch: {
    $route: function () {
      this.$store.commit("resetSelected");
      this.$store.commit("multiple", false);
      if (this.$store.state.show !== "success")
        this.$store.commit("closeHovers");
    },
  },
};
</script>
