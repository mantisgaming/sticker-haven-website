<script lang="ts">
	import './layout.css';
	import logo from '$lib/assets/favicon-228.png';
	import Header from '../Collections/Header.svelte';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={logo} />
</svelte:head>

<Header />
{@render children()}

<style lang="scss">
	:global(:root) {
		--primary: #75d8df;
		--header-text: #141414;
	}

	:global(*) {
		box-sizing: border-box;
	}
</style>
