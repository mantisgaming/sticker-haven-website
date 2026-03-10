<script lang="ts">
	import './layout.scss';
	import logo from '$lib/assets/favicon-228.png';
	import Header from '../Collections/Header.svelte';
	import Footer from '../Collections/Footer.svelte';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={logo} />
</svelte:head>

<Header />
{@render children()}
<Footer />