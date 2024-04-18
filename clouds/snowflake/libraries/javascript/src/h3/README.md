# Rebuild h3-js 3.7.2 dependency
First, ensure you have yarn and docker installed.  

```
wget https://github.com/uber/h3-js/releases/tag/v3.7.2
unzip h3-js-3.7.2.zip
cd h3-js-3.7.2
yarn docker-boot && yarn build-emscripten
```

Remove all the unneeded bindings from the `lib/bindings.js`  

Then run:  
```
yarn docker-emscripten-run
```

Your new library file is available at `out/a.out.js`. Copy it to the correct location with the new filename. For example: `cp out/a.out.js  ~/development/analytics-toolbox/core/clouds/snowflake/libraries/javascript/src/h3/h3_polyfill/libh3_custom.js`. Ensure it is named `libh3_custom.js`.

