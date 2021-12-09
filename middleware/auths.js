export default async function ({ app, store, redirect }) {
    const cookieRes = app.$cookies.get('x-access-token');
    if (!store.state.auth.loggedIn && !cookieRes) {
        return redirect('/auth/login');
    }
    if (cookieRes) {
        try {
            let returns = await app.$axios.$get(`/users?token=${cookieRes}`);
            if (returns.error) {
                return redirect('/auth/login');
            }
        } catch (error) {
            this.$sentry.captureException(error);
            return redirect('/auth/login');
        }
    }
}