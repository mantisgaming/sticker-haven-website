<script lang="ts">
    let { children } = $props();
</script>

{#if children}
    <section class="announcements" aria-label="Announcements">
        {@render children()}
    </section>
{/if}

<style lang="scss">
    .announcements {
        position: sticky;
        top: 0;
        margin-top: var(--header-height);
        width: 100%;
        z-index: 9;
        display: flex;
        flex-direction: column;
    }
</style>
