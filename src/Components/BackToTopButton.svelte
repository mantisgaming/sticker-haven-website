<script>
    import { FontAwesomeIcon } from '@fortawesome/svelte-fontawesome';
    import { faArrowUp } from '@fortawesome/free-solid-svg-icons';

    const scrollToTop = () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };
</script>

<button type="button" class="backTop" aria-label="Back to top" on:click={scrollToTop}>
    <span>Back to Top</span>
    <FontAwesomeIcon icon={faArrowUp} />
</button>

<style lang="scss">
    .backTop {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 0.4rem;
        background-color: transparent;
        color: var(--header-text);
        cursor: pointer;
    }
</style>
