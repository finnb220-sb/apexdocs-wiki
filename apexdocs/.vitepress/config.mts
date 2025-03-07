import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "VitePress ApexDocs",
  description: "Generated documentation from Salesforce Apex Class Files",
  base: '/apexdocs-wiki/',
  themeConfig: {
    // For reference, here is default theme: https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/index' }
    ],

    sidebar: [
      {
        text: 'Contents',
        items: [
          { text: 'Apex Classes', link: '/#miscellaneous' },
          { text: 'Back to Home', link: '/index' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/vuejs/vitepress' }
    ]
  }
})
