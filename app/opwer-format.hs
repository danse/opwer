{-# LANGUAGE OverloadedStrings #-}

import Control.Monad( forM_ )
import Text.Blaze.Html5 as H hiding( map, main )
import Text.Blaze.Html5.Attributes as A
import Text.Blaze.Renderer.String( renderHtml )
import Upwork
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Either( partitionEithers )
import Text.Read( readEither )
import System.IO( stderr, hPutStrLn )
import Opwer

formatProfile :: JobProfile -> Html
formatProfile profile = H.div $ do
  H.a ! A.target "_blank" ! A.href (toValue ref) $ do
    (H.span . toHtml) (((show . length . wrapper . candidates) profile) ++ " ")
    (H.span . toHtml) ("(" ++ (opTotCand profile) ++ ") ")
    (H.span . toHtml) ((opTitle profile) ++ " ")
    (H.span . toHtml) (opContractorTier profile ++ " ")
    (H.span . toHtml) ("interest: " ++ ((show . interestRatio) profile))
  where ref = "https://www.upwork.com/jobs/_"++(Upwork.id profile)

format :: [JobProfile] -> Html
format profiles = docTypeHtml $ do
  H.head $ do
    H.title "Results"
    H.style "a:visited { color: #bfbfbf; }"
  body $ do
    p "Results:"
    H.div (forM_ profiles formatProfile)

main = do
  contents <- C.getContents
  let (l,r) = partitionEithers (map (readEither . C.unpack) (C.lines contents))
    in do
      putStr (renderHtml (format r))
      mapM (hPutStrLn stderr) l

