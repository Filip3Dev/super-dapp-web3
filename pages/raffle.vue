<template>
  <div class="text-center py-8">
    <v-row align="center">
      <v-col>
        <v-card class="pa-8" outlined :loading="loadingCard">
          <div>
            <div v-if="!web3.wallet">
              <div>
                <h1>
                  Para iniciar você deve conectar sua carteira.
                </h1>
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
              <v-row>
                <v-col cols="12" sm="12" md="12" lg="12" class="my-5">
                  <h1>
                    Blockchain Rifa
                  </h1>
                  <div>Ultima atualização</div> {{dateChange}}
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" sm="12" md="12" lg="12">
                  <div  v-if="last_winner.fullname">
                    <h2>
                      Último vençedor
                    </h2>
                    <v-card :color="'#'+randomColor(last_winner.block)" class="cardSpliter">
                      <ul>
                        <li>
                          Carteira
                        </li>
                        <li>
                          {{last_winner.wallet}}
                        </li>
                      </ul>
                      <ul>
                        <li>
                          Bloco
                        </li>
                        <li>
                          {{last_winner.block}}
                        </li>
                      </ul>
                      <ul>
                        <li>
                          Usuario
                        </li>
                        <li>
                          {{last_winner.fullname}}
                        </li>
                      </ul>
                    </v-card>
                  </div>
                </v-col>
                <v-col cols="12" sm="6" md="6" lg="6">
                  <div  v-if="last_ticket.fullname">
                    <h2>
                      Seu bilhete
                    </h2>
                    <v-card :color="'#'+randomColor(last_ticket.block)" class="cardSpliter">
                      <ul>
                        <li>
                          Bilhete
                        </li>
                        <li>
                          {{last_ticket.block}}
                        </li>
                      </ul>
                    </v-card>
                  </div>
                  <div v-else>
                    <div>
                      <h2>
                        Você não está participando do sorteio.
                      </h2>
                    </div>
                  </div>
                </v-col>
                <v-col cols="12" sm="6" md="6" lg="6">
                  <v-form ref="form" v-model="valid" lazy-validation>
                    <v-text-field label="Nome completo" :rules="nameRules" v-model="create.fullname" outlined></v-text-field>
                    <v-text-field label="E-mail" :rules="nameRules" v-model="create.email" outlined type="email"></v-text-field>
                    <v-btn
                      :disabled="!valid"
                      color="black"
                      class="mr-4"
                      x-large
                      @click="validate"
                      :loading="loadButton"
                    >
                      Registrar seu ponto na rifa
                    </v-btn>
                  </v-form>
                </v-col>
              </v-row>
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
<script>
import Web3 from 'web3';
import RaffleContract from '@/contracts/raffle'
import { mapState } from 'vuex';
export default {
  name: 'newhome',
  layout: 'web3provider',
  data() {
    return {
      valid: true,
      loadButton: false,
      loadingCard: false,
      web3z: null,
      last_winner: {
        email: '',
        fullname: '',
      },
      last_ticket: {
        email: '',
        fullname: '',
      },
      players: 0,
      create: {
        email: '',
        fullname: '',
      },
      text: '',
      dateChange: '',
      nameRules: [ v => !!v || 'Este campo é obrigatorio!' ],
    }
  },
  async mounted() {
    if (this.web3 && this.web3.contract_addr) {
      this.callInitial();
      this.loadingCard = true;
    }
  },
  methods: {
    async validate () {
      let validater = this.$refs.form.validate();
      if (validater) {
        if (this.last_ticket.block) {
          return alert('Você já está participando do sorteio!');
        }
        this.loadButton = true;
        try {
          const web3 = new Web3(window.web3.currentProvider);
          await RaffleContract.setProvider(web3.currentProvider);
          let data = await RaffleContract.deployed();
          const contract = await new web3.eth.Contract(data.abi, data.address);
          const accounts = await window.ethereum.request({ method: 'eth_accounts' });
          let { email, fullname } = this.create;
          await contract.methods.buyTicket(fullname, email).send({ from: accounts[0] });
          alert('Sorteio registrado na blockchain!');
          this.create = {
            email: '',
            fullname: '',
          }
          this.loadButton = false;
          this.callInitial();
        } catch (error) {
          console.warn(error);
          alert('Falha ao registrar no sorteio na blockchain!');
          this.loadButton = false;
        }
      }
    },
    async callInitial() {
      try {
        const web3 = new Web3(window.web3.currentProvider);
        await RaffleContract.setProvider(web3.currentProvider);
        let data = await RaffleContract.deployed();
        const contract = await new web3.eth.Contract(data.abi, data.address);
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        const { email, fullname, block, wallet } = await contract.methods.currentWinner().call();
        const dateChange = await contract.methods.dateChange().call();
        const lastTicket = await contract.methods.users(accounts[0]).call();
        this.last_winner = { email, fullname, block, wallet };
        this.last_ticket = lastTicket;
        this.dateChange = new Date(Number(`${dateChange}000`)).toLocaleString();
        const contract_sold_tickets = await contract.methods.size().call();
        this.players = contract_sold_tickets;
        this.loadingCard = false;
      } catch (error) {
        this.loadingCard = false;
        console.log('error: ', error);
      }
    },
    randomColor(color) {
      try {
        let rand = Math.floor(Math.random() * 99) + 1;
        let num = Number(color);
        let final = String(num * rand).substring(0,6);
        return final
      } catch (error) {
        console.log(error);
        return color;
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
.cardSpliter{
  padding: 16px;
}
.cardSpliter ul{
  list-style: none;
  display: flex;
  margin: 0px;
  padding: 0px;
  align-items: center;
  width: 100%;
}
.cardSpliter ul li{
  width: 100%;
}
</style>