{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Lib where

import Network.HTTP.Client
import Network.HTTP.Client.TLS( tlsManagerSettings )
import Network.OAuth
import Network.OAuth.ThreeLegged
import Network.OAuth.Types.Params( workflow, Workflow(TemporaryTokenRequest) )
import Crypto.Random
import Network.URI
import Data.ByteString( getLine )
import Data.ByteString.Lazy( putStrLn )
import Data.Functor( fmap )
import Data.Maybe( fromJust )
import Network.HTTP.Client.Internal ( dummyConnection, requestBuilder )

base = "https://www.upwork.com/api"
authBase = base ++ "/auth/v1/oauth"
jobsLoc = base ++ "/profiles/v2/search/jobs.json"

maybeGetJobs :: Maybe Request
maybeGetJobs = parseUrl jobsLoc

-- http://hackage.haskell.org/package/oauthenticated-0.1.3.4/docs/Network-OAuth-ThreeLegged.html
-- https://developers.upwork.com/?lang=python#authentication_oauth-10

threeLegged = fromJust (parseThreeLegged r1 r2 r3 OutOfBand)
  where
    r1 = authBase ++ "/token/request"
    r2 = "https://www.upwork.com/services/api/auth"
    r3 = authBase ++ "/token/access"

getVerifier :: URI -> IO Verifier
getVerifier uri = do
  Prelude.putStrLn $ "please go to " ++ (show uri)
  Prelude.putStrLn $ "after accepting, paste the verifier code below and hit enter"
  Data.ByteString.getLine

server = defaultServer { parameterMethod=RequestEntityBody }

requestToken threeLegged key secret =
  let client = clientCred (Token key secret)
  in requestTokenProtocol' tlsManagerSettings client server threeLegged getVerifier

queryAll = setQueryString [("q", Just "*")]

getTemporaryTokenRequest key secret = do
  entropy <- createEntropyPool
  (oax, gen') <- freshOa (clientCred (Token key secret)) (cprgCreate entropy :: SystemRNG)
  return (sign (oax { workflow = TemporaryTokenRequest (callback threeLegged) }) server (temporaryTokenRequest threeLegged))

askForJobs key secret = do
  maybePermanent <- requestToken threeLegged key secret
  case maybePermanent of
    Nothing -> Prelude.putStrLn "Nothing permanent"
    Just permanent -> do
      entropy <- createEntropyPool
      (signed, gen) <- oauth permanent server (queryAll (fromJust maybeGetJobs)) (cprgCreate entropy :: SystemRNG)
      manager <- newManager defaultManagerSettings
      response <- httpLbs signed manager
      Data.ByteString.Lazy.putStrLn (responseBody response)

printRequestBody (RequestBodyLBS byteString) = byteString
printRequestBody _ = "other constructor"


