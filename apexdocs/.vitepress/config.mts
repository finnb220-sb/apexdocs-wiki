import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "VitePress ApexDocs",
  description: "Generated documentation from Salesforce Apex Class Files",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: 'index' }
    ],

    sidebar: [
      {
        text: 'Contents',
        items: [
          { text: 'Apex Classes', link: 'miscellaneous/index' },
          { text: 'Back to Home', link: 'index' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/vuejs/vitepress' }
    ]
  }
})
