{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Lib where

import Web.Authenticate.OAuth
import Network.HTTP.Client
import Network.HTTP.Client.TLS( tlsManagerSettings )
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Maybe( fromJust )
import Data.String( fromString )
import Control.Monad.IO.Class( MonadIO )

base = "https://www.upwork.com"
authBase = base ++ "/api/auth/v1/oauth/token"
jobsLoc = base ++ "/api/profiles/v2/search/jobs.json"

getJobs :: Request
getJobs = fromJust (parseUrl jobsLoc)

queryAll = setQueryString [("q", Just "*")]

-- https://developers.upwork.com/?lang=python#authentication_oauth-10
makeOAuth key secret = 
  def {
    oauthRequestUri = authBase ++ "/request",
    oauthAccessTokenUri = authBase ++ "/access",
    oauthAuthorizeUri = base ++ "/services/api/auth",
    oauthConsumerKey = key,
    oauthConsumerSecret = secret
    }

getCredentials :: OAuth -> IO Credential
getCredentials oauth = do
  manager <- newManager tlsManagerSettings
  temporaryCredential <- getTemporaryCredential oauth manager
  putStrLn "please go to:"
  putStrLn (authorizeUrl oauth temporaryCredential)
  putStrLn "after accepting, paste the verifier code below and hit enter"
  verifier <- getLine
  putStrLn $ "you pasted `"++ verifier ++"`"
  getAccessToken oauth (injectVerifier (fromString verifier) temporaryCredential) manager

askForJobs oauth tokenCredentials = do
  signed <- signOAuth oauth tokenCredentials (queryAll getJobs)
  manager <- newManager tlsManagerSettings
  response <- httpLbs signed manager
  C.putStrLn (responseBody response)
