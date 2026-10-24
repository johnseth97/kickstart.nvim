; inherits: rust

(token_tree "<" . (identifier) @tag
  (#set! priority 110))
(token_tree "<" . "/" . (identifier) @tag
  (#set! priority 110))
(token_tree ["<" ">" "/"] @tag.delimiter
  (#set! priority 105))
(token_tree (identifier) @tag.attribute . "="
  (#set! priority 110))
(token_tree "type" @tag.attribute . "="
  (#set! priority 110))
(token_tree "@" @tag.attribute . (identifier) @tag.attribute
  (#set! priority 110))
(token_tree (identifier) @variable.parameter . ":"
  (#set! priority 110))
(token_tree (identifier) @function.call . (token_tree "(")
  (#set! priority 110))
