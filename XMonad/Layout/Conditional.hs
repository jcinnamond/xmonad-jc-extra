module XMonad.Layout.Conditional (
    ConditionalLayout,
    conditionalLayout,
)
where

import Data.Maybe (fromMaybe)
import XMonad (LayoutClass, Window, runLayout)
import XMonad.StackSet qualified as W
import XMonad.Util.WindowProperties (Property, hasProperty)

data ConditionalLayout l1 l2 w = ConditionalLayout Property (l1 w) (l2 w)
    deriving (Read, Show)

instance
    (LayoutClass l1 Window, LayoutClass l2 Window) =>
    LayoutClass (ConditionalLayout l1 l2) Window
    where
    runLayout (W.Workspace wname (ConditionalLayout prop l1 l2) s) rect = do
        cond <- or <$> mapM (hasProperty prop) (W.integrate' s)
        if cond
            then do
                (ws', ml') <- runLayout (W.Workspace wname l1 s) rect
                let l1' = fromMaybe l1 ml'
                pure (ws', Just $ ConditionalLayout prop l1' l2)
            else do
                (ws', ml') <- runLayout (W.Workspace wname l2 s) rect
                let l2' = fromMaybe l2 ml'
                pure (ws', Just $ ConditionalLayout prop l1 l2')

conditionalLayout :: (LayoutClass l1 Window, LayoutClass l2 Window) => Property -> l1 Window -> l2 Window -> ConditionalLayout l1 l2 Window
conditionalLayout = ConditionalLayout