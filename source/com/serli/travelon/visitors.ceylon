
shared class All<RootType>(Visitor<RootType> v) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        variable [RootType*] reversedNewChildren = [];
        for (child in visitable.childrenToVisit) {
            Visitable<RootType,RootType>|Failure visited = v.visit(child);
            switch (visited)
            case (is Failure) {
                return failure;
            }
            case (is Visitable<RootType,RootType>) {
                reversedNewChildren = [visited.node, *reversedNewChildren];
            }
        }
        return visitable.updateChildrenToVisit(reversedNewChildren.reversed);
    }
}

shared class Apply<RootType>(Anything(RootType) action) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        action(visitable.node);
        return visitable;
    }
}

shared class One<RootType>(Visitor<RootType> v) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        variable [RootType*] reversedNewChildren = [];
        for (child in visitable.childrenToVisit) {
            Visitable<RootType,RootType>|Failure visited = v.visit(child);
            switch (visited)
            case (is Failure) {
            }
            case (is Visitable<RootType,RootType>) {
                reversedNewChildren = [visited.node, *reversedNewChildren];
                return visitable.updateChildrenToVisit(reversedNewChildren.reversed);
            }
        }
        return failure;
    }
}

shared class Some<RootType>(Visitor<RootType> v) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        variable Visitable<NodeType,RootType>|Failure result = failure;
        variable [RootType*] reversedNewChildren = [];
        for (child in visitable.childrenToVisit) {
            Visitable<RootType,RootType>|Failure visited = v.visit(child);
            switch (visited)
            case (is Failure) {
            }
            case (is Visitable<RootType,RootType>) {
                reversedNewChildren = [visited.node, *reversedNewChildren];
                result = visitable;
            }
        }
        return visitable.updateChildrenToVisit(reversedNewChildren.reversed);
    }
}

shared abstract class DefinedCombinator<RootType>() extends Visitor<RootType>()
        given RootType satisfies Object {
    
    shared formal Visitor<RootType> definition;
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        return definition.doVisit(visitable);
    }
}

shared class Sequence<RootType>(steps = null) extends Visitor<RootType>()
        given RootType satisfies Object {
    
    shared default [Visitor<RootType>, Visitor<RootType>+]? steps;
    
    variable [Visitor<RootType>*]? _reversedsteps = null;
    function reversedSteps() {
        if (_reversedsteps is Null) {
            if (exists existingSteps = steps) {
                _reversedsteps = existingSteps.reversed;
            } else {
                _reversedsteps = [];
            }
        }
        assert (exists result = _reversedsteps);
        return result;
    }
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        return visitSteps(reversedSteps(), visitable);
    }
    
    Visitable<NodeType,RootType>|Failure visitSteps<NodeType>([Visitor<RootType>*] remainingSteps, Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        if (nonempty remainingSteps) {
            value stepResult = visitSteps(remainingSteps.rest, visitable);
            switch (stepResult)
            case (is Failure) {
                return failure;
            }
            case (is Visitable<NodeType,RootType>) {
                return remainingSteps.first.doVisit(stepResult);
            }
        } else {
            return visitable;
        }
    }
}

shared class TopDown<RootType>(Visitor<RootType> v) extends Sequence<RootType>()
        given RootType satisfies Object {
    steps => [v, All(this)];
}

shared class BottomUp<RootType>(Visitor<RootType> v) extends Sequence<RootType>()
        given RootType satisfies Object {
    steps => [All(this), v];
}

shared class Fail<RootType>() extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType => failure;
}

shared class Identity<RootType>() extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies Object => visitable;
}

shared class Not<RootType>(Visitor<RootType> v) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual variable Walker<RootType> walker = MetaModelBasedWalker<RootType>();
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        value result = v.doVisit(visitable);
        switch (result)
        case (is Failure) {
            return visitable;
        }
        case (is Visitable<RootType,RootType>) {
            return failure;
        }
    }
}

