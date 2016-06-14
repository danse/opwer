import Opwer
import Upwork

main = do
  OpwerCredential oauth credential <- readCredential
  resp <- askForCategories oauth credential
  printResponse resp
