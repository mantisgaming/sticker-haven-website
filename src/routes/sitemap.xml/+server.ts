import type { RequestHandler } from './$types';

const siteUrl = 'https://www.stickerhaven.shop';

const routes = ['/'];

export const GET: RequestHandler = async () => {
    const lastmod = new Date().toISOString();
    const urlEntries = routes
        .map((path) => {
            const loc = `${siteUrl}${path}`;
            return `<url><loc>${loc}</loc><lastmod>${lastmod}</lastmod></url>`;
        })
        .join('');

    const sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urlEntries}</urlset>`;

    return new Response(sitemapXml, {
        headers: {
            'Content-Type': 'application/xml; charset=utf-8',
            'Cache-Control': 'max-age=0, s-maxage=3600'
        }
    });
};
