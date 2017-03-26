
# apex-chicken demo

This is a proof of concept of how to deploy a Chicken Scheme
program as an AWS Lambda function.

It uses Apex (http://apex.run/) which has a shim mechanism that allows
languages not supported natively by AWS to be used.

## demo

This assumes you have `apex` installed and in your path.

```
# (1) copy build-chicken-apex.sh to some dir in your PATH
$ cd apex-chicken
$ cp build-chicken-apex.sh /usr/local/bin

# (2) edit project.json and set the "role" value to an IAM role
# that has perms to execute lambda functions
# see the apex docs for more details on this

# (3) setup an aws profile in: ~/.aws/credentials
# and export it - apex will use this to when deploying your code
$ export AWS_PROFILE=bitmech

# (4) deploy the function
$ apex deploy

# (5) verify the function exists
$ apex list

  sum
    runtime: nodejs4.3
    memory: 128mb
    timeout: 5s
    role: arn:aws:iam::454738051317:role/apex_lambda_function
    handler: index.handle
    arn: arn:aws:lambda:us-west-2:454738051317:function:apex-chicken_sum:current
    aliases: current@v9


# (6) invoke the function
$ echo '{"numbers":[1,2,553]}' | apex invoke sum
556

# (7) fetch logs
apex logs

```

## assumptions / how it works

* See `project.json` - we use the "golang" runtime and override the build hook to invoke the shell script

```
"runtime": "golang",
"hooks": {
    "build": "build-chicken-apex.sh"
  },
  ```

* See: `functions/sum/chicken-apex.txt` - contains the list of eggs to build

```
# eggs to include in build - space separated
eggs="medea"
```

* After a build, each functions dir will have an `apex-build` directory containing your
compiled program + all dependencies.  This is zipped up by apex and uploaded as your lambda function.

* The build script tries to avoid recompiling eggs each time by checking to see if the `.so` for a given
egg already exists in the `apex-build` dir.

* If you want to force recompilation of all deps, simply remove the `apex-build` dir

## limitations

* The example `sum.scm` apex functions should probably be moved into a separate egg
* The build script doesn't do cross compiling -- this will only work on a Linux host
  * I could use some help there on the right flags to enable cross compiles

