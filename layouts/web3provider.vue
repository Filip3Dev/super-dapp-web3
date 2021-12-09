<template>
  <v-app dark>
    <HeaderWeb3 />
    <v-main>
      <v-container>
        <Nuxt />
      </v-container>
    </v-main>
    <v-footer absolute app>
      <span>
        Todos os direitos reservados | 2019 - 2021
      </span>
      <v-spacer></v-spacer>
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
  </v-app>
</template>
<script>
export default {
  layout: 'web3provider',
  data() {
    return {
      status: ''
    }
  },
  async created() {
  },
  methods: {}
}
</script>
