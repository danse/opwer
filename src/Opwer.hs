{-# LANGUAGE DeriveGeneric #-}
module Opwer where

import Web.Authenticate.OAuth

credentialFileName = "opwer-credential"

data OpwerCredential = OpwerCredential {
  oauth :: OAuth,
  credential :: Credential
  } deriving (Show, Read)
