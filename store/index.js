
export const state = () => ({
  raffles: null,
  web3: {
    isInjected: false,
    web3Instance: null,
    networkId: null,
    coinbase: null,
    balance: null,
    wallet: null,
    contract: null,
    error: null
  },
  contractInstance: null
})

export const mutations = {
  addRaffles(state, payload) {
    state.raffles = payload;
  },
  addWeb3(state, payload) {
    state.web3 = payload;
  },
  addUser(state, payload) {
    state.auth.user = payload;
    state.auth.loggedIn = true;
  },
}