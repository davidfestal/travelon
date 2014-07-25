import ceylon.language { ... }
import ceylon.language.meta {
    type,
    typeLiteral
}
import ceylon.language.meta.model {
    Attribute
}
import ceylon.language.meta.declaration {
    ValueDeclaration
}

shared class Rule<in NodeType = Object,out ReturnType = Anything>(Boolean(NodeType) when, ReturnType(NodeType) do)
        given NodeType satisfies Object
        given ReturnType satisfies Anything {
    shared <ReturnType()|Null> apply(Anything node) {
        if (is NodeType typedNode = node) {
            if (when(typedNode)) {
                return () => do(typedNode);
            }
        }
        return null;
    }
}

shared class Match<RootReturnType>({Rule<Nothing,RootReturnType>+} rules)
        given RootReturnType satisfies Anything {
    shared default RootReturnType noRuleApplied() {
        return nothing;
    }
    
    shared RootReturnType apply(Anything node) {
        for (rule in rules) {
            value toApply = rule.apply(node);
            if (exists toApply) {
                return toApply();
            }
        }
        return noRuleApplied();
    }
}

shared class OptionalMatch<RootReturnType>({Rule<Nothing,RootReturnType>+} rules)
        extends Match<RootReturnType?>(rules)
        given RootReturnType satisfies Anything {
    shared actual RootReturnType? noRuleApplied() {
        return null;
    }
}
