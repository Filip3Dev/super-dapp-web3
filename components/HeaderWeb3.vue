<template>
  <v-app-bar app color="grey darken-2">
    <v-container class="py-0 fill-height">
      <h2>
        Super DAPP
      </h2>
      <v-spacer></v-spacer>
      <div>
        <v-btn color="cyan" to="/raffle" class="mr-2">
          Blockchain Rifa
        </v-btn>
        <v-btn color="cyan" to="/" class="mr-2">
          Blockchain Registro
        </v-btn>
        <v-btn color="cyan" to="/nft" class="mr-2">
          Blockchain NFT
        </v-btn>
        <v-btn rounded color="teal" v-if="!web3.wallet" @click="syncAccount">
          Conectar carteira
        </v-btn>
        <v-btn rounded small color="primary" dark v-else>
          {{ splitedWallet(web3.wallet) }}
        </v-btn>
      </div>
    </v-container>
  </v-app-bar>
</template>
<script>
import Web3 from 'web3';
import { mapState, mapMutations } from 'vuex';
import SaverContract from '@/contracts/saver.js';
export default {
  methods: {
    ...mapMutations([
      'addWeb3'
    ]),
    async syncAccount() {
      const isMetaMaskInstalled = () => {
        const { ethereum } = window;
        return Boolean(ethereum && ethereum.isMetaMask);
      };
      setTimeout( async () => {
        try {
          if (!window.web3 || !isMetaMaskInstalled) {
            alert('MetaMask not instaled on the browser!');
            return;
          }
          const web3 = new Web3(window.web3.currentProvider);
          const permissions = await window.ethereum.request({
            method: 'wallet_requestPermissions',
            params: [{ eth_accounts: {} }],
          })
          const accountsPermission = permissions.find(
            (permission) => permission.parentCapability === 'eth_accounts'
          );
          if (accountsPermission) {
            console.log('eth_accounts permission successfully requested!');
          }

          const accounts = await window.ethereum.request({ method: 'eth_accounts' });
          let wei = await web3.eth.getBalance(accounts[0]);
          let balance = await web3.utils.fromWei(wei, 'ether');
          let network2 = await web3.eth.net.getId();
          if (network2 !== 97) {
            alert('Você não está na rede correta!');
            this.changeNetwork();
            return 0;
          }
          await SaverContract.setProvider(web3.currentProvider);
          let { abi, address } = await SaverContract.deployed();
          let payload = {
            wallet: accounts[0],
            balance,
            networkId: network2,
            contract_abi: abi,
            contract_addr: address,
          };
          this.addWeb3(payload);
        } catch (error) {
          console.log('syncAccount error: ');
        }
      }, 2000);
    },
    async changeNetwork() {
      try {
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x61' }],
        });
        this.syncAccount();
      } catch (error) {
        try {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [
              {
                chainId: '0x61',
                chainName: 'Smart Chain - Testnet',
                nativeCurrency: {
                  name: 'Binance',
                  symbol: 'BNB',
                  decimals: 18
                },
                blockExplorerUrls: ['https://testnet.bscscan.com'],
                rpcUrls: ['https://data-seed-prebsc-1-s1.binance.org:8545/'],
              },
            ],
          });
        } catch (addError) {
          console.error('addError: ', addError);
        }
      }
    },
    splitedWallet(value) {
      try {
        let spliter = value.match(/\S{1,6}/g);
        return `${spliter[0]}...${spliter[spliter.length - 1]}`;
      } catch (error) {
        return value;
      }
    }
  },
  computed: {
    ...mapState([
      'web3'
    ])
  }
}
</script>
<style>
</style>
