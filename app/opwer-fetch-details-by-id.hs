import Opwer
import Upwork
import System.Environment( getArgs )

-- this will require an id prefixed with tilde, as in "~01bf7490334544aef7"
main = do
  [id] <- getArgs
  OpwerCredential oauth credential <- readCredential
  resp <- askForJob oauth credential id
  printResponse resp
