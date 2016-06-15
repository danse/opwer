{-# LANGUAGE PartialTypeSignatures #-}
import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )
import Data.ByteString( ByteString )
import Data.String( fromString )
import Data.Maybe( Maybe( Just ) )
import System.Environment( getArgs )
import Control.Exception( catch )
import Data.Aeson( decode )
import Network.HTTP.Client( responseBody )
import Control.Applicative( (<$>) )
import Control.Concurrent.Async


readQuery :: String -> [(String, String)]
readQuery = read

adaptQuery :: (String, String) -> (ByteString, Maybe ByteString)
adaptQuery (a,b) = (fromString a, (Just . fromString) b)

addPages :: [String] -> [[(String, String)]]
addPages (base:extensions) = map addToQuery pages
  where addToQuery page = ("paging", (show (page*100))++";100") : query
        pages = [0..9]
        baseQuery = read base
        queryExtensions = map read extensions
        query = baseQuery ++ queryExtensions

askAndPrintParsed :: _ -> _ -> _ -> IO ()
askAndPrintParsed oauth credential id = do
  resp <- askForJob oauth credential id
  putStrLn ((parseJobDetails . responseBody) resp)

searchAndFetch oauth credential query = do
  resp <- askForJobs oauth credential (map adaptQuery query)
  case (decode (responseBody resp) :: Maybe SearchResult) of
    Nothing -> putStrLn "The input does not seem valid"
    Just result -> do
      mapM (\ (JobResult id) -> catch (askAndPrintParsed oauth credential id) printException) (jobs result)
      return ()

main = do
  args <- getArgs
  queryAndExtensions <- mapM readFile args
  OpwerCredential oauth credential <- readCredential
  asyncs <- mapM (async . (searchAndFetch oauth credential)) (addPages queryAndExtensions)
  mapM wait asyncs
  return ()