shared class IfThenElse<RootType>(Boolean(RootType)|Visitor<RootType> condition, Visitor<RootType> trueCase, Visitor<RootType> falseCase = Identity<RootType>()) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        Boolean result;
        if (is Visitor<RootType> condition) {
            result = condition.doVisit<NodeType>(visitable) != failure;
        } else if (is Boolean(RootType) condition) {
            result = condition(visitable.node);
        } else {
            assert (false);
        }
        
        if (result) {
            return trueCase.doVisit(visitable);
        } else {
            return falseCase.doVisit(visitable);
        }
    }
}

shared class Child<RootType>(Boolean(RootType)|Visitor<RootType> condition, Visitor<RootType> childAction) extends DefinedCombinator<RootType>()
        given RootType satisfies Object {
    definition => IfThenElse(
        condition,
        All(childAction));
}

shared final class Condition<RootType>(Boolean(RootType) condition) extends Visitor<RootType>()
        given RootType satisfies Object {
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType => condition(visitable.node) then visitable else failure;
}

"""
   Go down the tree until the condition succeeds
   on a node -- then apply the descendant action
   to the children of that node.

   The search does not recurse in nodes below
   those that meet the condition.

   This allows expressions such as :
   
   `Descendant(ProcedureBodyRecognizer, Descendant(SwitchRecognizer, Action))`
   
   which would apply an Action to all switch statements that in
   turn are contained within ProceduresBodies.
   """
see (`class Child`)
by ("Arie van Deursen", "David Festal")
shared class Descendant<RootType>(Boolean(RootType) condition, Visitor<RootType> action) extends DefinedCombinator<RootType>()
        given RootType satisfies Object {
    definition => TopDownUntil<RootType>(
        Condition(condition),
        All(action));
}

shared class Choice<RootType>(alternatives = null) extends Visitor<RootType>()
        given RootType satisfies Object {
    
    shared default [Visitor<RootType>, Visitor<RootType>+]? alternatives;
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        if (exists alts = alternatives) {
            for (alt in alts) {
                if (is Visitable<NodeType,RootType> result = alt.doVisit(visitable)) {
                    return result;
                }
            }
        }
        return failure;
    }
}

shared class TopDownUntil<RootType>(Visitor<RootType> v, Visitor<RootType>? vFinally = null) extends Choice<RootType>()
        given RootType satisfies Object {
    shared actual [Visitor<RootType>, Visitor<RootType>+]? alternatives {
        if (exists vFinally) {
            return [Sequence([v, vFinally]), All(this)];
        } else {
            return [v, All(this)];
        }
    }
}

shared class TopDownWhile<RootType>(Visitor<RootType> v) extends Choice<RootType>()
        given RootType satisfies Object {
    alternatives => [Sequence<RootType>([v, All(this)]), Identity<RootType>()];
}

shared class Try<RootType>(Visitor<RootType> v) extends Choice<RootType>()
        given RootType satisfies Object {
    alternatives => [v, Identity<RootType>()];
}

shared class DownUp<RootType>(Visitor<RootType> down, Visitor<RootType> up) extends Sequence<RootType>()
        given RootType satisfies Object {
    steps => [down, Sequence<RootType>([All<RootType>(this), up])];
}


"""
   A combinator that generates a loggable event each time that its
   argument visitor is invoked.
   """
shared class LogVisitor<RootType>(Visitor<RootType> visitor, Logger<RootType> logger) extends Visitor<RootType>()
        given RootType satisfies Object {
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        logger.log(Event(visitor, visitable.node));
        return visitor.doVisit(visitable);
    }
}

"""
   Simple visitor recognizing two nodes given at creation time.
   Can be used to test generic visitors requiring a recognizing
   argument.
    """
shared class FailAtNodes<RootType>(Visitable<RootType,RootType>* visitables) extends Visitor<RootType>()
        given RootType satisfies Object {
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        if (visitables.contains(visitable)) {
            return failure;
        }
        return visitable;
    }
}


"""
   Simple visitor recognizing two nodes given at creation time.
   Can be used to test generic visitors requiring a recognizing
   argument.
   """
shared class SucceedAtNodes<RootType>(Visitable<RootType,RootType>* visitables) extends Visitor<RootType>()
        given RootType satisfies Object {
    Visitor<RootType> success = Not(FailAtNodes(*visitables));
    
    shared actual Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> visitable)
            given NodeType satisfies RootType {
        return success.doVisit(visitable);
    }
}
