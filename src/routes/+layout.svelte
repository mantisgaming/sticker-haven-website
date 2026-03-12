<script lang="ts">
	import './layout.scss';
	import logo from '$lib/assets/favicon-228.png';
	import Header from '../Collections/Header.svelte';
	import Footer from '../Collections/Footer.svelte';

	let { children } = $props();
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
{@render children()}
<Footer />