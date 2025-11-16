module XMonad.Layout.PiP (
    PiP (..),
) where

import Control.Monad.Extra (partitionM)
import Data.Maybe (fromMaybe)
import Graphics.X11 (Dimension)
import XMonad (LayoutClass (..), Rectangle (..), Window, X)
import XMonad.StackSet (Stack, differentiate, integrate)
import XMonad.Util.WindowProperties (Property, hasProperty)

data PiP l w = PiP Property Dimension (l w)
    deriving (Read, Show)

instance (LayoutClass l Window) => LayoutClass (PiP l) Window where
    doLayout (PiP prop width l) rect s = do
        let height = width `div` 16 * 9
            xOffset = rect_width rect - width
            yStart = (rect_height rect - height) `div` 5
            pipRect = Rectangle (fromIntegral xOffset) (fromIntegral yStart) width height

        (ws, s') <- extract prop s

        (ws', ml') <- maybe (pure ([], Nothing)) (doLayout l rect) s'
        let l' = fromMaybe l ml'
        pure (layout pipRect ws <> ws', Just $ PiP prop width l')

extract :: Property -> Stack Window -> X ([Window], Maybe (Stack Window))
extract prop s = do
    (matching, unmatched) <- partitionM (hasProperty prop) $ integrate s
    pure (matching, differentiate unmatched)

layout :: Rectangle -> [Window] -> [(Window, Rectangle)]
layout _ [] = []
layout rect (w : ws) = (w, rect) : layout rect{rect_y = fromIntegral (rect.rect_y + rect.rect_y + 5)} ws