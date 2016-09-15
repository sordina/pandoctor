{-# OPTIONS -fno-warn-unused-do-bind #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

import Text.Pandoc
import Text.Pandoc.Error
import System.Process
import System.IO
import Data.Char
import Data.IORef
import System.Posix.Env
import Control.Arrow
import qualified Data.Set as S

writerOptions :: WriterOptions
writerOptions = def { writerHTMLMathMethod = MathJax "" }

readerOptions :: ReaderOptions
readerOptions = def { readerExtensions = foldr S.insert (readerExtensions def) [Ext_emoji] }

main :: IO ()
main = do counter <- newIORef 0
          getContents >>= return . readMarkdown readerOptions
                      >>= bottomUpM (process counter) . handleError >>= putStrLn . writeHtmlString writerOptions

process :: (IORef Int) -> Block -> IO Block
process counter cb@(CodeBlock trip@(_id, _classes, namevals) contents) = do
  case lookup "data-filter" namevals
       of     Just x -> CodeBlock trip `fmap` (comeIn counter x contents namevals)
              _      -> return $ cb
process _ x = return x

comeIn :: IORef Int -> String -> String -> [(String,String)] -> IO String
comeIn counter command input namevals = do
  count <- bump counter

  let withCount  = ("PANDOCTOR_COUNT", show count) : namevals
      fixedNames = map (first (map underscore)) withCount
      pairs      = map equalize fixedNames

  mapM_ putEnv pairs

  (hin,hout,herr,pid) <- runInteractiveProcess command pairs Nothing Nothing

  hPutStrLn hin input
  hClose hin

  out    <- hGetContents hout
  outErr <- hGetContents herr
  _      <- waitForProcess pid

  hPutStr stderr outErr

  return out

equalize :: ([Char], [Char]) -> [Char]
equalize (x,y) = x ++ "=" ++ y

underscore :: Char -> Char
underscore x | isAlpha x = x
             | otherwise = '_'

bump :: IORef Int -> IO Int
bump r = modifyIORef r (+1) >> readIORef r
