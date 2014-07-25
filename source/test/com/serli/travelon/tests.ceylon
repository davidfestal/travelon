import ceylon.test {
    test,
    assertEquals
}
import com.serli.travelon {
    ...
}
"""
   Test the Child combinator, distinguishing
   condition failure and success.
   """
by ("Arie van Deursen", "David festal")
shared class ChildTest() {
    test
    shared void testConditionFails() {
        value condition = FailAtNodes(tree.n0);
        value childVisitor =
                Child(logVisitor(condition), logVisitor(Identity<Node>()));
        value nodeReturned = childVisitor.visit(tree.n0);
        value expected = Logger<Node>();
        expected.log(Event(condition, tree.n0));
        assertEquals(expected, logger);
        assertEquals(nodeReturned, tree.n0);
    }
    
    test
    shared void testConditionSucceeds() {
        value condition = SucceedAtNodes<Node>(tree.n0);
        value childAction = Identity<Node>();
        value childVisitor =
                Child(logVisitor(condition), logVisitor(childAction));
        value nodeReturned = childVisitor.visit(tree.n0);
        value expected = Logger<Node>();
        expected.log(Event(condition, tree.n0));
        expected.log(Event(childAction, tree.n1));
        expected.log(Event(childAction, tree.n2));
        assertEquals(expected, logger);
        assertEquals(nodeReturned, tree.n0);
    }
}
