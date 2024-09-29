
*I will list here methods that the elemental engine understands and that those that want to write custom elements can leverage to get the desired result*


* `get_all_children(self)` (optional)
    * must be implemented by elements that layout children.
    * must return all children that the branch(self) wants to draw, in the order it wants to draw them in
* `_layout_children`

