export default function ({ $axios, error: nuxtError, redirect }, inject) {
    const api = $axios.create({
        baseURL: 'https://google.com',
        timeout: 50000
    });

    $axios.onRequest(config => {
        console.log('Making request to ' + config.url)
    });

    $axios.onError(error => {
        const code = parseInt(error.response && error.response.status)
        if (code === 400) { redirect('/') }
        nuxtError({ statusCode: error.response.status, message: error.message });
        return Promise.resolve(false);
    });

    inject('api', api);
}