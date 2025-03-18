import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "VitePress ApexDocs",
    description: "Generated documentation from Salesforce Apex Class Files",
    base: '/apexdocs-wiki/',
    themeConfig: {
        // For reference, here is default theme: https://vitepress.dev/reference/default-theme-config
        nav: [
            { text: 'Home', link: '/index' },
            { text: 'ApexDocs Reference', link: 'https://github.com/cesarParra/apexdocs/' }
        ],

        sidebar: POPULATE_ME,
        socialLinks: [
            { icon: 'github', link: 'https://github.com/vuejs/vitepress' },
        ]
    },
    ignoreDeadLinks: true // 'localhostLinks'
})
