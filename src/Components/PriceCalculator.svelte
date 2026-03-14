<script lang="ts">
    // ---------------------------------------------------------------------------
    // Placeholder — replace the body of this function with the real algorithm.
    // Parameters:
    //   width           – sticker width in inches
    //   height          – sticker height in inches
    //   quantity        – number of stickers
    //   baseMaterial    – key from BASE_MATERIALS (e.g. 'white-vinyl')
    //   laminateMaterial – key from LAMINATE_MATERIALS (e.g. 'gloss')
    // Returns the total price in dollars and estimated lead time.
    // ---------------------------------------------------------------------------
    type Estimate = {
        total: number;
        leadTime: string;
    };

    function calculateEstimate(
        width: number,
        height: number,
        quantity: number,
        baseMaterial: string,
        laminateMaterial: string
    ): Estimate {
        const areaPadding = 0.5; // Add half an inch to each dimension to account for cutting space
        const areaMultiplier = 1.5; // Multiplier to account for material waste and overhead
        const fixedCost = 10; // Base cost for setup and handling
        const minProfitPerSqrInch = 0.0125; // Minimum profit per square inch of sticker area
        const maxProfitPerSqrInch = 0.025; // Maximum profit per square inch of sticker area
        const profitExponent = 100; // Exponent to reduce profit margin for larger quantities
        const inkPricePerSqrInch = 0.0025; // Cost of ink per square inch

        const basePricePerSqrInch = (() => {
            const baseMat = BASE_MATERIALS.find((m) => m.value === baseMaterial);
            return baseMat?.pricePerSqrInch ?? NaN;
        })();

        const [lamPricePerSqrInch, lamFlatPrice] = (() => {
            const lamMat = LAMINATE_MATERIALS.find((m) => m.value === laminateMaterial);
            return [lamMat?.pricePerSqrInch ?? NaN, lamMat?.flatPrice ?? 0];
        })();

        const profitPerSqrInch =
            minProfitPerSqrInch +
            (maxProfitPerSqrInch - minProfitPerSqrInch) * Math.pow(2, -quantity / profitExponent);

        const totalPricePerSqrInch = basePricePerSqrInch + lamPricePerSqrInch + inkPricePerSqrInch;
        const area = (width + areaPadding) * (height + areaPadding) * areaMultiplier;

        const materialCostPerPiece = area * totalPricePerSqrInch;
        const profitPerPiece = area * profitPerSqrInch;

        const total =
            Math.round(
                100 *
                    (quantity * (materialCostPerPiece + profitPerPiece) + fixedCost + lamFlatPrice)
            ) / 100;

        const totalArea = area * quantity;

        let leadTime = 1; // Base lead time in days

        if (laminateMaterial !== 'none') {
            leadTime += 1; // Add a day if laminate is selected
        }

        leadTime += Math.floor(totalArea / 3000); // Add a day for every 3000 sq in of total area

        if (totalArea > 10000) {
            leadTime += 5; // Add extra time for very large orders
        }

        return { total, leadTime: `${leadTime} - ${Math.ceil(leadTime * 1.5)} days` };
    }

    const COMMON_QUANTITIES = [25, 50, 100, 200, 300, 500];

    const BASE_MATERIALS = [
        { value: 'DV4-G', label: 'White Glossy Vinyl', pricePerSqrInch: 0.0025 },
        { value: 'DV4-M', label: 'White Matte Vinyl', pricePerSqrInch: 0.0025 },
        { value: 'UV3-G', label: 'Transparent Glossy Vinyl', pricePerSqrInch: 0.0025 },
        { value: 'UV3-M', label: 'Transparent Matte Vinyl', pricePerSqrInch: 0.0025 },
        { value: 'RV4-S', label: 'Sparkly Holographic Vinyl', pricePerSqrInch: 0.01 }
    ] as const;

    const LAMINATE_MATERIALS = [
        { value: 'none', label: 'None', pricePerSqrInch: 0, flatPrice: 0 },
        { value: 'UV3-G', label: 'Gloss', pricePerSqrInch: 0.0025, flatPrice: 5 },
        { value: 'UV3-M', label: 'Matte', pricePerSqrInch: 0.0025, flatPrice: 5 }
    ] as const;

    let width = $state<string>('2');
    let height = $state<string>('2');
    let baseMaterial = $state<string>('DV4-G');
    let laminateMaterial = $state<string>('UV3-G');
    let customQuantity = $state<string>('');

    type Params = { width: number; height: number; baseMaterial: string; laminateMaterial: string };

    let params = $derived.by<Params | null>(() => {
        const w = parseFloat(width);
        const h = parseFloat(height);
        if (isNaN(w) || isNaN(h) || w <= 0 || h <= 0) return null;
        return { width: w, height: h, baseMaterial, laminateMaterial };
    });

    function rowResult(qty: number): { total: number; perPiece: number; leadTime: string } | null {
        if (!params) return null;
        const estimate = calculateEstimate(
            params.width,
            params.height,
            qty,
            params.baseMaterial,
            params.laminateMaterial
        );
        return {
            total: estimate.total,
            perPiece: estimate.total / qty,
            leadTime: estimate.leadTime
        };
    }

    let customResult = $derived.by(() => {
        const q = parseInt(customQuantity, 10);
        if (!params || isNaN(q) || q <= 0) return null;
        return rowResult(q);
    });
