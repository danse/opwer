import Opwer
import Upwork
import Data.ByteString.Char8( pack )

authAndWrite key secret = do
  credential <- getCredential oauth
  writeFile credentialFileName (show (OpwerCredential oauth credential))
  putStrLn $ "The credential has been written to "++credentialFileName
    where oauth = makeOAuth (pack key) (pack secret)

main = do
  putStrLn "Please enter an interface key to use with Opwer:"
  key <- getLine
  putStrLn $ "You entered `"++key++"`"
  putStrLn "Now please enter the secret to use with this key:"
  secret <- getLine
  putStrLn $ "You entered`"++secret++"`. Now we will authenticate with Upwork."
  authAndWrite key secret
