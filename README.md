# Publishing an Elm app to Netlify

### Getting Started

#### Prerequisites

- A GitHub account <a href="https://github.com" target="_blank">https://github.com</a>
- A way to quickly clone GitHub repos (command line, SourceTree, GitHub Desktop, etc.)
  - git installers: https://git-scm.com/downloads
- NodeJS (6.9.2 or higher): <a href="https://nodejs.org" target="_blank">https://nodejs.org</a>
- Netlify Account: <a href="https://app.netlify.com/" target="_blank">https://app.netlify.com/</a>
  - Netlify Docs: https://www.netlify.com/docs/

#### Setting up the Project

1. Login to GitHub and create a new repository for your project
2. Login to Netlify (preferably through GitHub) https://app.netlify.com/
3. Open your command like tool of choice (terminal, git bash etc.)
4. Clone the repo you created onto your computer
   `git clone <your-github-project-url>`
5. Switch to your project directory
   `cd <your-github-project-name>`
6. Run `npm init` to setup your project
7. Add necessary dependencies to project
   ```json
   "dependencies": {
       "bootstrap-scss": "^4.3.1",
       "dotenv": "^7.0.0",
       "querystring": "^0.2.0"
   },
   "devDependencies": {
       "copy-webpack-plugin": "^5.0.2",
       "css-loader": "^2.1.1",
       "elm-webpack-loader": "^5.0.0",
       "file-loader": "^3.0.1",
       "node-sass": "^4.11.0",
       "raw-loader": "^2.0.0",
       "sass-loader": "^7.1.0",
       "style-loader": "^0.23.1",
       "uglifyjs-webpack-plugin": "^2.1.2",
       "webpack": "^4.30.0",
       "webpack-cli": "^3.3.0",
       "webpack-dev-server": "^3.3.1"
   }
   ```
8. Run `npm install`
9. Navigate your browser to the Netlify site, and go to "Sites", then click the "New site from Git" button
10. In the "Continuous Deployment" section, click the "GitHub" button
11. Click the "Configure the Netlify app on GitHub" link
12. Walk through the steps for connecting to GitHub
13. Select the new repository you created in step #1
14. Select a "Branch to Deploy"
15. For the "Build Command", enter `npm run deploy`
16. For the "Publish Directory:, enter `dist`
17. Click "Deploy Site"

    - This deploy will fail, we haven't setup a deploy script, yet.

18. Next, we'll setup the npm commands for our project
19. Install the Netlify CLI `npm install -g netlify-cli`
20. Install the netlify-lambda on your computer `npm install -g netlify-lambda`
21. Add the following to your `package.json` file in the `scripts` section
    ```json
    "deploy": "npm run lambda:build && webpack --mode production",
    "watch": "webpack --mode production --watch",
    "elm": "elm",
    "lambda:build": "netlify-lambda build ./src/lambda"
    ```
22. Run `netlify init`
23. Choose "Link this directory to an existing site"
24. Select "Use current git remote url `<you-github-site-url>`"
25. Open the `.netlify/state.json` file and copy the `siteId` on to your clipboard
26. Create your Netlify settings file, name it `netlify.toml` with the following contents:

    ```toml
    [Settings]
    ID = "<your-netlfiy-site-id>"

    [build]
    functions = "./functions"
    publish = "dist"
    ```

27. Create a new file named `webpack.config.js` and add the contents of <a href="https://raw.githubusercontent.com/mikeonslow/elm-serverless/master/webpack.config.js" target="_blank">webpack.config.js</a> to it
28. Run `elm init` and select yes to create your Elm configuration file
29. Create a new `elm` directory in your `src` directory `mkdir -p src/elm`
30. Create a new file `src/elm/Main.elm` and copy the contents of this file into it <a href="https://raw.githubusercontent.com/mikeonslow/elm-serverless/92457a88d8741fece375c34a044fc928dad5a4a5/src/elm/Main.elm" target="_blank">src/elm/Main.elm</a>
31. Create a file `src/index.html` and copy the contents of this file into it <a href="https://raw.githubusercontent.com/mikeonslow/elm-serverless/92457a88d8741fece375c34a044fc928dad5a4a5/src/index.html" target="_blank">src/index.html</a>
32. Create a new `js` directory in your `src` directory `mkdir -p src/js`
33. Create a file `src/js/app.js` and copy the contents of this file into it <a href="https://raw.githubusercontent.com/mikeonslow/elm-serverless/92457a88d8741fece375c34a044fc928dad5a4a5/src/js/app.js" target="_blank">src/js/app.js</a>
34. Open a new terminal window/tab and run the following command `npm run watch`
35. Open a new terminal window/tab and run the following command `netlify dev --live`
36. Click on the link displayed in the terminal you executed `netlify dev --live` in to open a dev version of the site
37. Add the following to you `.gitignore` file:
    ```
    # elm-package generated files
    elm-stuff
    # elm-repl generated files
    repl-temp-*
    node_modules
    functions
    dist
    .env
    ```
38. To deploy, you have two options
    1. Commit and push all of your changes to the `master` branch of your repo
    2. Run `netlify deploy --prod`
