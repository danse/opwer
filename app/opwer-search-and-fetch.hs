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


readQuery :: String -> [(String, String)]
readQuery = read

adaptQuery :: (String, String) -> (ByteString, Maybe ByteString)
adaptQuery (a,b) = (fromString a, (Just . fromString) b)

convertQuery = (map adaptQuery) . readQuery

askAndPrintParsed :: _ -> _ -> _ -> IO ()
askAndPrintParsed oauth credential id = do
  resp <- askForJob oauth credential id
  putStrLn ((parseJobDetails . responseBody) resp)

main = do
  [arg] <- getArgs
  queryContents <- readFile arg
  OpwerCredential oauth credential <- readCredential
  resp <- askForJobs oauth credential (convertQuery queryContents)
  case (decode (responseBody resp) :: Maybe SearchResult) of
    Nothing -> putStrLn "The input does not seem valid"
    Just result -> do
      mapM (\ (JobResult id) -> catch (askAndPrintParsed oauth credential id) printException) (jobs result)
      return ()
