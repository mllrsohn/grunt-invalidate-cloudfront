module.exports = (grunt) ->
    'use strict'
    _ = grunt.util._
    AWS = require 'aws-sdk'

    rfc3986EncodeURI = (str) ->
      encodeURI(str).replace /[!'()*]/g, escape

    grunt.registerMultiTask "invalidate_cloudfront", "Invalidates Cloudfront files", ->
        options = @options(
            key: '',
            secret: '',
            region: 'eu-west-1'
            distribution: ''
        )

        done = @async()
        filelist = []

        checkForCompletion = () ->
            cf.listInvalidations { DistributionId: options.distribution }, (err, invalidations) ->
                grunt.fail.fatal(err) if err
                in_progress = invalidations.Items.length - (items.Status for items in invalidations.Items when items.Status is 'Completed').length
                if in_progress < 3
                    invalidateBatch()
                else
                    grunt.log.writeln('Waiting due to ' + in_progress + ' running invalidations')
                    setTimeout(checkForCompletion, 30000)

        invalidateBatch = () ->
            batch = filelist[0..999]
            filelist = filelist[1000..]

            grunt.log.subhead('Creating invalidation for ' + batch.length + ' files')
            # Create Invalidation params
            params =
                DistributionId: options.distribution
                InvalidationBatch:
                    CallerReference: '' + +new Date
                    Paths:
                        Quantity: batch.length
                        Items: batch


            cf.createInvalidation params, (err, data) ->
                grunt.fail.fatal(err) if err
                grunt.log.writeln('Invalidation created at ' + data.Location)
                if filelist.length > 0
                    grunt.log.writeln(filelist.length + ' files remaining.')
                    checkForCompletion()
                else
                    done(true)

        cf = new AWS.CloudFront(new AWS.Config({accessKeyId:options.key, secretAccessKey: options.secret, region:options.region}))
        filelist = ('/' + rfc3986EncodeURI(grunt.template.process(items.dest)) for items in this.files)
        grunt.log.writeflags(filelist, 'Invalidating '+filelist.length+' files')

        # List Current Invalidations
        cf.listInvalidations { DistributionId: options.distribution }, (err, invalidations) ->
            grunt.fail.fatal(err) if err
            completed = (items.Status for items in invalidations.Items when items.Status is 'Completed').length
            in_progress = invalidations.Items.length - completed
            grunt.log.subhead(completed + ' Completed and ' + in_progress + ' In Progress invalidations on: ' + options.distribution)

            if in_progress < 3
                invalidateBatch()
            else
                checkForCompletion()
