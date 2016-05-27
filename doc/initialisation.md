Any automated script acting on your behalf on Upwork needs to be
authorized by you before, also Opwer.

In order to do this there is a specific command to run, using the key
and secret Upwork gave you:

    $ opwer-init <key> <secret>

If the script runs successfully, it will create a file named
`opwer-credential` in the directory where it is run. This credential
will be used by `opwer-search` for any future access.
