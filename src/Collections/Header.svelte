<script lang="ts">
	import { resolve } from '$app/paths';
	import logo from '$lib/assets/favicon-228.png';
	import NavLink from '../Components/NavLink.svelte';

	const topLevelPageModules = import.meta.glob('/src/routes/*/+page.svelte', { eager: true });

	const routeLinks = Object.keys(topLevelPageModules)
		.map((filePath) => filePath.match(/\/src\/routes\/([^/]+)\/\+page\.svelte$/)?.[1] ?? null)
		.filter((segment) => segment !== null)
		.map((segment) => ({
			href: `/${segment}`,
			label: segment
				.split('-')
				.map((part) => part.charAt(0).toUpperCase() + part.slice(1))
				.join(' '),
			exact: false
		}))
		.sort((a, b) => a.label.localeCompare(b.label));

	const navLinks = [{ href: '/', label: 'Home', exact: true }, ...routeLinks];
	const showNavigation = false;
</script>

<header>
	<div class="container">
		<div class="flex">
			<div class="title">
				<a href={resolve('/')}>
					<img alt="Sticker Haven logo" src={logo} />
				</a>
			</div>
			{#if showNavigation}
				<nav>
					<ul>
						{#each navLinks as link}
							<li>
								<NavLink href={link.href} exact={link.exact}>{link.label}</NavLink>
							</li>
						{/each}
					</ul>
				</nav>
			{/if}
		</div>
	</div>
</header>

<style lang="scss">
	.flex {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
        height: 100%;
	}

	header {
		width: 100%;
		display: flex;
		position: absolute;
		top: 0;
		left: 0;
		flex-direction: row;
		justify-content: space-around;
		padding: 0 2.5rem;
		background-color: var(--primary);
		box-shadow: 0 -1.5rem 3rem 3rem #ffffff40;
		height: var(--header-height);
		z-index: 10;
        > div {
            width: 100%;
        }
	}

	.title {
		z-index: 10;
		padding: 1rem;

		& * {
			display: block;
			border-radius: 100%;
		}
		a {
			position: relative;
			transition: filter 0.25s ease;
			filter: drop-shadow(0 0 0 rgba(255, 255, 255, 0.35));

			&:hover {
				filter: drop-shadow(0 0 0.8rem rgba(255, 255, 255, 0.35));
			}
		}
	}

	img {
		width: 10rem;
		aspect-ratio: 1/1;
	}

	nav {
		display: flex;
		flex-direction: row;
		gap: 1rem;
	}

	nav ul {
		display: flex;
		height: 100%;
		margin: 0;
		padding: 1rem 0;
		gap: 0.5rem;
		list-style: none;
	}

	nav li {
		height: 100%;
		margin: 0;
		padding-left: 0;
	}

	nav li + li {
		margin-top: 0;
	}

	nav li::before {
		content: none;
	}

	@media (max-width: 1200px) {
		header {
			padding: 0 1rem;
		}

		.title {
			padding: 0.5rem;
			height: 100%;
			display: flex;
			align-items: center;
		}

		img {
			width: auto;
			height: clamp(2.75rem, 25vw, calc(var(--header-height) - 1rem));
		}
	}
</style>
