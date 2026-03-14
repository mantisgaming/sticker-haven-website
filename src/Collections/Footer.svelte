<script>
	import { resolve } from '$app/paths';
	import logo from '$lib/assets/favicon-228.png';
	import BackToTopButton from '../Components/BackToTopButton.svelte';
</script>

<footer class="footer">
	<div class="left">
		<a href={resolve('/')}>
			<img alt="Sticker Haven Logo" src={logo} />
		</a>
	</div>
	<div class="center">
		<p>
			<small>©2025 Sticker Haven. All rights reserved.</small>
		</p>
	</div>
	<div class="right">
		<BackToTopButton />
	</div>
</footer>

<style lang="scss">
	.footer {
		align-items: center;
		background-color: var(--footer-bg);
		display: flex;
		flex-direction: row;
		justify-content: center;
		width: 100%;
		padding: 0 2.5rem;

		a {
			padding: 0.5rem;
			display: inline-flex;
		}

		img,
		> * {
			display: block;
		}

		> * {
			text-align: center;
		}

		img {
			width: 57px;
		}

		small {
			font-weight: 300;
		}
	}

	.left,
	.right {
		flex: 2 1;
	}

	.left {
		display: flex;
		justify-content: flex-start;
	}

	.right {
		display: flex;
		justify-content: flex-end;
	}

	.center {
		flex: 8 1;
	}
</style>
