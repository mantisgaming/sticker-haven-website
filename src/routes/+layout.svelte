<script lang="ts">
    import { page } from '$app/state';
    import '../layout.scss';
    import Header from '../Collections/Header.svelte';
    import Footer from '../Collections/Footer.svelte';
    import Announcements from '../Collections/Announcements.svelte';
    import AnnouncementBanner from '../Components/AnnouncementBanner.svelte';

    type JsonLdEntry = Record<string, unknown>;

    type SeoData = {
        title?: string;
        description?: string;
        image?: string;
        type?: string;
        canonical?: string;
        jsonLd?: JsonLdEntry | JsonLdEntry[];
    };

    let { children, data } = $props<{ children: () => unknown; data?: { seo?: SeoData } }>();

    const siteName = 'Sticker Haven';
    const siteUrl = 'https://www.stickerhaven.shop';
    const defaultDescription =
        'Affordable custom die-cut and kiss-cut stickers for artists, students, and small businesses.';
    const defaultImage = '/img/Banner.png';

    const toAbsoluteUrl = (value: string): string => {
        if (value.startsWith('http://') || value.startsWith('https://')) {
            return value;
        }

        return `${siteUrl}${value.startsWith('/') ? value : `/${value}`}`;
    };

    const toJsonLdArray = (value?: JsonLdEntry | JsonLdEntry[]): JsonLdEntry[] => {
        if (!value) {
            return [];
        }

        return Array.isArray(value) ? value : [value];
    };

    const seo = $derived(data?.seo ?? {});
    const pathname = $derived(
        page.url.pathname === '/' ? '/' : page.url.pathname.replace(/\/+$/, '')
    );
    const canonicalUrl = $derived(seo.canonical ?? `${siteUrl}${pathname}`);
    const title = $derived(seo.title ?? siteName);
    const description = $derived(seo.description ?? defaultDescription);
    const pageType = $derived(seo.type ?? 'website');
    const imageUrl = $derived(toAbsoluteUrl(seo.image ?? defaultImage));

    const defaultJsonLd = $derived<JsonLdEntry[]>([
        {
            '@context': 'https://schema.org',
            '@type': 'WebSite',
            name: siteName,
            url: siteUrl
        },
        {
            '@context': 'https://schema.org',
            '@type': 'LocalBusiness',
            name: siteName,
            url: siteUrl,
            description,
            email: 'contact@stickerhaven.shop',
            image: imageUrl,
            serviceArea: 'United States',
            sameAs: ['https://share.google/lgxR1onu38l5pBhd4']
        }
    ]);

    const jsonLdEntries = $derived([...defaultJsonLd, ...toJsonLdArray(seo.jsonLd)]);
    const jsonLdPayloads = $derived(
        jsonLdEntries.map((entry) => JSON.stringify(entry).replace(/</g, '\\u003c'))
    );

    const announcements: [string, string][] = [
        [
            'Holographic stickers now available! - 50ct of 2"x2" laminated holographic stickers for only $32.03',
            'Store announcement'
        ]
    ];
</script>

<svelte:head>
    <title>{title}</title>
    <link rel="canonical" href={canonicalUrl} />
    <meta name="theme-color" content="#09909F" />
    <meta name="description" content={description} />
    <meta property="og:type" content={pageType} />
    <meta property="og:site_name" content={siteName} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:image" content={imageUrl} />
    <meta property="og:url" content={canonicalUrl} />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={title} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={imageUrl} />
    {#each jsonLdPayloads as payload, index (`jsonld-${index}`)}
        <svelte:element this={'script'} type="application/ld+json">{payload}</svelte:element>
    {/each}
</svelte:head>

<Header />

{#if announcements.length > 0}
    <Announcements>
        {#each announcements as [message, ariaLabel] (message)}
            <AnnouncementBanner {message} {ariaLabel} />
        {/each}
    </Announcements>
{/if}

{@render children()}
<Footer />
