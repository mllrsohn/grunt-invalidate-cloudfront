module.exports = (grunt) ->
    'use strict'
    _ = grunt.util._
    AWS = require 'aws-sdk'

    grunt.registerMultiTask "invalidate_cloudfront", "Invalidates Cloudfront files", ->
        options = @options(
            key: '',
            secret: '',
            region: 'eu-west-1'
            distribution: ''
        )

        done = @async()
        cf = new AWS.CloudFront.Client(new AWS.Config({accessKeyId:options.key, secretAccessKey: options.secret, region:options.region}))
        filelist = ('/' + items.dest for items in this.files)
        grunt.log.writeflags(filelist, 'Invalidating '+filelist.length+' files')

        # List Current Invalidations
        cf.listInvalidations { DistributionId: options.distribution }, (err, invalidations) ->
            grunt.fail.fatal(err) if err
            completed = (items.Status for items in invalidations.Items when items.Status is 'Completed')
            grunt.log.subhead(completed.length + ' Completed Invalidations on: ' + options.distribution)

            # Create Invalidation params
            params =
                DistributionId: options.distribution
                InvalidationBatch:
                    CallerReference: '' + +new Date
                    Paths:
                        Quantity: filelist.length
                        Items: filelist


            cf.createInvalidation params, (err, data) ->
                grunt.fail.fatal(err) if err
                grunt.log.subhead('Invalidation created at ' + data.Location)
                done(true)