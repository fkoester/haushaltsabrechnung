module namespace ab-update="http://wob2.iai.uni-bonn.de/ab/update";

declare function ab-update:add-subtree($subtree as element(*), $parent as element(*)) {
	update insert element {fn:node-name($subtree)} {($subtree/@*[local-name()!='created'], attribute { "created" } { current-dateTime() }), $subtree/*} into $parent
};

declare function ab-update:replace-subtree($old-subtree as element(*), $new-subtree as element(*)) {
        update replace $old-subtree with element {fn:node-name($new-subtree)} {($old-subtree/@*[local-name()!='last-modified'], attribute { "last-modified" } { current-dateTime() }), $new-subtree/*}
};

declare function ab-update:remove-subtree($subtree as element(*)) {
	update delete $subtree
};

declare function ab-update:set-attribute-value($attribute as attribute(*), $attribute-value as xs:anyAtomicType) {
        update value $attribute with $attribute-value 
};

declare function ab-update:set-element-value($element as element(*), $element-value as xs:anyAtomicType) {
        update value $element with $element-value
};
