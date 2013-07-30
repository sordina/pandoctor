{-# OPTIONS -fno-warn-unused-do-bind #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

import Text.Pandoc
import System.Process
import System.IO
import Data.Char

main :: IO ()
main = getContents >>= return . readMarkdown def >>= bottomUpM process >> return ()

process :: Block -> IO Block
process cb@(CodeBlock (_id, _classes, namevals) contents) = do
  case lookup "data-filter" namevals of Just x -> (comeIn x contents namevals)
                                        _      -> return ()
  return cb
process x = return x

comeIn :: String -> String -> [(String,String)] -> IO ()
comeIn command input namevals = do
  let foo = unwords (map equalize namevals)
  (hin,hout,herr,_pid) <- runInteractiveCommand (foo ++ " " ++ command ++ " " ++ foo)
  hSetBuffering hin NoBuffering
  hPutStrLn hin input
  hGetContents hout >>= putStr
  hGetContents herr >>= putStrLn

equalize :: ([Char], [Char]) -> [Char]
equalize (x,y) = map underscore x ++ "=" ++ y

underscore :: Char -> Char
underscore x | isAlpha x = x
             | otherwise = '_'
