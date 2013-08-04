{-# OPTIONS -fno-warn-unused-do-bind #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

import Text.Pandoc
import System.Process
import System.IO
import Data.Char
import Data.IORef
import System.Posix.Env

main :: IO ()
main = do
  counterIO <- newIORef 0
  getContents >>= return . readMarkdown def >>= bottomUpM (process counterIO) >> return ()

process :: (IORef Int) -> Block -> IO Block
process counterIO cb@(CodeBlock trip@(_id, _classes, namevals) contents) = do
  case lookup "data-filter" namevals
       of     Just x -> (bump counterIO)
                     >> CodeBlock trip `fmap` (comeIn counterIO x contents namevals)
              _      -> return $ cb
process _ x = return x

comeIn :: IORef Int -> String -> String -> [(String,String)] -> IO String
comeIn counterIO command input namevals = do
  let foo = unwords (map equalize namevals)
  count <- readIORef counterIO
  setEnv "PANDOCTOR_COUNT" (show count) True
  (hin,hout,herr,_pid) <- runInteractiveCommand (foo ++ " " ++ command ++ " " ++ foo)
  hSetBuffering hin NoBuffering
  hPutStrLn hin input
  out    <- hGetContents hout
  outErr <- hGetContents herr
  putStr out
  putStr outErr
  return (out ++ "\n" ++ outErr)

equalize :: ([Char], [Char]) -> [Char]
equalize (x,y) = map underscore x ++ "=" ++ y

underscore :: Char -> Char
underscore x | isAlpha x = x
             | otherwise = '_'

bump :: IORef Int -> IO ()
bump = flip modifyIORef (+1)
