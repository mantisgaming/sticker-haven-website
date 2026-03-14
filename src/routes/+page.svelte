<script lang="ts">
    import Jumbotron from '../Components/Jumbotron.svelte';
    import Testimonial from '../Components/Testimonial.svelte';
    import PriceCalculator from '../Components/PriceCalculator.svelte';

    const testimonials = [
        {
            quote: 'Truly above and Beyond. I contacted sticker Haven to get some stickers made for an upcoming party. Max was incredibly responsive and communicated clearly. The pricing was exceptionally competitive and when Max realized that the mail may not get me my stickers in time, he went above and beyond to expedite delivery. I would absolutely work with him again and give my full recommendation.',
            author: 'Paul Jasper'
        },
        {
            quote: "Great quality stickers of all shapes and sizes (I've used them for an assortment of shapes and sizes). Extremely affordable and fast, this might have to do with being local. It's also extremely easy to get in contact with the owner for help or consulting. I will definitely be using Sticker Haven for my personal use and business needs. Thank you for being such a great local business!",
            author: 'Adryen Gonzalez'
        },
        {
            quote: 'Sticker Haven was highly responsive and expertly walked us through the entire process of printing a professional-looking set of stickers. They helped us clarify what we wanted in terms of a final product and their quoted price was extremely competitive. They worked diligently with us to get our designs production-ready and the end result was fantastic. I cannot recommend Sticker Haven highly enough!',
            author: 'Bob Carmichael'
        }
    ];
</script>

<Jumbotron>
    <h1 class="title">Sticker Haven</h1>
    <p class="subtitle">Custom stickers for artists and more!</p>
    <a
        class="cta"
        href="mailto:contact@stickerhaven.shop?subject=Quote%20Request&body=Hi,%20I%20would%20like%20to%20get%20a%20quote%20for%20an%20order%20of%20custom%20stickers!"
        >Contact to Order</a
    >
</Jumbotron>
<section class="content-section text-center">
    <h2 id="about">About</h2>
    <p>
        Sticker Haven was created to make custom stickers more affordable, faster to order, and
        easier to access for artists and small businesses.
    </p>
    <p>
        The idea grew out of the sticker culture at Worcester Polytechnic Institute, where many
        students and creators wanted high-quality custom stickers without expensive shipping fees or
        large minimum orders. Instead of forcing people to choose between overpriced online options
        and unreliable desktop cutters, Sticker Haven provides professional printing and cutting for
        practical order sizes, especially for runs around 25-200 stickers.
    </p>
</section>

<section class="content-section split-layout">
    <div class="content-panel">
        <h2 id="sticker-products">Sticker Products</h2>
        <p>
            We offer a variety of custom sticker formats for artists, student organizations, and
            businesses:
        </p>
        <ul>
            <li>Die-cut stickers</li>
            <li>Kiss-cut sticker sheets</li>
            <li>Holographic and laminate finish options</li>
            <li>Bulk logo and business stickers</li>
            <li>Custom sizes and shapes</li>
        </ul>
    </div>

    <div class="content-panel">
        <h2 id="turnaround-delivery">Turnaround & Delivery</h2>
        <p>
            Whether you need stickers quickly for an event or are planning ahead, we offer flexible
            fulfillment options:
        </p>
        <ul>
            <li>Rush turnaround (2-3 days)</li>
            <li>Standard turnaround (3-5 days)</li>
            <li>Pickup near WPI</li>
            <li>Shipping within the US for $11</li>
        </ul>
    </div>
</section>

<section class="content-section split-layout">
    <div class="content-panel">
        <h2 id="price-calculator">Price Calculator</h2>
        <p>
            Enter your sticker dimensions, quantity, and material options to get an instant
            estimate. Every project is quoted individually &mdash; contact us to confirm your final
            price.
        </p>
        <PriceCalculator />
    </div>

    <div class="content-panel">
        <div class="content-subsection">
            <h2 id="how-to-order">How to Order</h2>
            <ol>
                <li>Send your artwork, desired quantity, and sticker specs.</li>
                <li>Review and approve your digital proof.</li>
                <li>We print and cut your order.</li>
                <li>Choose pickup, local delivery, or shipping.</li>
                <li>Reorder anytime from saved files for faster turnaround.</li>
            </ol>
            <p>
                Ready to order?
                <a
                    class="link-cta"
                    href="mailto:contact@stickerhaven.shop?subject=Quote%20Request&body=Hi,%20I%20would%20like%20to%20get%20a%20quote%20for%20an%20order%20of%20custom%20stickers!"
                    >Email us to start your order.</a
                >
            </p>
        </div>
        <div class="content-subsection">
            <h2 id="who-we-work-with">Who We Work With</h2>
            <p>
                Sticker Haven works with independent artists, students, clubs, families, nonprofits,
                and businesses of all sizes. If you need quality custom stickers without high
                minimums or expensive shipping, we are here to help.
            </p>
        </div>
        <div class="content-subsection">
            <h2 id="other-products">Other Products</h2>
            <p>
                Sticker Haven also offers photo printing and poster printing for personal projects,
                events, and business needs. The product lineup is actively expanding into custom
                metal signs and printed magnets so customers have even more ways to bring their
                ideas to life.
            </p>
            <p>
                Interested in custom products beyond stickers? Contact us to discuss your project
                and see how we can help make it a reality.
            </p>
        </div>
    </div>
</section>

<section class="content-section">
    <div class="content-panel">
        <div class="content-subsection">
            <h2 id="customer-testimony">Customer Testimony</h2>
            <div class="columns-3 text-left">
                {#each testimonials as testimonial (testimonial.author)}
                    <Testimonial quote={testimonial.quote} author={testimonial.author} />
                {/each}
            </div>
        </div>
        <div class="content-subsection">
            <p class="text-center">
                View reviews directly on Google:
                <a
                    class="link-cta"
                    href="https://share.google/lgxR1onu38l5pBhd4"
                    target="_blank"
                    rel="noreferrer">Open business profile</a
                >
            </p>
        </div>
    </div>
</section>
