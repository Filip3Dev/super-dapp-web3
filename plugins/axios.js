export default function ({ $axios, error: nuxtError, redirect }, inject) {
    const api = $axios.create({
        baseURL: 'https://dapp-api.netlify.app/.netlify/functions',
        // baseURL: 'http://localhost:8888/.netlify/functions',
        timeout: 50000
    });

    $axios.onRequest(config => {
        console.log('Making request to ' + config.url)
    });

    $axios.onError(error => {
        console.log('$axios.onError: ', error);
    });

    $axios.onRequestError(error => {
        console.log('$axios.onRequestError: ', error);
    });

    inject('api', api);
}