</script>

<div class="calculator">
    <form>
        <div class="form-row">
            <div class="form-group">
                <label for="calc-width">Width (in)</label>
                <input
                    id="calc-width"
                    type="number"
                    min="0.5"
                    max="24"
                    step="0.25"
                    placeholder="e.g. 2"
                    bind:value={width}
                    required
                />
            </div>
            <div class="form-group">
                <label for="calc-height">Height (in)</label>
                <input
                    id="calc-height"
                    type="number"
                    min="0.5"
                    max="24"
                    step="0.25"
                    placeholder="e.g. 2"
                    bind:value={height}
                    required
                />
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label for="calc-base">Base Material</label>
                <select id="calc-base" bind:value={baseMaterial}>
                    {#each BASE_MATERIALS as mat (mat.value)}
                        <option value={mat.value}>{mat.label}</option>
                    {/each}
                </select>
            </div>
            <div class="form-group">
                <label for="calc-laminate">Laminate</label>
                <select id="calc-laminate" bind:value={laminateMaterial}>
                    {#each LAMINATE_MATERIALS as lam (lam.value)}
                        <option value={lam.value}>{lam.label}</option>
                    {/each}
                </select>
            </div>
        </div>
    </form>

    <div class="results">
        <table>
            <thead>
                <tr>
                    <th>Quantity</th>
                    <th>Total Cost</th>
                    <th>Price Per Piece</th>
                    <th>Lead Time</th>
                </tr>
            </thead>
            <tbody>
                {#each COMMON_QUANTITIES as qty (qty)}
                    {@const row = rowResult(qty)}
                    <tr>
                        <td>{qty}</td>
                        <td>{row ? '$' + row.total.toFixed(2) : '—'}</td>
                        <td>{row ? '$' + row.perPiece.toFixed(3) : '—'}</td>
                        <td>{row ? row.leadTime : '—'}</td>
                    </tr>
                {/each}
                <tr class="custom-row">
                    <td>
                        <input
                            class="qty-input"
                            type="number"
                            min="1"
                            step="1"
                            placeholder="Custom qty"
                            bind:value={customQuantity}
                            aria-label="Custom quantity"
                        />
                    </td>
                    <td>{customResult ? '$' + customResult.total.toFixed(2) : '—'}</td>
                    <td>{customResult ? '$' + customResult.perPiece.toFixed(3) : '—'}</td>
                    <td>{customResult ? customResult.leadTime : '—'}</td>
                </tr>
            </tbody>
        </table>
        <p class="disclaimer">
            This is an estimate for planning purposes.
            <a
                class="link-cta"
                href="mailto:contact@stickerhaven.shop?subject=Quote%20Request&body=Hi,%20I%20would%20like%20to%20get%20a%20quote%20for%20an%20order%20of%20custom%20stickers!"
                >Contact us for a final quote.</a
            >
        </p>
    </div>
</div>

<style lang="scss">
    .calculator {
        display: flex;
        flex-direction: column;
        gap: clamp(1rem, 2vw, 1.5rem);
    }

    .results {
        display: flex;
        flex-direction: column;
        gap: clamp(0.5rem, 1vw, 0.75rem);
    }

    .results {
        th,
        td {
            white-space: nowrap;
        }
    }

    .disclaimer {
        font-size: 0.875rem;
        opacity: 0.8;
    }

    .custom-row {
        background-color: rgba(117, 216, 223, 0.12);
    }

    .qty-input {
        width: 100%;
        padding: 0.3rem 0.5rem;
        border: 1.5px solid #9dd8dc;
        border-radius: 0.3rem;
        background-color: #fff;
        font-size: 0.95rem;
        color: #141414;
        box-sizing: border-box;

        &:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(117, 216, 223, 0.3);
        }
    }
</style>
