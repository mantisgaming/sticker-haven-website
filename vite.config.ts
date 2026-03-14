import devtoolsJson from 'vite-plugin-devtools-json';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { cloudflare } from '@cloudflare/vite-plugin';

export default defineConfig(() => {
    const isLocalDevelopment = process.env.LOCAL_DEVELOPMENT === 'true';

    const plugins = [sveltekit(), devtoolsJson()];

    if (isLocalDevelopment) {
        plugins.push(
            ...cloudflare({
                viteEnvironment: {
                    name: 'staging'
                }
            })
        );
    }

    return { plugins };
});
