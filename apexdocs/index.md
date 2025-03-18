# Apex Classes Documentation
The documentation found here has been auto-generated from the Apex source files using the ApexDocs tool. See [ApexDocs Reference](https://github.com/cesarParra/apexdocs) for more details. It is modeled after the JavaDoc tool.

The site content is created/updated by a github action configured in your repository. By default, the action is named `deploy-apexdocs-to-vitepress.yml` and fires when the `master` and `release` branches are updated. See details about Vitepress [here](https://vitepress.dev). Keep reading for how to get started!

### [Head](guide) to Latest Release Documentation Now 

## Annotate Your Code
It is simple to document your code as you are developing it. Just follow the guidelines laid out in ApexDocs annotating class, methods & fields with the relevant @ tags and it will get picked up & transformed when ApexDocs generator fires.
## Install & Configure Vitepress
You can get started using VitePress right away using node! See Vitepress documentation for more configuration details and tips.

```sh
npm add -D vitepress
npm init
npx vitepress init
npm run docs:build 
```

## Generate Github Documentation & Test It Out! 
If you do not modify the `package.json` in this repository, then you can generate your documentation by running the following commands
1. The `apexdocs` target generates the file(s) in your configured `apexdocs` directory creating a subdirectory called `guide`.
2. The `docs:preview` target starts a local server to preview the generated content as follows 
   -  Source directory is `apexdocs/.vitepress/dist`
   -  Content is deployed locally at http://localhost:5173  
```sh
npm run apexdocs
npm run docs:preview
```


## References
 [Vitepress](https://vitepress.dev)

 [ApexDocs](https://github.com/cesarParra/apexdocs)

 [Github Pages](https://github.com/cesarParra/apexdocs)
