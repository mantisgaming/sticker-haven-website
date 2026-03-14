<script lang="ts">
    import { FontAwesomeIcon } from '@fortawesome/svelte-fontawesome';
    import { faXmark } from '@fortawesome/free-solid-svg-icons';

    let {
        message,
        ariaLabel
    }: {
        message: string;
        ariaLabel: string;
    } = $props();

    var hide: boolean = $state(false);
</script>

{#if !hide}
    <section class="announcement-banner" aria-label={ariaLabel}>
        <p>{message}</p>
        <button
            type="button"
            class="close-button"
            aria-label="Close announcement"
            onclick={() => (hide = true)}
        >
            <FontAwesomeIcon icon={faXmark} />
        </button>
    </section>
{/if}

<style lang="scss">
    .announcement-banner {
        position: relative;
        width: 100%;
        padding: 0.75rem max(1rem, calc((100% - var(--content-max-width)) / 2));
        background-color: var(--content-section-bg-b);
        border-top: 1px solid color-mix(in srgb, var(--header-text) 12%, transparent);
        border-bottom: 1px solid color-mix(in srgb, var(--header-text) 12%, transparent);

        p {
            margin: 0;
            padding-inline: clamp(2rem, 4vw, 2.75rem);
            text-align: center;
            color: var(--header-text);
            font-weight: 700;
        }

        .close-button {
            position: absolute;
            top: 50%;
            right: max(1rem, calc((100% - var(--content-max-width)) / 2));
            transform: translateY(-50%);
            color: var(--header-text);
            line-height: 1;
            font-size: 1.2rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
    }
</style>
