import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )
import Data.ByteString( ByteString )
import Data.String( fromString )
import Data.Maybe( Maybe( Just ) )
import System.Environment( getArgs )

readQuery :: String -> [(String, String)]
readQuery = read

adaptQuery :: (String, String) -> (ByteString, Maybe ByteString)
adaptQuery (a,b) = (fromString a, (Just . fromString) b)

convertQuery = (map adaptQuery) . readQuery

main = do
  [arg] <- getArgs
  queryContents <- readFile arg
  OpwerCredential oauth credential <- readCredential
  askForJobs oauth credential (convertQuery queryContents)
