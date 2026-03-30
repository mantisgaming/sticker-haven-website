<script>
    let { children } = $props();
</script>

<section class="jumbotron">
    {@render children?.()}
</section>

<style lang="scss">
    .jumbotron {
        background-image: url('/img/Banner.jpg');
        background-position: center;
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed;
        color: var(--jumbotron-text);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        position: relative;
        width: 100%;
        min-height: 100vh;
        min-height: 100svh;
        padding: 4rem 2rem;
        margin-bottom: 0;
        user-select: none;

        &::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            z-index: 1;
            -webkit-backdrop-filter: blur(2px) sepia(20%) brightness(35%);
            backdrop-filter: blur(2px) sepia(20%) brightness(35%);
            pointer-events: none;
        }

        > :global(*) {
            position: relative;
            z-index: 5;
        }

        :global(.title) {
            font-family: 'Artbrush', cursive;
            font-size: 8rem;
            font-weight: 700;
            line-height: 1.1;
            color: #f0f8ff;
            margin-top: 0;
            text-shadow: 0 4px 16px rgba(0, 0, 0, 0.6);
        }

        :global(.subtitle) {
            font-size: 1.5rem;
            line-height: 1.4;
            color: #f0f8ff;
            margin-top: 1rem;
            max-width: 40ch;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.55);
        }

        :global(.cta) {
            background-color: var(--jumbotron-button-bg);
            color: #242321;
            font-size: 1.5rem;
            font-weight: 700;
            padding: 1rem 1.5rem;
            border-radius: 2rem;
            text-decoration: none;
            transition:
                background-color 0.25s ease,
                filter 0.25s ease;
            margin-top: 1.5rem;

            &:hover {
                background-color: #98faff;
                filter: drop-shadow(0 0 0.8rem rgba(255, 255, 255, 0.35));
            }
        }

        @media (max-width: 768px) {
            padding: 2.5rem 1rem;
            min-height: 100dvh;
            min-height: 100svh;
            background-attachment: scroll;

            :global(.title) {
                font-size: clamp(3rem, 16vw, 5rem);
            }

            :global(.subtitle) {
                font-size: clamp(1rem, 5vw, 1.25rem);
            }

            :global(.cta) {
                width: 100%;
                max-width: 20rem;
            }
        }
    }
</style>
