<script lang="ts">
	import '../layout.scss';
	import logo from '$lib/assets/favicon-228.png';
	import Header from '../Collections/Header.svelte';
	import Footer from '../Collections/Footer.svelte';
	import Announcements from '../Collections/Announcements.svelte';
	import AnnouncementBanner from '../Components/AnnouncementBanner.svelte';

	let { children } = $props();

	const announcements: [string, string][] = [
		[
			'Holographic stickers now available! - 50ct of 2"x2" holographic stickers for only $25.86',
			'Store announcement'
		]
	];
</script>

<svelte:head>
	<title>Sticker Haven</title>
	<link rel="icon" href={logo} />
	<meta name="theme-color" content="#09909F" />
	<meta name="description" content="High-quality, cheap die cut stickers online!" />
	<meta property="og:title" content="Sticker Haven" />
	<meta property="og:description" content="High-quality, cheap die cut stickers online!" />
	<meta property="og:image" content={logo} />
	<meta property="og:url" content="https://www.stickerhaven.shop/" />
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
