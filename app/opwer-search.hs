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
import Control.Applicative( some )
import Options.Applicative
import Data.Monoid( (<>) )


readQuery :: String -> [(String, String)]
readQuery = read

adaptQuery :: (String, String) -> (ByteString, Maybe ByteString)
adaptQuery (a,b) = (fromString a, (Just . fromString) b)

addPages :: Int -> [String] -> [[(String, String)]]
addPages lastPage (base:extensions) = map addToQuery pages
  where addToQuery page = ("paging", (show (page*100))++";100") : query
        pages = [0..lastPage]
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

data Options = Options {
  arguments :: [String],
  pages :: Int
}

optionParser :: Parser Options
optionParser = Options
               <$> some (argument str (metavar "INPUT_MARGIN_FILES ..."))
               <*> option auto (long "pages" <> short 'p' <> Options.Applicative.value 9)

optionParserInfo :: ParserInfo Options
optionParserInfo = info optionParser fullDesc

main = do
  options <- execParser optionParserInfo
  queryAndExtensions <- mapM readFile (arguments options)
  OpwerCredential oauth credential <- readCredential
  asyncs <- mapM (async . (searchAndFetch oauth credential)) (addPages (pages options) queryAndExtensions)
  mapM wait asyncs
  return ()
