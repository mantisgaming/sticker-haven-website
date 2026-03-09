<script>
	import { resolve } from '$app/paths';
	import logo from '$lib/assets/favicon-228.png';
</script>

<header>
	<div class="container">
		<div class="flex">
			<div class="title">
				<a href={resolve('/')}>
					<img alt="Sticker Haven logo" src={logo} />
				</a>
			</div>
			<nav>
				<ul>
					<a href={resolve('/about')}>About</a>
				</ul>
			</nav>
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
		position: relative;
		flex-direction: row;
		justify-content: space-around;
		padding: 0 2.5rem;
		background-color: var(--primary);
		height: 6rem;
		z-index: 10;
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
		height: 100%;
		padding: 1rem 0;
	}

	nav a {
		height: 100%;
		padding: 0 1rem;
		display: flex;
		flex-direction: column;
		justify-content: center;
		font-weight: bold;
		color: var(--header-text);
		border-radius: 1rem;

		&:hover {
			background-color: rgba(255, 255, 255, 0.25);
		}
	}
</style>
