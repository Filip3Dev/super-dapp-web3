<template>
  <div class="text-center py-8">
    <v-row align="center">
      <v-col>
        <v-card class="pa-8" outlined  :loading="loadingCard">
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
              <div>
                <h1>
                  Blockchain NFT
                </h1>
                <div><br></div>
              </div>
              <div>

                <v-tabs v-model="tab" background-color="cyan" slider-color="white" grow>
                  <v-tab href="#tab-1" class="white--text">
                    Criar novo NFT
                  </v-tab>

                  <v-tab href="#tab-2" color="white" class="white--text">
                    Seus NFTs
                  </v-tab>
                </v-tabs>

                <v-tabs-items v-model="tab">
                  <v-tab-item value="tab-1">
                    <v-card elevation="5" class="ma-1 pa-5">
                      <v-form ref="form" v-model="valid" lazy-validation>
                        <v-text-field
                          label="Qual nome quer dar pra o seu NFT?"
                          :rules="nameRules"
                          v-model="create.name"
                          outlined
                        ></v-text-field>
                        <v-text-field
                          v-model="create.description"
                          :rules="descriptionRules"
                          label="Seu NFT precisa de uma descrição"
                          outlined
                          required
                        ></v-text-field>
                        <v-text-field
                          label="Selecione uma cor de fundo para o NFT"
                          v-model="create.background_color"
                          outlined
                          type="color"
                          class="coloredPick"
                        ></v-text-field>
                        <v-col cols="12">
                          <p>
                            <b>
                            Selecione a imagem do seu NFT
                            </b>
                          </p>
                        </v-col>
                        <v-row class="galleryImages">
                          <v-col v-for="(item, i) in images" :key="i" cols="2">
                            <v-img
                              :src="item.url"
                              :lazy-src="`https://picsum.photos/10/6?image=${i + 1}`"
                              aspect-ratio="1"
                              @click="selectImage(item)"
                              :class="{ imageSelect: item.inUse }"
                            >
                              <template v-slot:placeholder>
                                <v-row
                                  class="fill-height ma-0"
                                  align="center"
                                  justify="center"
                                >
                                  <v-progress-circular
                                    indeterminate
                                    color="grey lighten-5"
                                  ></v-progress-circular>
                                </v-row>
                              </template>
                            </v-img>
                          </v-col>
                        </v-row>
                        <v-col cols="12"><p><br></p></v-col>
                        <v-btn
                          :disabled="!valid"
                          color="purple"
                          class="mr-4"
                          x-large
                          @click="validate"
                          :loading="loadButton"
                        >
                          Registrar o seu NFT
                        </v-btn>
                      </v-form>
                    </v-card>
                  </v-tab-item>
                  <v-tab-item value="tab-2">
                    <v-card elevation="5" class="ma-1 pa-5">
                      <v-row v-if="nfts.length">
                        <v-col
                          v-for="n in nfts"
                          :key="n._id"
                          class="d-flex child-flex"
                          cols="3"
                        >
                          <v-img
                            :src="n.image_data.url"
                            lazy-src="https://picsum.photos/10/6?image=33"
                            aspect-ratio="1"
                            class="grey lighten-2 supremaClass"
                          >
                            <template v-slot:placeholder>
                              <v-row
                                class="fill-height ma-0"
                                align="center"
                                justify="center"
                              >
                                <v-progress-circular
                                  indeterminate
                                  color="grey lighten-5"
                                ></v-progress-circular>
                              </v-row>
                            </template>
                            <div class="supremaDiv" :style="'background-color: '+n.background_color">
                              <p>
                                Nome: {{n.name}}
                              </p>
                              <p>
                                Descrição: {{n.description}}
                              </p>
                              <ul>
                                <li v-for="(item, i) in n.attributes" :key="i">
                                  {{item.trait_type}} - {{item.value}}
                                </li>
                              </ul>
                            </div>
                          </v-img>
                        </v-col>
                      </v-row>
                      <v-row v-else>
                        <v-col cols="12">
                          <h2>
                            Você não tem nenhum NFT registrado nessa wallet
                          </h2>
                        </v-col>
                      </v-row>
                    </v-card>
                  </v-tab-item>
                </v-tabs-items>

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
import NFTContract from '@/contracts/nft'
import { mapState } from 'vuex';
export default {
  name: 'newhome',
  layout: 'web3provider',
  data() {
    return {
      tab: null,
      valid: true,
      loadButton: false,
      loadingCard: false,
      images: [],
      nfts: [],
      create: {
        name: '',
        description: '',
        background_color: '',
        image_data: '',
        creator: '',
      },
      nameRules: [ v => !!v || 'Nome é obrigatorio!' ],
      descriptionRules: [ v => !!v || 'Descrição é obrigatoria!' ],
    }
  },
  async mounted() {
    if (this.web3 && this.web3.contract_addr) {
      this.loadingCard = true;
      this.callInitial();
    }
  },
  methods: {
    async validate () {
      let validater = this.$refs.form.validate();
      if (validater) {
        if (this.create.background_color == '') {
          alert('Você precisa selecionar uma cor!');
          return 0;
        }
        if (this.create.image_data == '') {
          alert('Você precisa selecionar uma imagem!');
          return 0;
        }
        this.loadButton = true;
        try {
          const accounts = await window.ethereum.request({ method: 'eth_accounts' });
          this.create.creator = accounts[0];
          let { name, description, background_color, image_data, creator } = this.create;
          const user_info = await this.$api.$get('https://ipinfo.io?token=7094a7628d0295');
          let returner = await this.$api.$post('/nft', { payload: {name, description, background_color, image_data, creator }, user_info } );
          let getNft = await this.$api.get(`/getNft?creator=${returner.data._id}`);
          const web3 = new Web3(window.web3.currentProvider);
          await NFTContract.setProvider(web3.currentProvider);
          let data = await NFTContract.deployed();
          const contract = await new web3.eth.Contract(data.abi, data.address);
          await contract.methods.safeMint(accounts[0], getNft.request.responseURL).send({ from: accounts[0] });
          this.loadButton = false;
          this.create = { name: '', description: '', background_color: '', image_data: '', creator: ''};
          alert('NFT registrado na blockchain!');
          this.callInitial();
        } catch (error) {
          console.warn(error);
          this.loadButton = false;
        }
      }
    },
    async callInitial() {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        let nfts = await this.$api.get(`/listNfts?creator=${accounts[0]}`);
        nfts = nfts.data;
        let images = await this.$api.get('/images');
        this.images = images.data.data;
        this.nfts = nfts.tokens;
        this.loadingCard = false;
      } catch (error) {
        this.loadingCard = false;
        console.log('error: ', error);
      }
    },
    async selectImage(item) {
      let newItens = this.images.map( elem => {
        elem.inUse = false;
        return elem;
      }); 
      this.images = newItens;
      item.inUse = !item.inUse;
      this.create.image_data = item._id;
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
.coloredPick input{
  height: 70px;
  max-height: 70px;
}
.galleryImages{
  max-height: 450px;
  overflow-y: scroll;
}
.imageSelect{
  border: 8px solid #19e719 !important;
  border-radius: 8px;
}
.supremaClass .supremaDiv{
  height: 0%;
  background: rgba(0, 0, 0, 0);
  overflow: hidden;
  transition: all 0.7s ease-out;
}
.supremaClass:hover .supremaDiv{
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  transition: all 0.2s ease-in;
}
</style>