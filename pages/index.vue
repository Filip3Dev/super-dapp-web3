<template>
  <div class="text-center py-8 full-heig">
    <v-row align="center">
      <v-col>
        <v-card class="pa-8" outlined>
          <div>
            <div v-if="!web3.wallet">
              <div>
                <h1>
                  Para iniciar você deve conectar sua carteira.
                </h1>
                <br>
                <h2>
                  Essa plataforma roda na rede de teste da <b>Binace Smart Chain</b>
                </h2>
                <br>
                <h3>
                  Você precisa ter a extensão
                  <a href="https://metamask.io/" target="_blank" rel="noopener noreferrer">
                    MetaMask
                  </a>
                  instalada no navegador.
                </h3>
              </div>
            </div>
            <div v-else>
              <div>
                <h1>
                  Blockchain Registros
                </h1>
                <div>
                  <div>Ultima atualização</div>{{textChanger}}
                </div>
                <v-textarea v-model="textRead" :readonly="true" outlined style="cursor: default;"></v-textarea>
              </div>
              <div>
                <v-form ref="form" v-model="valid" lazy-validation>
                  <v-text-field v-model="text" outlined label="Texto" :rules="nameRules" required></v-text-field>

                  <v-btn
                    :disabled="!valid"
                    color="black"
                    class="mr-4"
                    x-large
                    @click="validate"
                    :loading="loadButton"
                  >
                    Registrar o texto
                  </v-btn>
                </v-form>
              </div>
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
<script>
import Web3 from 'web3';
import SaverContract from '@/contracts/saver.js'
import { mapState } from 'vuex';
export default {
  name: 'newhome',
  layout: 'web3provider',
  data() {
    return {
      valid: true,
      loadButton: false,
      web3z: null,
      text: '',
      textRead: '',
      textChanger: '',
      nameRules: [ v => !!v || 'Texto é obrigatorio!' ],
    }
  },
  async mounted() {
    if (this.web3 && this.web3.contract_addr) {
      this.callInitial();
    }
  },
  methods: {
    async validate () {
      let validater = this.$refs.form.validate();
      if (validater) {
        this.loadButton = true;
        try {
          const web3 = new Web3(window.web3.currentProvider);
          await SaverContract.setProvider(web3.currentProvider);
          let data = await SaverContract.deployed();
          const contract = await new web3.eth.Contract(data.abi, data.address);
          const accounts = await window.ethereum.request({ method: 'eth_accounts' });
          await contract.methods.setText(this.text).send({ from: accounts[0] });
          alert('Texto registrado na blockchain!');
          this.loadButton = false;
          this.callInitial();
        } catch (error) {
          console.warn(error);
          alert('Falha ao registrar o texto na blockchain!');
          this.loadButton = false;
        }
      }
    },
    async callInitial() {
      this.text = '';
      try {
        const web3 = new Web3(window.web3.currentProvider);
        await SaverContract.setProvider(web3.currentProvider);
        let data = await SaverContract.deployed();
        const contract = await new web3.eth.Contract(data.abi, data.address);
        const contract_txt = await contract.methods.text().call();
        const contract_date = await contract.methods.dateChange().call();
        this.textRead = contract_txt;
        this.textChanger = new Date(Number(`${contract_date}000`)).toLocaleString();
      } catch (error) {
        console.log('error: ', error);
      }
    }
  },
  computed: {
    ...mapState([
      'web3'
    ]),
  },
  watch: {
    web3 (newCount, oldCount) {
      this.callInitial();
    }
  }
}
</script>
<style>
.full-heig{
  height: 70vh;
}
</style>