<script>
	import { page } from '$app/state';

	let { href, exact = false, children } = $props();

	const isActive = $derived(exact ? page.url.pathname === href : page.url.pathname.startsWith(href));
</script>

<a href={href} class:active={isActive} aria-current={isActive ? 'page' : undefined}>
	{@render children?.()}
</a>

<style lang="scss">
	a {
		height: 100%;
		padding: 0 1rem;
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		position: relative;
		font-weight: 700;
		font-size: 1.125rem;
		color: var(--header-text);
		text-decoration: none;

		&::after {
			content: '';
			position: absolute;
			left: 50%;
			bottom: 0.8rem;
			transform: translateX(-50%);
			width: 75%;
			height: 0.25rem;
			border-radius: 0.25rem;
			background-color: color-mix(in srgb, var(--header-text) 25%, transparent);
			transition: width 0.25s ease, background-color 0.25s ease;
		}

		&:hover::after,
		&.active::after {
			width: 100%;
			background-color: var(--header-text);
		}

		&:focus-visible {
			outline: 2px solid color-mix(in srgb, var(--header-text) 70%, white);
			outline-offset: 0.25rem;
			border-radius: 0.5rem;
		}

		&:focus-visible::after {
			width: 90%;
			background-color: var(--header-text);
		}
	}
</style>
