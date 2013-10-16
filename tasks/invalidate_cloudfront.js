// Generated by CoffeeScript 1.6.3
module.exports = function(grunt) {
  'use strict';
  var AWS, _;
  _ = grunt.util._;
  AWS = require('aws-sdk');
  return grunt.registerMultiTask("invalidate_cloudfront", "Invalidates Cloudfront files", function() {
    var cf, done, filelist, items, options;
    options = this.options({
      key: '',
      secret: '',
      region: 'eu-west-1',
      distribution: ''
    });
    done = this.async();
    cf = new AWS.CloudFront.Client(new AWS.Config({
      accessKeyId: options.key,
      secretAccessKey: options.secret,
      region: options.region
    }));
    filelist = (function() {
      var _i, _len, _ref, _results;
      _ref = this.files;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        items = _ref[_i];
        _results.push('/' + grunt.template.process(items.dest));
      }
      return _results;
    }).call(this);
    grunt.log.writeflags(filelist, 'Invalidating ' + filelist.length + ' files');
    return cf.listInvalidations({
      DistributionId: options.distribution
    }, function(err, invalidations) {
      var completed, params;
      if (err) {
        grunt.fail.fatal(err);
      }
      completed = (function() {
        var _i, _len, _ref, _results;
        _ref = invalidations.Items;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          items = _ref[_i];
          if (items.Status === 'Completed') {
            _results.push(items.Status);
          }
        }
        return _results;
      })();
      grunt.log.subhead(completed.length + ' Completed Invalidations on: ' + options.distribution);
      params = {
        DistributionId: options.distribution,
        InvalidationBatch: {
          CallerReference: '' + +(new Date),
          Paths: {
            Quantity: filelist.length,
            Items: filelist
          }
        }
      };
      return cf.createInvalidation(params, function(err, data) {
        if (err) {
          grunt.fail.fatal(err);
        }
        grunt.log.subhead('Invalidation created at ' + data.Location);
        return done(true);
      });
    });
  });
};
