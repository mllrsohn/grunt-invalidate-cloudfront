# grunt-invalidate-cloudfront

> Sends a invalidation request to amazon cloudfront, list the invalid files and gives you a link to the invalidation progress

## Getting Started
This plugin requires Grunt `~0.4.1`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-invalidate-cloudfront --save-dev
```

One the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-invalidate-cloudfront');
```

## The "invalidate_cloudfront" task

### Example
In your project's Gruntfile, add a section named `invalidate_cloudfront` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  invalidate_cloudfront: {
    options: {
      key: 'XXXXXX',
      secret: 'XXXXXX',
      distribution: 'XXXXXX'
    },
    production: {
      files: [{
        expand: true,
        cwd: './build/',
        src: ['**/*'],
        filter: 'isFile',
        dest: ''
      }]
    }
  }
})
```

### Options
You need to pass in your ```key``` (Amazon Key), your ```secrect``` (Amazon Secret) and the ```distribution``` you want to clear


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
04. Mai 2013 - first release
