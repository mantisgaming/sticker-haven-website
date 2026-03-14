import type { PageLoad } from './$types';

export const load: PageLoad = () => {
    return {
        seo: {
            title: 'Sticker Haven | Custom Stickers',
            description:
                'Order affordable custom die-cut and kiss-cut stickers with fast turnaround, proofing support, and US shipping.',
            image: '/img/Banner.png',
            type: 'website',
            jsonLd: {
                '@context': 'https://schema.org',
                '@type': 'WebPage',
                name: 'Sticker Haven Home',
                description:
                    'Custom sticker printing for artists, student organizations, and small businesses with low minimums.',
                url: 'https://www.stickerhaven.shop/'
            }
        }
    };
};
